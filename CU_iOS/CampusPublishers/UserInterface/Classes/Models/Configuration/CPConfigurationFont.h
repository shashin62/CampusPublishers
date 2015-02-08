//
//  CPConfigurationFont.h
//  CampusPublishers
//
//  Created by v2team on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPConfigurationFont : UIFont{
    @private
    UIFont *_font;
}

@property(nonatomic, strong) UIFont *font;

@end
