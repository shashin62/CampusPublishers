//
//  CPPage.h
//  CampusPublishers
//
//  Created by v2team on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CPContent;
@class CMPImage;

@interface CMPPage : NSObject{
@private
    
    NSString         *_title;
    NSString         *_subTitle;
    CPContent       *_content;
    NSMutableArray   *_images;
    NSMutableArray   *_videos;
    CMPImage         *_image;
    
}

@property (nonatomic, strong) NSString       *title;
@property (nonatomic, strong) NSString       *subTitle;
@property (nonatomic, strong) CPContent     *content;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableArray *videos;
@property (nonatomic, strong) CMPImage       *image;

@end
