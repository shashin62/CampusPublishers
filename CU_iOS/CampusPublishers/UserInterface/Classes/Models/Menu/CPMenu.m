//
//  CPMenu.m
//  CampusPublishers
//
//  Created by v2team on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CPMenu.h"
#import "CMPPage.h"

@implementation CPMenu
@synthesize  id       = _id;
@synthesize  name     = _name;
@synthesize  image    = _image;
@synthesize  subMenu  = _subMenu;
@synthesize  parentId = _parentId;
@synthesize  page     = _page;
@synthesize imageURL = _imageURL;
@synthesize  category_id;
@synthesize is_tourmap;
@synthesize is_map;


-(id) init{
    self = [super init];
    
    if (self != nil) {
        self.id         = nil;
        self.name       = nil;
        self.image      = nil;
        self.subMenu    = [NSMutableArray array];
        self.parentId   = nil;
        self.page       = nil;
        self.imageURL = nil;
    }
    return  self; 
}

-(BOOL) isEqual:(id)object
{
    CPMenu *_menu = (CPMenu*) object; 
    return [self.id isEqual:_menu.id];
}

-(NSUInteger) hash{

    return  101;
}

-(NSString*) description{

    return [NSString stringWithFormat:@"id: %@, name: %@, SubMenu: %@, parentId: %@, page: %@ ", self.id, self.name, self.subMenu, self.parentId, self.page];
}



@end
