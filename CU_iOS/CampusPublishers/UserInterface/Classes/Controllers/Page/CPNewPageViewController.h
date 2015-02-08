//
//  CPNewPageViewController.h
//  CampusPublishers
//
//  Created by V2Solutions-05 on 17/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "CPConnectionManager.h"
#import "ZBarSDK.h"
#import "CPFooterView.h"
#import "GAITrackedViewController.h"
#import "GADBannerView.h"

@class CPAddBannerView;
@class CPContent;
@class RootViewController;
@class CustomImageView;

@interface CPNewPageViewController : GAITrackedViewController < UIWebViewDelegate,
                                                        UITableViewDelegate,
                                                        ADBannerViewDelegate,
                                                        CPConnectionDelegate, 
                                                        CPFooterViewDelegate,
                                                        ZBarReaderDelegate ,UIScrollViewDelegate,GADBannerViewDelegate>
{
@private
    UITableView *_tblView;
    CustomImageView *_imgView;
    UIWebView   *_webView;
    UIActivityIndicatorView *_activityView;
    
    RootViewController * mapViewController;
    CPFooterView *_footerView;
    CPContent   *qrContent;
    BOOL isAddOPen;
    GADBannerView *gADBannerView;

}

@property(nonatomic, retain) CPContent *qrContent;
- (void)centerScrollViewContents;

@end
