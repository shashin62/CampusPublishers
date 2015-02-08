//
//  CPConnection.h
//  CampusPublishers
//
//  Created by V2Solutions on 26/07/11.
//  Copyright 2011 V2Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPNetworkConstant.h"

@class CPRequest;
@class CPConnection;
@class CPConnectionManager;

@protocol CPConnectionDelegate <NSObject>

- (void)CPConnection:(CPConnection*)CPConnection didReceiveResponse:(id)response;
- (void)CPConnection:(CPConnection*)CPConnection didFailWithError:(NSError*)error;

@end

@interface CPConnection : NSObject 
{
@private
	CPRequest						*_request;
	CPConnectionManager				*_connectionManager;
	
	NSString						*_identifier;
	NSMutableData					*_data;
	NSURLConnection					*_urlConnection;
	
	NSObject <CPConnectionDelegate>	*__unsafe_unretained _delegate;
    
    NSInteger                       statusCode;
}

@property (nonatomic, unsafe_unretained) NSObject <CPConnectionDelegate> *delegate;
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) CPRequest *request;

- (id)initWithRequest:(CPRequest*)inRequest 
			 delegate:(NSObject <CPConnectionDelegate> *)inDelegate
			  manager:(CPConnectionManager*)inManager;
- (void)start;
- (void)cancel;

@end
