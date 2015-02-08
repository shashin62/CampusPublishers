/*
 File: CustomAnnotationView.m
 Abstract: The custom MKAnnotationView object representing a generic location, displaying a title and image.
 Version: 1.3
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */

#import "CustomAnnotationView.h"
#import "CustomMapItem.h"
#import "Place.h"


#define TITLE_FONT_SIZE 12
#define DESCRIPTION_FONT_SIZE 11



@interface CustomAnnotationView ()

@end

@implementation CustomAnnotationView
@synthesize annotationLabel,annotationImage;
@synthesize titleLabel;
@synthesize closeButton;
@synthesize backGroundImageButton;
@synthesize closeButtonBg;
@synthesize imageButton;
@synthesize videoIcon;
@synthesize isMap;
// determine the MKAnnotationView based on the annotation info and reuseIdentifier
//



- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        self.userInteractionEnabled = YES;
        CustomMapItem *mapItem = (CustomMapItem *)self.annotation;
        [ self setBackgroundColor:[UIColor clearColor]];
        
        // button to change back ground image
        backGroundImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backGroundImageButton.frame=CGRectMake(2,2, 196, 76);
        //backGroundImageButton.frame=CGRectMake(0,0, 200, 100);
        
        // self.backGroundImageButton.backgroundColor=[UIColor clearColor];
        self.backGroundImageButton.contentMode = UIViewContentModeScaleAspectFit;
        backGroundImageButton.userInteractionEnabled=YES;
        [self addSubview:self.backGroundImageButton];
        
        closeButtonBg = [[UIImageView alloc] init];
        closeButtonBg.frame=CGRectMake(0, 0, 200, 100);
        closeButtonBg.userInteractionEnabled=YES;
        
        //closeButtonBg.image=[UIImage imageNamed:@"gray_back.png"];
        self.closeButtonBg.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.closeButtonBg];
        // [self setBackgroundColor:[UIColor clearColor]];
        
        
        
        // title lable
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 160,20)];
        self.titleLabel.font = [UIFont fontWithName:@"ArialMT" size:TITLE_FONT_SIZE];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.userInteractionEnabled=YES;
        
        [self addSubview:self.titleLabel];
        
        
        
        // imageview to show map item image
        //NSLog(@"%@",mapItem.imageName);
        
        annotationImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:mapItem.imageName]];
        annotationImage.frame=CGRectMake(10,30 , 40, 40);
        CGRect rect=CGRectMake(0,0 , 40, 40);
        rect.size.width=40;
        rect.size.height=40;
        self.annotationImage.userInteractionEnabled=YES;
        self.annotationImage.backgroundColor = [UIColor clearColor];
        self.annotationImage.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.annotationImage];
        // add the annotation's label
        annotationLabel = [[UIWebView alloc] initWithFrame:CGRectMake(55, 25, 135, 50)];
        // self.annotationLabel.font = [UIFont systemFontOfSize:DESCRIPTION_FONT_SIZE];
        self.annotationLabel.backgroundColor = [UIColor clearColor];
        annotationLabel.userInteractionEnabled=YES;
        // self.annotationLabel.numberOfLines=0;
        // self.titleLabel.text =[annotation description];
        //self.annotationLabel.text = [annotation subtitle];
        //  [self.annotationLabel sizeToFit];   // get the right vertical size
        [self addSubview:self.annotationLabel];
        
        /* closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
         closeButton.frame=CGRectMake(170, 5, 20, 20);
         closeButton.backgroundColor=[UIColor clearColor];
         self.closeButton.contentMode = UIViewContentModeScaleAspectFit;
         [self addSubview:self.closeButton];*/
        imageButton=[[UIButton alloc]initWithFrame:CGRectMake(10,30,40,40)];
        //imageButton.backgroundColor=[UIColor clearColor];
        //[imageButton setBackgroundImage:[UIImage imageNamed:mapItem.imageName] forState:UIControlStateNormal];
        [self addSubview:self.imageButton];
        self.videoIcon.userInteractionEnabled=YES;
        
        
        
        
        /*videoIcon = [[UIImageView alloc] init];
         videoIcon.frame=CGRectMake(10,30,40,40);
         closeButtonBg.image=[UIImage imageNamed:@"gray_back.png"];
         videoIcon.contentMode = UIViewContentModeScaleAspectFit;
         // [self addSubview:videoIcon];
         [self bringSubviewToFront:closeButton];*/
        
        
        
        titleLabel.userInteractionEnabled=NO;
        annotationLabel.userInteractionEnabled=NO;
        annotationImage.userInteractionEnabled=NO;
        
        closeButtonBg.userInteractionEnabled=YES;// Modified by V2
        closeButton.userInteractionEnabled=NO;
        backGroundImageButton.userInteractionEnabled=NO;
        videoIcon.userInteractionEnabled=NO;
        
        
    }
    
    return self;
}

-(void)imageButtonAction{
    //NSLog(@"button pressed");
    
}



- (void)setAnnotation:(id <MKAnnotation>)annotation
{
    [super setAnnotation:annotation];
    
    // this annotation view has custom drawing code.  So when we reuse an annotation view
    // (through MapView's delegate "dequeueReusableAnnoationViewWithIdentifier" which returns non-nil)
    // we need to have it redraw the new annotation data.
    //
    // for any other custom annotation view which has just contains a simple image, this won't be needed
    //
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    isMap=YES;
    //NSLog(@"touchesBegan");
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    isMap=NO;
    //NSLog(@"touchesCancelled");
    
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{    isMap=NO;
    
    //NSLog(@"touchesEnded");
    
}


@end
