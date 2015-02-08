//
//  CPFooterView.h
//  CampusPublishers
//
// Custom view shows the footer bar,depending upon page contents

//  Created by V2Solutions on 30/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CPConstants.h"

@class CPFooterView;

@protocol CPFooterViewDelegate <NSObject>

@optional
- (void)footerView:(CPFooterView*)footerView didClickItemWithType:(CPFooterItemType)type;
@end

@interface CPFooterView : UIToolbar
{
@private
    NSObject <CPFooterViewDelegate> *__unsafe_unretained delegate;
}

+ (id)footerViewWithToolBarType:(CPFooterItemType)type;

@property (nonatomic, unsafe_unretained) NSObject <CPFooterViewDelegate>*delegate;
@property(nonatomic,strong)UIBarButtonItem *barItemImage;

@end
