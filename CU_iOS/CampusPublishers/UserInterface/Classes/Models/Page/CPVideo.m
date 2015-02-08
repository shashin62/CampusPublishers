//
//  CPVideos.m
//  CampusPublishers
//
//  Created by v2team on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CPVideo.h"

@implementation CPVideo

@synthesize  url = _url;

-(id)init
{
    self = [super init];
    if (self != nil) {
        self.url = nil;
    }
    return  self;
}


-(BOOL) isEqual:(id)object
{
    return NO;
}

-(NSUInteger) hash{
    
    return 501;
}

-(NSString *) description
{
    return  [NSString stringWithFormat:@"Content: %@, Type: %d , Image: %@, URL: %@" ,self.text, self.type, self.image, self.url];
}



@end
