//
//  CPUtility.h
//  CampusPublishers
//
//  Created by v2team on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//save


#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>

@class CPAppDelegate;

@interface CPUtility : NSObject 

+ (NSString*)sha1:(NSString*)input;
+ (NSString *)stringByGeneratingUUID;
+ (UIColor *)colorFromHexString:(NSString *)hexString;
+ (NSString*) deviceDensity;
+ (CPAppDelegate*)applicationDelegate;

@end
