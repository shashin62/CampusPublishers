//
//  CPMasterViewController.m
//  CampusPublishers
//
//  Created by V2Solutions on 29/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
// final code

#import "CPAppDelegate.h"
#import "CPMenuViewController.h"
#import "CPMenu.h"
#import "CPPageViewController.h"
#import "CPNewPageViewController.h"
#import "CMPPage.h"
#import "CPDataManger.h"
#import "CPConfiguration.h"
#import "JSON.h"
#import "CPNetworkConstant.h"
#import "CPRequest.h"
#import "CPUtility.h"
#import "CPUtility.h"
#import "CPAppDelegate.h"
#import <GoogleMobileAds/GADBannerView.h>
#import "CPContent.h"
#import "CpTourGuideIPhone.h"
#import "GAITrackedViewController.h"
#import "RootViewController.h"
#import "CpTourGuideIPhone.h"

@interface CPMenuViewController (PRIVATE)

- (void)initializeAllMemberData;

- (void)initializeAllUIElement;

- (void)getImageRequest:(NSUInteger)index;
- (void)initializeNextViewControllerAndDisplay;

- (void)updateDetailViewController;

@end

@implementation CPMenuViewController (PRIVATE)

- (void)viewDidLoad
{

    self.screenName = @"Menu";
    [super viewDidLoad];
}

- (void)updateDetailViewController
{
    CPMenu *_menu = [[CPDataManger sharedDataManager] selectedMenu];
    UINavigationController *navigationController = (UINavigationController*)self.splitViewController.viewControllers.lastObject;
    // //NSLog(@"navigationController.viewControllers.count:%d",navigationController.viewControllers.count);
    CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
    
    
    ////NSLog(@"isRootViewController: %d",appDelegate.isRootViewController);
    
    
    if(navigationController.viewControllers.count > 1)
    {
        if(appDelegate.isRootViewController==YES){
            if(navigationController.viewControllers.count>=2)
                [navigationController popToRootViewControllerAnimated:NO];
            appDelegate.isRootViewController=NO;
            
        }
        else{
            appDelegate.isRootViewController=NO;
            
            [navigationController popViewControllerAnimated:NO];
        }
        
    }
    
    CPPageViewController *detailViewController = (CPPageViewController*)[navigationController.viewControllers objectAtIndex:0];
    appDelegate.splitViewController.delegate=detailViewController;
    if([detailViewController isKindOfClass:[CPPageViewController class]] == YES)
    {
        detailViewController.navigationItem.title = _menu.name;
        
        if(detailViewController.masterPopoverController != nil)
        {
            [detailViewController.masterPopoverController dismissPopoverAnimated:NO];
        }
        
        [detailViewController updateAndDisplayPageContent];
    }
}
//depending upon,submenu count,navigate to particular view
- (void)initializeNextViewControllerAndDisplay
{
    CPMenu *_menu = [[CPDataManger sharedDataManager] selectedMenu];
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        if([_menu.subMenu count] > 0)
        {
            CPMenuViewController *menuViewController = [[CPMenuViewController alloc] initWithNibName:nil bundle:nil];
            menuViewController.datasource = _menu.subMenu;
            menuViewController.navigationItem.title = _menu.name;
            [self.navigationController pushViewController:menuViewController animated:YES];
        }
        else if([_menu.subMenu count] == 0)
        {
            
            if(_menu.is_tourmap){
                
                
                
                
                if(pageViewController==nil){
                    pageViewController = [[CpTourGuideIPhone alloc] initWithNibName:nil bundle:nil];
                    
                    pageViewController.isTourGuide=YES;
                    //  pageViewController.isBackButtonHiden=YES;
                    [pageViewController setTitle:[[[CPDataManger sharedDataManager] selectedMenu] name]];
                    
                    pageViewController.pathLoopCount=0;
                    pageViewController.isGoogleAPI=NO;
                    pageViewController.isDirectionSelected=NO;
                    
                    [pageViewController performSelector:@selector(upDAteCall) withObject:nil afterDelay:0.2];
                }
                else{
                    [[CPConnectionManager sharedConnectionManager] closeAllConnections];
                    
                    CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
                    appDelegate.isRootViewController=YES;
                    
                    
                    [pageViewController.mapView removeAnnotations:[pageViewController.mapView annotations]];
                    [pageViewController.mapView removeOverlays:[pageViewController.mapView overlays]];
                    if(pageViewController.customImagesDict!=nil)
                        [pageViewController.customImagesDict removeAllObjects];
                    if(pageViewController.annotationsArray!=nil)
                        [pageViewController.annotationsArray removeAllObjects];
                    
                    
                    // pageViewController.isBackButtonHiden=YES;
                    [pageViewController setTitle:[[[CPDataManger sharedDataManager] selectedMenu] name]];
                    
                    
                    
                    
                    pageViewController.isTourGuide=YES;
                    pageViewController.pathLoopCount=0;
                    pageViewController.isGoogleAPI=NO;
                    pageViewController.isDirectionSelected=NO;
                    
                    [pageViewController upDAteCall];
                    
                    
                }
                pageViewController.isGoogleAPI=NO;
                pageViewController.pathLoopCount=0;
                pageViewController.isDirectionSelected=NO;
                [self.navigationController pushViewController:pageViewController animated:NO];
                
                
                
            }
            else{
                
                CPPageViewController *pageViewController1 = [[CPPageViewController alloc] initWithNibName:nil bundle:nil];
                [pageViewController1 setTitle:[[[CPDataManger sharedDataManager] selectedMenu] name]];
                [self.navigationController pushViewController:pageViewController1 animated:YES];
                
            }
        }
    }
}
- (void)initializeAllMemberData
{
    dManager = [CPDataManger sharedDataManager];
    // addBaner = [CPAddBannerView sharedAddBannerView];
    
    CGRect frame = self.view.frame ;
    frame.origin.x = 0.0;
    frame.origin.y = 0.0;
    frame.size.width = 320.0;
    frame.size.height = self.view.frame.size.height;
    
    frame.size.height = [[CPUtility applicationDelegate] window].frame.size.height;
    // CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
    
    
    self.tableViewMenu = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.tableViewMenu.delegate = self;
    self.tableViewMenu.dataSource = self;
    self.tableViewMenu.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:self.tableViewMenu];
    
    selectedIndexPath = nil;
    //self.isRotated = NO;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
}


- (void)initializeAllUIElement
{
    self.navigationController.navigationBar.tintColor =  dManager.configuration.color.header;
    self.tableViewMenu.backgroundColor = dManager.configuration.color.background;
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        UIImage *myImage = [UIImage imageNamed:@"logo.png"];
        UIImageView *imageView = [[UIImageView alloc ]initWithImage:myImage];
        imageView.frame = CGRectMake(0.0, 0.0, myImage.size.width, myImage.size.height);
        
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:imageView];
        
        self.navigationItem.rightBarButtonItem = rightButton;
    }
}



//get the Image for particular index
- (void)getImageRequest:(NSUInteger)index
{
    CPMenu *menu = (CPMenu*)[self.datasource objectAtIndex:index];
    
    @autoreleasepool {
        CPConnectionManager *manager = [CPConnectionManager sharedConnectionManager];
        NSURL *urlServer = menu.imageURL;
        
        CPRequest*request = [[CPRequest alloc] initWithURL:urlServer
                                           withRequestType:CPRequestTypeImage];
        [manager spawnConnectionWithRequest:request delegate:self];
        request.identifier = [NSNumber numberWithInteger:index];
    }
}

@end

@implementation CPMenuViewController

@synthesize isRotated;
@synthesize datasource = _datasource;
@synthesize tableViewMenu = _tableViewMenu;
@synthesize footerView = _footerView;

#pragma mark - init/dealloc -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if(self)
    {
        self.view.backgroundColor = [UIColor clearColor];
    }
    return self;
}



#pragma mark - Memory Management -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - View lifecycle

- (void)loadView
{
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieDidExitFullScreen:)
    //         name:MPMoviePlayerWillExitFullscreenNotification
    //     object:nil];
    
    
    
    [super loadView];
    [self initializeAllMemberData];
    
    
    self.navigationItem.title = @"Menu";
    
    _footerView = [CPFooterView footerViewWithToolBarType:CPFooterItemTypeDefault];
    _footerView.tag = CPFooterItemTypeDefault;
    _footerView.delegate = self;
    [self.view addSubview:_footerView];
    
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [_footerView setItems:nil];
    }else{
        [self showBannarView];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"Page";
}

-(void)movieDidExitFullScreen:(id)sender{
    isMediaPlayer=YES;
}

#pragma marks  - bannerview delegates
-(void)showBannarView{
    //Comment out for screenshots -Austin
    
    gADBannerView = [CPAddBannerView sharedGADBannerView];
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        return;
    }
    
    gADBannerView.frame = CGRectMake(0.0, self.view.frame.size.height , _footerView.frame.size.width, _footerView.frame.size.height);
    
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
        gADBannerView.adSize = kGADAdSizeSmartBannerPortrait;
    }else{
        gADBannerView.adSize = kGADAdSizeFullBanner;
    }
    
    gADBannerView.center =CGPointMake(self.view.center.x, gADBannerView.center.y);
    
    gADBannerView.delegate = self;
    [gADBannerView setRootViewController:self];
    [self.view addSubview:gADBannerView];
    GADRequest *r = [[GADRequest alloc] init];
//    r.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, nil]; // testDevices -Austin
    [gADBannerView loadRequest:r];
    
    
}

-(void)reloadAdd{
    GADRequest *r = [[GADRequest alloc] init];
//    r.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, nil]; // testDevices -Austin
    [gADBannerView loadRequest:r];
}


-(void)adViewDidReceiveAd:(GADBannerView *)view{
    //  [UIView beginAnimations:@"animateAdBannerOn"  context:NULL];
    //[UIView setAnimationDuration:0.0];
    //  GADBannerView *adBanner = [CPAddBannerView sharedAddBannerView].adBanner;
    view.frame = CGRectMake(0.0, self.view.frame.size.height - (_footerView.frame.size.height+BANNER_HEIGHT), _footerView.frame.size.width, view.frame.size.height);
    self.tableViewMenu.frame = CGRectMake(0.0, 0.0, 320.0, self.view.frame.size.height - (44.0+BANNER_HEIGHT));
    
    // [UIView commitAnimations];
    
}

-(void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error{
    //GADBannerView *adBanner = [CPAddBannerView sharedAddBannerView].adBanner;
    view.frame = CGRectMake(0.0, self.view.frame.size.height , _footerView.frame.size.width, _footerView.frame.size.height);
    self.tableViewMenu.frame = CGRectMake(0.0, 0.0, 320.0, self.view.frame.size.height - 44);
    
}
-(void)adViewWillDismissScreen:(GADBannerView *)adView{
    isAddOPen=YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
    
    if (appDelegate.isMediaPlayer==YES) {
        appDelegate.isMediaPlayer=NO;
        return;
    }
    
    self.tableViewMenu.frame=CGRectMake(0, 0, 320, self.view.frame.size.height);
    
    
    [_tableViewMenu reloadData];
    [super viewWillAppear:animated];
    [self initializeAllUIElement];
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        
        CPConfiguration *configuration = (CPConfiguration*)dManager.configuration;
        _footerView.tintColor = configuration.color.footer;
        _footerView.frame = CGRectMake(0.0, self.view.frame.size.height - 44.0, _footerView.frame.size.width, _footerView.frame.size.height);
        [self reloadAdd];
        
        
        //  (isAddOPen==YES)?(isAddOPen=NO):[self showBannarView];
        
    }
    else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        
        _footerView.tintColor = dManager.configuration.color.footer;
        _footerView.frame = CGRectMake(0.0, self.view.frame.size.height - 44.0, _footerView.frame.size.width, _footerView.frame.size.height);
        self.tableViewMenu.frame = CGRectMake(0.0, 0.0, 320.0, self.view.frame.size.height - 44.0);
        
        [self.tableViewMenu reloadData];
        if([[CPUtility applicationDelegate] isSplitViewConfigured] == NO)
        {
            if(self.navigationController.viewControllers.count == 1)
            {/*
              NSArray *datasource = [[CPDataManger sharedDataManager] datasource];
              if(datasource.count > 0)
              {
              CPMenu *menu = (CPMenu*)[datasource objectAtIndex:0];
              CPMenuViewController *controller = [[CPMenuViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
              controller.datasource = menu.subMenu;
              controller.navigationItem.title = menu.name;
              [self.navigationController pushViewController:controller animated:NO];
              [controller release];
              }
              
              */
                [CPUtility applicationDelegate].isSplitViewConfigured = YES;
            }
            
            
        }
        else
        {
            if(self.navigationController.viewControllers.count == 2)
            {
                CPMenuViewController *menuController = (CPMenuViewController*)self.navigationController.viewControllers.lastObject;
                if(self.datasource.count > 0)
                {
                    UINavigationController *navigationController = (UINavigationController*)self.splitViewController.viewControllers.lastObject;
                    CPPageViewController *detailViewController = (CPPageViewController*)[navigationController.viewControllers objectAtIndex:0];
                    CPMenu *_menu = [self.datasource objectAtIndex:selectedIndexPath.row];
                    detailViewController.navigationItem.title = _menu.name;
                    [[CPDataManger sharedDataManager] setSelectedMenu:_menu];
                    
                    int detailCount = detailViewController.navigationController.viewControllers.count;
                    menuController.isRotated = [[[NSUserDefaults standardUserDefaults] valueForKey:@"isRotated"] boolValue];
                    if((detailCount == 2 && menuController.isRotated == YES) || (menuController.isRotated == YES))
                        //if(detailCount == 2 && menuController.isRotated == YES)
                    {
                        if(!appDelegate.isRootViewController)
                            [detailViewController.navigationController popToRootViewControllerAnimated:YES];
                    }
                    
                    CGRect rect = [[UIApplication sharedApplication] statusBarFrame];
                    NSUserDefaults *sud = [NSUserDefaults standardUserDefaults];
                    if(rect.size.width == 20.0 && rect.size.height == 1024.0)
                    {
                        [sud setValue:[NSNumber numberWithBool:YES]
                               forKey:@"isRotated"];
                    }
                    else
                    {
                        [sud setValue:[NSNumber numberWithBool:NO]
                               forKey:@"isRotated"];
                    }
                    
                    [sud synchronize];
                    
                    if(detailViewController.isIPadUIConfigured == YES)
                    {
                        CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
                        if(!appDelegate.isRootViewController)
                            [detailViewController updateAndDisplayPageContent];
                    }
                }
            }
            
            if(selectedIndexPath != nil && [selectedIndexPath isKindOfClass:[NSIndexPath class]] == YES){
                BOOL isAppLanuch=[[[NSUserDefaults standardUserDefaults] objectForKey:@"APP_LAUNCH"] boolValue];
                if (!isAppLanuch) {
                    [self.tableViewMenu selectRowAtIndexPath:selectedIndexPath
                                                    animated:NO
                                              scrollPosition:UITableViewScrollPositionNone];
                }
            }
        }
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    isAddOPen=NO;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        
        //[[CPConnectionManager sharedConnectionManager] closeAllConnections];
    }
    else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        if([[CPUtility applicationDelegate] isSplitViewConfigured] == YES)
        {
            UINavigationController *navigationController = (UINavigationController*)self.splitViewController.viewControllers.lastObject;
            CPPageViewController *detailViewController = (CPPageViewController*)[navigationController.viewControllers objectAtIndex:0];
            if(detailViewController.navigationItem.leftBarButtonItem == nil)
            {
                [[CPConnectionManager sharedConnectionManager] closeAllConnections];
            }
        }
        else
        {
            CGRect rect = [[UIApplication sharedApplication] statusBarFrame];
            NSUserDefaults *sud = [NSUserDefaults standardUserDefaults];
            if(rect.size.width == 20.0 && rect.size.height == 1024.0)
            {
                [sud setValue:[NSNumber numberWithBool:YES]
                       forKey:@"isRotated"];
            }
            else
            {
                [sud setValue:[NSNumber numberWithBool:NO]
                       forKey:@"isRotated"];
            }
            
            [sud synchronize];
        }
    }
    
    [super viewWillDisappear:animated];
}

//
#pragma mark - UIInterfaceOrientation -
//override if want to support orientations other than default portrait orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    self.navigationController.navigationBar.tintColor =  dManager.configuration.color.header;
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }else{
        /*
         CPAppDelegate *appDelegate= (CPAppDelegate*)[UIApplication sharedApplication].delegate;
         
         CGRect rect=self.view.frame;
         rect.size.height=appDelegate.window.rootViewController.interfaceOrientation>2?appDelegate.window.frame.size.width:self.view.frame.size.height;
         self.view.frame=rect;
         self.tableViewMenu.frame=CGRectMake(0, 0, 320, self.view.frame.size.height);
         self.tableViewMenu.frame=CGRectMake(0, 0, 320, self.view.frame.size.height);*/
    }
    
    return YES;
}


-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        return;
    }else{
        
    }
    
    /*
     CPAppDelegate *appDelegate= (CPAppDelegate*)[UIApplication sharedApplication].delegate;
     self.view.frame=CGRectMake(0, 0,  appDelegate.window.rootViewController.interfaceOrientation>2?320:self.view.frame.size.width,appDelegate.window.rootViewController.interfaceOrientation>2?(appDelegate.window.frame.size.width-64):(appDelegate.window.frame.size.height-64));
     
     CGRect rect=self.view.frame;
     rect.size.height=appDelegate.window.rootViewController.interfaceOrientation>2>1?(appDelegate.window.frame.size.width- 64):self.view.frame.size.height;
     self.view.frame=rect;
     self.tableViewMenu.frame=CGRectMake(0, 0, 320,appDelegate.window.rootViewController.interfaceOrientation>2?(appDelegate.window.frame.size.width- 64):self.view.frame.size.height);*/
    
}

#pragma mark - CPFooterViewDelegate -
- (void)footerView:(CPFooterView*)footerView didClickItemWithType:(CPFooterItemType)type
{
    if(type == CPFooterItemTypeDefault)
    {
        ZBarReaderViewController *reader = [ZBarReaderViewController new];
        reader.readerDelegate = self;
        
        reader.readerView.torchMode = 0;
        
        ZBarImageScanner *scanner = reader.scanner;
        // TODO: (optional) additional reader configuration here
        
        // EXAMPLE: disable rarely used I2/5 to improve performance
        [scanner setSymbology: ZBAR_I25
                       config: ZBAR_CFG_ENABLE
                           to: 0];
        
        // present and release the controller
        [self presentModalViewController: reader
                                animated: YES];
    }
    
}

#pragma mark - UITableviewdatasource -
// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.datasource count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIView *bgView = [[UIView alloc] init];
        [bgView setBackgroundColor:dManager.configuration.color.header];
        cell.selectedBackgroundView = bgView;
    }
    
    cell.imageView.image = [UIImage imageNamed:@"MenuIconPlaceholder.png"];
    cell.textLabel.textColor = dManager.configuration.color.menuFontColor;
    
    //setting title for rows from datasource
    CPMenu *menu = (CPMenu*)[self.datasource objectAtIndex:indexPath.row];
    
    //show activity indicator till images from data are loading from server
    if (menu.image == nil)
    {
        if(cell.imageView.subviews.count == 0)
        {
            UIActivityIndicatorView *activityView =  [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [cell.imageView addSubview:activityView];
            [activityView sizeToFit];
            CGRect rect = activityView.frame;
            rect.origin.x = (cell.imageView.image.size.width - rect.size.width) / 2;
            rect.origin.y = (cell.imageView.image.size.height - rect.size.height) / 2;
            activityView.frame = rect;
            
            [activityView startAnimating];
        }
        
        [self getImageRequest:indexPath.row];
    }
    else
    {
        //as soon as iamges are fetched,load them as images on cell
        if(cell.imageView.subviews.count > 0)
        {
            UIActivityIndicatorView *_activityView = (UIActivityIndicatorView*)[cell.imageView.subviews objectAtIndex:0];
            [_activityView stopAnimating];
            [_activityView removeFromSuperview];
        }
        
        cell.imageView.image = menu.image;
    }
    
    cell.textLabel.text = menu.name;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if([animationID isEqualToString:@"animateAdBannerOff"] == YES)
    {
        /*ADBannerView *banner = [CPAddBannerView sharedAddBannerView].adBannerView;
         if(banner.superview != nil)
         {
         banner.delegate = nil;
         [banner removeFromSuperview];
         }*/
        
        [self initializeNextViewControllerAndDisplay];
    }
}

//select/deselect the row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
    
    
    
    [[CPConnectionManager sharedConnectionManager] closeAllConnections];
    
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"APP_LAUNCH"];
        
        selectedIndexPath = indexPath;
        [[CPDataManger sharedDataManager] setSelectedMenu:[self.datasource objectAtIndex:indexPath.row]];
        CPMenu *_menu = [[CPDataManger sharedDataManager] selectedMenu];
        
        if([_menu.subMenu count] > 0)
        {
            CPMenuViewController *menuViewController = [[CPMenuViewController alloc] initWithNibName:nil bundle:nil];
            menuViewController.datasource = _menu.subMenu;
            menuViewController.navigationItem.title = _menu.name;
            [self.navigationController pushViewController:menuViewController animated:YES];
        }
        else if([_menu.subMenu count] == 0)
        {
            
            
            /*
             if (appDelegate.cpTourGuideIPhone!=nil) {
             if([appDelegate.cpTourGuideIPhone.masterPopoverController isPopoverVisible]) {
             [appDelegate.cpTourGuideIPhone.masterPopoverController dismissPopoverAnimated:YES];
             }
             }
             
             
             if (appDelegate.detailViewController!=nil) {
             
             if([appDelegate.detailViewController.masterPopoverController isPopoverVisible]) {
             [appDelegate.detailViewController.masterPopoverController dismissPopoverAnimated:YES];
             }
             }
             */
            
            [self menuButtonAction];
            
            
            [self updateDetailViewController];
        }
        
        
    }
    
    
    
    else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [[CPDataManger sharedDataManager] setSelectedMenu:[self.datasource objectAtIndex:indexPath.row]];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        CPMenu *_menu = [[CPDataManger sharedDataManager] selectedMenu];
        
        if([_menu.subMenu count] > 0)
        {
            CPMenuViewController *menuViewController = [[CPMenuViewController alloc] initWithNibName:nil bundle:nil];
            menuViewController.datasource = _menu.subMenu;
            [menuViewController setTitle:_menu.name];
            [self.navigationController pushViewController:menuViewController animated:YES];
            
        }
        else if([_menu.subMenu count] == 0)
        {
            //CPPageViewController *pageViewController = [[CPPageViewController alloc] initWithNibName:nil bundle:nil];
            
            // //NSLog(@"is_tourmap: %d",_menu.is_tourmap);
            
            
            if(_menu.is_tourmap){
                
                
                if(pageViewController==nil){
                    pageViewController = [[CpTourGuideIPhone alloc] initWithNibName:nil bundle:nil];
                    
                    pageViewController.isTourGuide=YES;
                    // pageViewController.isBackButtonHiden=YES;
                    [pageViewController setTitle:[[[CPDataManger sharedDataManager] selectedMenu] name]];
                    
                    pageViewController.pathLoopCount=0;
                    pageViewController.isGoogleAPI=NO;
                    pageViewController.isDirectionSelected=NO;
                    
                    [pageViewController performSelector:@selector(upDAteCall) withObject:nil afterDelay:0.2];
                }
                else{
                    [[CPConnectionManager sharedConnectionManager] closeAllConnections];
                    
                    CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
                    appDelegate.isRootViewController=YES;
                    
                    
                    [pageViewController.mapView removeAnnotations:[pageViewController.mapView annotations]];
                    [pageViewController.mapView removeOverlays:[pageViewController.mapView overlays]];
                    if(pageViewController.customImagesDict!=nil)
                        [pageViewController.customImagesDict removeAllObjects];
                    if(pageViewController.annotationsArray!=nil)
                        [pageViewController.annotationsArray removeAllObjects];
                    
                    
                    //pageViewController.isBackButtonHiden=YES;
                    [pageViewController setTitle:[[[CPDataManger sharedDataManager] selectedMenu] name]];
                    
                    
                    
                    
                    pageViewController.isTourGuide=YES;
                    pageViewController.pathLoopCount=0;
                    pageViewController.isGoogleAPI=NO;
                    pageViewController.isDirectionSelected=NO;
                    
                    [pageViewController upDAteCall];
                    
                    
                }
                pageViewController.isDirectionSelected=NO;
                pageViewController.pathLoopCount=0;
                pageViewController.isGoogleAPI=NO;
                
                
                [self.navigationController pushViewController:pageViewController animated:NO];
                
                
            }
            else{
                
                CPNewPageViewController *pageViewController1 = [[CPNewPageViewController alloc] initWithNibName:nil bundle:nil];
                [pageViewController1 setTitle:[[[CPDataManger sharedDataManager] selectedMenu] name]];
                [self.navigationController pushViewController:pageViewController1 animated:YES];
                
            }
            
            
            
            
        }
    }
}






//customized height for cell
#pragma mark - UITableViewDelegate -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0;
}

#pragma mark - CPConnectionDelegate -
- (void)CPConnection:(CPConnection*)CPConnection didReceiveResponse:(id)response
{
    CPRequestType _type = CPConnection.request.type;
    if(_type == CPRequestTypeImage)
    {
        NSData *_data = [(NSDictionary*)response valueForKey:@"data"];
        CPMenu *menu = (CPMenu*)[self.datasource objectAtIndex:[CPConnection.request.identifier intValue]];
        menu.image = [UIImage imageWithData:_data];
        [self.tableViewMenu reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[CPConnection.request.identifier intValue]
                                                                                               inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationNone];
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            if(selectedIndexPath != nil && [selectedIndexPath isKindOfClass:[NSIndexPath class]] == YES)
            {
                //[self.tableViewMenu selectRowAtIndexPath:selectedIndexPath  animated:NO  scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }
}

- (void)CPConnection:(CPConnection*)CPConnection didFailWithError:(NSError*)error
{
    CPRequestType _type = CPConnection.request.type;
    if(_type == CPRequestTypeImage)
    {
        UITableViewCell *cell = [self.tableViewMenu cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[CPConnection.request.identifier intValue]
                                                                                             inSection:0]];
        if(cell.imageView.subviews.count > 0)
        {
            UIActivityIndicatorView *_activityView = (UIActivityIndicatorView*)[cell.imageView.subviews objectAtIndex:0];
            [_activityView stopAnimating];
            [_activityView removeFromSuperview];
        }
    }
    else
    {
        NSString *message = nil;
        if(error.code == 403)
        {
            
            message = @"The operation could not be completed this time. Please check your network connection and try again.";
        }
        else if(error.code == 202)
        {
            message = @"Data not found!!!";
        }
        else
        {
            message = error.localizedDescription;
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"UMD"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - ADBannerViewDelegate -
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if(banner == [[CPAddBannerView sharedAddBannerView] adBannerView])
    {
        [UIView beginAnimations:@"animateAdBannerOn"
                        context:NULL];
        [UIView setAnimationDuration:0.0];
        
        // set the banner origin visible
        CGRect rect = banner.frame;
        rect.origin.y = self.view.frame.size.height - rect.size.height;
        banner.frame = rect;
        
        // set footer view
        rect = _footerView.frame;
        rect.origin.y = self.view.frame.size.height - rect.size.height - banner.frame.size.height;
        _footerView.frame = rect;
        
        // set table view size to occupy full screen
        rect = self.tableViewMenu.frame;
        rect.size.height = _footerView.frame.origin.y;
        self.tableViewMenu.frame = rect;
        
        [UIView commitAnimations];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if(banner == [[CPAddBannerView sharedAddBannerView] adBannerView])
    {
        [UIView beginAnimations:@"animateAdBannerOff"
                        context:NULL];
        [UIView setAnimationDuration:0.0];
        
        CGRect rect = CGRectZero;
        
        // set the banner origin.y to out of bound
        rect = banner.frame;
        rect.origin.y = self.view.frame.size.height + rect.size.height;
        banner.frame = rect;
        
        // set the footer view
        rect = _footerView.frame;
        rect.origin.y = self.view.frame.size.height - rect.size.height;
        _footerView.frame = rect;
        
        // set the table view
        rect =  self.tableViewMenu.frame;
        rect.size.height = _footerView.frame.origin.y;
        self.tableViewMenu.frame = rect;
        
        [UIView commitAnimations];
    }
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    BOOL shouldExecuteAction = YES;
    
    if (!willLeave && shouldExecuteAction)
    {
        // stop all interactive processes in the app
        // [video pause];
        // [audio pause];
    }
    return shouldExecuteAction;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    // resume everything you've stopped
    // [video resume];
    // [audio resume];
}

#pragma mark - UIImagePickerControllerDelegate -


-(void)imagePickerController:(UIImagePickerController *)reader didFinishPickingMediaWithInfo:(NSDictionary *)info{
    // ADD: get the decode results
    CPAppDelegate *appDelegate= (CPAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate upDateViewFramewithPicker:reader toReplaceView:self.view];
    isAddOPen=YES;
    
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    NSString *hiddenData = nil;
    for(symbol in results)
        hiddenData=[NSString stringWithString:symbol.data];
    
    NSURL *url = [NSURL URLWithString:hiddenData];
    
    if ([[[url scheme] lowercaseString] isEqualToString:@"http"])
    {
        qrContent = [[CPContent alloc] init];
        qrContent.type = CPContentTypeURL;
        qrContent.text = hiddenData;
        CPPageViewController *_pageViewController = [[CPPageViewController alloc] initWithNibName:nil bundle:nil];
        _pageViewController.qrContent = qrContent;
        _pageViewController.title = @"Results";
        [self.navigationController pushViewController:_pageViewController animated:NO];
//        [reader dismissModalViewControllerAnimated: NO];
        [reader dismissViewControllerAnimated:NO completion:nil];
    }
    else
    {
        qrContent = [[CPContent alloc] init];
        qrContent.type = CPContentTypeHTML;
        qrContent.text = hiddenData;
        CPPageViewController *_pageViewController = [[CPPageViewController alloc] initWithNibName:nil bundle:nil];
        _pageViewController.qrContent = qrContent;
        _pageViewController.title = @"Results";
        [self.navigationController pushViewController:_pageViewController animated:NO];
//        [reader dismissModalViewControllerAnimated: NO];
        [reader dismissViewControllerAnimated:NO completion:nil];
        
    }
}


-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    CPAppDelegate *appDelegate= (CPAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate upDateViewFramewithPicker:picker toReplaceView:self.view];
//    [picker dismissModalViewControllerAnimated:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
    isAddOPen=YES;
    
}



-(void)menuButtonAction{
    CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    UIInterfaceOrientation orientation=[[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation== UIInterfaceOrientationPortrait  ||  orientation== UIInterfaceOrientationPortraitUpsideDown) {
        if (version>=6.0) {
            if (appDelegate.splitViewController!=nil) {
                if (appDelegate.isLandScape==NO) {
                    [appDelegate.splitViewController performSelector:@selector(toggleMasterVisible:)];
                    appDelegate.isSetUpViewClosed=NO;
                }
            }
        }
        else{
            
            
            
            
            //     if ([appDelegate.detailViewController.masterPopoverController isPopoverVisible]) {
            if (appDelegate.masterPopoverController !=nil) {
                [appDelegate.masterPopoverController dismissPopoverAnimated:YES];
            }
            
            
            if([appDelegate.cpTourGuideIPhone.masterPopoverController isPopoverVisible]) {
                [appDelegate.cpTourGuideIPhone.masterPopoverController dismissPopoverAnimated:YES];
            }
            
        }
        
    }
}

@end
