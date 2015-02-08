//
//  CPMapCategories.h
//  CampusPublishers
//
//  Created by v2solutions on 08/01/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPMapCategories : NSObject
@property(nonatomic,assign)int category_id;
@property(nonatomic,strong)NSString *category_name;
@property(nonatomic,strong)NSString *category_iphone_color;
@property(nonatomic,strong)NSString *category_ipad_color;
@property(nonatomic,strong)NSString *device_image;
@property(nonatomic,strong)NSString *category_ipad_image;

@end
