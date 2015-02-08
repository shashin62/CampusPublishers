//
//  CPDataManger.h
//  CampusPublishers
//
//  Created by v2team on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CPConfiguration;
@class CPUniversity;
@class CPMenu;

@interface CPDataManger : NSObject
{
    NSMutableArray  *_datasource;
    CPConfiguration *_configuration;
    CPMenu *__unsafe_unretained _selectedMenu;
    UIInterfaceOrientation orientation;
    NSDictionary *dictInfo;
}

@property(nonatomic, strong) NSMutableArray  *datasource;
@property(nonatomic, strong) CPConfiguration *configuration;
@property(nonatomic, assign) UIInterfaceOrientation orientation;
@property(nonatomic, unsafe_unretained) CPMenu *selectedMenu;
@property(nonatomic, strong) NSDictionary *dictionary;

+ (CPDataManger*)sharedDataManager;

-(void)updateDataSource:(NSArray*)data;
-(void) configurationData:(NSDictionary*)data;

@end
