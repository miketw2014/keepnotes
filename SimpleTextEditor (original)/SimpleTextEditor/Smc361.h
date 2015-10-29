//
//  Smc361.h
//  SMC361Demo
//
//  Created by Nick on 2013/12/20.
//  Copyright (c) 2013年 Nick. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioQueue.h>
#import <AVFoundation/AVFoundation.h>

@protocol Smc361ProtocolDelegate <NSObject>
@required
- (void) receivedMessage: (SInt32)type
                  Result: (Boolean)result
                    Data: (void *)data;
@end



#define MESSAGE_READ_DATA 1

#define AudioBufferCount        1


#define STATUS_FAIL 0xff

#define PCM_RECORD_COUNT  (44100 * 20 / 10)   // 44100 * 0.8s

typedef struct _MSG_INFORM_DATA
{
    UInt8 data[5];
    UInt16 version;
    
}MSG_INFORM_DATA;

//@class NIKViewController;

@interface Smc361Device : NSOperation
{
    AudioQueueRef mAudioQueue;
    AudioQueueRef mAudioQueueInput;
    AudioQueueBufferRef mAudioQueuedBuffer[AudioBufferCount];
    AudioQueueBufferRef mAudioQueuedBufferInput[AudioBufferCount];
    AudioStreamBasicDescription mPlayFormat;
    AudioStreamBasicDescription mRecordFormat;
    
    UInt64 mReadData;
    UInt8 functionType;
    SInt16 gRecordData[PCM_RECORD_COUNT];
    
    SInt32 gRecordCount;
    MSG_INFORM_DATA inform_data;
}
@property (nonatomic, retain) id <Smc361ProtocolDelegate> delegate;

@property (nonatomic, readonly) bool isPlaying;
@property (nonatomic, assign) long playPacketCounts;
@property (nonatomic, assign) long currentPacket;

@property (nonatomic, readonly) bool isRecording;
@property (nonatomic, assign) long recordPacketCounts;

- (Boolean) readData;






@end
