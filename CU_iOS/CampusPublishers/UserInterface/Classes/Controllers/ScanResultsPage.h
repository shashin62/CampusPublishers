//
//  ScanResultsPage.h
//  CampusPublishers
//
//  Created by v2solutions on 05/01/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CPContent;
#import "CPFooterView.h"
#import "ZBarReaderViewController.h"
#import "CPAddBannerView.h"
#import "CPDataManger.h"
#import <GoogleMobileAds/GADBannerView.h>
@class CpTourGuideIPhone;

@class DescriptionViewController;
@class RootViewController;

@interface ScanResultsPage : UIViewController<UIWebViewDelegate,CPFooterViewDelegate,ZBarReaderDelegate,ADBannerViewDelegate,GADBannerViewDelegate>
{
UIWebView *_webView;
    
    CPFooterView *_footerView;
    CPDataManger* dtManager ;
   // BOOL isSelfView;
    BOOL isPotrait;
    GADBannerView *gADBannerView;
    UIView *bgBannerView;

}
@property(nonatomic,strong)  CPContent *qrContent;
@property(nonatomic,strong)DescriptionViewController * descriptionViewController;
@property(nonatomic,strong)RootViewController *rootViewController;
@property(nonatomic,strong)CpTourGuideIPhone * cpTourGuideIPhone;



//- (void)animateFooterView:(BOOL)animated;
-(void)upDateUI;
-(void)loadRequest;
-(void)upDateUIForScanner;

@end
