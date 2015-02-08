//
//  CPConfigurationColor.h
//  CampusPublishers
//
//  Created by v2team on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPConfigurationColor : NSObject{
@private
    
    UIColor *_header;
    UIColor *_headerText;
    UIColor *_footer;
    UIColor *_footerText;
    UIColor *_background;
    UIColor *_menuFontColor;
}

@property(nonatomic, strong)  UIColor *header;
@property(nonatomic, strong)  UIColor *headerText;
@property(nonatomic, strong)  UIColor *footer;
@property(nonatomic, strong)  UIColor *footerText;
@property(nonatomic, strong)  UIColor *background;
@property(nonatomic, strong)  UIColor *menuFontColor;
@property(nonatomic, strong)  UIColor *tour_path_color;
@property(nonatomic, strong)  UIColor *visited_path_color;

@end
