//
//  AddNoteViewController.m
//  SimpleTextEditor
//
//  Created by Jason Tsai on 7/30/14.
//  Copyright (c) 2014 nick. All rights reserved.
//

#import "AddNoteViewController.h"
#import "STEMasterViewController.h"
#import "STEDetailViewController.h"
@interface AddNoteViewController ()

@end

@implementation AddNoteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bg.png"] forBarMetrics:UIBarMetricsDefault];
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(initializeiCloudAccess1)];
    
    self.navigationItem.rightBarButtonItem = saveItem;
    self.navigationItem.title=@"Add Note";
    // Do any additional setup after loading the view from its nib.
}

-(void)loadData
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"New Note" object:self userInfo:[NSDictionary dictionaryWithObject:self.noteName.text forKey:@"Note"]];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Information"
                          message:@"New Note Created"
                          delegate:self
                          cancelButtonTitle:@"Done"
                          otherButtonTitles:nil];
    [alert show];
    

}

- (void)initializeiCloudAccess1 {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             0), ^{
        if ([[NSFileManager defaultManager]
             URLForUbiquityContainerIdentifier:nil] != nil)
            NSLog(@"iCloud is available\n");
        else
            NSLog(@"This tutorial requires iCloud, but it is not available.\n");
        
    });
    
    id token = [[NSFileManager defaultManager] ubiquityIdentityToken];
    if (token == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Information"
                              message:@"Please Log in to your iCloud account or create one"
                              delegate:self
                              cancelButtonTitle:@"Done"
                              otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"New Note" object:self userInfo:[NSDictionary dictionaryWithObject:self.noteName.text forKey:@"Note"]];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Information"
                              message:@"New Note Created"
                              delegate:self
                              cancelButtonTitle:@"Done"
                              otherButtonTitles:nil];
        [alert show];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)save:(id)sender {
}

- (IBAction)cancel:(id)sender {
}
@end
