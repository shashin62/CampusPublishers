


//
//  CPSetUpViewController.m
//  CampusPublishers
//
//  Created by v2team on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CPSetUpViewController.h"
#import "CPDataManger.h"
#import "JSON.h"
#import "CPNetworkConstant.h"
#import "CPRequest.h"
#import "CPUtility.h"
#import "CPUniversity.h"
#import "CPConfiguration.h"
#import "CPConstants.h"
#import "CPAppDelegate.h"
#import "CPMenuViewController.h"
#import "CPPageViewController.h"

@interface  CPSetUpViewController (Private)

- (void)initializeAllMemberData;

- (void)initializeAllUIElement;

- (void)callServiceConfiguration;
- (void)callServiceMenuList;

@end

@implementation CPSetUpViewController (Private)

- (void)initializeAllMemberData
{
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(networkFailNotification:)
    //                                                 name:@"NetworkFailNotification"
    //                                               object:nil];
    dManager = [CPDataManger sharedDataManager];
    
    //The following was written to give a few extra seconds of "splash screen" to the app
    //and has been removed because it's unnecessary work to update, and violates HIG guidelines on the subject. -Austin
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        UIImage *image = [UIImage imageNamed:@"Default.png"];
        imageViewBackground = [[UIImageView alloc] initWithImage:image];
        imageViewBackground.frame = CGRectMake((super.view.frame.size.width/2) - (image.size.width/2), (super.view.frame.size.height/2) - (image.size.height/2), image.size.width, image.size.height);
        [self.view addSubview:imageViewBackground];
    }
    else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        if(([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait) || ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown))
        {
            UIImage *image = [UIImage imageNamed:@"Default.png"];
            imageViewBackground = [[UIImageView alloc] initWithImage:image];
            imageViewBackground.frame = CGRectMake((super.view.frame.size.width/2) - (image.size.width/2), (super.view.frame.size.height/2) - (image.size.height/2), image.size.width, image.size.height);
            [self.view addSubview:imageViewBackground];
            //Below is code for replacing the UVN logo with a bigger image -Austin
            /*
             UIImage *image = [UIImage imageNamed:@"Default.png"];
             imageViewBackground = [[UIImageView alloc] initWithImage:image];
             CGRect screenBounds = [[UIScreen mainScreen] bounds];
             imageViewBackground.frame = screenBounds;
             [self.view addSubview:imageViewBackground];
             imageViewBackground.contentMode = UIViewContentModeScaleAspectFit;
             */
        }
        else if(([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeRight) || ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft))
        {
            UIImage *image = [UIImage imageNamed:@"Default.png"];
            imageViewBackground = [[UIImageView alloc] initWithImage:image];
            imageViewBackground.frame = CGRectMake((super.view.frame.size.width/2) - (image.size.width/2), (super.view.frame.size.height/2) - (image.size.height/2), image.size.width, image.size.height);
            [self.view addSubview:imageViewBackground];
            //Below is code for replacing the UVN logo with a bigger image -Austin
            /*UIImage *image = [UIImage imageNamed:@"Default.png"];
             imageViewBackground = [[UIImageView alloc] initWithImage:image];
             imageViewBackground.frame = CGRectMake((super.view.frame.size.width/2) - (image.size.width/2), (super.view.frame.size.height/2) - (image.size.height/2), image.size.width, image.size.height);
             [self.view addSubview:imageViewBackground];
             */
        }
        
        imageViewBackground = [[UIImageView alloc] init];
        [self.view addSubview:imageViewBackground];
    }
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect frame = activityView.frame;
    frame.origin.y = (self.view.frame.size.height - activityView.frame.size.height ) / 2;
    frame.origin.x = (self.view.frame.size.width - activityView.frame.size.width ) / 2;
    [activityView setFrame:frame];
    [activityView sizeToFit];
    [self.view addSubview:activityView];
    
}


- (void)initializeAllUIElement
{
    
}



//method for getting Configuration settings as per university
- (void)callServiceConfiguration
{
    //    @autoreleasepool {
    CPConnectionManager *manager = [CPConnectionManager sharedConnectionManager];
    
    //    NSString* plistPath = nil;
    //#if TARGET_CAMPUS
    //    plistPath = [[NSBundle mainBundle] pathForResource:@"CampusPublishers-Config" ofType:@"plist"];
    //#elif TARGET_UMD
    //    plistPath = [[NSBundle mainBundle] pathForResource:@"UMD-Config" ofType:@"plist"];
    //#endif
    //    NSDictionary *dictInfo = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSDictionary *dictInfo = [[CPDataManger sharedDataManager] dictionary];
    
    NSString *strURL = nil;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        strURL = [NSString stringWithFormat:@"%@configs?method=getConfigData&univId=%d&deviceId=%d", SERVER_URL,[[dictInfo objectForKey:@"UniversityID"] intValue] , CPDeviceTypeiPhone];
    }
    else
    {
        strURL = [NSString stringWithFormat:@"%@configs?method=getConfigData&univId=%d&deviceId=%d", SERVER_URL,[[dictInfo objectForKey:@"UniversityID"] intValue] , CPDeviceTypeiPad];
    }
    
    NSURL *urlServer = [NSURL URLWithString:strURL];
    
    CPRequest*request = [[CPRequest alloc] initWithURL:urlServer
                                       withRequestType:CPRequestTypeConfiguration];
    [manager spawnConnectionWithRequest:request delegate:self];
    //    }
}

//method for getting list of Menus
- (void)callServiceMenuList
{
    isMenuData=YES;
    
    @autoreleasepool {
        CPConnectionManager *manager = [CPConnectionManager sharedConnectionManager];
        NSString *strURL = [NSString stringWithFormat:@"%@menus?method=getAllMenus&univId=%d", SERVER_URL, [dManager.configuration.university.id intValue]];
        NSURL *urlServer = [NSURL URLWithString:strURL];
        CPRequest*request = [[CPRequest alloc] initWithURL:urlServer
                                           withRequestType:CPRequestTypeMenuList];
        [manager spawnConnectionWithRequest:request delegate:self];
    }
}

@end


@implementation CPSetUpViewController

#pragma mark - init/dealloc -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkFailNotification:)
                                                 name:@"NetworkFailNotification"
                                               object:nil];
    return self;
}



#pragma mark - Memory Management -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    
}

#pragma mark - View lifecycle
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initializeAllMemberData];
    [self initializeAllUIElement];
    [self upDateUI];
    CPAppDelegate *appDelegate= (CPAppDelegate *)[[UIApplication sharedApplication] delegate];
    if((appDelegate.reachability.reachable == NO) && ([appDelegate isReachableWiFi] == NO))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:NSLocalizedString(@"NetworkCheck","")
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
    
    //    NSDictionary *dictInfo = [[CPDataManger sharedDataManager] dictionary];
    //    if([[dictInfo objectForKey:@"isLiveMode"] boolValue] == NO)
    //    {
    //        [self performSelector:@selector(dismissModalViewControllerAnimated:)
    //                   withObject:nil
    //                   afterDelay:2.0];
    //    }
}

-(void)upDateUI{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        CGRect frame = activityView.frame;
        frame.origin.y = 160.0;
        frame.origin.x = (self.view.frame.size.width - activityView.frame.size.width ) / 2;
        [activityView setFrame:frame];
        [activityView startAnimating];
    }
    else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        CGRect frame = activityView.frame;
        
        imageViewBackground.contentMode = UIViewContentModeCenter;
        UIInterfaceOrientation orientation=[[UIApplication sharedApplication]statusBarOrientation];
        
        if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
            
            UIImage *imaage =[UIImage imageNamed:@"Default-Portrait~ipad.png"];
            [imageViewBackground setImage:imaage];
            [imageViewBackground sizeToFit];
            
            imageViewBackground.frame = CGRectMake(0.0, 0.0, imaage.size.width, imaage.size.height);
            
            frame.origin.y = 350.0;
            
            CGRect rect = activityView.frame;
            rect.origin.x = (self.view.frame.size.width - rect.size.width) / 2;
            rect.origin.y = (self.view.frame.size.height - rect.size.height) / 2;
            activityView.frame = rect;
        }
        else {
            
            UIImage *imaage =[UIImage imageNamed:@"Default-Landscape~ipad.png"];
            [imageViewBackground setImage:imaage];
            [imageViewBackground sizeToFit];
            
            imageViewBackground.frame = CGRectMake(0.0, 0.0, imaage.size.width, imaage.size.height);
            frame.origin.y = 280.0;
            
            CGRect rect = activityView.frame;
            rect.origin.x = (self.view.frame.size.width - rect.size.width) / 2;
            rect.origin.y = (self.view.frame.size.height - rect.size.height) / 2;
            activityView.frame = rect;
        }
        
        frame.origin.x = (self.view.frame.size.width - activityView.frame.size.width ) / 2;
        [activityView startAnimating];
    }
}
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self upDateUI];
}

//override if want to support orientations,other than default portrait orientation
#pragma mark UIInterfaceOrientation -
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        CGRect frame = activityView.frame;
        frame.origin.y = 160.0;
        frame.origin.x = (self.view.frame.size.width - activityView.frame.size.width ) / 2;
        [activityView setFrame:frame];
        [activityView startAnimating];
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        CGRect frame = activityView.frame;
        
        imageViewBackground.contentMode = UIViewContentModeCenter;
        if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            
            UIImage *imaage =[UIImage imageNamed:@"Default-Portrait~ipad.png"];
            [imageViewBackground setImage:imaage];
            [imageViewBackground sizeToFit];
            
            imageViewBackground.frame = CGRectMake(0.0, 0.0, imaage.size.width, imaage.size.height);
            
            frame.origin.y = 350.0;
            
            CGRect rect = activityView.frame;
            rect.origin.x = (self.view.frame.size.width - rect.size.width) / 2;
            rect.origin.y = (self.view.frame.size.height - rect.size.height) / 2;
            activityView.frame = rect;
        }
        else {
            
            UIImage *imaage =[UIImage imageNamed:@"Default-Landscape~ipad.png"];
            [imageViewBackground setImage:imaage];
            [imageViewBackground sizeToFit];
            
            imageViewBackground.frame = CGRectMake(0.0, 0.0, imaage.size.width, imaage.size.height);
            frame.origin.y = 280.0;
            
            CGRect rect = activityView.frame;
            rect.origin.x = (self.view.frame.size.width - rect.size.width) / 2;
            rect.origin.y = (self.view.frame.size.height - rect.size.height) / 2;
            activityView.frame = rect;
        }
        
        frame.origin.x = (self.view.frame.size.width - activityView.frame.size.width ) / 2;
        [activityView startAnimating];
    }
    return YES;
}



#pragma mark - CPConnectionDelegate -
//method to fecth the data from server
- (void)CPConnection:(CPConnection*)CPConnection didReceiveResponse:(id)response
{
    
    NSData *_data = [(NSDictionary*)response valueForKey:@"data"];
    
    NSString *strResponse = [[NSString alloc] initWithBytes:(const void*)[_data bytes]
                                                     length:[_data length]
                                                   encoding:NSASCIIStringEncoding];
    
    // //NSLog(@"%@",strResponse);
    
    // Create SBJSON object to parse JSON
    SBJSON *parser = [[SBJSON alloc] init];
    
    // parse the JSON string into an object - assuming json_string is a NSString of JSON data
    
    NSError *err = nil;
    
    
    NSDictionary *parsedObject = [parser objectWithString:strResponse error:&err];
    
    //  //NSLog(@"%@",parsedObject);
    
    
    
    //show alert if response data is not found
    
    if (parsedObject == nil)
    {
        
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertTitle", @"")
                                                             message:NSLocalizedString(@"NetworkError", @"")
                                                            delegate:nil
                                                   cancelButtonTitle:NSLocalizedString(@"cancelButton", @"")
                                                   otherButtonTitles:nil];
        [errorAlert show];
        
        [activityView stopAnimating];
        [activityView removeFromSuperview];
    }
    else if ([parsedObject objectForKey:@"error"] != nil)
    {
        
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertTitle", @"")
                                                             message:[parsedObject objectForKey:@"error"]
                                                            delegate:nil
                                                   cancelButtonTitle:NSLocalizedString(@"cancelButton", @"")
                                                   otherButtonTitles:nil];
        [errorAlert show];
        
        [activityView stopAnimating];
        [activityView removeFromSuperview];
    }
    else
    {
        CPRequestType _type = CPConnection.request.type;
        
        //method to get response as per the type of request (menu/configuration)
        if (_type == CPRequestTypeMenuList)
        {
            NSArray *newArray = [parsedObject valueForKey:@"menus"];
            [dManager updateDataSource:newArray];
            
            UINavigationController *navigationController = (UINavigationController*)[CPUtility applicationDelegate].splitViewController.viewControllers.lastObject;
            CPPageViewController *detailViewController = (CPPageViewController*)[navigationController.viewControllers objectAtIndex:0];
            if([detailViewController isKindOfClass:[CPPageViewController class]] == YES)
            {
                //   [detailViewController initializeFirstLoad];
            }
            
            [self performSelector:@selector(dismissSetupViewController:)
                       withObject:nil
                       afterDelay:2.0];
        }
        else if (_type == CPRequestTypeConfiguration)
        {
            [dManager configurationData:parsedObject];
            
            CPAppDelegate *appDelegate= (CPAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            //niether network is connected nor wifi is connected,show the alert
            if ((appDelegate.reachability.reachable == NO ) && ([appDelegate isReachableWiFi] == NO))
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"UMD"
                                                                message:NSLocalizedString(@"NetworkCheck", @"")
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                [self callServiceMenuList];
            }
        }
    }
    
}




//show alert if failed with error while fetching response
- (void)CPConnection:(CPConnection*)CPConnection didFailWithError:(NSError*)error
{
    NSString *message = nil;
    if(error.code == 403)
    {
        message = @"The operation could not be completed this time. Please check your network connection and try again.";
    }
    else if(error.code == 202)
    {
        message = @"Data not found!!!";
    }
    else
    {
        message = error.localizedDescription;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"UMD"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    [activityView stopAnimating];
    [activityView removeFromSuperview];
}

- (void) networkFailNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    //CPAppDelegate *appDelegate= (CPAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CPAppDelegate *appDelegate= (CPAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([[notification name] isEqualToString:@"NetworkFailNotification"])
    {
        if ((appDelegate.reachability.reachable == NO ) && ([appDelegate isReachableWiFi] == NO)){
            [activityView stopAnimating];
        }
        else
        {
            if (dManager.configuration == nil)
            {
                [activityView startAnimating];
                [self callServiceConfiguration];
            }
            else
            {
                [self performSelector:@selector(dismissSetupViewController:)
                           withObject:nil
                           afterDelay:2.0];
            }
        }
    }
}

- (void)dismissSetupViewController:(id)sender
{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [[CPUtility applicationDelegate] setIsSplitViewConfigured:NO];
    }
    
    [activityView stopAnimating];
    CPAppDelegate *appDelegate=(CPAppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.isSetUpViewClosed=YES;
//    [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
