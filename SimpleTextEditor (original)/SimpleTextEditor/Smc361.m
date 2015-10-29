//
//  Smc361.m
//  SMC361Demo
//
//  Created by Nick on 2013/12/20.
//  Copyright (c) 2013年 Nick. All rights reserved.
//


#import "Smc361.h"

#define PLAY_SAMPLE_RATE    44100
#define RECORD_SAMPLE_RATE  44100

#define BAUDRATE            600
#define CMD_START_BYTES     10
#define CMD_DELAY_BYTES     6

// Tag Data Type
#define STX             0x82
#define ETX             0x03
#define RESP_OK         0x00
#define RESP_ERROR      0xff

#define MIN_CYCLE_WIDTH  8
#define MAX_CYCLE_WIDTH  200
#define COUNT_SIZE  (64*6)



//#define PCM_START_CHECK_COUNT  21       // (660+220)/2/20.83us
//#define PCM_START_CHECK_COUNT_OVER  (PCM_START_CHECK_COUNT*2)
//#define PCM_DATA_CHECK_COUNT        16  // (440+220)/2)/(20.83us)
//#define PCM_DATA_CHECK_COUNT_OVER   (PCM_DATA_CHECK_COUNT*2)
//#define PCM_RESPONSE_TIMEOUT_COUNT  100 // 1050us/20.us ~= 72

#define PCM_PLAY_CMD_COUNT  (PLAY_SAMPLE_RATE * 2 * 5/10)	// 0.6s * 2 (2channel)
//#define PCM_WRITE_WAIT_COUNT 1200	// 48000 * 0.025s
#define PCM_CMD_DELAY_COUNT 480     // 48000 * 0.01s

#define PCM_IR_WAIT_TIME_WIDTH 2400 // 48000 * 0.05s

#define PCM_RISING_OFFSET   1000  //+300
#define PCM_FALLING_OFFSET -1000  //-300


#define PCM_LOW_LEVEL -10000
#define PCM_HIGH_LEVEL 10000
#define PCM_SLIENT_LEVEL 500

#define PCM_COUNT_LEVEL 20
#define PCM_COUNT_TIMEOUT 100
#define PCM_COUNT_SLIENT  120   //

#define PCM_START_LEVEL 20

#define PCM_SEND_DATA0_WIDTH 11
#define PCM_SEND_DATA1_WIDTH 8

#define PCM_CHECK_COUNT_UNDER   6       // 44.1k/3.6k/2 ~= 6
#define PCM_CHECK_COUNT         17      // 44.1k/((3.6k+1.8k)/2) ~= 18
#define PCM_CHECK_COUNT_OVER    38      // 44.1k/1.8k*1.5 ~= 37


#define  PCM_DATA_CHECK_UNDER 5     // (14)/2
#define  PCM_DATA_CHECK_WIDTH 15    // (14+28)/2
#define  PCM_DATA_CHECK_OVER  30    // (14+28)

@interface Smc361Device ()

- (bool) setupAudioQueue;
- (int) computeRecordBufferSize: (AudioStreamBasicDescription*) format withSecond: (float) seconds;

void AQBufferCallback(	void *					inUserData,
                      AudioQueueRef			inAQ,
                      AudioQueueBufferRef		inCompleteAQBuffer);

- (void) informDecoded:(SInt32)type
                Result:(Boolean)result
                  Data:(void *)data;

- (Boolean) checkRecordData:(SInt16 *) recordData
                     Length:(SInt32)length;



-(void) FilterRecordData:(SInt16 *)buffer
              BufferSize:(SInt32)bufferSize;
-(void) FilterRecordData2:(SInt16 *)buffer
               BufferSize:(SInt32)bufferSize;

-(void) SaveRecordData:(SInt16 *)buffer
            BufferSize:(SInt32)bufferSize;

@end




@implementation Smc361Device

@synthesize isPlaying;
@synthesize playPacketCounts;
@synthesize currentPacket;
@synthesize recordPacketCounts;
@synthesize isRecording;
@synthesize delegate;




void AQBufferCallback(	void *					inUserData,
                      AudioQueueRef			inAQ,
                      AudioQueueBufferRef		inCompleteAQBuffer)
{
    Smc361Device *player = (__bridge Smc361Device *)inUserData;
   	
    if (!player->isPlaying) return;
    
    UInt32 numBytes = (UInt32)player.playPacketCounts*2;
    UInt32 nPackets = (UInt32)player.playPacketCounts;
    
    if (nPackets > 0) {
        inCompleteAQBuffer->mAudioDataByteSize = numBytes;
        inCompleteAQBuffer->mPacketDescriptionCount = PCM_PLAY_CMD_COUNT;
        AudioQueueEnqueueBuffer(inAQ, inCompleteAQBuffer, 0, NULL);
        player.currentPacket = player.currentPacket + nPackets;
        if(player.currentPacket >= player.playPacketCounts)
        {
            //AudioQueueStop(inAQ, NO);
            player->isPlaying = NO;
            //inAQ = NULL;
            //AudioQueueDispose(inAQ, NO);
            
        }
    }
    else
    {
        //if (THIS->IsLooping())
        //{
        player.currentPacket = 0;
        AQBufferCallback(inUserData, inAQ, inCompleteAQBuffer);
        //}
        //		else
        //		{
        //			// stop
        //			THIS->mIsDone = true;
        //			AudioQueueStop(inAQ, false);
        //		}
    }
}



void aAudioQueueInputCallback (void * inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp* inStartTime, UInt32 inNumberPacketDescriptions, const AudioStreamPacketDescription *inPacketDescs)
{
    if(!inUserData)
    {
        //NSLog(@"audio queue input callback did not receive AudioRecorder object");
        return;
    }
    Smc361Device* player = (__bridge Smc361Device*)inUserData;
    
    if(inBuffer->mAudioDataByteSize > 0 && inNumberPacketDescriptions > 0 && player->isRecording)
    {
        
        SInt16* recordData = inBuffer->mAudioData;
        memcpy(player->gRecordData, recordData, sizeof(SInt16)*inNumberPacketDescriptions);
        
        AudioQueueStop(player->mAudioQueue,YES);
        AudioQueueDispose(player->mAudioQueue, YES);
        
        AudioQueueStop(inAQ,YES);
        AudioQueueDispose(inAQ, YES);
        //player->isRecording = NO;
        
        //[player informDecoded: player->functionType Result:FALSE Data:nil];
        if([player checkRecordData: player->gRecordData Length:player->gRecordCount] == TRUE)
        {
        }
    }
    /*
     if(player.isRecording)
     {
     OSStatus err = AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
     if(err != noErr)
     {
     //NSLog(@"fail to enqueue buffer in input callback code: %d", (int)err);
     }
     }
     */
}




- (Boolean) checkRecordData :(SInt16 *) recordData
                      Length:(SInt32)length
{
    UInt8 responseData[32];
    Boolean result = FALSE;
    
    if([self parseRecordData:recordData RecordDataLength:length
                ResponseData:responseData ResponseLength:24]==FALSE)
    {
        [self informDecoded: functionType Result:result Data:NULL];
        ///[_delegate receivedMessage:functionType Result:result Data:NULL];
        return FALSE;
    }
    
    UInt64 tmpReadData = mReadData;
    
    for(int i = 4; i >= 0; --i)
    {
        inform_data.data[i] = tmpReadData & 0xff;
        tmpReadData >>= 8;
    }
    
    result = TRUE;
    
    
    [self informDecoded: functionType Result:result Data:&inform_data];
    ///[_delegate receivedMessage:functionType Result:result Data:&inform_data];
    
    return result;
    
    
}




-(void) FilterRecordData:(SInt16 *)buffer
              BufferSize:(SInt32)bufferSize
{
    
    for(int i = 1; i < bufferSize; ++i)
    {
        buffer[i] = (short) ((buffer[i] + buffer[i - 1]) / 2);
    }
    
}

-(void) FilterRecordData2:(SInt16 *)buffer
               BufferSize:(SInt32)bufferSize
{
    for(int i = 1; i < bufferSize - 1; ++i)
    {
        if((buffer[i] < 0 && buffer[i-1] >= 0 && buffer[i+1] >= 0) ||
           (buffer[i] >= 0 && buffer[i-1] < 0 && buffer[i+1] < 0))
        {
            buffer[i] =  buffer[i-1];
        }
    }
    
}

-(void) SaveRecordData:(SInt16 *)buffer
            BufferSize:(SInt32)bufferSize
{
    
    NSFileManager *filemgr;
    
    //	NSString* filePath  = [NSString stringWithFormat:@"tmpRecordSmc.pcm"];
    
    NSString *documentsDirectory= [NSHomeDirectory()
                                   stringByAppendingPathComponent:@"Documents"];
    
    
    NSString *filePath= [documentsDirectory
                         stringByAppendingPathComponent:@"tmpRecordSmc361.pcm"];
    
    filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: filePath ] == YES)
    {
        //NSLog (@"tmpRecordSmc361.pcm exists");
        [filemgr removeItemAtPath: filePath error: NULL];
    }
    else
    {
        //NSLog (@"tmpRecordSmc361.pcm not found");
        
    }
    
    
    NSMutableData *data;
    
    
    data = [NSMutableData dataWithBytes:buffer length:(bufferSize*sizeof(SInt16))];
    
    BOOL ans = [filemgr createFileAtPath:filePath contents:data attributes:nil];
    
    if(ans == FALSE)
    {
        //NSLog (@"Create \"tmpRecordSmc361.pcm\" fail");
        
    }
    
    NSFileHandle *file;
    
    file = [NSFileHandle fileHandleForWritingAtPath: filePath];
    [file seekToFileOffset: 0];
    
    
    [file writeData:data];
    if (file == nil)
        //NSLog(@"Failed to open file");
        
        
        [file closeFile];
    
}


-(Boolean) parseRecordData:(SInt16 *)recordData
          RecordDataLength:(SInt32)recordDataLength
              ResponseData:(UInt8 *)responseData
            ResponseLength:(SInt32)responseLength
{
    
    int i;
    BOOL findFirstEagle = false;
    int widthCount = 0;
    short nowPCM, lastPCM;
    
    
    
    //[self SaveRecordData:recordData BufferSize:recordDataLength];
    
    //[self FilterRecordData2:recordData BufferSize:recordDataLength];
    [self FilterRecordData:recordData BufferSize:recordDataLength];
    
    
    BOOL findDutyCount = false;
    int dutyWidth0 = 0, dutyWidth1 = 0;
    int correctCount = 0;
    nowPCM = recordData[0];
    int countBuf[COUNT_SIZE];
    int startX = 0;
    
    
    startX = 1;
    
    while(startX < recordDataLength) {
        findFirstEagle = false;
        
        for (i = startX; i < recordDataLength; ++i) {
            lastPCM = nowPCM;
            nowPCM = recordData[i];
            if (findFirstEagle == false) {
                if((nowPCM >= 0 && lastPCM < 0) && (nowPCM - lastPCM) > 200) {
                    findFirstEagle = true;
                    findDutyCount = false;
                    correctCount = 0;
                    widthCount = 0;
                    startX = i;
                }
                continue;
            }
            ++widthCount;
            
            if (!(nowPCM >= 0 && lastPCM < 0))
                continue;
            
            if (widthCount < MIN_CYCLE_WIDTH || widthCount >= MAX_CYCLE_WIDTH) { // 44.1K/10 ~ 44.1K/44
                findFirstEagle = false;
                continue;
            }
            
            countBuf[correctCount++] = widthCount;
            widthCount = 0;
            if (correctCount < COUNT_SIZE)
                continue;
            
            
            int p, w0 = 0, w1 = 0;
            
            int levelBuf[MAX_CYCLE_WIDTH];
            
            
            for(p = 0; p < MAX_CYCLE_WIDTH; ++p)	{
                levelBuf[p] = 0;
            }
            
            for(p = 0; p < COUNT_SIZE; ++p)	{
                levelBuf[countBuf[p]]++;
            }
            
            w0 = 0;
            int max = levelBuf[0];
            for(p = 1; p < MAX_CYCLE_WIDTH; ++p) {
                if(levelBuf[p] > max) {
                    max = levelBuf[p];
                    w0 = p;
                }
            }
            levelBuf[w0] = 0;
            
            w1 = 0;
            max = levelBuf[0];
            for(p = 1; p < MAX_CYCLE_WIDTH; ++p) {
                if(levelBuf[p] > max) {
                    max = levelBuf[p];
                    w1 = p;
                }
            }
            levelBuf[w1] = 0;
            
            
            if(abs(w1-w0) <= 1) {
                w1 = 0;
                max = levelBuf[0];
                for(p = 1; p < MAX_CYCLE_WIDTH; ++p) {
                    if(levelBuf[p] > max) {
                        max = levelBuf[p];
                        w1 = p;
                    }
                }
                levelBuf[w1] = 0;
            }
            
            if(abs(w1-w0) <= 1) {
                w1 = 0;
                max = levelBuf[0];
                for(p = 1; p < MAX_CYCLE_WIDTH; ++p) {
                    if(levelBuf[p] > max) {
                        max = levelBuf[p];
                        w1 = p;
                    }
                }
                levelBuf[w1] = 0;
            }
            
            if(w0 > w1) {
                dutyWidth1 = w0;
                dutyWidth0 = w1;
            }else {
                dutyWidth0 = w1;
                dutyWidth1 = w0;
            }
            
            findDutyCount = true;
            break;
            
        }
        startX = i;
        
        if (findDutyCount == FALSE) {
            break;
        }
        
        int checkWidth = (dutyWidth0 + dutyWidth1)/2;
        
        BOOL findFirstBitChange = false;
        BOOL bitReady = false;
        BOOL bigWidthState = countBuf[0] >= checkWidth ? TRUE: FALSE;
        int cycleCount = 0, bitData = 0, bitCount = 0;
        UInt64 tmpData = 0x0; //(UInt64) 0x7F800000 << 32;
        
        for(int p = 1; p < COUNT_SIZE; ++p)
        {
            if(findFirstBitChange == false) {
                if(bigWidthState == true) {
                    if(countBuf[p] < checkWidth) {
                        findFirstBitChange = true;
                        cycleCount = 1;
                        bigWidthState = false;
                    }
                }
                else {
                    if(countBuf[p] >= checkWidth) {
                        findFirstBitChange = true;
                        cycleCount = 1;
                        bigWidthState = true;
                    }
                }
                continue;
            }
            
            cycleCount++;
            
            if(bigWidthState == true) {
                if(countBuf[p] < checkWidth) {
                    if(cycleCount >= 2) {
                        bitData = 1;
                        bitReady = true;
                    }
                    bigWidthState = false;
                    cycleCount = 0;
                }
                else {
                    if(cycleCount >= 3) {
                        bitData = 1;
                        bitReady = true;
                        cycleCount = 0;
                    }
                }
            }
            else {
                if(countBuf[p] >= checkWidth) {
                    if(cycleCount >= 5) {
                        bitData = 0;
                        bitReady = true;
                    }
                    bigWidthState = true;
                    cycleCount = 0;
                }
                else {
                    if(cycleCount >= 6) {
                        bitData = 0;
                        bitReady = true;
                        cycleCount = 0;
                    }
                }
            }
            
            if(bitReady == true) {
                bitReady = false;
                tmpData <<= 1;
                if(bitData == 1)
                    tmpData |= 0x1;
                if(++bitCount >= 64)
                    break;
            }
        }
        
        
        UInt8 byteBuffer[11];
        
        if(bitCount >= 64) {
            if ([self Check4001Data:tmpData Buf:byteBuffer] == true) {
                mReadData = 0;
                for(int p = 0; p <= 9; ++p)
                {
                    mReadData <<= 4;
                    mReadData |= byteBuffer[p];
                }
                return TRUE;
                
            }
        }
        
    }
    
    
    return FALSE;
}

- (BOOL) Check4001Data:(UInt64)data
                   Buf:(UInt8 *) buf
{
    for (int step = 0; step < 2; ++step) {
        UInt64 shiftData;
        if (step == 0)
            shiftData = data;
        else
            shiftData = data ^ (UInt64)0xffffffffffffffff;
        for(int i = 0; i < 64; ++i)
        {
            shiftData = (shiftData << 1) | (shiftData >> 63);
            
            if ((((shiftData >> (64 - 9)) & 0x1ff) == 0x1ff) && (shiftData&0x1) == 0x0) {
                int ct;
                buf[10] = (UInt8) ((shiftData >> 1)&0xf);
                shiftData >>= 5;
                for (ct = 0; ct < 10; ++ct) {
                    UInt8 byteData = (UInt8) (shiftData & 0x1f);
                    if ([self CheckEvenParity:byteData] == false)
                        break;
                    buf[9 - ct] = (UInt8) (byteData >> 1);
                    shiftData >>= 5;
                }
                if (ct == 10) {
                    return true;
                }
            }
        }
    }
    return false;
}


- (BOOL) CheckEvenParity:(UInt8) data
{
    UInt8 parity = 0x00;
    for (int i = 0; i < 5; ++i) {
        parity ^= data;
        data >>= 1;
    }
    
    if ((parity & 0x01) == 0x00)
        return true;
    else
        return false;
}

- (void) informDecoded:(SInt32)type
                Result:(Boolean)result
                  Data:(void *)data;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self delegate] receivedMessage: type
                                  Result: result
                                    Data: data];
    });
}


- (Boolean) readData
{
    functionType = MESSAGE_READ_DATA;
    
    return [self startPlaying];
}



- (Boolean) startPlaying
{
    
    if(isPlaying)
        return FALSE;
    
    
    if(![self setupAudioQueue])
    {
        return FALSE;
    }
    
    isPlaying = YES;
    currentPacket = 0;
    recordPacketCounts = 0;
    
    for (int i = 0; i < AudioBufferCount; ++i) {
        AQBufferCallback ((__bridge void *)(self), mAudioQueue, mAudioQueuedBuffer[i]);
    }
    OSStatus err = AudioQueueStart(mAudioQueue, NULL);
    if(err != noErr)
    {
        //NSLog(@"fail to start audio queue with code: %d", (int)err);
    }
    
    err = AudioQueueStart(mAudioQueueInput, NULL);
    if(err != noErr)
    {
        //NSLog(@"fail to start audio queue Input with code: %d", (int)err);
    }
    isRecording = YES;
    
    
    
    
    return TRUE;
}

- (void) stopPlaying
{
    if(!isPlaying)
        return;
    
    isPlaying = NO;
    OSStatus err = AudioQueueStop(mAudioQueue, NO);
    if(err != noErr)
    {
        //NSLog(@"fail to stop audio queue with code: %d", (int)err);
    }
}

- (bool) setupAudioQueue
{
    //if(!mAudioQueue)
    //{
    AVAudioSession* session = [AVAudioSession sharedInstance];
    //session.delegate = self;
    
    [session setMode:AVAudioSessionModeMeasurement error: NULL];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error: NULL];
    UInt32 mix = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers	, sizeof(mix), &mix);
    [session setActive: YES error: NULL];
    
    
    [self setPlayingFormat: kAudioFormatLinearPCM
                FormatFlag:kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked
                SampleRate:PLAY_SAMPLE_RATE
             BitPerChannel: 16
           ChannelPerFrame:2
            FramePerPacket:1];
    
    
    [self setRecordingFormat: kAudioFormatLinearPCM
                  FormatFlag: kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked
                  SampleRate:RECORD_SAMPLE_RATE
               BitPerChannel: 16
             ChannelPerFrame:1
              FramePerPacket:1];
    
    
    OSStatus err;
    err = AudioQueueNewOutput(&mPlayFormat, AQBufferCallback, (__bridge void *)(self), NULL, kCFRunLoopCommonModes, 0, &mAudioQueue);
    if(err != noErr)
    {
        //NSLog(@"fail to create audio queue with code: %d", (int)err);
        return NO;
    }
    
    int buffersize;
    
    playPacketCounts = PCM_PLAY_CMD_COUNT;
    
    buffersize = (int32_t)playPacketCounts * 2;
    for(int i = 0; i < AudioBufferCount; i++)
    {
        err = AudioQueueAllocateBufferWithPacketDescriptions(mAudioQueue, buffersize, (UInt32)playPacketCounts, &mAudioQueuedBuffer[i]);
        if(err != noErr)
        {
            //NSLog(@"fail to allocate audio queue buffer %i bytes with code: %d", buffersize, (int)err);
            return NO;
        }
        
        /*err = AudioQueueEnqueueBuffer(mAudioQueue, mAudioQueuedBuffer[i], 0, NULL);
         if(err != noErr)
         {
         //NSLog(@"fail to enqueue buffer %i with code: %ld", i, err);
         return NO;
         }*/
        [self setRawData:mAudioQueuedBuffer[i]->mAudioData];
    }
    
    
    
    AudioQueueSetParameter(mAudioQueue, kAudioQueueParam_Volume, 1.0);
    
    
    err = AudioQueueNewInput(&mRecordFormat, aAudioQueueInputCallback, (__bridge void *)(self), NULL, kCFRunLoopCommonModes, 0, &mAudioQueueInput);
    if(err != noErr)
    {
        //NSLog(@"fail to create audio queue with code: %d", (int)err);
        return NO;
    }
    
    
    gRecordCount = (float)RECORD_SAMPLE_RATE * 0.5f;
    buffersize = [self computeRecordBufferSize: &mRecordFormat withSecond: 0.5f];
    
    
    for(int i = 0; i < AudioBufferCount; i++)
    {
        err = AudioQueueAllocateBuffer(mAudioQueueInput, buffersize, &mAudioQueuedBufferInput[i]);
        if(err != noErr)
        {
            //NSLog(@"fail to allocate audio queue buffer %i bytes with code: %d", buffersize, (int)err);
            return NO;
        }
        
        err = AudioQueueEnqueueBuffer(mAudioQueueInput, mAudioQueuedBufferInput[i], 0, NULL);
        if(err != noErr)
        {
            //NSLog(@"fail to enqueue buffer %i with code: %d", i, (int)err);
            return NO;
        }
    }
    
    //}
    return YES;
}


- (void) setRawData : (SInt16 *) buf
{
    
    int p;
    
    double increment20k = ((double) 2 * M_PI * 20000 / PLAY_SAMPLE_RATE); // angular
    
    memset(buf, 0x00, PCM_PLAY_CMD_COUNT);
    
    double angle = 0;
    
    for ( p = 0; p < (PCM_PLAY_CMD_COUNT - 1); p=p+2)
    {
        buf[p] = (SInt16) (sin(angle) * INT16_MAX);
        buf[p+1] = buf[p] * -1;
        angle += increment20k;
    }
    
    /*for ( p = 0; p < (PCM_PLAY_CMD_COUNT - 1); p=p+2)
     {
     buf[p] = 0;
     buf[p+1] = 0;
     }
     */
}






- (void) setPlayingFormat:(UInt32)formatID FormatFlag:(UInt32)formatFlags SampleRate:(Float64)sampleRate BitPerChannel:(UInt32)bitpChannel ChannelPerFrame:(UInt32)chanpFrame FramePerPacket:(UInt32)framepPacket
{
    if(isPlaying)
        return;
    
    mPlayFormat.mSampleRate = [[AVAudioSession sharedInstance] sampleRate];
    if([[AVAudioSession sharedInstance] setPreferredSampleRate:sampleRate error: NULL])
        mPlayFormat.mSampleRate = sampleRate;
    mPlayFormat.mFormatID = formatID;
    mPlayFormat.mFormatFlags = formatFlags;
    mPlayFormat.mBitsPerChannel = bitpChannel;
    mPlayFormat.mChannelsPerFrame = chanpFrame;
    mPlayFormat.mFramesPerPacket = framepPacket;
    mPlayFormat.mBytesPerFrame = (mPlayFormat.mBitsPerChannel / 8) * mPlayFormat.mChannelsPerFrame;
    mPlayFormat.mBytesPerPacket = mPlayFormat.mBytesPerFrame * mPlayFormat.mFramesPerPacket;
}


- (void) setRecordingFormat:(UInt32)formatID FormatFlag:(UInt32)formatFlags SampleRate:(Float64)sampleRate BitPerChannel:(UInt32)bitpChannel ChannelPerFrame:(UInt32)chanpFrame FramePerPacket:(UInt32)framepPacket
{
    if(isRecording)
        return;
    
    mRecordFormat.mSampleRate = [[AVAudioSession sharedInstance] sampleRate];
    if([[AVAudioSession sharedInstance] setPreferredSampleRate:sampleRate error: NULL])
        mRecordFormat.mSampleRate = sampleRate;
    mRecordFormat.mFormatID = formatID;
    mRecordFormat.mFormatFlags = formatFlags;
    mRecordFormat.mBitsPerChannel = bitpChannel;
    mRecordFormat.mChannelsPerFrame = chanpFrame;
    mRecordFormat.mFramesPerPacket = framepPacket;
    mRecordFormat.mBytesPerFrame = (mRecordFormat.mBitsPerChannel / 8) * mRecordFormat.mChannelsPerFrame;
    mRecordFormat.mBytesPerPacket = mRecordFormat.mBytesPerFrame * mRecordFormat.mFramesPerPacket;
}

- (int) computeRecordBufferSize: (AudioStreamBasicDescription*) format withSecond: (float) seconds
{
    int packets, frames, bytes = 0;
    
    frames = (int)ceil(seconds * format->mSampleRate);
    
    if (format->mBytesPerFrame > 0)
        bytes = frames * format->mBytesPerFrame;
    else {
        UInt32 maxPacketSize;
        if (format->mBytesPerPacket > 0)
            maxPacketSize = format->mBytesPerPacket;	// constant packet size
        else {
            UInt32 propertySize = sizeof(maxPacketSize);
            OSStatus err = AudioQueueGetProperty(mAudioQueue, kAudioQueueProperty_MaximumOutputPacketSize, &maxPacketSize, &propertySize);
            
            if(err != noErr)
            {
                //NSLog(@"fail to get maximum ouput packet size with code: %d", (int)err);
                return 0;
            }
        }
        if (format->mFramesPerPacket > 0)
            packets = frames / format->mFramesPerPacket;
        else
            packets = frames;	// worst-case scenario: 1 frame in a packet
        if (packets == 0)		// sanity check
            packets = 1;
        bytes = packets * maxPacketSize;
    }
    
    return bytes;
}

@end
