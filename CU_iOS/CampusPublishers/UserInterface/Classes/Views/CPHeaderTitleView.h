//
//  CPHeaderTitleView.h
//  CPHeaderTitle
//
//  custom & dynamic titleView displayed as NavigationTitleView in GalleryView

//  Created by v2team on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPHeaderTitleView;

@protocol CPHeaderTitleViewDelegate <NSObject>

@optional

@end

@interface CPHeaderTitleView : UIView
{
@private
    NSObject <CPHeaderTitleViewDelegate> *__unsafe_unretained delegate;

    UILabel *_title;
    UIButton *_previous;
    UIButton *_next;
}

@property(nonatomic, strong) UIButton *previous;
@property(nonatomic, strong) UIButton *next;
@property(nonatomic, unsafe_unretained) NSObject <CPHeaderTitleViewDelegate>*delegate;

- (void)setTitle:(NSString *)inTitle;

@end
