//
//  CPAnalytics.m
//  CampusPublishersDEV
//
//  Created by August on 9/16/14.
//
//

#import "CPAnalytics.h"

@implementation CPAnalytics


@synthesize id  = _id;
@synthesize analyticsid = _analyticsid;
@synthesize dictionary = dictInfo;

-(id)init{
    
    self = [super init];
    self.id = nil;
    
    NSArray *paths = [[NSBundle mainBundle] pathsForResourcesOfType:@".plist" inDirectory:nil];
    NSString* plistPath = nil;
    if(paths.count > 0)
    {
        for(plistPath in paths)
        {
            if([plistPath rangeOfString:@"-Config.plist"].length > 0)
            {
                self.dictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
                break;
            }
        }
    }
    
    self.analyticsid = [dictInfo objectForKey:@"GAnalyticsID"];
    
    return self;
}

@end

