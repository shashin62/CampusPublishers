//
//  CPContent.h
//  CampusPublishers
//
//  Created by v2team on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPConstants.h"

@interface CPContent : NSObject{
@private
    
    NSString        *_text;
    CPContentType   _type;
    UIFont *_font;
}

@property (nonatomic, strong) NSString      *text;
@property (nonatomic, assign) CPContentType type;
@property(nonatomic, strong) UIFont *font;


@end
