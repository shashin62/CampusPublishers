//
//  CPUniversity.h
//  CampusPublishers
//
//  Created by v2team on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPUniversity : NSObject{
@private
    
    NSNumber *_id;
    NSNumber *_latitude;
    NSNumber *_longitude;
    BOOL      _showRoute; 
}

@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, assign, getter=shouldShowRoute) BOOL showRoute;



@end
