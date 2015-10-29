//
//  STEDetailViewController.m
//  SimpleTextEditor
//
//  Created by Jason Tsai on 7/30/14.
//  Copyright (c) 2014 nick. All rights reserved.
//
#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad
#import "STEDetailViewController.h"
#import "STEMasterViewController.h"
#import "PTKEntryCell.h"
#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]
@interface STEDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation STEDetailViewController
{
    STESimpleTextDocument* _document;
    NSString *keyid;
}

bool cr;//complete pairing or not-password
bool check;//check if key inserted or not-password

//buttons and labels for subviews
UIButton *button1;
UIButton *button;
UILabel *fromLabel;
UIView *view ;
UITextField *textField ;

bool re;

NSData *encryptedData;
NSString *newString;
NSString *strFromInt;
NSString *name;
NSString *val;
//userDefaults for storing
NSUserDefaults *defaults;
NSUserDefaults *date;
NSUserDefaults *passWord;
NSUserDefaults *passWord2;
NSUserDefaults *checkp;
NSUserDefaults *check2;
NSURL *urll;
NSString *daaa;
NSString *plainString;
@synthesize masterTitle1;
@synthesize dateN;
@synthesize  date2;//last edit
@synthesize num;//last edit
@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize textView,masterTitle;
@synthesize sound;
@synthesize encrypt,decrypt;
@synthesize spin;
@synthesize pairid;
#pragma mark - Managing the detail item

//- (void)setDetailItem:(id)newDetailItem
//{
//    if (_detailItem != newDetailItem) {
//        _detailItem = newDetailItem;
//        
//        // Update the view.
//        [self configureView];
//    }
//
//    if (self.masterPopoverController != nil) {
//        [self.masterPopoverController dismissPopoverAnimated:YES];
//    }        
//}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSString* newText = self.textView.text;
    _document.documentText = newText;
    
    [passWord setObject:newText forKey:@"name"];
    [passWord synchronize];
     NSString *firstName = [passWord objectForKey:@"name"];
    NSLog(@"the OLD string was %@",firstName);
    // Close the document.
   

    
    [_document closeWithCompletionHandler:nil];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}
//called whenever textfield changes for continuous synch of data with icloud , also to
//find last edit continoiously
- (void)textViewDidChange:(UITextView *)textView {
    
//for last date edit, save the current time of edit
     NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
     [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      [formatter stringFromDate:[NSDate date]];
      NSString *fileName = [NSString stringWithFormat:@"Last Edit: %@",
                           [formatter stringFromDate:[NSDate date]]];
   dateN.text=fileName;
    //convert the index.row from listviewcontroller from int to NSSTRING
     strFromInt = [NSString stringWithFormat:@"%d",num];
    //name for the key to be used in nsdefault
    
     //name=[NSString stringWithFormat:@"%@",strFromInt];
    //NSLog(@"the ROW is %@ and %@",strFromInt,name);
    
    [date setObject:fileName forKey:strFromInt];
    [date synchronize];
    
    
    
}

//EXTREMELY IMPORTANT
//to give the functionality of encrption, if key already inserted, do not encrypt, otherwise encrypy
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (sound==false)
        
    {
        //do not encrypt
        [self dec];
//        _document = [[STESimpleTextDocument alloc]
//                     initWithFileURL:self.detailItem];
//        _document.delegate = self;
//        NSURL *test= _document.fileURL;
//        NSLog(@"the URL IS %@",test);
//        NSLog(@"contents are %@", _document.documentText);
//        // If the file exists, open it; otherwise, create it.
//        NSFileManager *fm = [NSFileManager defaultManager];
//        [_document saveToURL:self.detailItem
//            forSaveOperation:UIDocumentSaveForCreating
//           completionHandler:nil];
        //if ([fm fileExistsAtPath:[self.detailItem path]])
            //[_document openWithCompletionHandler:nil];
        
    }
    else{
        //encrypt
        decrypt.enabled=NO;
        // Clear out the text view contents.
    self.textView.text = @"";
    // Create the document and assign the delegate.
    _document = [[STESimpleTextDocument alloc]
                 initWithFileURL:self.detailItem];
    _document.delegate = self;
       NSURL *test= _document.fileURL;
        NSLog(@"the URL IS %@",test);
       NSLog(@"contents are %@", _document.documentText);
    // If the file exists, open it; otherwise, create it.
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:[self.detailItem path]])
        [_document openWithCompletionHandler:nil];
        
    else
        // Save the new document to disk.
        [_document saveToURL:self.detailItem
            forSaveOperation:UIDocumentSaveForCreating
           completionHandler:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    }
}
- (void)keyboardWillShow:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGRect kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey]
                     CGRectValue];
    double duration = [[info
                        objectForKey:UIKeyboardAnimationDurationUserInfoKey]
                       doubleValue];
    UIEdgeInsets insets = self.textView.contentInset;
    insets.bottom += kbSize.size.height;
    [UIView animateWithDuration:duration animations:^{
        self.textView.contentInset = insets;
    }];
}
- (void)keyboardWillHide:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    double duration = [[info
                        objectForKey:UIKeyboardAnimationDurationUserInfoKey]
                       doubleValue];
    // Reset the text view's bottom content inset.
    UIEdgeInsets insets = self.textView.contentInset;
    insets.bottom = 0;
    [UIView animateWithDuration:duration animations:^{
        self.textView.contentInset = insets;
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (IDIOM != IPAD )
    {
        masterTitle.enabled=NO;
        masterTitle.borderStyle=UITextBorderStyleNone;
    }
    NSLog(@"the paiiiiiir id  is %@",pairid);
    spin.hidesWhenStopped=YES;
    textView.backgroundColor=[UIColor clearColor];
    UIImage *im=[UIImage imageNamed:@"word_bg.png"];
    UIImageView *img=[[UIImageView alloc]initWithImage:im];
    [self.view addSubview:img];
    [self.view bringSubviewToFront:textView];
    strFromInt = [NSString stringWithFormat:@"%d",num];
      dateN.text = [date stringForKey:strFromInt ];
    NSString *fileName = [NSString stringWithFormat:@"Last Edit: %@",
                          date2];
    //dateN.text=fileName;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incomingNotification:) name:@"rename1" object:nil];
    daaa=textView.text;
    
//      [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg_top2.png"] forBarMetrics:UIBarMetricsDefault];
   dateN.textColor= Rgb2UIColor(173, 162, 156);
    check=NO;
    masterTitle.text=masterTitle1;
    //[masterTitle addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];

   // masterTitle.text=self.navigationController.title;
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    defaults = [NSUserDefaults standardUserDefaults];
    passWord=[NSUserDefaults standardUserDefaults];
     passWord2=[NSUserDefaults standardUserDefaults];
    checkp=[NSUserDefaults standardUserDefaults];
    check2= [NSUserDefaults standardUserDefaults];
    date=[NSUserDefaults standardUserDefaults];
    //[self isHeadsetPluggedIn];
    //sound=FALSE;
    //[[AVAudioSession sharedInstance] setDelegate: self];
    [self isHeadsetPluggedIn];

   // [[AVAudioSession sharedInstance] setActive:YES
                                       //  error:nil];
    strFromInt = [NSString stringWithFormat:@"%d",num];
    //name for the key to be used in nsdefault
    
    name=[NSString stringWithFormat:@"myKey%@",strFromInt];
if(sound)
{
    if (IDIOM != IPAD )
    {
        masterTitle.enabled=NO;
        masterTitle.borderStyle=UITextBorderStyleNone;
    }
    else
        
    {
    masterTitle.borderStyle = UITextBorderStyleRoundedRect;
    masterTitle.enabled=NO;
    }
   
}
    else
    {
        masterTitle.borderStyle=UITextBorderStyleNone;
        masterTitle.enabled=NO;
    }
}
-(void)enabledit
{
    if (IDIOM != IPAD )
    {
        masterTitle.enabled=NO;
        masterTitle.borderStyle=UITextBorderStyleNone;
    }
    else
        
    {
        masterTitle.borderStyle = UITextBorderStyleNone;
        masterTitle.enabled=NO;
    }
 
}
- (IBAction)end:(id)sender {

NSLog(@"Want to rename  end");
    if ([masterTitle1 isEqualToString:masterTitle.text]) {
     
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle:@"Information"
//                              message:@"New name same as original one, Choose a different name."
//                              delegate:self
//                              cancelButtonTitle:@"Done"
//                              otherButtonTitles:nil];
//        [alert show];
    }
    else
    {
  [self renameEntry:_document to:masterTitle.text];
    }
}

- (void) incomingNotification:(NSNotification *)notification{
    urll = [notification object];
    [self renameagain:_document to:masterTitle.text];
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
    //[self textChanged:textField];
	return YES;
}

- (void)renameEntry:(STESimpleTextDocument *)entry to:(NSString *)filename {
   
    // Bail if not actually renaming
//    if ([entry.description isEqualToString:filename]) {
//        return YES;
//    }
    
    // Check if can rename file
    [[NSNotificationCenter defaultCenter] postNotificationName:@"rename" object:self userInfo:[NSDictionary dictionaryWithObject:self.masterTitle.text forKey:@"Note"]];
    //for master
//    NSString * newDocFilename = [NSString stringWithFormat:@"%@.%@",
//                                 filename, PTK_EXTENSION];
//    
//    [[ NSNotification *NoteInstanceID ] post];
//    if ([self docNameExistsInObjects:newDocFilename]) {
//        NSString * message = [NSString stringWithFormat:@"\"%@\" is already taken.  Please choose a different name.", filename];
//        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//        [alertView show];
//        return NO;
//    }
//    
//    NSURL * newDocURL = [self getDocURL:newDocFilename];
//    NSLog(@"Moving %@ to %@", entry.fileURL, newDocURL);
    
    // Rename by saving/deleting - hack?


}
- (BOOL)renameagain:(STESimpleTextDocument *)entry to:(NSString *)filename {
    re=TRUE;
 
    NSLog(@"the url is %@",urll);
    _document = [[STESimpleTextDocument alloc] initWithFileURL:entry.fileURL];
    _document.documentText=daaa;
      [_document openWithCompletionHandler:nil];
    _document.documentText=daaa;
         [_document saveToURL:urll forSaveOperation:UIDocumentSaveForCreating completionHandler:nil];
    _document.documentText=daaa;
    _document.new=YES;
    entry.new=YES;
    //entry.fileURL.new=YES;
    
    NSLog(@"Doc saved to %@", self.detailItem);
            //[_document closeWithCompletionHandler:nil ];
    
    re=true;
    return YES;
[[NSNotificationCenter defaultCenter] postNotificationName:@"delete1" object:self userInfo:[NSDictionary dictionaryWithObject:self.masterTitle.text forKey:@"Note"]];
    textView.text=daaa;

}


  - (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isHeadsetPluggedIn {
    
    
    
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
        {
            NSLog(@"HEADPHONE IN");
            // sound=true;
            
            return YES;
        }
        else{
            return NO;
             sound=false;
            NSLog(@"HEADPHONE OUT");
        }
    }
    return YES;
}
#pragma mark - Split view
- (void)documentContentsDidChange:(STESimpleTextDocument *)document {
    
    if (re) {
        
     [check2 setBool:TRUE forKey:@"bool"];
        [check2 synchronize];
        re=false;
        _document.new=YES;
        document.new=YES;
        
            NSString *firstName = [defaults objectForKey:@"name"];
            
            self.textView.text = firstName;
        [ document setDocumentText:firstName];
         document.documentText=firstName;
        [ _document setDocumentText:firstName];
        _document.documentText=firstName;
        // Close the document.
        [  document closeWithCompletionHandler:nil];
        [  _document closeWithCompletionHandler:nil];
            //[defaults setObject:val forKey:@"name"];
            //[defaults synchronize];
        
        //NSLog(@"the value of test is %@",test);
    
    }
    else
    {
         NSString *firstName = [passWord objectForKey:@"name"];
        bool saved=[check2 boolForKey:@"bool"];
        if (saved) {
            
         
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textView.text = firstName;
            val=document.documentText;
            [defaults setObject:val forKey:@"name"];
            [defaults synchronize];
[check2 setBool:FALSE forKey:@"bool"];
            [check2 synchronize];
        });
        }
        
        else
            {
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.textView.text = document.documentText;
                    val=document.documentText;
                    [defaults setObject:val forKey:@"name"];
                    [defaults synchronize];
                    
                    
                });
            }

        }
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([masterTitle isFirstResponder] && [touch view] != masterTitle) {
        [masterTitle resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
    NSLog(@"Want to rename  end");
    if ([masterTitle1 isEqualToString:masterTitle.text]) {
        
        NSLog(@"same");
    }
    else
    {
        [self renameEntry:_document to:masterTitle.text];
    }

}
- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}


#pragma mark-security
//to load data/string without encryption
-(void)decr
{
    textView.editable=YES;
    decrypt.enabled=NO;
    encrypt.enabled=YES;
    self.textView.text = @"";
    // Create the document and assign the delegate.
    _document = [[STESimpleTextDocument alloc]
                 initWithFileURL:self.detailItem];
    
    _document.delegate = self;
    NSLog(@"contents are %@", _document.documentText);
    // If the file exists, open it; otherwise, create it.
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:[self.detailItem path]])
        [_document openWithCompletionHandler:nil];
    else
        // Save the new document to disk.
        [_document saveToURL:self.detailItem
            forSaveOperation:UIDocumentSaveForCreating
           completionHandler:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];    
}

//decryption method
-(void)dec
{
    //goli chal gayi bade bjai 
    NSString *plainString = self.textView.text;
    
    NSData *data = [plainString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    encryptedData = [RNEncryptor encryptData:data
                                withSettings:kRNCryptorAES256Settings
                                    password:@"123"
                                       error:&error];
    //NSString* newStr = [[NSString alloc] initWithData:encryptedData encoding:NSUTF8StringEncoding];
    NSString* newStr = [NSString stringWithUTF8String:[encryptedData bytes]];
    
    //NSLog(@"encrypter string is %@",encryptedData);
    
    
    int n1= [plainString length];
    
   //convert the text on the textfield to *
    if (n1 > 0){
        NSInteger starUpTo = n1 ;
        
        NSString *stars = [@"" stringByPaddingToLength:starUpTo withString:@"*" startingAtIndex:0];
        newString=[plainString stringByReplacingCharactersInRange:NSMakeRange(0, starUpTo) withString:stars];
    }
    else
    {
        newString=plainString;
    }
    
   textView.editable=NO;
    self.textView.text=newString;
    encrypt.enabled=NO;
    decrypt.enabled=YES;
    
}
//encryption method
- (IBAction)encrypt:(id)sender {
    
    plainString = self.textView.text;
    
    NSData *data = [plainString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    encryptedData = [RNEncryptor encryptData:data
                                withSettings:kRNCryptorAES256Settings
                                    password:@"123"
                                       error:&error];
    //NSString* newStr = [[NSString alloc] initWithData:encryptedData encoding:NSUTF8StringEncoding];
    NSString* newStr = [NSString stringWithUTF8String:[encryptedData bytes]];
    
    NSLog(@"encrypter string is %@",encryptedData);
    
    
    int n1= [plainString length];
    
    if (n1 > 0){
        NSInteger starUpTo = n1 ;
        
        NSString *stars = [@"" stringByPaddingToLength:starUpTo withString:@"*" startingAtIndex:0];
        newString=[plainString stringByReplacingCharactersInRange:NSMakeRange(0, starUpTo) withString:stars];
    }
    else
    {
        newString=plainString;
    }
    
    self.textView.text=newString;
    textView.editable=NO;
    encrypt.enabled=NO;
    decrypt.enabled=YES;
 
    
}
//decprytion method
- (IBAction)decrypt:(id)sender {
    if (sound)
    {
        NSError *error;
        NSData *decryptedData = [RNDecryptor decryptData:encryptedData
                                            withPassword:@"123"
                                                   error:&error];
        NSString* newStr = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
        //NSLog(@"decrypter string is %@",newStr);
        self.textView.text=newStr;
        textView.editable=YES;
        decrypt.enabled=NO;
        encrypt.enabled=YES;
    }
    else{
        [spin startAnimating];
        [self check1];
    }
}


#pragma mark-KeyPro library

- (void) initAudioPlayer {
    if(!mSmc361Device)
        mSmc361Device = [[Smc361Device alloc] init];
    mSmc361Device.delegate = self;
}


- (NSString *) hexDataToString:(UInt8 *)data
                        Length:(int)len
{
    NSString *tmp = @"";
    NSString *str = @"";
    for(int i = 0; i < len; ++i)
    {
        tmp = [NSString stringWithFormat:@"%02X",data[i]];
        str = [str stringByAppendingString:tmp];
    }
    return str;
}



- (void) receivedMessage: (SInt32)type
                  Result: (Boolean)result
                    Data: (void *)data;
{
    NSLog(@" CHECK2");
    NSString *msg = nil;
    
    switch(type)
    {
        case MESSAGE_READ_DATA:
            if (result == TRUE)
            {
                
                MSG_INFORM_DATA *infrom_data = data;
                
                NSString *strData = [self hexDataToString: infrom_data->data Length: 5];
                keyid = [[NSString alloc] initWithFormat:@"Data : %@",strData];
                msg = [[NSString alloc] initWithFormat: @"%@",keyid];
                NSLog(@"m %@",msg);
                NSLog(@"k %@",keyid);
                NSLog(@"s %@",strData);
                if ([strData isEqualToString:pairid]) {
                    
                    masterTitle.enabled=YES;
                     masterTitle.borderStyle = UITextBorderStyleRoundedRect;
                sound=TRUE;
                    //[self enabledit];
                [spin stopAnimating];
                [self decr];
                if (check) {
                    [self saveP];
                }
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:@"Information"
                                          message:@"Wrong Key Inserted or key not paired"
                                          delegate:self
                                          cancelButtonTitle:@"Done"
                                          otherButtonTitles:nil];
                    [alert show];
                    [spin stopAnimating];
                }
                
                //dataLabel. text = strDataLabel;
            }
            
            
            else
            {
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:@"Information"
                                          message:@"pls insert key"
                                          delegate:self
                                          cancelButtonTitle:@"Done"
                                          otherButtonTitles:nil];
                    [alert show];
                [spin stopAnimating];
            }
            
            break;
            
        default:
            break;
     
    }
    
}


#pragma mark-password
//clean/hide the subviews from the main view

-(void)clearView
{
    textField.hidden=YES;
    fromLabel.hidden=YES;
    button.hidden=YES;
    button1.hidden=YES;
    textView.hidden=NO;
}
-(void)check1
{
    NSLog(@" CHECK");
    [self initAudioPlayer];
    
    [mSmc361Device readData];
}

//method to save password
-(void)savePassword:(NSString *)pass
{
    //save in NSUserdefault
  [passWord2 setObject:pass forKey:@"pas1"];
    [passWord2 synchronize];
    [self clearView];
    
    NSString *msg= [[NSString alloc] initWithFormat:@"Your Password is %@",pass];
    UIAlertView *alert = [[UIAlertView alloc]
                                                        initWithTitle:@"Password Created"
                                                        message:msg
                                                        delegate:self
                                                        cancelButtonTitle:@"Done"
                                                        otherButtonTitles:nil];
                                  [alert show];
    textView.hidden=NO;
    //check 1- to show pairining has been done
    
    [checkp setBool:TRUE forKey:@"bool2"];
    [checkp synchronize];
    bool saved=[checkp boolForKey:@"bool2"];
}

//function called for first time creating password, must check if key inserted

-(void)saveP
{
    check=false;
    NSString *passs;
    passs=textField.text;
    //the entered password
    
    //if key inserted
    if (sound==TRUE)
    {
        //save password to NSuserdefault
        [self savePassword:passs];
    }
    else
    {
        //check for key
        check=TRUE;
        [self check1];
    }
 
    // [self check1];
 
}
//function to clear the views
-(void)backP
{
    [self clearView];
    
}
//function called when user enters password
-(void)de
{
    textView.hidden=NO;
    //NSLog(@"de");
    //NSString *pa =textField.text;
    NSString *pa=[passWord2 stringForKey:@"pas1"];
    NSLog(@"the password is %@",textField.text);
    //check the NSuserdefault for string matching with password
    if([textField.text isEqualToString:pa])
    {
        
        //call decrypt function
        [self clearView];
        [self decr];
        
    }
    else{
        //error
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Information"
                              message:@"wrong password"
                              delegate:self
                              cancelButtonTitle:@"Done"
                              otherButtonTitles:nil];
        [alert show];
    }
    
}


#pragma mark-create_view
- (IBAction)passWord:(id)sender {
    
   //check the NSuserdefault to find out the state (password created or not)
    bool saved=[checkp boolForKey:@"bool2"];
     //NSLog(@"the value of bool is %d",saved);
     if ( IDIOM == IPAD ) {
    if (saved)
        
    {
        textView.hidden=YES;
        view = [[UIView alloc] initWithFrame:CGRectMake(400, 500, 400, 400)];
        //creating textfield
        textField = [[UITextField alloc] initWithFrame:CGRectMake(245, 600, 200, 40)];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.font = [UIFont systemFontOfSize:18];
        textField.placeholder = @"enter text";
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.secureTextEntry=YES;
        textField.returnKeyType = UIReturnKeyDone;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.delegate = self;
        
        //create label
        fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(255, 490, 250, 150)];
        fromLabel.text = @"Enter Password";
        fromLabel.numberOfLines = 1;
        fromLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
        fromLabel.adjustsFontSizeToFitWidth = YES;
        fromLabel.adjustsLetterSpacingToFitWidth = YES;
        fromLabel.minimumScaleFactor = 10.0f/12.0f;
        fromLabel.font = [UIFont systemFontOfSize:18];
        fromLabel.clipsToBounds = YES;
        fromLabel.backgroundColor = [UIColor clearColor];
        fromLabel.textColor = [UIColor blackColor];
        fromLabel.textAlignment = NSTextAlignmentLeft;
        //[collapsedViewContainer addSubview:fromLabel];
        
        //create buttons
        //check password
        button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button addTarget:self
                   action:@selector(de)
         forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Decrypt" forState:UIControlStateNormal];
        button.frame = CGRectMake(250.0, 650.0, 80.0, 40.0);
        [self.view addSubview:button];
        //cancel button
        button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button1 addTarget:self
                    action:@selector(backP)
          forControlEvents:UIControlEventTouchUpInside];
        [button1 setTitle:@"Cancel" forState:UIControlStateNormal];
        button1.frame = CGRectMake(350.0, 650.0, 80.0, 40.0);
        
        //add subviews
        [self.view addSubview:button1];
        [self.view addSubview:fromLabel];
        [self.view addSubview:textField];
        [self.view addSubview:view];
        }
    
    else{
        //for first time,when user hasn't created a password yet
        //creating textfield
        textView.hidden=YES;
        view = [[UIView alloc] initWithFrame:CGRectMake(400, 500, 400, 400)];
        textField = [[UITextField alloc] initWithFrame:CGRectMake(245, 600, 200, 40)];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.font = [UIFont systemFontOfSize:18];
        textField.placeholder = @"enter text";
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.secureTextEntry=YES;
        textField.returnKeyType = UIReturnKeyDone;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.delegate = self;
        
        //create label
        fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(245, 490, 250, 150)];
        fromLabel.text = @"Please create a password";
        fromLabel.numberOfLines = 1;
        fromLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
        fromLabel.adjustsFontSizeToFitWidth = YES;
        fromLabel.adjustsLetterSpacingToFitWidth = YES;
        fromLabel.minimumScaleFactor = 10.0f/12.0f;
        fromLabel.font = [UIFont systemFontOfSize:18];
        fromLabel.clipsToBounds = YES;
        fromLabel.backgroundColor = [UIColor clearColor];
        fromLabel.textColor = [UIColor blackColor];
        fromLabel.textAlignment = NSTextAlignmentLeft;
        //[collapsedViewContainer addSubview:fromLabel];
        
        //create buttons
        
        //first time password pairing
        button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button addTarget:self
                   action:@selector(saveP)
         forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Save" forState:UIControlStateNormal];
        button.frame = CGRectMake(250.0, 650.0, 80.0, 40.0);
        [self.view addSubview:button];
        
        //cancel button
        button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button1 addTarget:self
                    action:@selector(backP)
          forControlEvents:UIControlEventTouchUpInside];
        [button1 setTitle:@"Cancel" forState:UIControlStateNormal];
        button1.frame = CGRectMake(350.0, 650.0, 80.0, 40.0);
        
        //add on main view
        [self.view addSubview:button1];
        [self.view addSubview:fromLabel];
        [self.view addSubview:textField];
        [self.view addSubview:view];
        
    }
    
    
    
    }
    else
    {
        if (saved)
            
        {
            textView.hidden=YES;
            view = [[UIView alloc] initWithFrame:CGRectMake(180, 500, 500, 400)];
            //creating textfield
            textField = [[UITextField alloc] initWithFrame:CGRectMake(105, 220, 130, 25)];
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.font = [UIFont systemFontOfSize:18];
            textField.placeholder = @"enter text";
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.keyboardType = UIKeyboardTypeDefault;
            textField.secureTextEntry=YES;
            textField.returnKeyType = UIReturnKeyDone;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textField.delegate = self;
            
            //create label
            fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 120, 180, 40)];
            fromLabel.text = @"Enter Password";
            fromLabel.numberOfLines = 1;
            fromLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
            fromLabel.adjustsFontSizeToFitWidth = YES;
            fromLabel.adjustsLetterSpacingToFitWidth = YES;
            fromLabel.minimumScaleFactor = 10.0f/12.0f;
            fromLabel.font = [UIFont systemFontOfSize:18];
            fromLabel.clipsToBounds = YES;
            fromLabel.backgroundColor = [UIColor clearColor];
            fromLabel.textColor = [UIColor blackColor];
            fromLabel.textAlignment = NSTextAlignmentLeft;
            //[collapsedViewContainer addSubview:fromLabel];
            
            //create buttons
            //check password
            button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button addTarget:self
                       action:@selector(de)
             forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:@"Decrypt" forState:UIControlStateNormal];
            button.frame = CGRectMake(180.0, 180.0, 70.0, 20.0);
            [self.view addSubview:button];
            //cancel button
            button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button1 addTarget:self
                        action:@selector(backP)
              forControlEvents:UIControlEventTouchUpInside];
            [button1 setTitle:@"Cancel" forState:UIControlStateNormal];
            button1.frame = CGRectMake(100.0, 180.0, 50.0, 20.0);
            
            //add subviews
            [self.view addSubview:button1];
            [self.view addSubview:fromLabel];
            [self.view addSubview:textField];
            [self.view addSubview:view];
        }
        
        else{
            //for first time,when user hasn't created a password yet
            //creating textfield
            textView.hidden=YES;
            view = [[UIView alloc] initWithFrame:CGRectMake(180, 500, 500, 400)];
            textField = [[UITextField alloc] initWithFrame:CGRectMake(105, 250, 130, 25)];
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.font = [UIFont systemFontOfSize:17];
            textField.placeholder = @"enter text";
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.keyboardType = UIKeyboardTypeDefault;
            textField.secureTextEntry=YES;
            textField.returnKeyType = UIReturnKeyDone;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textField.delegate = self;
            
            //create label
            fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 150, 180, 40)];
            fromLabel.text = @"Please create a password";
            fromLabel.numberOfLines = 1;
            fromLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
            fromLabel.adjustsFontSizeToFitWidth = YES;
            fromLabel.adjustsLetterSpacingToFitWidth = YES;
            fromLabel.minimumScaleFactor = 10.0f/12.0f;
            fromLabel.font = [UIFont systemFontOfSize:18];
            fromLabel.clipsToBounds = YES;
            fromLabel.backgroundColor = [UIColor clearColor];
            fromLabel.textColor = [UIColor blackColor];
            fromLabel.textAlignment = NSTextAlignmentLeft;
            //[collapsedViewContainer addSubview:fromLabel];
            
            //create buttons
            
            //first time password pairing
            button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button addTarget:self
                       action:@selector(saveP)
             forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:@"Save" forState:UIControlStateNormal];
            button.frame = CGRectMake(180.0, 210.0, 50.0, 20.0);
            [self.view addSubview:button];
            
            //cancel button
            button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button1 addTarget:self
                        action:@selector(backP)
              forControlEvents:UIControlEventTouchUpInside];
            [button1 setTitle:@"Cancel" forState:UIControlStateNormal];
            button1.frame = CGRectMake(100.0, 210.0, 50.0, 20.0);
            
            //add on main view
            [self.view addSubview:button1];
            [self.view addSubview:fromLabel];
            [self.view addSubview:textField];
            [self.view addSubview:view];
            
        }
    
    
    }

}
@end
