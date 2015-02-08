//
//  CPRequest.m
//  CampusPublishers
//
//  Created by V2Solutions on 26/07/11.
//  Copyright 2011 V2Solutions. All rights reserved.
//

#import "CPRequest.h"

#import "CPAppDelegate.h"
@interface CPRequest (PRIVATE)

@end

@implementation CPRequest (PRIVATE)

@end

@implementation CPRequest

@dynamic URL;
@dynamic userAgent;
@dynamic requestBody;
@synthesize URLRequest = _urlRequest;
@synthesize type = _type;
@synthesize identifier = _identifier;
@synthesize  indexForOverLay;

- (id)initWithURL:(NSURL*)inURL withRequestType:(CPRequestType)inType
{
    self = [super init];
	if(self)
	{
		_url = inURL;

		_userAgent = nil;
		self.type = inType;

		if(_url != nil)
		{
            
			_urlRequest = [[NSMutableURLRequest alloc] initWithURL:_url];
		}
		else
		{
			_urlRequest = [[NSMutableURLRequest alloc] init];
		}
        
      //  //NSLog(@"%@",_url);
       // if(inType==CPRequestTypeTour){
            
       // }
       // else{
        [_urlRequest setHTTPMethod:HTTP_METHOD_GET];
        [_urlRequest setTimeoutInterval:TIME_OUT_INTERVAL];
        [_urlRequest setValue:REQUEST forHTTPHeaderField:@"request"];
        [_urlRequest setValue:COMPRESSION forHTTPHeaderField:@"Accept-Encoding"];
       // }
    }
	return self;
}



- (void)setURL:(NSURL*)inURL
{
	[_urlRequest setURL:inURL];
	_url = inURL;
}

- (NSURL*)URL
{
    return _url;
}

- (void)setUserAgent:(NSString*)inAgent
{
	if(_userAgent == nil)
	{
		[_urlRequest addValue:inAgent forHTTPHeaderField:@"User-Agent"];
	}
	else
	{
		[_urlRequest setValue:inAgent forHTTPHeaderField:@"User-Agent"];
	}
	
	_userAgent = inAgent;
}

- (void)setRequestBody:(NSString*)inBody
{
	_requestBody = inBody;
	[_urlRequest setHTTPBody:[_requestBody dataUsingEncoding:NSASCIIStringEncoding]];
}

- (void)setHttpMethod:(NSString *)httpMethod
{
    [_urlRequest setHTTPMethod:httpMethod];
}

@end
