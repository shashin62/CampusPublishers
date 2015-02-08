//
//  CPPage.m
//  CampusPublishers
//
//  Created by v2team on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMPPage.h"
#import "CPContent.h"

@implementation CMPPage

@synthesize title       = _title;
@synthesize subTitle    = _subTitle;
@synthesize content     = _content;
@synthesize images      = _images;
@synthesize videos      = _videos;
@synthesize image       = _image;

-(id) init{
 
    self = [super init];
    if (self != nil) {
        self.title      = nil;
        self.subTitle   = nil;
        self.content    = nil;
        NSMutableArray *array = [[NSMutableArray alloc] init];
        self.images     = array;
        NSMutableArray * array1 = [[NSMutableArray alloc] init];
        self.videos     = array1;
        self.image = nil;
    }
    return self;
}

-(BOOL) isEqual:(id)object{

    CMPPage *_page = (CMPPage*) object;
    return [self.title isEqual:_page.title];
}

-(NSUInteger) hash{
    
    return  201;
}

-(NSString*) description{
    
    return [NSString stringWithFormat:@"Title: %@ , SubTitle: %@ , Content: %@ , Images : %@, Videos: %@, Image: %@" , 
                                                self.title,
                                                self.subTitle,
                                                self.content,
                                                self.images,
                                                self.videos, 
                                                self.image];
}



@end
