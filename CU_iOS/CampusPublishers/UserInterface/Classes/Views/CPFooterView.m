//
//  CPFooterView.m
//  CampusPublishers
//
//  Created by V2Solutions on 30/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CPFooterView.h"

@implementation CPFooterView

@synthesize delegate;
@synthesize barItemImage;

+ (id)footerViewWithToolBarType:(CPFooterItemType)type
{
    
    CPFooterView *footerView = [[CPFooterView alloc] initWithFrame:CGRectMake(0.0, 0.0, [[UIScreen mainScreen] applicationFrame].size.width, 44.0)];
    
    UIImageView *midImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"divider.png"]];
    midImage.contentMode = UIViewContentModeScaleToFill;
    CGRect frame = CGRectZero;
    frame.size.width = midImage.frame.size.width;
    frame.size.height = midImage.frame.size.height;
    midImage.frame = frame;
    
    UIImageView *_midImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"divider.png"]];
    _midImage.contentMode = UIViewContentModeScaleToFill;
    CGRect _frame = CGRectZero;
    _frame.size.width = _midImage.frame.size.width;
    _frame.size.height = _midImage.frame.size.height;
    _midImage.frame = _frame;
    
    UIImageView *__midImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"divider.png"]];
    __midImage.contentMode = UIViewContentModeScaleToFill;
    CGRect __frame = CGRectZero;
    __frame.size.width = __midImage.frame.size.width;
    __frame.size.height = __midImage.frame.size.height;
    __midImage.frame = __frame;
    
    UIBarButtonItem *separator = [[UIBarButtonItem alloc] initWithCustomView:midImage];
    UIBarButtonItem *separator1 = [[UIBarButtonItem alloc] initWithCustomView:_midImage];
    UIBarButtonItem *seperator2 = [[UIBarButtonItem alloc] initWithCustomView:__midImage];
    
    UIBarButtonItem *barItemQRCode = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ScanIcon.png"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:footerView
                                                                     action:@selector(doAction:)];
    barItemQRCode.tag = CPFooterItemTypeDefault;
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
    if(type == CPFooterItemTypeImagesVideos)
    {
        UIBarButtonItem *barItemImage = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ImageIcon.png"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:footerView
                                                                        action:@selector(doAction:)];
        barItemImage.tag = CPFooterItemTypeImage;
        
        UIBarButtonItem *barItemVideos = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"VideoIcon.png"]
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:footerView
                                                                         action:@selector(doAction:)];
        barItemVideos.tag = CPFooterItemTypeVideo;
        
        footerView.items = [NSArray arrayWithObjects:flexibleSpace, barItemQRCode, flexibleSpace, separator, flexibleSpace, barItemImage, flexibleSpace, separator1, flexibleSpace, barItemVideos, flexibleSpace, nil];
    }
    else if(type == CPFooterItemTypeDefault)
    {
        footerView.items = [NSArray arrayWithObjects:flexibleSpace,barItemQRCode,flexibleSpace, nil];
    }
    
    else if(type == CPFooterItemTypeImage)
    {
        UIBarButtonItem *barItemImage = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ImageIcon.png"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:footerView
                                                                        action:@selector(doAction:)];
        barItemImage.tag = CPFooterItemTypeImage;
        
        footerView.items = [NSArray arrayWithObjects:flexibleSpace, barItemQRCode, flexibleSpace, separator, flexibleSpace,barItemImage, flexibleSpace, nil];
    }
    
    else if(type == CPFooterItemTypeVideo)
    {
        UIBarButtonItem *barItemVideos = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"VideoIcon.png"]
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:footerView
                                                                         action:@selector(doAction:)];
        barItemVideos.tag = CPFooterItemTypeVideo;
        
        footerView.items = [NSArray arrayWithObjects:flexibleSpace, barItemQRCode, flexibleSpace, separator, flexibleSpace,barItemVideos, flexibleSpace, nil];
    }
    
    else if(type == CPFooterItemShowDirection)
    {
        UIBarButtonItem *barItemDirection =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"DirectionIcon.png"]
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:footerView
                                                                           action:@selector(doAction:)];
        barItemDirection.tag = CPFooterItemShowDirection;
        
        footerView.items = [NSArray arrayWithObjects:flexibleSpace, barItemQRCode, flexibleSpace, separator, flexibleSpace, barItemDirection,flexibleSpace, nil];
    }
    else if(type == CPFooterItemTypeSDImage)
    {
        UIBarButtonItem *barItemImage = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ImageIcon.png"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:footerView
                                                                        action:@selector(doAction:)];
        barItemImage.tag = CPFooterItemTypeImage;
        
        UIBarButtonItem *barItemDirection =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"DirectionIcon.png"]
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:footerView
                                                                           action:@selector(doAction:)];
        barItemDirection.tag = CPFooterItemShowDirection;
        
        footerView.items = [NSArray arrayWithObjects:flexibleSpace, barItemQRCode, flexibleSpace, separator, flexibleSpace, barItemDirection,flexibleSpace,separator1,flexibleSpace,barItemImage,flexibleSpace, nil];
    }
    else if(type == CPFooterItemTypeSDVideos)
    {
        UIBarButtonItem *barItemVideos = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"VideoIcon.png"]
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:footerView
                                                                         action:@selector(doAction:)];
        barItemVideos.tag = CPFooterItemTypeVideo;
        
        UIBarButtonItem *barItemDirection =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"DirectionIcon.png"]
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:footerView
                                                                           action:@selector(doAction:)];
        barItemDirection.tag = CPFooterItemShowDirection;
        
        footerView.items = [NSArray arrayWithObjects:flexibleSpace, barItemQRCode, flexibleSpace, separator, flexibleSpace, barItemDirection,flexibleSpace,separator1,flexibleSpace,barItemVideos,flexibleSpace, nil];
    }
    else if(type == CPFooterItemTypeSDAll)
    {
        UIBarButtonItem *barItemImage = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ImageIcon.png"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:footerView
                                                                        action:@selector(doAction:)];
        barItemImage.tag = CPFooterItemTypeImage;
        
        UIBarButtonItem *barItemVideos = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"VideoIcon.png"]
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:footerView
                                                                         action:@selector(doAction:)];
        barItemVideos.tag = CPFooterItemTypeVideo;
        
        UIBarButtonItem *barItemDirection =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"DirectionIcon.png"]
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:footerView
                                                                           action:@selector(doAction:)];
        barItemDirection.tag = CPFooterItemShowDirection;
        
        footerView.items = [NSArray arrayWithObjects:flexibleSpace, barItemQRCode, flexibleSpace, separator, flexibleSpace, barItemDirection,flexibleSpace,separator1,flexibleSpace,barItemImage,flexibleSpace,seperator2,flexibleSpace,barItemVideos,flexibleSpace, nil];
    }
    else if(type == CPFooterItemToureGuide)
    {
        UIBarButtonItem *barItemDirection =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tour_guide.png"]
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:footerView
                                                                           action:@selector(doAction:)];
        barItemDirection.tag = CPFooterItemToureGuide;
        
        footerView.items = [NSArray arrayWithObjects:flexibleSpace, barItemQRCode, flexibleSpace, separator, flexibleSpace, barItemDirection,flexibleSpace,nil];
    }
    
        
    return footerView;
}

- (void)setFrame:(CGRect)frame
{
    frame.size.width = [[UIScreen mainScreen] applicationFrame].size.width;
    frame.size.height = 44.0;
    [super setFrame:frame];
}

- (CGRect)frame
{
    return [super frame];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)doAction:(id)sender
{
    CPFooterItemType type = (CPFooterItemType*)[sender tag];
    if([self.delegate respondsToSelector:@selector(footerView:didClickItemWithType:)])
	{
        [self.delegate footerView:self 
                       didClickItemWithType:type];
	}    
}


@end
