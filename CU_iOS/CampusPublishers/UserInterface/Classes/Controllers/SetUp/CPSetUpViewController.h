//
//  CPSetUpViewController.h
//  CampusPublishers
//
// Setting up the initial view with the basic settings
//
//  Created by v2team on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPConnectionManager.h"

@class CPDataManger;

@interface CPSetUpViewController : UIViewController<CPConnectionDelegate>
{
    CPDataManger *dManager;
    UIActivityIndicatorView *activityView;
    UIImageView *imageViewBackground;
    
    BOOL isMenuData;
}
@end
