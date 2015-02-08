//
//  CPImages.m
//  CampusPublishers
//
//  Created by v2team on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMPImage.h"


@implementation CMPImage
@synthesize  image =_image;
@synthesize imageUrl = _imageURl;

-(id)init
{
    self = [super init];
    if (self != nil) {
        self.image = nil;
        self.imageUrl = nil;
    }
    return  self;
}


-(BOOL) isEqual:(id)object
{
    return NO;
}

-(NSUInteger) hash{
    
    return 401;
}

-(NSString *) description
{
    return  [NSString stringWithFormat:@"Content: %@, Type: %d , Image: %@, ImageURL: %@" ,self.text, self.type, self.image, self.imageUrl];
}



@end
