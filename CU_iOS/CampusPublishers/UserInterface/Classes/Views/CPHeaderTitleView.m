//
//  CPHeaderTitleView.m
//  CPHeaderTitle
//
//  Created by v2team on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CPHeaderTitleView.h"

@implementation CPHeaderTitleView

@synthesize previous = _previous;
@synthesize next = _next;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {       
        _title = [[UILabel alloc] initWithFrame:CGRectZero];
        _title.textColor = [UIColor whiteColor];
        _title.shadowColor = [UIColor blackColor];
        _title.shadowOffset = CGSizeMake(0.0, -1.0);
        _title.font = [UIFont fontWithName:@"Arial-BoldMT" size:17.0];
        _title.backgroundColor = [UIColor clearColor];
        [self addSubview:_title];

        _previous = [[UIButton alloc] initWithFrame:CGRectZero];
        [_previous setTitle:@"<   " forState:UIControlStateNormal];
        [_previous setTitleColor:[[_previous titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.8]
                        forState:UIControlStateDisabled];
        [_previous.titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:19.0]];
        _previous.showsTouchWhenHighlighted = YES;
        [self addSubview:_previous];
        
        _next = [[UIButton alloc] initWithFrame:CGRectZero]; 
        [_next setTitle:@"   >" forState:UIControlStateNormal];
        [_next setTitleColor:[[_next titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.8]
                        forState:UIControlStateDisabled];
        [_next.titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:19.0]];
        _next.showsTouchWhenHighlighted = YES;        
        [self addSubview:_next];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.frame;
	[_title sizeToFit];
    [_previous sizeToFit];
    [_next sizeToFit];
    
	CGRect _rect = rect;
	_rect.size = _title.frame.size;
    _rect.origin.x = (rect.size.width - _rect.size.width)/2;
    _rect.origin.y = (rect.size.height - _rect.size.height)/2;
	_title.frame = _rect;
    
    CGRect _rect1 = _previous.frame;
    _rect1.origin.x = _rect.origin.x - _rect1.size.width;
    _rect1.origin.y = _rect.origin.y;
    _previous.frame = _rect1;
    
    CGRect _rect2 = _next.frame;
    _rect2.origin.x = _rect.origin.x + _rect.size.width;
    _rect2.origin.y = _rect.origin.y;
    _next.frame = _rect2;
    
    rect.size.width = _rect1.size.width + _rect.size.width + _rect2.size.width;
    self.frame = rect;
}

- (void)setTitle:(NSString *)inTitle
{    
    _title.text = inTitle;
    [self setNeedsLayout];
}

- (CGRect)frame
{
    return [super frame];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}



@end
