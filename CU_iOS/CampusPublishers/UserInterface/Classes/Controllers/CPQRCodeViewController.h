//
//  CPQRCodeViewController.h
//  CampusPublishers
//
//  Created by V2Solutions on 15/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"
#import "CPFooterView.h"

@interface CPQRCodeViewController : UIViewController <UIImagePickerControllerDelegate,ZBarReaderDelegate>
{
    CPFooterItemType footerType;
    UITextView *txtView;
    UIButton *scanButton;
}
@property (nonatomic, assign)CPFooterItemType footerType;
@end
