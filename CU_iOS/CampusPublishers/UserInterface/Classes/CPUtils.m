//
//  CPUtils.m
//  CampusPublishersDEV
//
//  Created by Namrata on 2/16/15.
//
//

#import "CPUtils.h"

@implementation CPUtils

+(CGFloat)getSceenWidth{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    //    CGFloat screenHeight = screenRect.size.height;
    return screenWidth;
}


+(CGFloat)getSceenHeight{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    //    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    return screenHeight;
}
@end
