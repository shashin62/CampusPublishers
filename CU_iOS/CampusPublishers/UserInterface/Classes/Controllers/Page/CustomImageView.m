//
//  CustomImageView.m
//  CampusPublishers
//
//  Created by v2solutions on 03/02/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "CustomImageView.h"
@implementation CustomImageView
@synthesize imageView;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ImagePlaceholderTwo.png"]];
        imageView.frame=frame;
        imageView.userInteractionEnabled=YES;
        imageView.backgroundColor=[UIColor whiteColor];
       // imageView.contentMode=UIViewContentModeCenter;
        //[imageView sizeToFit];
       // imageView.center=self.center;
       // [myView addGestureRecognizersToPiece];
        [self addSubview:imageView];
        
        
       // self.contentMode=UIViewContentModeCenter;
        self.contentSize=imageView.frame.size;
        
        
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        doubleTapRecognizer.numberOfTouchesRequired = 1;
       // [self addGestureRecognizer:doubleTapRecognizer];
        
        UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
        twoFingerTapRecognizer.numberOfTapsRequired = 1;
        twoFingerTapRecognizer.numberOfTouchesRequired = 2;
      //  [self addGestureRecognizer:twoFingerTapRecognizer];
       // [self centerScrollViewContents];

        
        
        // Initialization code
    }
    return self;
}



- (UIImageView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that we want to zoom
    return imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.bounds.size;
    CGRect contentsFrame = imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    imageView.frame = contentsFrame;
}


- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    // Get the location within the image view where we tapped
    CGPoint pointInView = [recognizer locationInView:imageView];
    
    // Get a zoom scale that's zoomed in slightly, capped at the maximum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, self.maximumZoomScale);
    
    // Figure out the rect we want to zoom to, then zoom to it
    CGSize scrollViewSize = self.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    [self zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.minimumZoomScale);
    [self setZoomScale:newZoomScale animated:YES];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
