//
//  CPAddBannerView.m
//  CampusPublishers
//
//  Created by v2team on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CPAddBannerView.h"
#import "GADBannerView.h"
#import "CPConstants.h"
#import "CPConfiguration.h"
#import "CPAdmob.h"

static CPAddBannerView *sharedAddBannerView = nil;

@implementation CPAddBannerView

@synthesize adBannerView= _adBannerView;
@synthesize adBanner;
- (id)init
{
    self = [super init];
    if(self)
    {        
        // Initialization code
        
        
    //    CGPoint origin = CGPointMake(0.0,self.view.frame.size.height -                                     CGSizeFromGADAdSize(kGADAdSizeBanner).height);
        
        
        //kGADAdSizeSmartBannerPortrait
        //kGADAdSizeBanner
        // Use predefined GADAdSize constants to define the GADBannerView.
        adBanner = [[GADBannerView alloc] init];
        ;
        CPAdmob *admob = [[CPAdmob alloc] init];
        
        [adBanner setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        // Note: Edit SampleConstants.h to provide a definition for kSampleAdUnitID
        // before compiling.
        
        if ([[UIDevice currentDevice ] userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
            adBanner.adUnitID = admob.admobid;

        }else{
            adBanner.adUnitID = admob.admobid ;

        }

       // adBanner.delegate = self;
        adBanner.backgroundColor=[UIColor redColor];
        
        
        // ***********************************************************
        
        // ***********************************************************

        ADBannerView *bView = [[ADBannerView alloc] initWithFrame:CGRectZero];
        CGRect bannerFrame = self.adBannerView.frame;
        self.adBannerView.frame = bannerFrame;
        
        self.adBannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil];
        
        if([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait)
        {
            self.adBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
        }
        else
        {
            self.adBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
        }
        self.adBannerView = bView;
        
    }
    
    return self;
}

#pragma -------- Method to implement singlton class

+ (CPAddBannerView*)sharedAddBannerView
{
	@synchronized(self) 
	{
        if(sharedAddBannerView == nil) 
		{
            [[self alloc] init]; // assignment not done here
        }
    }
	
    return sharedAddBannerView;
}

+(GADBannerView*)sharedGADBannerView{
        // Initialization code
        // Use predefined GADAdSize constants to define the GADBannerView.
        GADBannerView *adBanner = [[GADBannerView alloc] init];
        CPAdmob *admob = [[CPAdmob alloc] init];
        
        [adBanner setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        // Note: Edit SampleConstants.h to provide a definition for kSampleAdUnitID
        // before compiling.
        
        if ([[UIDevice currentDevice ] userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
            adBanner.adUnitID = admob.admobid ; // for iphone
            
        }else{
            adBanner.adUnitID = admob.admobid ; // for ipad
            
        }
        
        adBanner.backgroundColor=[UIColor clearColor];
        return adBanner;
}


+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) 
	{
        if(sharedAddBannerView == nil) 
		{
            sharedAddBannerView = [super allocWithZone:zone];
            return sharedAddBannerView;  // assignment and return on first allocation
        }
    }
	
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


#pragma ---------- end


@end
