//
//  CPConfiguration.m
//  CampusPublishers
//
//  Created by v2team on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CPConfiguration.h"

@implementation CPConfiguration

@synthesize color       = _color;
@synthesize font        = _font;
@synthesize university  = _university;
@synthesize imagePath   = _imagePath;
@synthesize videoPath   = _videoPath;
@synthesize admobid       = _admobid;

-(id) init{

    self = [super init];
    
    if (self != nil) {
        
        self.color      = nil;
        self.font       = nil;
        self.university = nil;
        self.admobid    = nil;
        self.imagePath  = [NSMutableString string];
        self.videoPath  = [NSMutableString string];
    }
    return self;
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
    return  [NSString stringWithFormat:@"color: %@, font: %@, university : %@, imagePath: %@, videoPath: %@" ,self.color, self.font, self.university,self.imagePath, self.videoPath];
}




@end
