//
//  CPVideos.h
//  CampusPublishers
//
//  Created by v2team on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMPImage.h"


@interface CPVideo : CMPImage{
@private
    
    NSURL * _url;
}

@property (nonatomic, strong) NSURL * url;



@end
