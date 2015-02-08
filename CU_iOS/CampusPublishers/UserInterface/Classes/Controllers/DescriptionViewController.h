//
//  DescriptionViewController.h
//  CampusPublishers
//
//  Created by v2solutions on 03/01/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPDataManger.h"
#import "CPFooterView.h"
#import "LoadingView.h"
#import "RootViewController.h"

#import "CustomMapItem.h"
#import "CPFooterView.h"
#import "CPDataManger.h"
#import "ZBarReaderViewController.h"
#import "CPConnectionManager.h"
#import "CPRequest.h"
#import "CPQRCodeViewController.h"
#import "CPAddBannerView.h"
#import "CPConnectionManager.h"
#import "CPRequest.h"
#import "CPContent.h"
#import <MediaPlayer/MediaPlayer.h>
#import "GADBannerView.h"
@class Place;

@interface DescriptionViewController : UIViewController<CPFooterViewDelegate,ZBarReaderDelegate,CPConnectionDelegate,ADBannerViewDelegate,GADBannerViewDelegate>{
    UIImageView *imageView;
	UITextView *textView;
	BOOL isLandScape;
	UIActivityIndicatorView *_activityView;
    Place *place;
    CPFooterView *_footerView;
    CPDataManger* dtManager ;
    
    BOOL isQRCodeScan;
    BOOL isInteractionEnabled;
    BOOL isPlay;
    UIScrollView *scrollView;
CPContent *qrContent;
    UIButton *_videoIcon;
    BOOL isPotrait;
    UIButton* _videoIcon1;
    UIWebView *_webView;
    BOOL isThumb;
    
    NSData *image;
    BOOL isSubView;
    GADBannerView *gADBannerView;
    UIView *bgBannerView;
}
@property (nonatomic,assign)BOOL isLandScape;
@property(nonatomic,strong)    NSMutableDictionary *customImagesDict;
@property(nonatomic,strong)NSMutableArray *pathObjectsArray;
@property(nonatomic,strong)Place *place;
@property(nonatomic,assign)BOOL isImageUrl;
@property(nonatomic,assign)BOOL isVideoUrl;
@property(nonatomic,strong) UIImageView *imageView;




-(void)playVideo:(id)sender;



-(void)updateUI;
    -(void)createUI;
- (void)animateFooterView:(BOOL)animated;
-(void)viewWillDisappear:(BOOL)animated;
- (void)footerView:(CPFooterView*)footerView didClickItemWithType:(CPFooterItemType)type;
- (void)bannerViewDidLoadAd:(ADBannerView *)banner;
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error;
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave;

- (void)getImageRequest;


@end
