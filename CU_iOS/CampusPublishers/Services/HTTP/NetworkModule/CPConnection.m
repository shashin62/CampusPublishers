 //
//  CPConnection.m
//  CampusPublishers
//
//  Created by V2Solutions on 26/07/11.
//  Copyright 2011 V2Solutions. All rights reserved.
//

#import "CPConnection.h"
#import "CPRequest.h"
#import "CPConnectionManager.h"
#import "CPUtility.h"
#import "CPAppDelegate.h"
@interface CPConnection (PRIVATE)

@end

@implementation CPConnection (PRIVATE)

// A delegate method called by the NSURLConnection when the request/response 
// exchange is complete.  We look at the response to check that the HTTP 
// status code is 2xx and that the Content-Type is acceptable.  If these checks 
// fail, we give up on the transfer.
- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
	statusCode = [(NSHTTPURLResponse*)response statusCode];
      
    if(statusCode == 200)
    {
        [_data setLength:0];
    }
	else 
	{
		NSError *error = [NSError errorWithDomain:NSLocalizedString(@"CPConnectio-Error", "")
											 code:statusCode 
										 userInfo:nil];
		if([self.delegate respondsToSelector:@selector(CPConnection:didFailWithError:)])
		{
			[self.delegate CPConnection:self didFailWithError:error];
		}
		
		[_connectionManager closeConnectionWithIdentifier:_identifier];
	}
}

// A delegate method called by the NSURLConnection as data arrives.  We just 
// write the data to the file.
- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
	[_data appendData:data];
}

// A delegate method called by the NSURLConnection if the connection fails. 
// We shut down the connection and display the failure.  Production quality code 
// would either display or log the actual error.
- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
	if([self.delegate respondsToSelector:@selector(CPConnection:didFailWithError:)])
	{
		[self.delegate CPConnection:self didFailWithError:error];
	}
	
    [_connectionManager closeConnectionWithIdentifier:_identifier];
}

// A delegate method called by the NSURLConnection when the connection has been 
// done successfully.  We shut down the connection with a nil status, which 
// causes the image to be displayed.
- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
	if(_data.length > 0)
	{
		if([self.delegate respondsToSelector:@selector(CPConnection:didReceiveResponse:)])
		{
			[self.delegate CPConnection:self didReceiveResponse:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 _data, @"data",
                                                                 [NSNumber numberWithInteger:statusCode], @"statusCode",
                                                                 nil]];
           
        }
	}
    else
    {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Data not found!" forKey:NSLocalizedDescriptionKey];

        NSError * error = [[NSError alloc] initWithDomain:@"Error" code:202 userInfo:details];
        
        if ([self.delegate respondsToSelector:@selector(CPConnection:didFailWithError:)]) {
            [self.delegate CPConnection:self didFailWithError:error];

        }
        
        [self.delegate CPConnection:self didFailWithError:error];

    }
    
	[_connectionManager closeConnectionWithIdentifier:_identifier];
}

@end

@implementation CPConnection

@synthesize delegate = _delegate;
@synthesize identifier = _identifier;
@synthesize request = _request;

- (id)initWithRequest:(CPRequest*)inRequest 
			 delegate:(NSObject <CPConnectionDelegate> *)inDelegate
			  manager:(CPConnectionManager*)inManager
{
    self = [super init];
	if(self)
	{
		_identifier = [CPUtility stringByGeneratingUUID];
		self.delegate = inDelegate;
		_request = inRequest;
		_data = [[NSMutableData alloc] init];
		_connectionManager = inManager;
        
        CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
        
        if(appDelegate.isRootViewController){
            _urlConnection=[NSURLConnection connectionWithRequest:[_request URLRequest] delegate:self];
            
        }
        else{
            
            _urlConnection = [[NSURLConnection alloc] initWithRequest:[_request URLRequest] 
                                                             delegate:self];
        }
	}
	
	return self;
}



- (void)start
{
	[_urlConnection start];
}

- (void)cancel
{
    self.delegate = nil;
	[_urlConnection cancel];
}

@end
