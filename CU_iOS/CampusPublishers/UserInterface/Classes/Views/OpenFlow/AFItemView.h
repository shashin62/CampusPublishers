

#import <UIKit/UIKit.h>


@interface AFItemView : UIView {
	UIImageView		*imageView;
	int				number;
	CGFloat			horizontalPosition;
	CGFloat			verticalPosition;
	CGFloat			originalImageHeight;
    
}

@property (nonatomic) int number;
@property (nonatomic, readonly) CGFloat horizontalPosition;
@property (nonatomic, readonly) CGFloat verticalPosition;
@property (nonatomic, readonly) UIImageView *imageView;


- (void)setImage:(UIImage *)newImage originalImageHeight:(CGFloat)imageHeight reflectionFraction:(CGFloat)reflectionFraction;
- (CGSize)calculateNewSize:(CGSize)originalImageSize boundingBox:(CGSize)boundingBox;

@end