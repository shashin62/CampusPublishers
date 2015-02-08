//
//  CPSwipeView.m
//  Campus Publishers
//
//  Created by V2 Solutions on 27/03/12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CPSwipeView.h"

@interface CPSwipeView ()

@end

@implementation CPSwipeView

@synthesize tableViewOrientation = _tableViewOrientation;
@synthesize playMode = _playMode;;

- (void)setTableViewOrientation:(CPTableViewOrientation)anOrientation
{
    if (_tableViewOrientation != anOrientation)
    {
        _tableViewOrientation = anOrientation;
        if (_tableViewOrientation == CPGTableViewOrientationHorizontal)
        {
            CGRect frame = self.frame;
            self.transform = CGAffineTransformMakeRotation(-M_PI/2.0);
            super.frame = frame;
        }
        else
        {
            self.transform = CGAffineTransformMakeRotation(0.0);
        }
        [self reloadData];
    }
}
@end
