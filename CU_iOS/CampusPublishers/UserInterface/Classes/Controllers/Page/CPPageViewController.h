//
//  CPPageViewController.h
//  CampusPublishers
//
//  Created by V2Solutions on 30/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPFooterView.h"
#import "CPConnectionManager.h"
#import <iAd/iAd.h>
#import "ZBarSDK.h"
#import "LoadingView.h"
#import "GADBannerView.h"
#import "GAITrackedViewController.h"
@class CMPPage;
@class CPContent;
@class CPDataManger;
@class CPAddBannerView;
@class CPMenu;

@class RootViewController;
@class CpTourGuideIPhone;
@class MyView;
@class CustomImageView;

@interface CPPageViewController : GAITrackedViewController <CPFooterViewDelegate, CPConnectionDelegate, UIWebViewDelegate,ADBannerViewDelegate,UIImagePickerControllerDelegate,ZBarReaderDelegate, UISplitViewControllerDelegate,UIScrollViewDelegate,GADBannerViewDelegate>
{
    CGSize size;
    UIWebView *_webView;
    //  MyView *_imgView;
    CustomImageView *_imgView;
    
    UIImage *imgPlaceholder;
    CPDataManger *dtManager;
    UIActivityIndicatorView *activityView;
    
    CPFooterView *_footerView;
    CPFooterItemType fType;
    LoadingView *loadView;
    
    UIPopoverController *masterPopoverController;
    BOOL isIPadUIConfigured;
    BOOL isRootViewController;
    RootViewController * mapViewController;
    
    CpTourGuideIPhone *pageViewController ;
    UIAlertView *errorAlert;
    
    
    BOOL isLandScape;
    
    CGRect normalFrame;
    
    UIImageView * startImageView;
    UIView *startView;
    BOOL isMenuPopUP;
    BOOL isScanner;
    ZBarReaderViewController *zbarReader;
    
    

@private
    CPContent *qrContent;
    UIView *bgBannerView;

}


@property (nonatomic, strong) CPContent *qrContent;
@property (nonatomic) BOOL isIPadUIConfigured;
@property (nonatomic, strong) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) RootViewController * mapViewController;
@property (nonatomic, strong) GADBannerView *gADBannerView;

- (void)centerScrollViewContents;
-(void)menuButtonAction;
- (void)updateAndDisplayPageContent;
- (void)initializeFirstLoad;
-(void)upDateUI;
@end
