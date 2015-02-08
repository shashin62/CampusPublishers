//
//  CPAppDelegate.h
//  CampusPublishers
//
//  Created by V2Solutions on 29/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetReachability.h"
#import "CpTourGuideIPhone.h"
#import "CPMenuViewController.h"
#import "CPPageViewController.h"
@interface CPAppDelegate : UIResponder <UIApplicationDelegate,NetReachabilityDelegate>
{
    NetReachability *netReach;
	BOOL reachableWiFi;
    BOOL isSplitViewConfigured; 
}

@property(nonatomic) BOOL isSplitViewConfigured;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) UISplitViewController *splitViewController;
@property (nonatomic, readonly) NetReachability *reachability;
@property(nonatomic, getter=isReachableWiFi) BOOL reachableWiFi;
@property (nonatomic) BOOL isRootViewController;
@property (nonatomic) BOOL isPlay;
@property (strong,nonatomic)UINavigationController *cpMenuViewController;
@property (strong,nonatomic) CPMenuViewController *masterViewController;
@property(strong,nonatomic)CpTourGuideIPhone *cpTourGuideIPhone;
@property(nonatomic) BOOL isSetUpViewClosed;
@property(nonatomic) BOOL isLandScape;
@property(nonatomic,assign)BOOL isMediaPlayer;

@property (nonatomic, strong) UIPopoverController *masterPopoverController;
-(void)menuButtonAction;
-(void)upDateViewFramewithPicker:(UIImagePickerController*) picker toReplaceView:(UIView*)view;

@end
