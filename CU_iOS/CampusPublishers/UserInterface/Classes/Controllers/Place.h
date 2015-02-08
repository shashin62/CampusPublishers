//
//  AppDelegate.h
//  CampusStore
//
//  Created by v2solutions on 19/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPMapCategories.h"

@interface Place : NSObject {

	NSString* name;
	NSString* description;
	double latitude;
	double longitude;
}

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* description;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

// addded
@property(nonatomic, strong)NSString*map_point_name;
@property(nonatomic, strong)NSString*map_image;
@property(nonatomic, strong)NSString*map_details;
@property(nonatomic,assign)int tourmap_id;
@property(nonatomic,assign)int map_order;

@property(nonatomic, assign)int media_type;
@property(nonatomic, assign)int video_id;
@property(nonatomic, strong)NSString *video_name;
@property(nonatomic, strong)NSString *video_text;
@property(nonatomic, strong)NSString *video_thumb;
@property(nonatomic, strong)CPMapCategories *categories;


/*
 
 "media_type": "2",
 "video_id": "2",
 "video_name": "a11a6b9db6b19e405ca7b8f2c6cd7200.m4v",
 "video_thumb": "a11a6b9db6b19e405ca7b8f2c6cd7200.png",
 "video_text": "Testing2 video",
 */

@end
