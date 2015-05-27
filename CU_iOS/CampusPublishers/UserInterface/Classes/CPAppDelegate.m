
//  CPAppDelegate.m
//  CampusPublishers
//
//  Created by V2Solutions on 29/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CPAppDelegate.h"
#import "CPMenuViewController.h"
#import "CPUtility.h"
#import "JSON.h"
#import "CPDataManger.h"
#import "CPSetUpViewController.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#include <netinet/in.h>
#import "CPMenu.h"
#import "CPPageViewController.h"
#import "CPAnalytics.h"

@implementation CPAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize splitViewController = _splitViewController;
@synthesize reachability = netReach;
@synthesize reachableWiFi;
@synthesize isSplitViewConfigured;
@synthesize isRootViewController;
@synthesize isPlay;
@synthesize cpMenuViewController;
@synthesize cpTourGuideIPhone;
@synthesize masterViewController;
@synthesize isSetUpViewClosed;
@synthesize masterPopoverController;
@synthesize isLandScape,isMediaPlayer;



-(void)movieDidExitFullScreen:(id)sender{
    
    UIDeviceOrientation orientation=[[UIDevice currentDevice ] orientation];
    if (orientation==UIDeviceOrientationPortrait ||orientation==UIDeviceOrientationPortraitUpsideDown) {
        
    }else{
        isMediaPlayer=YES;
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    NSLog(@"Screen Width -%f & Height -%f ",screenWidth,screenHeight);
       
    netReach = [[NetReachability alloc] initWithHostName:@"www.google.com"];
	netReach.delegate = self;
    self.reachableWiFi = [netReach startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieDidExitFullScreen:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
   // [self.window setAutoresizesSubviews:YES];
    //self.window.autoresizingMask=UIViewAutoresizingFlexibleHeight;
    //NSLog(@"%@",NSStringFromCGRect([UIScreen mainScreen].bounds));

    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        CPMenuViewController *menuViewController = [[CPMenuViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:menuViewController]; //procs
        self.window.rootViewController = self.navigationController;
        menuViewController.datasource = [CPDataManger sharedDataManager].datasource;
    }
    else
    {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"APP_LAUNCH"];

        //CPMenuViewController *masterViewController = [[CPMenuViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
        masterViewController = [[CPMenuViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
        
        masterViewController.datasource = [[CPDataManger sharedDataManager] datasource];
        UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
        cpMenuViewController=masterNavigationController;
        
     CPPageViewController*   pageViewController = [[CPPageViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
        UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:pageViewController];
        
        self.splitViewController = [[UISplitViewController alloc] init];
        self.splitViewController.delegate = pageViewController;
        self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];
        if([self.splitViewController respondsToSelector:@selector(presentsWithGesture)] == YES)
        {
            // self.splitViewController.presentsWithGesture = NO;
        }
        
        
        self.window.rootViewController = self.splitViewController;
        self.isSplitViewConfigured = YES;
        
        NSUserDefaults *sud = [NSUserDefaults standardUserDefaults];
        [sud setValue:[NSNumber numberWithBool:NO] 
               forKey:@"isRotated"];
        [sud synchronize];
    }
    
    [self.window makeKeyAndVisible];
    self.window.backgroundColor=[UIColor whiteColor];
    //NSLog(@"%@",NSStringFromCGRect([UIScreen mainScreen].bounds));
    
    CPAnalytics *analytics = [[CPAnalytics alloc] init];
    
    // Below is the code to intialize Google Analytics
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
    [GAI sharedInstance].dispatchInterval = 120;
    // TODO: Change below to tracker id as detirmined by the data manager.
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:analytics.analyticsid];
    // End Google Analytics code.
    
    CPSetUpViewController *controller = [[CPSetUpViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller]; //procs
    navController.navigationBarHidden = YES;
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
//    [self.window.rootViewController presentModalViewController:navController animated:NO];
    [self.window.rootViewController presentViewController:navController animated:NO completion:nil];
    isSetUpViewClosed=NO;
    return YES;
}

-(void)menuButtonAction{
    CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
    float version=[[UIDevice currentDevice].systemVersion floatValue];
        if (version>=6.0) {
            if (_splitViewController!=nil) {
            [appDelegate.splitViewController performSelector:@selector(toggleMasterVisible:)];
            appDelegate.isSetUpViewClosed=NO;
        }
    }
    else{
        if (cpMenuViewController!=nil) {
//            UIPopoverController*  masterPopoverController=[[UIPopoverController alloc]initWithContentViewController:cpMenuViewController];
            
            masterPopoverController=[[UIPopoverController alloc]initWithContentViewController:cpMenuViewController];
          
            [masterPopoverController presentPopoverFromRect:CGRectMake(100,100, 1, 1) inView:self.window.rootViewController.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }
    }
    
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
}

- (void) reachabilityDidUpdate:(NetReachability*)reachability reachable:(BOOL)reachable usingCell:(BOOL)usingCell;
{
    self.reachableWiFi = usingCell;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkFailNotification" object:self];
    
    if(reachability.isReachable == NO && reachability.isUsingCell == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                        message:NSLocalizedString(@"NetworkCheck","")
													   delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
		[alert show];	
    }
}



-(void)upDateViewFramewithPicker:(UIImagePickerController*) picker toReplaceView:(UIView*)view{
    // view.frame=CGRectMake(0, 0, picker.interfaceOrientation>2?704:768, picker.interfaceOrientation>2?704:960);
    UIDevice *device=[UIDevice currentDevice];
    if (device.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        CGRect rect=CGRectMake(0, 0,  picker.interfaceOrientation>2?(self.window.frame.size.height-320):self.window.frame.size.width,picker.interfaceOrientation>2?(self.window.frame.size.width-64):(self.window.frame.size.height-64));
        view.frame=rect;
        //NSLog(@"rect: %@",NSStringFromCGRect(rect));
        
    }
    
}

@end
