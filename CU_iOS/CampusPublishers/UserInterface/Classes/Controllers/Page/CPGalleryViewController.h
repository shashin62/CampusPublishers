//
//  CPGalleryViewController.h
//  CampusPublishers
//
//  Created by V2Solutions on 04/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPHeaderTitleView.h"
#import "CPSwipeView.h"
#import "CPConnectionManager.h"
#import "CPFooterView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AFOpenFlowView.h"
#import <iAd/iAd.h>

#import "ZBarSDK.h"
#import <GoogleMobileAds/GADBannerView.h>
@class CMPPage;
@class CPContent;
@class CPDataManger;
@class CMPImage;
@class CPAddBannerView;
@interface CPGalleryViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,CPHeaderTitleViewDelegate,CPFooterViewDelegate,/*AFOpenFlowViewDelegate,AFOpenFlowViewDataSource,*/ADBannerViewDelegate,CPConnectionDelegate,CPFooterViewDelegate,ZBarReaderDelegate,GADBannerViewDelegate>
{
    CPHeaderTitleView *headerTitleView;
    UIWebView *webView;
    CPSwipeView *swipeView;
    CPFooterItemType footerType;
    CPDataManger *dtManager;
    NSInteger currentIndex;
    UIImage *imgPlaceholder;
    NSOperationQueue *loadImagesOperationQueue;
    AFOpenFlowView *openFlow;
    BOOL bannerIsVisible;
    CPFooterView *_footerView;
    NSMutableArray *_dataGallary;
    UIButton *videoIcon;
    GADBannerView *gADBannerView;
    
    UIView *bgBannerView;


}

@property (nonatomic , assign) CPFooterItemType footerType;
@property (nonatomic,assign) BOOL bannerIsVisible;
@property (nonatomic, strong) NSMutableArray *dataGallary;
@end
