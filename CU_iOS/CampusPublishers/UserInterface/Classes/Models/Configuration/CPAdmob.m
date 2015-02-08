//
//
// CPAdmob.m
//
// Created by Austin Bookheimer 2/13/14
//
//

#import "CPAdmob.h"

@implementation CPAdmob

@synthesize id  = _id;
@synthesize admobid = _admobid;
@synthesize dictionary = dictInfo;

-(id)init{

    self = [super init];
    self.id = nil;
    //self.admobid = nil;
    
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
    
    self.admobid = [dictInfo objectForKey:@"AdMobID"];
    
    return self;
}

@end