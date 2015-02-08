//
//  CPContent.m
//  CampusPublishers
//
//  Created by v2team on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CPContent.h"

@implementation CPContent

@synthesize  text = _text;
@synthesize  type = _type;

-(id) init
{
    self = [super init];
    
    if (self != nil) {
        
        self.text = nil;
        self.type = CPContentTypeURL;
        self.font = [UIFont fontWithName:@"ArialMT" size:0];
    }
    return  self;
}

-(BOOL) isEqual:(id)object
{
    return NO;
}

-(NSUInteger) hash{

    return 301;
}

-(NSString *) description
{
    return  [NSString stringWithFormat:@"Content: %@, Type: %d, Font: %@",self.text, self.type, self.font];
}


@end
