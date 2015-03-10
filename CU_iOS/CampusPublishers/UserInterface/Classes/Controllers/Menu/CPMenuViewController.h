//
//  CPMasterViewController.h
//  CampusPublishers
//
//  Created by V2Solutions on 29/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPConnectionManager.h"
#import "CPFooterView.h"
#import "ZBarSDK.h"
//#import "GADBannerView.h"

#import <GoogleMobileAds/GADBannerView.h>

#import "GAITrackedViewController.h"



@class CPContent;
@class CPMenu;
@class CPPageViewController;
@class CPDataManger;
@class CPAddBannerView;
#import "CpTourGuideIPhone.h"
#import <MediaPlayer/MediaPlayer.h>
@interface CPMenuViewController : GAITrackedViewController < CPConnectionDelegate, ADBannerViewDelegate, UITableViewDataSource, UITableViewDelegate,CPFooterViewDelegate,UIImagePickerControllerDelegate,ZBarReaderDelegate,GADBannerViewDelegate>
{
    NSMutableArray *_datasource;
    GADBannerView *adView;
    CPFooterView *_footerView;
    UITableView *_tableViewMenu;
    BOOL isMediaPlayer;
    
@private
    CPDataManger *dManager;
    CPAddBannerView *addBaner;
    CPContent *qrContent;
    
    NSIndexPath *selectedIndexPath;
    CpTourGuideIPhone *pageViewController ;
    
    BOOL isRotated;
    BOOL isAddOPen;
    GADBannerView *gADBannerView;
    UIView *addView;
}

@property (nonatomic) BOOL isRotated;
@property (nonatomic, strong) NSMutableArray *datasource;
@property (nonatomic, strong) UITableView *tableViewMenu;
@property (nonatomic, strong) CPFooterView *footerView;

@end
