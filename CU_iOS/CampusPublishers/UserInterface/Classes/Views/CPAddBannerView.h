//
//  CPAddBannerView.h
//  CampusPublishers
//
//  Created by v2team on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "GADBannerView.h"
@interface CPAddBannerView : NSObject
{
    ADBannerView *_adBannerView;
    
}

@property (nonatomic, strong) ADBannerView *adBannerView;
@property(strong,nonatomic)GADBannerView *adBanner;

+ (CPAddBannerView*)sharedAddBannerView;
+(GADBannerView*)sharedGADBannerView;
@end
