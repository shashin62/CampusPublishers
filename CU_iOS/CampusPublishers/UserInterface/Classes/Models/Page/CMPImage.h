//
//  CPImages.h
//  CampusPublishers
//
//  Created by v2team on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPContent.h"

@interface CMPImage : CPContent{
@private
    
    UIImage *_image;
    NSURL * _imageURl;
}

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL * imageUrl;

@end
