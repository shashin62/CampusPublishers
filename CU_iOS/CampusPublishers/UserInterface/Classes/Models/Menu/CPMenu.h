//
//  CPMenu.h
//  CampusPublishers
//
//  Created by v2team on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMPPage;

@interface CPMenu : NSObject{
@private
    
    NSNumber       *_id;
    NSString       *_name;
    UIImage        *_image;
    NSMutableArray *_subMenu;
    NSNumber       *_parentId;
    CMPPage         *_page;
    NSURL          *_imageURL;
}


@property (nonatomic, strong) NSNumber       *id;
@property (nonatomic, strong) NSString       *name;
@property (nonatomic, strong) UIImage        *image;
@property (nonatomic, strong) NSMutableArray *subMenu;
@property (nonatomic, strong) NSNumber       *parentId;
@property (nonatomic, strong) CMPPage         *page;
@property (nonatomic, strong) NSURL          *imageURL;
@property (nonatomic, assign)BOOL is_tourmap;
@property (nonatomic, assign)int category_id;
@property (nonatomic, assign)BOOL is_map;
@end
