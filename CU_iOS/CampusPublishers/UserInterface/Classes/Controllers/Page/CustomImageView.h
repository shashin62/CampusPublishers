//
//  CustomImageView.h
//  CampusPublishers
//
//  Created by v2solutions on 03/02/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyView;


@interface CustomImageView : UIScrollView<UIGestureRecognizerDelegate,UIScrollViewDelegate>
@property(nonatomic,retain)UIImageView *imageView;
- (void)centerScrollViewContents;

@end
