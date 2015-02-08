//
//  CPConfigurationFont.m
//  CampusPublishers
//
//  Created by v2team on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CPConfigurationFont.h"

@implementation CPConfigurationFont

@synthesize font = _font;

-(id) init{
    self = [super init];
    self.font = [UIFont fontWithName:@"ArialMT" size:0];
    return self;
}

-(NSString *) description
{
    return [NSString stringWithFormat:@"font: %@", self.font];
}

@end
