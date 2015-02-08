//
//  CPDataManger.m
//  CampusPublishers
//
//  Created by v2team on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CPDataManger.h"
#import "CPConfiguration.h"
#import "CPMenu.h"
#import "CMPPage.h"
#import "CPContent.h"
#import "CMPImage.h"
#import "CPVideo.h"
#import "CPConfigurationColor.h"
#import "CPConfigurationFont.h"
#import "CPUtility.h"
#import "CPUniversity.h"
#import "CPConstants.h"
#import "CPAdmob.h"
@implementation CPDataManger
@synthesize datasource = _datasource;
@synthesize configuration = _configuration;
@synthesize selectedMenu = _selectedMenu;
@synthesize dictionary = dictInfo;
@synthesize orientation;
static CPDataManger *sharedDataManager = nil;

- (id)init
{
    self = [super init];
	if(self)
	{
        self.datasource = [NSMutableArray array];
        self.configuration = nil;
        self.selectedMenu = nil;
        
      

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
        
        if([[self.dictionary objectForKey:@"isLiveMode"] boolValue] == NO) 
        {   
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for(int loop = 0; loop < 10; loop++)
            {
                CPMenu *menu = [CPMenu new];
                menu.id = [NSNumber numberWithInt:loop + 1];
                menu.name = [NSString stringWithFormat:@"Menu %d", loop + 1];
                menu.image = [UIImage imageNamed:@"icon.png"];
                [array addObject:menu];
                
                for(int _loop = 0; _loop < 3; _loop++)
                {
                    CPMenu *_menu = [CPMenu new];
                    [menu.subMenu addObject:_menu];
                    
                    _menu.id = [NSNumber numberWithInt:_loop + 1];
                    _menu.parentId = menu.id;
                    _menu.name = [NSString stringWithFormat:@"Submenu %d", _loop + 1];
                    
                    CMPPage *page = [[CMPPage alloc] init];
                    _menu.page = page;
                    
                    // add text content
                    CPContent *content = [[CPContent alloc] init];
                    _menu.page.content = content;
                    
                    _menu.page.content.text = @"<html><body><h1>It works!</h1></body></html>";
                    _menu.page.content.type = CPContentTypeHTML;
                    
                    // add image content
                    for(int imgLoop = 0; imgLoop < 10; imgLoop++)
                    {
                        CMPImage *imageContent = [CMPImage new];
                        [_menu.page.images addObject:imageContent];
                        
                        //conditional check for testing dynamic data per image
                        if(imgLoop % 2 == 0)
                        {
                            imageContent.text = @"Sample Text";
                        }
                        else 
                        {
                            imageContent.text = @"Smaple text demo";
                        }
                        [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://192.168.25.67/flower.png"]]];
                    }
                    
                    // add video content
                    for(int vidLoop = 0; vidLoop < 3; vidLoop++)
                    {
                        CPVideo *video = [CPVideo new];
                        [_menu.page.videos addObject:video];
                        
                        video.text = @"Sample Text";
                        video.image =  [UIImage imageNamed:@"ImagePlaceholder.png"];
                    }
                }
            }
            
            self.datasource = array;
            
            CPConfiguration *_config = [[CPConfiguration alloc] init];
            self.configuration = _config;
            
            CPConfigurationColor *_color = [[CPConfigurationColor alloc] init];
            self.configuration.color = _color;
            
            CPUniversity *_university = [[CPUniversity alloc] init];
            self.configuration.university = _university;
            
            CPAdmob *_admobid = [[CPAdmob alloc] init];
            self.configuration.admobid = _admobid;
            
            self.configuration.university.id = [dictInfo objectForKey:@"UniversityID"];
            self.configuration.admobid = [dictInfo objectForKey:@"AdMobID"]; //TODO: Admob_ID placeholder
            
            
            self.configuration.university.latitude = [NSNumber numberWithDouble:19.180237];
            self.configuration.university.longitude = [NSNumber numberWithDouble:72.8554149];
            self.configuration.university.showRoute = YES;   
            
            self.configuration.color.header = [UIColor colorWithRed:195.0/255.0 
                                                              green:37.0/ 255.0 
                                                               blue:57.0/255.0 
                                                              alpha:1.0];
            self.configuration.color.headerText = [UIColor whiteColor];
            self.configuration.color.footer = [UIColor colorWithRed:195.0/255.0 
                                                              green:37.0/ 255.0 
                                                               blue:57.0/255.0 
                                                              alpha:1.0];
            self.configuration.color.footerText = [UIColor whiteColor];
            self.configuration.color.background = [UIColor lightGrayColor];
         
            
            self.configuration.color.tour_path_color = [CPUtility colorFromHexString:DEFAULT_PATH_COLOR];
            self.configuration.color.visited_path_color = [CPUtility colorFromHexString:VISITED_PATH_COLOR];

        }
    }
    
	return self;
}

//Update the datasource for Live mode
-(void) updateDataSource:(NSArray*)data
{
//    NSString* plistPath = nil;
//#if TARGET_CAMPUS
//    plistPath = [[NSBundle mainBundle] pathForResource:@"CampusPublishers-Config" ofType:@"plist"];
//#elif TARGET_UMD
//    plistPath = [[NSBundle mainBundle] pathForResource:@"UMD-Config" ofType:@"plist"];
//#endif
//    NSDictionary *dictInfo = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    if([[self.dictionary objectForKey:@"isLiveMode"] boolValue] == YES) 
    {
        [self.datasource removeAllObjects];
        for(NSMutableDictionary *dictMain in data)
        {    
            CPMenu *menu = [[CPMenu alloc] init];
            menu.id = [dictMain objectForKey:@"id"];
            menu.name = [dictMain objectForKey:@"name"];
            
            if([dictMain objectForKey:@"image"] != nil && ![[dictMain objectForKey:@"image"] isEqualToString:@""])
            {
                NSString *path = [NSString stringWithFormat:@"%@/iphone/%@/%@", self.configuration.imagePath, [CPUtility deviceDensity],[dictMain objectForKey:@"image"]];
                menu.imageURL = [NSURL URLWithString:path];
            }
            
            NSMutableArray *_subMenu = [[NSMutableArray alloc] init];
            for(NSMutableDictionary *dict in [dictMain objectForKey:@"submenus"])
            {
                CPMenu *menu = [[CPMenu alloc] init];
                menu.id = [dict objectForKey:@"id"];
                menu.name = [dict objectForKey:@"name"];
                menu.is_tourmap = [[dict objectForKey:@"is_tourmap"] boolValue];
                menu.category_id = [[dict objectForKey:@"category_id"] intValue];
                menu.is_map = [[dict objectForKey:@"is_map"] boolValue];

             //   //NSLog(@"is_tourmap: %d",menu.is_tourmap);
                
                
                if([dict objectForKey:@"image"] != nil && ![[dict objectForKey:@"image"] isEqualToString:@""])
                {
                    NSString *path = [NSString stringWithFormat:@"%@/iphone/%@/%@", self.configuration.imagePath, [CPUtility deviceDensity],[dict objectForKey:@"image"]];
                    menu.imageURL = [NSURL URLWithString:path];
                }
                
                menu.parentId = [dictMain objectForKey:@"id"];
                [_subMenu addObject:menu];
            }
            menu.subMenu = _subMenu;
            [self.datasource addObject:menu];
        }
    }
}

//configure the data,as per selected university
- (void) configurationData:(NSDictionary*)data
{
    
    ////NSLog(@"data:%@",data);
    
//     NSString* plistPath = nil;
//#if TARGET_CAMPUS
//    plistPath = [[NSBundle mainBundle] pathForResource:@"CampusPublishers-Config" ofType:@"plist"];
//#elif TARGET_UMD
//    plistPath = [[NSBundle mainBundle] pathForResource:@"UMD-Config" ofType:@"plist"];
//#endif
//    NSDictionary *dictInfo = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    if([[self.dictionary objectForKey:@"isLiveMode"] boolValue] == YES) 
    {
        CPConfiguration *_config = [[CPConfiguration alloc] init];
        self.configuration = _config;
        
        CPConfigurationColor *_color = [[CPConfigurationColor alloc] init];
        self.configuration.color = _color;
        
        CPUniversity * _university = [[CPUniversity alloc] init];
        self.configuration.university = _university;
        
        CPAdmob *_admobid = [[CPAdmob alloc] init];
        self.configuration.admobid = _admobid;
        
        CPConfigurationFont *_font = [[CPConfigurationFont alloc] init];
        self.configuration.font = _font;
        //--font
        
        
        self.configuration.color.header = [CPUtility colorFromHexString:[data objectForKey:@"header_background_color"]];
        self.configuration.color.headerText = [CPUtility colorFromHexString:[data objectForKey:@"header_font_color"]];
        self.configuration.color.footer = [CPUtility colorFromHexString:[data objectForKey:@"footer_background_color"]];
        self.configuration.color.footerText = [CPUtility colorFromHexString:[data objectForKey:@"footer_font_color"]];
        self.configuration.color.background = [CPUtility colorFromHexString:[data objectForKey:@"page_background_color"]];
        self.configuration.color.menuFontColor = [CPUtility colorFromHexString:[data objectForKey:@"menu_font_color"]];
        
       // //NSLog(@"%@",[data objectForKey:@"tour_path_color"]);
        
        if(![data objectForKey:@"tour_path_color"])
            self.configuration.color.tour_path_color = [CPUtility colorFromHexString:[data objectForKey:@"tour_path_color"]];
        else
            self.configuration.color.tour_path_color = [CPUtility colorFromHexString:[data objectForKey:@"tour_path_color"]];
        
        ////NSLog(@"%@",[data objectForKey:@"visited_path_color"]);

        
        if(![data objectForKey:@"visited_path_color"])
            self.configuration.color.visited_path_color = [UIColor orangeColor];
        else
            self.configuration.color.visited_path_color = [CPUtility colorFromHexString:[data objectForKey:@"visited_path_color"]];


        
        self.configuration.university.id = [dictInfo objectForKey:@"UniversityID"];
        self.configuration.university.latitude = [data objectForKey:@"latitude"];
       self.configuration.university.longitude = [data objectForKey:@"longitude"];
        
        self.configuration.admobid = [dictInfo objectForKey:@"AdMobID"];
        
        self.configuration.university.showRoute = [[data objectForKey:@"show_direction"] boolValue];        
        self.configuration.imagePath = [data objectForKey:@"image_path"];
        self.configuration.videoPath = [data objectForKey:@"video_path"];
        
    }
} 

#pragma -------- Methods to implement singlton class

+ (CPDataManger*)sharedDataManager
{
	@synchronized(self) 
	{
        if(sharedDataManager == nil) 
		{
            [[self alloc] init]; // assignment not done here
        }
    }
	
    return sharedDataManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) 
	{
        if(sharedDataManager == nil) 
		{
            sharedDataManager = [super allocWithZone:zone];
            return sharedDataManager;  // assignment and return on first allocation
        }
    }
	
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}





@end
