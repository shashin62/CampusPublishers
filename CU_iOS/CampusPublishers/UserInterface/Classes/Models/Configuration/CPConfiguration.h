//
//  CPConfiguration.h
//  CampusPublishers
//
//  Created by v2team on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPConfigurationColor.h"
#import "CPConfigurationFont.h"
#import "CPUniversity.h"
#import "CPAdmob.h"

@interface CPConfiguration : NSObject{
@private

    CPConfigurationColor *_color;
    CPConfigurationFont  *_font;
    CPUniversity         *_university;
    CPAdmob              *_admobid;
    NSMutableString      *_imagePath;
    NSMutableString      *_videoPath;
    
}

@property (nonatomic, strong)  CPConfigurationColor *color;
@property (nonatomic, strong)  CPConfigurationFont  *font;
@property (nonatomic, strong)  CPUniversity         *university;
@property (nonatomic, strong)  CPAdmob              *admobid;
@property (nonatomic, strong)  NSMutableString      *imagePath;
@property (nonatomic, strong)  NSMutableString      *videoPath;

@end
