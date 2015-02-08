/*
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple Software"), to
 use, reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
 to endorse or promote products derived from the Apple Software without specific
 prior written permission from Apple.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Apple herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be
 incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2008 Apple Inc. All Rights Reserved.
 
 */

#import <SystemConfiguration/SCNetworkReachability.h>
#import <netinet/in.h>

#import "NetReachability.h"

//MACROS:

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#define IS_REACHABLE(__FLAGS__) (((__FLAGS__) & kSCNetworkReachabilityFlagsReachable) && !((__FLAGS__) & kSCNetworkReachabilityFlagsConnectionRequired))
#if TARGET_IPHONE_SIMULATOR
#define IS_CELL(__FLAGS__) (0)
#else
#define IS_CELL(__FLAGS__) (IS_REACHABLE(__FLAGS__) && ((__FLAGS__) & kSCNetworkReachabilityFlagsIsWWAN))
#endif
#else
#define IS_REACHABLE(__FLAGS__) (((__FLAGS__) & kSCNetworkFlagsReachable) && !((__FLAGS__) & kSCNetworkFlagsConnectionRequired))
#define IS_CELL(__FLAGS__) (0)
#endif

//CLASS IMPLEMENTATION:

@implementation NetReachability

static void _ReachabilityCallBack(SCNetworkReachabilityRef target, SCNetworkConnectionFlags flags, void* info)
{
	NSAutoreleasePool*              pool = [NSAutoreleasePool new];
	NetReachability*                self = (__bridge NetReachability*)info;
	
	[self->_delegate reachabilityDidUpdate:self reachable:(IS_REACHABLE(flags) ? YES : NO) usingCell:(IS_CELL(flags) ? YES : NO)];

	[[NSNotificationCenter defaultCenter] postNotificationName:@"ReachabilityChangedNotification" object: self];
	
	[pool release];
}

@synthesize delegate=_delegate;

/*
 This will consume a reference of "reachability"
 */
- (id) _initWithNetworkReachability:(SCNetworkReachabilityRef)reachability
{
	if(reachability == NULL) 
    {
		[self release];
		return nil;
	}
	
	if((self = [super init])) 
    {
		_runLoop = (CFRunLoopRef)CFRetain(CFRunLoopGetCurrent());
		_netReachability = reachability;
	}
	
	return self;
}

- (id) initWithDefaultRoute:(BOOL)ignoresAdHocWiFi
{
	return [self initWithIPv4Address:(ignoresAdHocWiFi ? INADDR_ANY : IN_LINKLOCALNETNUM)];
}

- (id) initWithAddress:(const struct sockaddr*)address
{
	return [self _initWithNetworkReachability:(address ? SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, address) : NULL)];
}

- (id) initWithIPv4Address:(UInt32)address
{
	struct sockaddr_in                              ipAddress;
	
	bzero(&ipAddress, sizeof(ipAddress));
	ipAddress.sin_len = sizeof(ipAddress);
	ipAddress.sin_family = AF_INET;
	ipAddress.sin_addr.s_addr = htonl(address);
	
	return [self initWithAddress:(struct sockaddr*)&ipAddress];
}

- (id) initWithHostName:(NSString*)name
{
	return [self _initWithNetworkReachability:([name length] ? SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [name UTF8String]) : NULL)];
}



- (BOOL) isReachable
{
	SCNetworkConnectionFlags    flags;
	
	return (SCNetworkReachabilityGetFlags(_netReachability, &flags) && IS_REACHABLE(flags) ? YES : NO);
}

- (BOOL) isUsingCell
{
	SCNetworkConnectionFlags    flags;
	
	return (SCNetworkReachabilityGetFlags(_netReachability, &flags) && IS_CELL(flags) ? YES : NO);
}

- (void) setDelegate:(id<NetReachabilityDelegate>)delegate
{
	SCNetworkReachabilityContext    context = {0, self, NULL, NULL, NULL};
	
	if(delegate && !_delegate) 
    {
		if(SCNetworkReachabilitySetCallback(_netReachability, _ReachabilityCallBack, &context)) 
        {
			if(!SCNetworkReachabilityScheduleWithRunLoop(_netReachability, _runLoop, kCFRunLoopCommonModes)) 
            {
				SCNetworkReachabilitySetCallback(_netReachability, NULL, NULL);
				delegate = nil;
			}
		}
		else
			delegate = nil;
	}
	else if(!delegate && _delegate) 
    {
		SCNetworkReachabilityUnscheduleFromRunLoop(_netReachability, _runLoop, kCFRunLoopCommonModes);
		SCNetworkReachabilitySetCallback(_netReachability, NULL, NULL);
	}
	
	_delegate = delegate;
}

- (BOOL) startNotifier
{
	BOOL retVal = NO;
	SCNetworkReachabilityContext	context = {0, self, NULL, NULL, NULL};
	if(SCNetworkReachabilitySetCallback(_netReachability, _ReachabilityCallBack, &context))
	{
		if(SCNetworkReachabilityScheduleWithRunLoop(_netReachability, _runLoop, kCFRunLoopCommonModes))
		{
			retVal = YES;
		}
	}
	return retVal;
}


- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = 0x%08lX | reachable = %i>", [self class], (long)self, [self isReachable]];
}

@end