//
//  CPConnectionManager.m
//  CampusPublishers
//
//  Created by V2Solutions on 26/07/11.
//  Copyright 2011 V2Solutions. All rights reserved.
//

#import "CPConnectionManager.h"

@implementation CPConnectionManager

static CPConnectionManager *sharedConnectionManager = nil;

#pragma mark - alloc/init/dealloc -
+ (CPConnectionManager*)sharedConnectionManager
{
	@synchronized(self) 
	{
        if(sharedConnectionManager == nil) 
		{
            [[self alloc] init]; // assignment not done here
        }
    }
	
    return sharedConnectionManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) 
	{
        if(sharedConnectionManager == nil) 
		{
            sharedConnectionManager = [super allocWithZone:zone];
            return sharedConnectionManager;  // assignment and return on first allocation
        }
    }
	
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}



- (id)init
{   self = [super init];
	if(self) 
	{
		_connections = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}



#pragma mark - Instance Method -
- (NSInteger)activeConnections
{
	return [_connections count];
}

- (NSArray*)connectionIdentifiers
{
	return [_connections allKeys];
}

- (CPConnection*)connectionWithIdentifier:(NSString*)inIdentifier
{
	return [_connections valueForKey:inIdentifier];
}

- (NSString*)spawnConnectionWithRequest:(CPRequest*)inRequest delegate:(NSObject <CPConnectionDelegate> *)inDelegate
{
	CPConnection *connection = [[CPConnection alloc] initWithRequest:inRequest 
															delegate:inDelegate 
															 manager:self];
	NSString *identifier = [connection identifier];
    [_connections setValue:connection forKey:identifier];
    return identifier;
}

- (void)closeConnectionWithIdentifier:(NSString*)inIdentifier
{
	CPConnection *connection = [self connectionWithIdentifier:inIdentifier];
    if(connection != nil) 
	{
		[connection cancel];
		[_connections removeObjectForKey:inIdentifier];
    }
}

- (void)closeAllConnections
{
	[[_connections allValues] makeObjectsPerformSelector:@selector(cancel)];
    [_connections removeAllObjects];
}

@end
