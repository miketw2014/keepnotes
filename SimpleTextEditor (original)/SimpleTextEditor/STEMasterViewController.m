//
//  STEMasterViewController.m
//  SimpleTextEditor
//
//  Created by 畠山 貴 on 12/02/05.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "STEMasterViewController.h"
#import "STEDetailViewController.h"
#import "AddNoteViewController.h"
//NSString* DisplayDetailSegue = @"DisplayDet3ailSegue";
//NSString* STEDocumentsDirectoryName = @"Do3cuments";
//NSString *STEDocFilenameExtension = @"sted3oc";
//NSString* DocumentEntryCell = @"DocumentEntry3Cell";
//NSString* keyid;
@implementation STEMasterViewController {
    NSMutableArray *documents;
    NSMetadataQuery *_query;
    
}
NSString *test;
bool soundk;
@synthesize addButton;
@synthesize docName;
@synthesize searchBar;
@synthesize filteredArray;
//- (void)processFiles:(NSNotification*)aNotification {
//    NSMutableArray *discoveredFiles = [NSMutableArray array];
//    
//    // Always disable updates while processing results.
//    [_query disableUpdates];
//    
//    // The query reports all files found, every time.
//    NSArray *queryResults = [_query results];
//    for (NSMetadataItem *result in queryResults) {
//        NSURL *fileURL = [result valueForAttribute:NSMetadataItemURLKey];
//        NSNumber *aBool = nil;
//        
//        // Don't include hidden files.
//        [fileURL getResourceValue:&aBool forKey:NSURLIsHiddenKey error:nil];
//        if (aBool && ![aBool boolValue])
//            [discoveredFiles addObject:fileURL];
//    }
//    
//    // Update the list of documents.
//    [documents removeAllObjects];
//    [documents addObjectsFromArray:discoveredFiles];
//    [self.tableView reloadData];
//    
//    // Reenable query updates.
//    [_query enableUpdates];
//}
//- (BOOL)isHeadsetPluggedIn {
//    
//    
//    
//    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
//    for (AVAudioSessionPortDescription* desc in [route outputs]) {
//        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
//        {
//            NSLog(@"HEADPHONE IN");
//            // sound=true;
//            //[self check1];
//            return YES;
//        }
//        else{
//            return NO;
//             soundk=false;
//            NSLog(@"HEADPHONE OUT");
//        }
//    }
//    return YES;
//}
//- (NSMetadataQuery*)textDocumentQuery {
//    NSMetadataQuery* aQuery = [[NSMetadataQuery alloc] init];
//    if (aQuery) {
//        // Search the Documents subdirectory only.
//        [aQuery setSearchScopes:[NSArray
//                                 arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
//        
//        // Add a predicate for finding the documents.
//        NSString* filePattern = [NSString stringWithFormat:@"*.%@",
//                                 STEDocFilenameExtension];
//        [aQuery setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE %@",
//                              NSMetadataItemFSNameKey, filePattern]];
//    }
//    
//    return aQuery;
//}
//
//-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
//{
//    [self filterContentForSearchText:searchString
//                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
//                                      objectAtIndex:[self.searchDisplayController.searchBar
//                                                     selectedScopeButtonIndex]]];
//    
//    return YES;
//}
//-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
//    // Tells the table data source to reload when scope bar selection changes
//    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
//     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
//    // Return YES to cause the search result table view to be reloaded.
//    return YES;
//}
//
//
//- (void)setupAndStartQuery {
//    // Create the query object if it does not exist.
//    if (!_query)
//        _query = [self textDocumentQuery];
//    
//    // Register for the metadata query notifications.
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(processFiles:)
//                                                 name:NSMetadataQueryDidFinishGatheringNotification
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(processFiles:)
//                                                 name:NSMetadataQueryDidUpdateNotification
//                                               object:nil];
//    
//    // Start the query and let it run.
//    [_query startQuery];
//}
//
//- (void)awakeFromNib
//{
//    [super awakeFromNib];
//    if (!documents)
//        documents = [[NSMutableArray alloc] init];
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;
//    [self setupAndStartQuery];
//    [self check1];
//}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Release any cached data, images, etc that aren't in use.
//}
//
//#pragma mark - View lifecycle
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    [self isHeadsetPluggedIn];
// 
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(didAddNewNote:)
//                                                 name:@"New Note"
//                                               object:nil];
//     self.filteredArray = [NSMutableArray arrayWithCapacity:[documents count]];
//    [[AVAudioSession sharedInstance] setDelegate: self];
//    [self isHeadsetPluggedIn];
//    NSError *setCategoryError = nil;
//    [[AVAudioSession sharedInstance] setActive:YES
//                                         error:nil];
//    
//    
//    
//    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//    // Registers the audio route change listener callback function
//    AudioSessionAddPropertyListener (kAudioSessionProperty_AudioRouteChange, audioRouteChangeListenerCallback2, (__bridge void *)(self));
//	// Do any additional setup after loading the view, typically from a nib.
//}
//
//void audioRouteChangeListenerCallback2 (void *inUserData, AudioSessionPropertyID inPropertyID, UInt32 inPropertyValueSize, const void *inPropertyValue ) {
//    
//    
//    // ensure that this callback was invoked for a route change
//    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
//    
//    
//    {
//        
//        // Determines the reason for the route change, to ensure that it is not
//        //      because of a category change.
//        CFDictionaryRef routeChangeDictionary = (CFDictionaryRef)inPropertyValue;
//        
//        CFNumberRef routeChangeReasonRef = (CFNumberRef)CFDictionaryGetValue (routeChangeDictionary, CFSTR (kAudioSession_AudioRouteChangeKey_Reason) );
//        SInt32 routeChangeReason;
//        CFNumberGetValue (routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
//        
//        if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
//            NSLog(@"PLUG OUT ");
////            [(__bridge id)inUserData performSelectorOnMainThread:@selector(check1)withObject:nil waitUntilDone:NO];
//             soundk=FALSE;
//            // [(__bridge id)inUserData performSelectorOnMainThread:@selector(countTotalFrames)withObject:nil waitUntilDone:NO];
//            // [(__bridge id)inUserData performSelectorOnMainThread:@selector(clear)withObject:nil waitUntilDone:NO];
//            
//            
//            // [[UIScreen mainScreen] setBrightness:1.0];
//            //[(__bridge id)inUserData performSelectorOnMainThread:@selector(countTotalFrames)withObject:nil waitUntilDone:NO];
//            //Handle Headset Unplugged
//        } else if (routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable) {
//            
//            NSLog(@"PLUG IN ");
//            [(__bridge id)inUserData performSelectorOnMainThread:@selector(check1)withObject:nil waitUntilDone:YES];
//            //sound=TRUE;
//            //                        [(__bridge id)inUserData performSelectorOnMainThread:@selector(check1)withObject:nil waitUntilDone:NO];
//            //[(__bridge id)inUserData performSelectorOnMainThread:@selector(initKeypro)withObject:nil waitUntilDone:NO];
//            //           if([test isEqual:@"30303030303030303030303030303046"])
//            //            {
//            //            [audioPlayer stop];
//            //            }
//            //[(__bridge id)inUserData performSelectorOnMainThread:@selector(countTotalFrames)withObject:nil waitUntilDone:NO];
//            //the best cdm depends on what you are lokking for to do
//            
//            
//            
//            
//            //  [(id) performSelectorOnMainThread:@selector(countTotalFrames)withObject:nil waitUntilDone:NO];
//            
//            // [(__bridge id)inUserData performSelectorOnMainThread:@selector(countTotalFrames)withObject:nil waitUntilDone:NO];
//            //            {
//            //                if((test=@"a"))
//            
//            //                {
//            //
//            //                    [[UIScreen mainScreen] setBrightness:0.5];
//            //
//            //                }
//            //            }
//            //
//            //Handle Headset plugged in
//        }
//        
//        // Do any additional setup after loading the view, typically from a nib.
//    }
//}
//
//
//-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
//    // Update the filtered array based on the search text and scope.
//    // Remove all objects from the filtered search array
//    [self.filteredArray removeAllObjects];
//    // Filter the array using NSPredicate
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.fileURL contains[c] %@",searchText];
//    filteredArray = [NSMutableArray arrayWithArray:[documents filteredArrayUsingPredicate:predicate]];
//}
//- (void)viewDidUnload
//{
//    addButton = nil;
//    [super viewDidUnload];
//    // Release any retained subviews of the main view.
//    // e.g. self.myOutlet = nil;
//}
//
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//}
//
//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//	[super viewWillDisappear:animated];
//}
//
//- (void)viewDidDisappear:(BOOL)animated
//{
//	[super viewDidDisappear:animated];
//}
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    // Return YES for supported orientations
//    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
//}
//
//- (NSString*)newUntitledDocumentName {
//    NSInteger docCount = 0;     // Start with 1 and go from there.
//    NSString* newDocName = nil;
//    
//    // At this point, the document list should be up-to-date.
//    BOOL done = NO;
//    while (!done) {
//        if (docCount==0)
//        {
//        newDocName = [NSString stringWithFormat:@"%@.%@",
//                      docName,STEDocFilenameExtension];
//        }
//        else
//        {
//            newDocName = [NSString stringWithFormat:@"%@ %d.%@",
//                          docName,docCount, STEDocFilenameExtension];
//        }
//        
//        // Look for an existing document with the same name. If one is
//        // found, increment the docCount value and try again.
//        BOOL nameExists = NO;
//        for (NSURL* aURL in documents) {
//            if ([[aURL lastPathComponent] isEqualToString:newDocName]) {
//                docCount++;
//                nameExists = YES;
//                break;
//            }
//        }
//        
//        // If the name wasn't found, exit the loop.
//        if (!nameExists)
//            done = YES;
//    }
//    return newDocName;
//}
//- (void)didAddNewNote:(NSNotification *)notification
//{
//    
//    NSDictionary *userInfo = [notification userInfo];
//    docName = [userInfo valueForKey:@"Note"];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        // Create the new URL object on a background queue.
//        NSFileManager *fm = [NSFileManager defaultManager];
//        NSURL *newDocumentURL = [fm URLForUbiquityContainerIdentifier:nil];
//        
//        newDocumentURL = [newDocumentURL
//                          URLByAppendingPathComponent:STEDocumentsDirectoryName
//                          isDirectory:YES];
//        newDocumentURL = [newDocumentURL
//                          URLByAppendingPathComponent:[self newUntitledDocumentName]];
//        
//        // Perform the remaining tasks on the main queue.
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // Update the data structures and table.
//            [documents addObject:newDocumentURL];
//            
//            // Update the table.
//            NSIndexPath* newCellIndexPath =
//            [NSIndexPath indexPathForRow:([documents count] - 1) inSection:0];
//            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newCellIndexPath]
//                                  withRowAnimation:UITableViewRowAnimationAutomatic];
//            
//            [self.tableView selectRowAtIndexPath:newCellIndexPath
//                                        animated:YES
//                                  scrollPosition:UITableViewScrollPositionMiddle];
//            
//            // Segue to the detail view controller to begin editing.
////            UITableViewCell* selectedCell = [self.tableView
////                                             cellForRowAtIndexPath:newCellIndexPath];
////            [self performSegueWithIdentifier:DisplayDetailSegue sender:selectedCell];
//            
//            // Reenable the Add button.
//            self.addButton.enabled = YES;
//        });
//    });
//
//}
//- (IBAction)addDocument:(id)sender {
//    // Disable the Add button while creating the document.
//    //self.addButton.enabled = NO;
//    
//    AddNoteViewController *ViewController = [[AddNoteViewController alloc] initWithNibName:@"AddNoteViewController" bundle:nil];
//    [self.navigationController pushViewController:ViewController animated:YES];
//   /*
//    */
//    }
//
//- (NSInteger)tableView:(UITableView *)tableView
// numberOfRowsInSection:(NSInteger)section {
//    
//    
//    if (tableView == self.searchDisplayController.searchResultsTableView) {
//        return [filteredArray count];
//        
//    } else {
//        return [documents count];
//    }
//}
//
//- (UITableViewCell*)tableView:(UITableView *)tableView
//        cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:DocumentEntryCell];
//    if (!newCell)
//        newCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
//                                         reuseIdentifier:DocumentEntryCell];
//    
//    if (!newCell)
//        return nil;
//    NSURL *fileURL=nil;
//    // Get the doc at the specified row.
//    //Recipe *recipe = nil;
//    if (tableView == self.searchDisplayController.searchResultsTableView) {
//         fileURL = [filteredArray objectAtIndex:indexPath.row];
//    } else {
//         fileURL = [documents objectAtIndex:[indexPath row]];;
//    }
//
//    
//    //NSURL *fileURL = [documents objectAtIndex:[indexPath row]];
//    
//    // Configure the cell.
//    newCell.textLabel.text = [[fileURL lastPathComponent] stringByDeletingPathExtension];
//    return newCell;
//}
// 
//- (void)tableView:(UITableView *)tableView
//commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
//forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        NSURL *fileURL = [documents objectAtIndex:[indexPath row]];
//        
//        // Don't use file coordinators on the app's main queue.
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            NSFileCoordinator *fc = [[NSFileCoordinator alloc]
//                                     initWithFilePresenter:nil];
//            [fc coordinateWritingItemAtURL:fileURL
//                                   options:NSFileCoordinatorWritingForDeleting
//                                     error:nil
//                                byAccessor:^(NSURL *newURL) {
//                                    NSFileManager *fm = [[NSFileManager alloc] init];
//                                    [fm removeItemAtURL:newURL error:nil];
//                                }];
//        });
//        
//        // Remove the URL from the documents array.
//        [documents removeObjectAtIndex:[indexPath row]];
//        
//        // Update the table UI. This must happen after
//        // updating the documents array.
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
//                         withRowAnimation:UITableViewRowAnimationAutomatic];
//    }
//}
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if (![segue.identifier isEqualToString:DisplayDetailSegue])
//        return;
//    
//    // Get the detail view controller.
//    STEDetailViewController* destVC = (STEDetailViewController*)segue.destinationViewController;
//    
//    // Find the correct dictionary from the documents array.
//    NSIndexPath *cellPath = [self.tableView indexPathForSelectedRow];
//    int a=cellPath.row;
//    UITableViewCell *theCell = [self.tableView cellForRowAtIndexPath:cellPath];
//    NSURL *theURL = [documents objectAtIndex:[cellPath row]];
//    
//    // Assign the URL to the detail view controller and
//    // set the title of the view controller to the doc name.
//    destVC.detailItem = theURL;
//    NSLog(@"the details are %@",theURL);
//    destVC.navigationItem.title = theCell.textLabel.text;
//    destVC.num=a;
//    destVC.sound=soundk;
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//- (void) initAudioPlayer {
//    if(!mSmc361Device)
//        mSmc361Device = [[Smc361Device alloc] init];
//    mSmc361Device.delegate = self;
//}
//
//
//- (NSString *) hexDataToString:(UInt8 *)data
//                        Length:(int)len
//{
//    NSString *tmp = @"";
//    NSString *str = @"";
//    for(int i = 0; i < len; ++i)
//    {
//        tmp = [NSString stringWithFormat:@"%02X",data[i]];
//        str = [str stringByAppendingString:tmp];
//    }
//    return str;
//}
//
//
//
//- (void) receivedMessage: (SInt32)type
//                  Result: (Boolean)result
//                    Data: (void *)data;
//{
//    NSLog(@" CHECK2");
//    NSString *msg = nil;
//    
//    switch(type)
//    {
//        case MESSAGE_READ_DATA:
//            if (result == TRUE)
//            {
//                MSG_INFORM_DATA *infrom_data = data;
//                
//                NSString *strData = [self hexDataToString: infrom_data->data Length: 5];
//                keyid = [[NSString alloc] initWithFormat:@"Data : %@",strData];
//                msg = [[NSString alloc] initWithFormat: @"%@",keyid];
//                NSLog(@"%@",msg);
//                
//                    soundk=TRUE;
//                    
//                
//                
//                
//                //dataLabel. text = strDataLabel;
//            }
//            else
//            {
//                msg = [[NSString alloc] initWithFormat: @"Read Data Error!!!"];
//            }
//            
//            break;
//            
//        default:
//            break;
//            
//            
//    }
//    //    UIAlertView *alert = [[UIAlertView alloc]
//    //                          initWithTitle:@"Information"
//    //                          message:msg
//    //                          delegate:self
//    //                          cancelButtonTitle:@"Done"
//    //                          otherButtonTitles:nil];
//    //    [alert show];
//    
//    //[self setAllButtonState: TRUE];
//}
//
//-(void)check1
//{
//    NSLog(@" CHECK");
//    [self initAudioPlayer];
//    
//    [mSmc361Device readData];
//}
//
//
//
//
///*
// // Override to support conditional editing of the table view.
// - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
// {
// // Return NO if you do not want the specified item to be editable.
// return YES;
// }
// */
//
///*
// // Override to support editing the table view.
// - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
// {
// if (editingStyle == UITableViewCellEditingStyleDelete) {
// // Delete the row from the data source.
// [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
// } else if (editingStyle == UITableViewCellEditingStyleInsert) {
// // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
// }
// }
// */
//
///*
// // Override to support rearranging the table view.
// - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
// {
// }
// */
//
///*
// // Override to support conditional rearranging of the table view.
// - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
// {
// // Return NO if you do not want the item to be re-orderable.
// return YES;
// }
// */

@end
