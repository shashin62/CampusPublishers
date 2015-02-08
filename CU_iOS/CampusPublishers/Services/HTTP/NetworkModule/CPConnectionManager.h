//
//  CPConnectionManager.h
//  CampusPublishers
//
//  Created by V2Solutions on 26/07/11.
//  Copyright 2011 V2Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPConnection.h"
#import "CPRequest.h"

@interface CPConnectionManager : NSObject 
{
@private	
	NSMutableDictionary *_connections;
}

+ (CPConnectionManager*)sharedConnectionManager;

- (NSInteger)activeConnections;
- (NSArray*)connectionIdentifiers;
- (CPConnection*)connectionWithIdentifier:(NSString*)inIdentifier;
- (void)closeConnectionWithIdentifier:(NSString*)inIdentifier;
- (void)closeAllConnections;
- (NSString*)spawnConnectionWithRequest:(CPRequest*)inRequest 
							   delegate:(id <CPConnectionDelegate>)inDelegate;

@end
