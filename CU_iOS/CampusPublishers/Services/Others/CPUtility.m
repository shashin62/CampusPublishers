//
//  CPUtility.m
//  CampusPublishers
//
//  Created by v2team on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CPUtility.h"
#import "JSON.h"
#import "CPConstants.h"
#import "CPDataManger.h"
#import "CPConfiguration.h"
#import "CPAppDelegate.h"


@implementation CPUtility

/* SHA1 */
+ (NSString*)sha1:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

+ (NSString *)stringByGeneratingUUID
{
    CFUUIDRef UUIDReference = CFUUIDCreate(nil);
    CFStringRef tempUUIDString = CFUUIDCreateString(nil, UUIDReference);
    CFRelease(UUIDReference);
    return [NSMakeCollectable(tempUUIDString) autorelease];
}

+ (UIColor *) colorFromHexString:(NSString *)hexString 
{
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@", 
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

//fetch the data,as per required density(LD/HD)
+ (NSString*) deviceDensity
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)
    {
        return @"HD";
    }
    else
    {
        return @"LD";
    }
}

+ (CPAppDelegate*)applicationDelegate
{
    return (CPAppDelegate*)[[UIApplication sharedApplication] delegate];
}

@end
