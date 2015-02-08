//
//  CPRequest.h
//  CampusPublishers
//
//  Created by V2Solutions on 26/07/11.
//  Copyright 2011 V2Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPNetworkConstant.h"

@interface CPRequest : NSObject 
{
@private	
	NSURL				*_url;
	CPRequestType		_type;
	NSString			*_userAgent;
	NSMutableURLRequest	*_urlRequest;
	NSString			*_requestBody;
    NSNumber           *_identifier;
    int           indexForOverLay;
}

@property (unsafe_unretained, nonatomic, readonly)	NSURL           *URL;
@property (unsafe_unretained, nonatomic, readonly)	NSString        *userAgent;
@property (nonatomic, strong)	NSString        *requestBody;
@property (nonatomic, readonly) NSURLRequest    *URLRequest;
@property (nonatomic, assign)	CPRequestType   type;
@property (nonatomic, strong)	NSNumber       *identifier;
@property (nonatomic, assign) int           indexForOverLay;

- (id)initWithURL:(NSURL*)inURL withRequestType:(CPRequestType)inType;
- (void)setHttpMethod:(NSString *)httpMethod;

@end
