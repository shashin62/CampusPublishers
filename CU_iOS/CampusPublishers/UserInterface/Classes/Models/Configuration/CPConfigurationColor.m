//
//  CPConfigurationColor.m
//  CampusPublishers
//
//  Created by v2team on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CPConfigurationColor.h"

@implementation CPConfigurationColor

@synthesize header      = _header;
@synthesize headerText  = _headerText;
@synthesize footer      = _footer;
@synthesize footerText  = _footerText;
@synthesize background  = _background;
@synthesize menuFontColor = _menuFontColor;
@synthesize visited_path_color,tour_path_color;
-(id) init{

    self = [super init];
    self.header = nil;
    self.headerText = nil;
    self.footer = nil;
    self.footerText = nil;
    self.background = nil;
    self.menuFontColor = nil;
    
    return self;
}

-(BOOL) isEqual:(id)object
{
    return NO;
}

-(NSUInteger) hash{
    
    return 601;
}

-(NSString *) description
{
    
    //[NSString stringWithFormat:@"header: %@, headerText: %@ , footer: %@, footerText: %@, background : %@",@"menuFontColor :" ,self.header, self.headerText, self.footer, self.footerText, self.background,self.menuFontColor]
    return  [NSString stringWithFormat:@"headerText: %@ ,footerText: %@, background : %@" ,self.headerText,  self.footerText, self.background];
}



@end
