//
//  NewViewController.m
//  SimpleTextEditor
//
//  Created by Jason Tsai on 8/7/14.
//  Copyright (c) 2014 nick. All rights reserved.
//
#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad
#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]
#import "PTKEntryCell.h"
#import "NewViewController.h"
//#import "STEMasterViewController.h"
#import "STEDetailViewController.h"
#import "AddNoteViewController.h"
#import "STESimpleTextDocument.h"
NSString* DisplayDetailSegue = @"DisplayDetailSegue";
NSString* STEDocumentsDirectoryName = @"Documents";
NSString *STEDocFilenameExtension = @"doc";
static NSString* DocumentEntryCell = @"DocumentEntryCell";
NSString* keyid;
NSURL *urll;
NSString *a;
int a2,newtest;;
UILabel *labelTwo;
NSString *titl;
bool inside;

UITextField *textTwo;
@interface NewViewController ()

@end

@implementation NewViewController
{
    NSTimer *timer1;
    NSTimer *timer2;
    STESimpleTextDocument *document;
    NSMutableArray *documents;
    NSMetadataQuery *_query;
    NSArray *searchResults;
    NSMutableArray *name;
    NSUserDefaults *pairedc;
    NSUserDefaults *pairedidc;
}
NSString *test;
bool soundk;
bool paired;
NSString *pairid;
UITextField * _activeTextField;
@synthesize addButton;
@synthesize docName;
@synthesize pair;
@synthesize Table;
@synthesize filteredArray;
@synthesize labelOne;
@synthesize spin;
@synthesize main,main1;
- (void)processFiles:(NSNotification*)aNotification {
    NSMutableArray *discoveredFiles = [NSMutableArray array];
    
    // Always disable updates while processing results.
    [_query disableUpdates];
    
    // The query reports all files found, every time.
    NSArray *queryResults = [_query results];
    for (NSMetadataItem *result in queryResults) {
        NSURL *fileURL = [result valueForAttribute:NSMetadataItemURLKey];
        NSNumber *aBool = nil;
        
        // Don't include hidden files.
        [fileURL getResourceValue:&aBool forKey:NSURLIsHiddenKey error:nil];
        if (aBool && ![aBool boolValue])
            [discoveredFiles addObject:fileURL];
    }
    
    // Update the list of documents.
    [documents removeAllObjects];
    
    [documents addObjectsFromArray:discoveredFiles];
    [Table reloadData];
    
    // Reenable query updates.
    [_query enableUpdates];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
     [self refresharray];
    
NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
    searchResults =[name filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

-(void)refresharray
{
    [name removeAllObjects];
    
    for (int i=0; i<[documents count]; i++) {
        NSURL *fileURL = [documents objectAtIndex:i];;
        NSString *new=[[fileURL lastPathComponent] stringByDeletingPathExtension];
        [name addObject:new];
    }
}
- (BOOL)isHeadsetPluggedIn {
    
    
    
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
        {
            NSLog(@"HEADPHONE IN");
            inside=TRUE;
             [self check1];
            return YES;
        }
        else{
            return NO;
            inside=false;
            soundk=false;
            NSLog(@"HEADPHONE OUT");
        }
    }
    return YES;
}
- (NSMetadataQuery*)textDocumentQuery {
    NSMetadataQuery* aQuery = [[NSMetadataQuery alloc] init];
    if (aQuery) {
        // Search the Documents subdirectory only.
        [aQuery setSearchScopes:[NSArray
                                 arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
        
        // Add a predicate for finding the documents.
        NSString* filePattern = [NSString stringWithFormat:@"*.%@",
                                 STEDocFilenameExtension];
        [aQuery setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE %@",
                              NSMetadataItemFSNameKey, filePattern]];
    }
    
    return aQuery;
}




- (void)setupAndStartQuery {
    // Create the query object if it does not exist.
    if (!_query)
        _query = [self textDocumentQuery];
    
    // Register for the metadata query notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processFiles:)
                                                 name:NSMetadataQueryDidFinishGatheringNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processFiles:)
                                                 name:NSMetadataQueryDidUpdateNotification
                                               object:nil];
    
    // Start the query and let it run.
    [_query startQuery];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    if (!documents)
        documents = [[NSMutableArray alloc] init];
     self.navigationItem.leftBarButtonItem = self.editButtonItem;
    [self setupAndStartQuery];
     [self check1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refresharray];
    spin.hidesWhenStopped=YES;
   pairedc=[NSUserDefaults standardUserDefaults];
    pairedidc=[NSUserDefaults standardUserDefaults];
    paired=[pairedc boolForKey:@"bool1"];
    pairid=[pairedidc stringForKey:@"pas"];
    NSLog(@"the value of pairid is %@",pairid);
    
    if (paired) {
        pair.enabled=NO;
        [self check1];
        UIImage *buttonImage = [UIImage imageNamed:@"co_ok.png"];
        [pair setBackgroundImage:buttonImage forState:UIControlStateNormal];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Information"
                              message:@"Please pair your key-1 via pressing the lock button to use encryption features"
                              delegate:self
                              cancelButtonTitle:@"Done"
                              otherButtonTitles:nil];
        [alert show];
        [self animat];
        
        UIImage *buttonImage = [UIImage imageNamed:@"what's_co1.png"];
        [pair setBackgroundImage:buttonImage forState:UIControlStateNormal];
        
        
        
        //pair.highlighted=YES;
        
    }
    
//             NSTimer *mytimer = [NSTimer scheduledTimerWithTimeInterval:3.28
//                                                                 target:self
//                                                               selector:@selector(refresharray)
//                                                             userInfo:nil
//                                                                repeats:YES];
    PTKEntryCell *t = [self.Table dequeueReusableCellWithIdentifier:DocumentEntryCell];
    [t.titleTextField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    NSString *test=@"test";
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    name = [[NSMutableArray alloc] init];
    searchResults=[[NSArray alloc]init];
    textTwo.enabled=NO;
   // [tex addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    [self isHeadsetPluggedIn];
    UIButton *backBtn     = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backBtnImage;
       if ( IDIOM == IPAD ) {
     backBtnImage = [UIImage imageNamed:@"button_new1.png"] ;
       }
       else{
           NSLog(@"@iphone ui");
            backBtnImage = [UIImage imageNamed:@"button_new1ii.png"] ;
       }
    [backBtn setBackgroundImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(addd) forControlEvents:UIControlEventTouchUpInside];
    if ( IDIOM == IPAD ) {
     backBtn.frame = CGRectMake(0, 0, 44, 38);
    }
    else{
        backBtn.frame = CGRectMake(0, 0, 26, 26);
    }
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn] ;
    self.navigationItem.rightBarButtonItem = cancelButton;
 
     [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bg.png"] forBarMetrics:UIBarMetricsDefault];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didAddNewNote1:)
                                                 name:@"rename"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didAddNewNote:)
                                                 name:@"New Note"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didAddNewNote2:)
                                                 name:@"delete1"
                                               object:nil];
    self.filteredArray = [NSMutableArray arrayWithCapacity:[documents count]];
    [[AVAudioSession sharedInstance] setDelegate: self];
    [self isHeadsetPluggedIn];
    NSError *setCategoryError = nil;
    [[AVAudioSession sharedInstance] setActive:YES
                                         error:nil];
    
     //[[documents reverseObjectEnumerator] allObjects];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    // Registers the audio route change listener callback function
    AudioSessionAddPropertyListener (kAudioSessionProperty_AudioRouteChange, audioRouteChangeListenerCallback4, (__bridge void *)(self));
	// Do any additional setup after loading the view, typically from a nib.
}

void audioRouteChangeListenerCallback4 (void *inUserData, AudioSessionPropertyID inPropertyID, UInt32 inPropertyValueSize, const void *inPropertyValue ) {
    
    
    // ensure that this callback was invoked for a route change
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
    
    
    {
        
        // Determines the reason for the route change, to ensure that it is not
        //      because of a category change.
        CFDictionaryRef routeChangeDictionary = (CFDictionaryRef)inPropertyValue;
        
        CFNumberRef routeChangeReasonRef = (CFNumberRef)CFDictionaryGetValue (routeChangeDictionary, CFSTR (kAudioSession_AudioRouteChangeKey_Reason) );
        SInt32 routeChangeReason;
        CFNumberGetValue (routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
        
        if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
            NSLog(@"PLUG OUT ");
            inside=false;
            //            [(__bridge id)inUserData performSelectorOnMainThread:@selector(check1)withObject:nil waitUntilDone:NO];
            soundk=FALSE;
            // [(__bridge id)inUserData performSelectorOnMainThread:@selector(countTotalFrames)withObject:nil waitUntilDone:NO];
            // [(__bridge id)inUserData performSelectorOnMainThread:@selector(clear)withObject:nil waitUntilDone:NO];
            
            
            // [[UIScreen mainScreen] setBrightness:1.0];
            //[(__bridge id)inUserData performSelectorOnMainThread:@selector(countTotalFrames)withObject:nil waitUntilDone:NO];
            //Handle Headset Unplugged
        } else if (routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable) {
            
            NSLog(@"PLUG IN ");
            [(__bridge id)inUserData performSelectorOnMainThread:@selector(check1)withObject:nil waitUntilDone:YES];
            inside=TRUE;
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
}

-(void)animat
{
    if ( IDIOM == IPAD ) {
        NSLog(@"start animate");
    UIImage* img1 = [UIImage imageNamed:@"light_01.png"];
    UIImage* img2 = [UIImage imageNamed:@"light_02.png"];
    UIImage* img3 = [UIImage imageNamed:@"light_03.png"];
    UIImage* img4 = [UIImage imageNamed:@"light_04.png"];
    UIImage* img5 = [UIImage imageNamed:@"light_05.png"];
    UIImage* img6 = [UIImage imageNamed:@"light_06.png"];
    UIImage* img7 = [UIImage imageNamed:@"light_07.png"];
    UIImage* img8 = [UIImage imageNamed:@"light_08.png"];
    UIImage* img9 = [UIImage imageNamed:@"light_09.png"];
    UIImage* img10 = [UIImage imageNamed:@"light_10.png"];
          NSArray *images = [NSArray arrayWithObjects:img1,img2,img3,img4,img5,img6,img7,img8,img9,img10,nil];
        main=[[UIImageView alloc] initWithFrame:CGRectMake(548, 930, 142, 122)];;
        main.animationImages=images;
        main.animationDuration = 1.22;
        main.animationRepeatCount=0;
        [self.view addSubview:main];
        [UIView animateWithDuration:1.22
                              delay:0.0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             
                         }
                         completion:^(BOOL finished){
                             
                         }];
        [ main startAnimating];
        
        
        
        
    
    }
    else
    {
        NSLog(@"start ipanimate");
        UIImage* img1 = [UIImage imageNamed:@"light_01i.png"];
        UIImage* img2 = [UIImage imageNamed:@"light_02i.png"];
        UIImage* img3 = [UIImage imageNamed:@"light_03i.png"];
        UIImage* img4 = [UIImage imageNamed:@"light_04i.png"];
        UIImage* img5 = [UIImage imageNamed:@"light_05i.png"];
        UIImage* img6 = [UIImage imageNamed:@"light_06i.png"];
        UIImage* img7 = [UIImage imageNamed:@"light_07i.png"];
        UIImage* img8 = [UIImage imageNamed:@"light_08i.png"];
        UIImage* img9 = [UIImage imageNamed:@"light_09i.png"];
        UIImage* img10 = [UIImage imageNamed:@"light_10i.png"];
        NSArray *images1 = [NSArray arrayWithObjects:img1,img2,img3,img4,img5,img6,img7,img8,img9,img10,nil];
        main1=[[UIImageView alloc] initWithFrame:CGRectMake(229, 514, 57, 58)];;
        main1.animationImages=images1;
        main1.animationDuration = 1.22;
        main1.animationRepeatCount=0;
        [self.view addSubview:main1];
        [UIView animateWithDuration:1.22
                              delay:0.0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             
                         }
                         completion:^(BOOL finished){
                             
                         }];
        [ main1 startAnimating];
        
    }
    
}

- (IBAction)e:(id)sender forEvent:(UIEvent *)event {
}





- (void)viewDidUnload
{
    addButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (IBAction)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeTextField = textField;
}

- (IBAction)textFieldDidEndEditing:(UITextField *)textField
{
    _activeTextField = nil;
}

- (void)textChanged:(UITextField *)textField {
    UIView * view = textField.superview;
    while( ![view isKindOfClass: [PTKEntryCell class]]){
        view = view.superview;
    }
    PTKEntryCell *cell = (PTKEntryCell *) view;
    NSIndexPath * indexPath = [self.Table indexPathForCell:cell];
    
    NSLog(@"Want to rename %ld to", (long)indexPath.row);
    //[self renameEntry:entry to:textField.text];
    //kisko accha lagta hai fuddiya marna
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
    [self textChanged:textField];
	return YES;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self check1];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSString*)newUntitledDocumentName {
    NSInteger docCount = 0;     // Start with 1 and go from there.
    NSString* newDocName = nil;
    
    // At this point, the document list should be up-to-date.
    BOOL done = NO;
    while (!done) {
        if (docCount==0)
        {
            newDocName = [NSString stringWithFormat:@"%@.%@",
                          docName,STEDocFilenameExtension];
        }
        else
        {
            newDocName = [NSString stringWithFormat:@"%@ %ld.%@",
                          docName,(long)docCount, STEDocFilenameExtension];
        }
        
        // Look for an existing document with the same name. If one is
        // found, increment the docCount value and try again.
        BOOL nameExists = NO;
        for (NSURL* aURL in documents) {
            if ([[aURL lastPathComponent] isEqualToString:newDocName]) {
                docCount++;
                nameExists = YES;
                break;
            }
        }
        
        // If the name wasn't found, exit the loop.
        if (!nameExists)
            done = YES;
    }
    return newDocName;
}
- (void)didAddNewNote:(NSNotification *)notification
{
    
    NSDictionary *userInfo = [notification userInfo];
    docName = [userInfo valueForKey:@"Note"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Create the new URL object on a background queue.
        NSFileManager *fm = [NSFileManager defaultManager];
        NSURL *newDocumentURL = [fm URLForUbiquityContainerIdentifier:nil];
        
        newDocumentURL = [newDocumentURL
                          URLByAppendingPathComponent:STEDocumentsDirectoryName
                          isDirectory:YES];
        newDocumentURL = [newDocumentURL
                          URLByAppendingPathComponent:[self newUntitledDocumentName]];
        
        
        // Perform the remaining tasks on the main queue.
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the data structures and table.
            [documents addObject:newDocumentURL];
            
            // Update the table.
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            [formatter stringFromDate:[NSDate date]];
            NSString *fileName = [NSString stringWithFormat:@"%@",
                                  [formatter stringFromDate:[NSDate date]]];
            
            NSIndexPath* newCellIndexPath =
            [NSIndexPath indexPathForRow:([documents count] - 1) inSection:0];
            [self.Table insertRowsAtIndexPaths:[NSArray arrayWithObject:newCellIndexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [self.Table selectRowAtIndexPath:newCellIndexPath
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionMiddle];
            
            // Segue to the detail view controller to begin editing.
            //            UITableViewCell* selectedCell = [self.tableView
            //                                             cellForRowAtIndexPath:newCellIndexPath];
            //            [self performSegueWithIdentifier:DisplayDetailSegue sender:selectedCell];
            
            // Reenable the Add button.
            self.addButton.enabled = YES;
        });
    });
    
}

- (void)didAddNewNote2:(NSNotification *)notification
{
    NSURL *fileURL = [documents objectAtIndex:a2];
    
    // Don't use file coordinators on the app's main queue.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileCoordinator *fc = [[NSFileCoordinator alloc]
                                 initWithFilePresenter:nil];
        [fc coordinateWritingItemAtURL:fileURL
                               options:NSFileCoordinatorWritingForDeleting
                                 error:nil
                            byAccessor:^(NSURL *newURL) {
                                NSFileManager *fm = [[NSFileManager alloc] init];
                                [fm removeItemAtURL:newURL error:nil];
                            }];
    });
    
    // Remove the URL from the documents array.
    [documents removeObjectAtIndex:a2];
    NSIndexPath *cellPath = [self.Table indexPathForSelectedRow];
    // Update the table UI. This must happen after
    // updating the documents array.
    
    
    // Update the table UI. This must happen after
    // updating the documents array.
    [self.Table deleteRowsAtIndexPaths:[NSArray arrayWithObject:cellPath]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
  
    
    
}
- (void)didAddNewNote1:(NSNotification *)notification
{
    
    NSDictionary *userInfo = [notification userInfo];
    docName = [userInfo valueForKey:@"Note"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Create the new URL object on a background queue.
        NSFileManager *fm = [NSFileManager defaultManager];
        NSURL *newDocumentURL = [fm URLForUbiquityContainerIdentifier:nil];
        
        newDocumentURL = [newDocumentURL
                          URLByAppendingPathComponent:STEDocumentsDirectoryName
                          isDirectory:YES];
        newDocumentURL = [newDocumentURL
                          URLByAppendingPathComponent:[self newUntitledDocumentName]];
        urll=newDocumentURL;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"rename1" object:urll];
        NSLog(@"the new one is %@",urll);

        
        // Perform the remaining tasks on the main queue.
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the data structures and table.
            [documents addObject:newDocumentURL];
            [name addObject:[[newDocumentURL lastPathComponent] stringByDeletingPathExtension]];
            
            // Update the table.
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            [formatter stringFromDate:[NSDate date]];
            NSString *fileName = [NSString stringWithFormat:@"%@",
                                  [formatter stringFromDate:[NSDate date]]];
            
            NSIndexPath* newCellIndexPath =
            [NSIndexPath indexPathForRow:([documents count] - 1) inSection:0];
            [self.Table insertRowsAtIndexPaths:[NSArray arrayWithObject:newCellIndexPath]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [self.Table selectRowAtIndexPath:newCellIndexPath
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionMiddle];
            
            // Segue to the detail view controller to begin editing.
            //            UITableViewCell* selectedCell = [self.tableView
            //                                             cellForRowAtIndexPath:newCellIndexPath];
            //            [self performSegueWithIdentifier:DisplayDetailSegue sender:selectedCell];
            
            // Reenable the Add button.
            self.addButton.enabled = YES;
            
        });
    });
    

    
//   / NSURL *fileURL = [documents objectAtIndex:[indexPath row]];
//    
//    // Don't use file coordinators on the app's main queue.
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSFileCoordinator *fc = [[NSFileCoordinator alloc]
//                                 initWithFilePresenter:nil];
//        [fc coordinateWritingItemAtURL:fileURL
//                               options:NSFileCoordinatorWritingForDeleting
//                                 error:nil
//                            byAccessor:^(NSURL *newURL) {
//                                NSFileManager *fm = [[NSFileManager alloc] init];
//                                [fm removeItemAtURL:newURL error:nil];
//                            }];
//    });
    
    // Remove the URL from the documents array.
//    [documents removeObjectAtIndex:[indexPath row]];
//    
//    // Update the table UI. This must happen after
//    // updating the documents array.
//    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
//                     withRowAnimation:UITableViewRowAnimationAutomatic];




}


-(void)addd
{
    
    AddNoteViewController *ViewController;
    if ( IDIOM == IPAD ) {
       ViewController = [[AddNoteViewController alloc] initWithNibName:@"AddNoteViewController" bundle:nil];
    } else {
       ViewController = [[AddNoteViewController alloc] initWithNibName:@"Addnote_iphone" bundle:nil];
    }
    
    [self.navigationController pushViewController:ViewController animated:YES];
}
- (IBAction)addDocument:(id)sender {
    // Disable the Add button while creating the document.
    //self.addButton.enabled = NO;
   
    AddNoteViewController *ViewController = [[AddNoteViewController alloc] initWithNibName:@"AddNoteViewController" bundle:nil];
    [self.navigationController pushViewController:ViewController animated:YES];
    /*
     */
}

- (IBAction)del:(id)sender {
    [self setEditing:YES animated:YES];
    
}



- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
        
    } else {
   
        return [documents count];
    }
}
- (NSDictionary *) attributesForFile:(NSURL *)anURI {
    
    // note: singleton is not thread-safe
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *aPath = [anURI path];
    
    if (![fileManager fileExistsAtPath:aPath]) return nil;
    
    NSError *attributesRetrievalError = nil;
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:aPath
                                                             error:&attributesRetrievalError];
    
    if (!attributes) {
        NSLog(@"Error for file at %@: %@", aPath, attributesRetrievalError);
        return nil;
    }
    
    NSMutableDictionary *returnedDictionary =
    [NSMutableDictionary dictionaryWithObjectsAndKeys:
     [attributes fileType], @"fileType",
     [attributes fileModificationDate], @"fileModificationDate",
     [attributes fileCreationDate], @"fileCreationDate",
     [NSNumber numberWithUnsignedLongLong:[attributes fileSize]], @"fileSize",
     nil];
     a=[returnedDictionary objectForKey:@"fileCreationDate"];
    // NSLog(@"creat date IS %@",a);
    return returnedDictionary;
}

- (IBAction)checkBoxTapped:(id)sender forEvent:(UIEvent*)event
{
    NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.Table];
    
    // Lookup the index path of the cell whose checkbox was modified.
	NSIndexPath *indexPath = [self.Table indexPathForRowAtPoint:currentTouchPosition];
    
	if (indexPath != nil)
	{
		// Update our data source array with the new checked state.
        NSMutableDictionary *selectedItem = documents[(NSUInteger)indexPath.row];
       // selectedItem[@"checked"] = @([(Checkbox*)sender isChecked]);
	}
    
    // Accessibility
   // [self updateAccessibilityForCell:(PTKEntryCell*)[self.Table cellForRowAtIndexPath:indexPath]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Find the cell being touched and update its checked/unchecked image.
	PTKEntryCell *targetCustomCell = (PTKEntryCell *)[tableView cellForRowAtIndexPath:indexPath];
    targetCustomCell.checkBox.checked = !targetCustomCell.checkBox.checked;
	
	// Don't keep the table selection.
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	// Update our data source array with the new checked state.
	//NSMutableDictionary *selectedItem = documents[(NSUInteger)indexPath.row];
   // selectedItem[@"checked"] = @(targetCustomCell.checkBox.checked);
    
    // Accessibility
    //[self updateAccessibilityForCell:targetCustomCell];
}

- (void)updateAccessibilityForCell:(PTKEntryCell*)cell
{
    // The cell's accessibilityValue is the Checkbox's accessibilityValue.
    cell.accessibilityValue = cell.checkBox.accessibilityValue;
    
     
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
     PTKEntryCell *newCell = [self.Table dequeueReusableCellWithIdentifier:DocumentEntryCell];
    //  UILabel *label;
//    //NSDictionary *item =[documents objectAtIndex:[indexPath row]];
    if (!newCell)
         newCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:DocumentEntryCell];
    
    if (!newCell)
        return nil;
    NSURL *fileURL=nil;
    // Get the doc at the specified row.
    //Recipe *recipe = nil;
    NSDictionary *item = documents[(NSUInteger)indexPath.row];
    //tableView.allowsMultipleSelection = YES;
        fileURL = [documents objectAtIndex:[indexPath row]];;
    
 //   newCell.checkBox.checked=[item[@"checked"] boolValue];
    newCell.subtitleLabel.textColor=Rgb2UIColor(173, 162, 156);
     //labelOne = (UILabel *)[newCell.contentView viewWithTag:1];
     //textTwo=(UITextField *)[newCell.contentView viewWithTag:2];
    NSDate *a1=[[self attributesForFile:fileURL] objectForKey:@"fileCreationDate"];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterLongStyle]; // day, Full month and year
    [df setTimeStyle:NSDateFormatterNoStyle];  // nothing
    
    NSString *dateString = [df stringFromDate:a1];
    newCell.subtitleLabel.text =dateString;
    //NSLog(@"DATE %@",a);
    
    
    //NSURL *fileURL = [documents objectAtIndex:[indexPath row]];
    
    // Configure the cell.
    //labelTwo.textColor=Rgb2UIColor(173, 162, 156);
    if(tableView==self.searchDisplayController.searchResultsTableView)
    {
         fileURL = [searchResults objectAtIndex:[indexPath row]];;
        
        
        
        NSString *test2=@"file:///private/var/mobile/Library/Mobile%20Documents/iCloud~com~mike~dox/Documents/";
        NSString *test=[NSString stringWithFormat:@"%@.doc",fileURL];
        NSString *newString = [test stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSString *final=[NSString stringWithFormat:@"%@%@",test2,newString];
        NSString *urlString = [NSString stringWithFormat:@"%@", final];
        
        NSURL *url = [NSURL URLWithString:urlString];
 
        NSDate *a2=[[self attributesForFile:url] objectForKey:@"fileCreationDate"];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateStyle:NSDateFormatterLongStyle]; // day, Full month and year
        [df setTimeStyle:NSDateFormatterNoStyle];  // nothing
        
        NSString *dateString = [df stringFromDate:a2];
        newCell.subtitleLabel.text =dateString;
        newCell.titleTextField.text =  fileURL ;
//        NSDate *a1=[[self attributesForFile:fileURL] objectForKey:@"fileCreationDate"];
//        
//        NSDateFormatter *df = [[NSDateFormatter alloc] init];
//        [df setDateStyle:NSDateFormatterLongStyle]; // day, Full month and year
//        [df setTimeStyle:NSDateFormatterNoStyle];  // nothing
//        
//        NSString *dateString = [df stringFromDate:a1];
          
        //[name addObject:test];
    }
    else{
      fileURL = [documents objectAtIndex:[indexPath row]];;
     newCell.titleTextField.text = [[fileURL lastPathComponent] stringByDeletingPathExtension];
        NSString *test=newCell.titleTextField.text;
        NSLog(@"LABEL STRING IS %@",test);
        
        
    }
        UIView *bgColorView = [[UIView alloc] init];
    
    bgColorView.backgroundColor = Rgb2UIColor(255, 240, 214);
    [newCell setSelectedBackgroundView:bgColorView];
   
    
    return newCell;
}
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    //[titleTextField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.Table setEditing:editing animated:YES];
    [UIView animateWithDuration:0.1 animations:^{
        if(editing){
           // titleTextField.enabled = YES;
            //titleTextField.borderStyle = UITextBorderStyleRoundedRect;
        }else{
            //titleTextField.enabled = NO;
            //titleTextField.borderStyle = UITextBorderStyleNone;
        }
    }];
    
}
- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSURL *fileURL = [documents objectAtIndex:[indexPath row]];
        
        // Don't use file coordinators on the app's main queue.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
            NSFileCoordinator *fc = [[NSFileCoordinator alloc]
                                     initWithFilePresenter:nil];
            [fc coordinateWritingItemAtURL:fileURL
                                   options:NSFileCoordinatorWritingForDeleting
                                     error:nil
                                byAccessor:^(NSURL *newURL) {
                                    NSFileManager *fm = [[NSFileManager alloc] init];
                                    [fm removeItemAtURL:newURL error:nil];
                                }];
        });
        
        // Remove the URL from the documents array.
        [documents removeObjectAtIndex:[indexPath row]];
        
        
        // Update the table UI. This must happen after
        // updating the documents array.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (![segue.identifier isEqualToString:DisplayDetailSegue])
        return;
    NSString *dateString;
    NSIndexPath *cellPath=nil;
    UITableViewCell *theCell;
    NSURL *fileurl;
    // Get the detail view controller.
    STEDetailViewController* destVC = (STEDetailViewController*)segue.destinationViewController;
    
    // Find the correct dictionary from the documents array.
    if (self.searchDisplayController.active) {
        cellPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
       NSString *tname = [searchResults objectAtIndex: cellPath.row];
        NSString *newString = [tname stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];


        NSLog(@"THE CURRENT IS %@",newString);
 
        
        NSString *test2=@"file:///private/var/mobile/Library/Mobile%20Documents/iCloud~com~mike~dox/Documents/";
        NSString *test=[NSString stringWithFormat:@"%@.doc",newString];
     
        
        NSString *final=[NSString stringWithFormat:@"%@%@",test2,test];
        NSString *urlString = [NSString stringWithFormat:@"%@", final];
        NSURL *url = [NSURL URLWithString:urlString];
        NSLog(@"THE URL IS %@",[url absoluteString]);
        titl=tname;
        NSDate *a1=[[self attributesForFile:url] objectForKey:@"fileModificationDate"];
        NSLog(@"the DATT IS %@",a1);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        dateString = [formatter stringFromDate:a1];
        
        
        // [url path];
        
        destVC.detailItem = url;
        
        
        //recipe = [searchResults objectAtIndex:indexPath.row];
    } else {
     cellPath = [self.Table indexPathForSelectedRow];
    a2=cellPath.row;
        
       fileurl = [documents objectAtIndex:[cellPath row]];
        destVC.detailItem = fileurl;
         NSLog(@"THE URL IS %@",fileurl);
    NSLog(@"the pATTTH is %d",a2);
        NSURL *fileURL=nil;
        fileURL = [documents objectAtIndex:a2];
    UITableViewCell *theCell = [self.Table cellForRowAtIndexPath:cellPath];
        titl=[[fileURL lastPathComponent] stringByDeletingPathExtension];
        NSDate *a1=[[self attributesForFile:fileURL] objectForKey:@"fileModificationDate"];
        NSLog(@"the DATT IS %@",a1);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        //[formatter stringFromDate:[NSDate date]];
        
        dateString = [formatter stringFromDate:a1];
        NSLog(@"the DATTEE STRING IS  %@",dateString);
    }
    
   
    // Assign the URL to the detail view controller and
    // set the title of the view controller to the doc name.
   // destVC.detailItem = fileurl;
    
    
    // Get the doc at the specified row.
    //Recipe *recipe = nil;
    
    //tableView.allowsMultipleSelection = YES;
    
//    document = [[STESimpleTextDocument alloc]
//                 initWithFileURL:theURL];
//   NSString *doc= document.documentText;
//    NSLog(@"DOCUMENT IS %@",doc);
    
       destVC.navigationItem.title = titl;
    destVC.num=a2;
    destVC.sound=soundk;
    destVC.masterTitle1=titl;
    destVC.date2=dateString;
    destVC.pairid=pairid;
    NSLog(@"the pair id is %@",pairid);
}


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
    
    NSString *msg = nil;
    
    switch(type)
    {
        case MESSAGE_READ_DATA:
            if (result == TRUE)
            {
                 NSLog(@"PAIR CALLED final");
                MSG_INFORM_DATA *infrom_data = data;
                pairid=[pairedidc stringForKey:@"pas"];
                NSString *strData = [self hexDataToString: infrom_data->data Length: 5];
                keyid = [[NSString alloc] initWithFormat:@"Data : %@",strData];
                msg = [[NSString alloc] initWithFormat: @" Key-1 has been paired, Please set password for further security"];
                UIImage *buttonImage = [UIImage imageNamed:@"co_ok.png"];
                [pair setBackgroundImage:buttonImage forState:UIControlStateNormal];
                [main stopAnimating];
                [main1 stopAnimating];
                if([strData isEqualToString:pairid])
                {
                     soundk=TRUE;
                //    NSLog(@"the sound is %@",soundk);
                }
                [spin stopAnimating];
                if (paired) {
                    
                [spin stopAnimating];
                   
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:@"Information"
                                          message:msg
                                          delegate:self
                                          cancelButtonTitle:@"Done"
                                          otherButtonTitles:nil];
                    [alert show];
                    [spin stopAnimating];
                }
                if(paired)
                {
                   NSLog(@"ppp");
                    [spin stopAnimating];
                }
                else
                {
                    [pairedc setBool:TRUE forKey:@"bool1"];
                    [pairedidc setObject:strData forKey:@"pas"];
                    [pairedidc synchronize];
                    [pairedc synchronize];
                    pair.enabled=NO;
                    pairid=[pairedidc stringForKey:@"pas"];
                    paired=[pairedc boolForKey:@"bool1"];
                }
                
                //soundk=TRUE;
                
                
                
                //dataLabel. text = strDataLabel;
            }
            else
            {
                soundk=false;
                msg = [[NSString alloc] initWithFormat: @"Read Key-1 Error!!!"];
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Information"
                                      message:msg
                                      delegate:self
                                      cancelButtonTitle:@"Done"
                                      otherButtonTitles:nil];
                //[alert show];
                [spin stopAnimating];
            }
            
            break;
            
        default:
            break;
            
            
    }
    //    UIAlertView *alert = [[UIAlertView alloc]
    //                          initWithTitle:@"Information"
    //                          message:msg
    //                          delegate:self
    //                          cancelButtonTitle:@"Done"
    //                          otherButtonTitles:nil];
    //    [alert show];
    
    //[self setAllButtonState: TRUE];
}

-(void)check1
{
    NSLog(@" CHECK");
    if (paired) {
        if(inside)
        {
            NSLog(@"sound is true");
        [spin startAnimating];
    
    [self initAudioPlayer];
        }
        else
        {
            NSLog(@"sound is false");
            soundk=false;
        }
    [mSmc361Device readData];
    }
    else
    {
        NSLog(@"not paired");
    }
    
    }




/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional mrearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (IBAction)lock:(id)sender {
}
- (IBAction)pair:(id)sender {
    NSLog(@"PAIR CALLED");
    [self initAudioPlayer];
    
    [mSmc361Device readData];
    
    [spin startAnimating];
    
}
@end
