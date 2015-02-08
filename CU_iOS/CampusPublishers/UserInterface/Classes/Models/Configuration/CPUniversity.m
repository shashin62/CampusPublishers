//
//  CPUniversity.m
//  CampusPublishers
//
//  Created by v2team on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CPUniversity.h"

@implementation CPUniversity

@synthesize id          = _id;
@synthesize latitude    = _latitude;
@synthesize longitude   = _longitude;
@synthesize showRoute    = _showRoute;


-(id)init{

    self = [super init];
    if(self != nil)
    {
        self.id         = nil;
        self.latitude   = nil;
        self.longitude  = nil;
        self.showRoute   = NO;
    }
    return self;
}

-(BOOL) isEqual:(id)object
{
    CPUniversity *_university = (CPUniversity*) object;
    return [_university.id isEqual:self.id];
    
}

-(NSUInteger) hash{
    
    return 601;
}

-(NSString *) description
{
    return  [NSString stringWithFormat:@"id: %@, latitude: %@, longitude: %@" ,self.id, self.latitude, self.longitude];
}






@end
