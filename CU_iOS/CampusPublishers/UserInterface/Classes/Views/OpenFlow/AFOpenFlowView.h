


#import <UIKit/UIKit.h>
#import "AFItemView.h"
#import <QuartzCore/QuartzCore.h>


@protocol AFOpenFlowViewDataSource;
@protocol AFOpenFlowViewDelegate;

@interface AFOpenFlowView : UIView {
	id <AFOpenFlowViewDataSource>	__unsafe_unretained dataSource;
	id <AFOpenFlowViewDelegate>	__unsafe_unretained viewDelegate;
	NSMutableSet					*offscreenCovers;
	NSMutableDictionary				*onscreenCovers;
	NSMutableDictionary				*coverImages;
	NSMutableDictionary				*coverImageHeights;
	UIImage							*defaultImage;
	CGFloat							defaultImageHeight;

	UIScrollView					*scrollView;
	int								lowerVisibleCover;
	int								upperVisibleCover;
	int								numberOfImages;
	int								beginningCover;
    
	
	

	CATransform3D leftTransform, rightTransform;
	
	CGFloat halfScreenHeight;
	CGFloat halfScreenWidth;
	
	Boolean isSingleTap;
	Boolean isDoubleTap;
	Boolean isDraggingACover;
	CGFloat startPosition;
    int selectedCover;
    
    //@public
    AFItemView						*selectedCoverView;
}

@property (nonatomic, unsafe_unretained) id <AFOpenFlowViewDataSource> dataSource;
@property (nonatomic, unsafe_unretained) id <AFOpenFlowViewDelegate> viewDelegate;
@property (nonatomic, strong) UIImage *defaultImage;
@property (nonatomic) int numberOfImages;
@property (nonatomic)int selectedCover;

- (void)setSelectedCover:(int)newSelectedCover;
- (void)centerOnSelectedCover:(BOOL)animated;
- (void)setImage:(UIImage *)image forIndex:(int)index;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

- (AFItemView *)coverItemForIndex:(int)coverIndex;

@end

@protocol AFOpenFlowViewDelegate <NSObject>
@optional
- (void)openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index;
-(void)openFlowView:(AFOpenFlowView *)openFlowView touchcount:(int)touch;
@end

@protocol AFOpenFlowViewDataSource <NSObject>
- (void)openFlowView:(AFOpenFlowView *)openFlowView requestImageForIndex:(int)index;
- (UIImage *)defaultImage;
@end