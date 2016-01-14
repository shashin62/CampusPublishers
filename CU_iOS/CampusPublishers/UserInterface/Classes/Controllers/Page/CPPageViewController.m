//
//  CPPageViewController.m
//  CampusPublishers
//
//  Created by V2Solutions on 30/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "CpTourGuideIPhone.h"
#import "CPPageViewController.h"
#import "CMPPage.h"
#import "CPContent.h"
#import "CPFooterView.h"
#import "CPDataManger.h"
#import "CPConfiguration.h"
#import "CPGalleryViewController.h"
#import "CPMenu.h"
#import "JSON.h"
#import "CPNetworkConstant.h"
#import "CPRequest.h"
#import "CPConstants.h"
#import "CMPImage.h"
#import "CPVideo.h"
#import "CPUtility.h"
#import "CPAppDelegate.h"
#import "CPAddBannerView.h"
#import "ZBarSDK.h"
#import "CPMenuViewController.h"
#import "LoadingView.h"

#import "CustomImageView.h"
#import "RootViewController.h"


#define WIDTH    (1024-64)


#define HEIGHT    (763-64)
#define EXTRA_HEIGHT8    8


@interface CPPageViewController (PRIVATE)




- (void)initializeAllMemberData;
- (void)initializeAllUIElement;

- (void)callServicePage;
- (void)showActivityIndicator:(BOOL)yorn;
- (void)dataDisplay;
- (void)animateFooterView:(BOOL)animated;
- (void)initializeNextViewControllerAndDisplay:(CPFooterItemType)type;
- (void)removeLoadingView;
- (void)getImageAtIndex:(int)index forURL:(NSURL*)url;

@end

@implementation CPPageViewController (PRIVATE)

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    self.screenName = @"Page";
//}


//get the image as per index,with the related URL
- (void)getImageAtIndex:(int)index forURL:(NSURL*)url
{
    //NSLog(@"%@",url);
    
    @autoreleasepool {
        CPConnectionManager *manager = [CPConnectionManager sharedConnectionManager];
        CPRequest*request = [[CPRequest alloc] initWithURL:url
                                           withRequestType:CPRequestTypeImage];
        [manager spawnConnectionWithRequest:request delegate:self];
        request.identifier = [NSNumber numberWithInteger:index];
    }
}

- (void)initializeAllMemberData
{
    dtManager = [CPDataManger sharedDataManager];
    self.qrContent = nil;
    _footerView = nil;
    self.masterPopoverController = nil;
    self.isIPadUIConfigured = NO;
}



- (void)initializeAllUIElement
{
    dtManager = [CPDataManger sharedDataManager];
    
    //setting image for university logo
    UIImage *myImage = [UIImage imageNamed:@"logo.png"];
    UIImageView *imageView = [[UIImageView alloc ]initWithImage:myImage];
    imageView.frame = CGRectMake(0.0, 0.0, myImage.size.width, myImage.size.height);
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    
    //configuration settings as per university
    self.view.backgroundColor = [UIColor whiteColor];
    
    //adding webview for diplaying page contents
    //_imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ImagePlaceholderTwo.png"]];
    _imgView = [[CustomImageView alloc] init];
    _imgView.imageView.image=[UIImage imageNamed:@"ImagePlaceholderTwo.png"];
    _imgView.contentMode = UIViewContentModeCenter;
    _imgView.delegate=self;
    _imgView.userInteractionEnabled=YES;
    _imgView.contentSize=CGSizeMake(320.0f, 320.0f);
    
    
    CGRect scrollViewFrame = _imgView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / _imgView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / _imgView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    _imgView.minimumZoomScale = minScale;
    _imgView.maximumZoomScale =  .0f;
    _imgView.zoomScale = minScale;
    _imgView.backgroundColor=[UIColor clearColor];
    
    
    _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    
    
    
    
    CGRect frame = self.view.frame;
    _webView = [[UIWebView alloc] initWithFrame:frame];
    [self.view addSubview:_webView];
    
    
    
    activityView =  [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView sizeToFit];
    CGRect _frame = activityView.frame;
    _frame.origin.x = (self.view.frame.size.width - _frame.size.width)/2;
    _frame.origin.y = (self.view.frame.size.height - (_frame.size.height + 44.0))/2;
    activityView.frame = _frame;
    
    //activity indicator added to show the progress of the process
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [_webView addSubview:activityView];
    }
}

-(void) backClicked:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}



//activity indicator animation start/stop
- (void)showActivityIndicator:(BOOL)yorn
{
    if(activityView != nil)
    {
        if(yorn == YES)
        {
            [activityView startAnimating];
        }
        else if(yorn == NO)
        {
            [activityView stopAnimating];
        }
    }
}

//method calling service for fetching page contents
- (void)callServicePage
{
    @autoreleasepool {
        CPConnectionManager *manager = [CPConnectionManager sharedConnectionManager];
        CPMenu *menu = [[CPDataManger sharedDataManager] selectedMenu];
        
        NSString *strURL = nil;
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            strURL = [NSString stringWithFormat:@"%@pages?method=getPage&pageId=%d&deviceId=%d", SERVER_URL,[menu.id intValue] , CPDeviceTypeiPhone];
        }
        else
        {
            strURL = [NSString stringWithFormat:@"%@pages?method=getPage&pageId=%d&deviceId=%d", SERVER_URL,[menu.id intValue] , CPDeviceTypeiPad];
        }
        
        NSURL *urlServer = [NSURL URLWithString:strURL];
        CPRequest*request = [[CPRequest alloc] initWithURL:urlServer withRequestType:CPRequestTypePage];
        request.identifier = menu.id;
        [manager spawnConnectionWithRequest:request delegate:self];
    }
}

//common method used for displaying the basic page contents
- (void)dataDisplay
{
    BOOL isAppLanuch=[[[NSUserDefaults standardUserDefaults] objectForKey:@"APP_LAUNCH"] boolValue];
    if (!isAppLanuch) {
        if (startImageView!=nil) {
            [startImageView removeFromSuperview];
            [startView removeFromSuperview];
        }
    }
    //get the selected menu item
    CPMenu *menu = [[CPDataManger sharedDataManager] selectedMenu];
    CPConfiguration *configuration = (CPConfiguration*)dtManager.configuration;
    
    //depending upontype of page content (HTML text/URL),load the page
    if(self.qrContent != nil)
    {
        [_webView stopLoading];
        if(self.qrContent.type == CPContentTypeHTML)
        {
            if(self.qrContent.text != nil)
            {
                [_webView loadHTMLString:self.qrContent.text baseURL:nil];
            }
        }
        else if(self.qrContent.type == CPContentTypeURL)
        {
            if(self.qrContent.text != nil)
            {
                [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.qrContent.text]]];
            }
        }
    }
    else
    {
        
        // CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
        // appDelegate.isRootViewController=YES;
        
        if(menu.is_tourmap){
            
            
            if(pageViewController==nil){
                pageViewController = [[CpTourGuideIPhone alloc] initWithNibName:nil bundle:nil];
                
                pageViewController.isTourGuide=YES;
                pageViewController.isBackButtonHiden=YES;
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
                
                
                pageViewController.isBackButtonHiden=YES;
                [pageViewController setTitle:[[[CPDataManger sharedDataManager] selectedMenu] name]];
                pageViewController.isTourGuide=YES;
                pageViewController.pathLoopCount=0;
                pageViewController.isGoogleAPI=NO;
                pageViewController.isDirectionSelected=NO;
                
                [pageViewController upDAteCall];
                
            }
            pageViewController.isDirectionSelected=NO;
            pageViewController.isGoogleAPI=NO;
            [self.navigationController pushViewController:pageViewController animated:NO];
        }
        else{
//            [[CPConnectionManager sharedConnectionManager] closeAllConnections];
            
            [_webView stopLoading];
            _webView.delegate = self;
            if(menu.page.content.type == CPContentTypeHTML)
            {
                if(menu.page.content.text != nil)
                {
                    [_webView loadHTMLString:menu.page.content.text baseURL:nil];
                }
            }
            else if(menu.page.content.type == CPContentTypeURL)
            {
                if(menu.page.content.text != nil)
                {
                    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:menu.page.content.text]]];
                }
            }
            
            //adding footerView depending upon its type,if its nil
            if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                
                if(_footerView.superview != nil)
                {
                    [_footerView removeFromSuperview];
                    _footerView = nil;
                }
                
                if([menu.page.images count] > 0 && [menu.page.videos count] > 0)
                {
                    _footerView = [CPFooterView footerViewWithToolBarType:CPFooterItemTypeImagesVideos];
                    _footerView.tag = CPFooterItemTypeImagesVideos;
                }
                else if([menu.page.images count] > 0)
                {
                    _footerView = [CPFooterView footerViewWithToolBarType:CPFooterItemTypeImage];
                    _footerView.tag = CPFooterItemTypeImage;
                }
                else if([menu.page.videos count] > 0)
                {
                    _footerView = [CPFooterView footerViewWithToolBarType:CPFooterItemTypeVideo];
                    _footerView.tag = CPFooterItemTypeVideo;
                }
                else if([menu.page.images count] == 0 && [menu.page.videos count] == 0)
                {
                    _footerView = [CPFooterView footerViewWithToolBarType:CPFooterItemTypeDefault];
                    _footerView.tag = CPFooterItemTypeDefault;
                }
                //if([[self.navigationItem.title lowercaseString] isEqualToString:@"map"])
                if(menu.is_map)
                    
                {
                    if(dtManager.configuration.university.showRoute == YES)
                    {
                        _footerView = [CPFooterView footerViewWithToolBarType:CPFooterItemShowDirection];
                        _footerView.tag = CPFooterItemShowDirection;
                    }
                    if([menu.page.images count] > 0)
                    {
                        _footerView = [CPFooterView footerViewWithToolBarType:CPFooterItemTypeSDImage];
                        _footerView.tag = CPFooterItemTypeImage;
                    }
                    if([menu.page.videos count] > 0)
                    {
                        _footerView = [CPFooterView footerViewWithToolBarType:CPFooterItemTypeSDVideos];
                        _footerView.tag = CPFooterItemTypeVideo;
                    }
                    if([menu.page.images count] > 0 && [menu.page.videos count] > 0)
                    {
                        _footerView = [CPFooterView footerViewWithToolBarType:CPFooterItemTypeSDAll];
                        _footerView.tag = CPFooterItemTypeSDAll;
                    }
                }
                
                _footerView.tintColor = configuration.color.footer;
                _footerView.frame = CGRectMake(0.0, self.view.frame.size.height -44.0, _footerView.frame.size.width, _footerView.frame.size.height);
                _footerView.delegate = self;
                [self.view addSubview:_footerView];
            }
            else
            {
                if (_footerView == nil)
                {
                    if([menu.page.images count] > 0 && [menu.page.videos count] > 0)
                    {
                        _footerView = [CPFooterView footerViewWithToolBarType:CPFooterItemTypeImagesVideos];
                        _footerView.tag = CPFooterItemTypeImagesVideos;
                    }
                    else if([menu.page.images count] > 0)
                    {
                        _footerView = [CPFooterView footerViewWithToolBarType:CPFooterItemTypeImage];
                        _footerView.tag = CPFooterItemTypeImage;
                    }
                    else if([menu.page.videos count] > 0)
                    {
                        _footerView = [CPFooterView footerViewWithToolBarType:CPFooterItemTypeVideo];
                        _footerView.tag = CPFooterItemTypeVideo;
                    }
                    else if([menu.page.images count] == 0 && [menu.page.videos count] == 0)
                    {
                        _footerView = [CPFooterView footerViewWithToolBarType:CPFooterItemTypeDefault];
                        _footerView.tag = CPFooterItemTypeDefault;
                    }
                    //   if([[self.title lowercaseString] isEqualToString:@"map"])
                    if(menu.is_map)
                        
                    {
                        if(dtManager.configuration.university.showRoute == YES)
                        {
                            
                            _footerView = [CPFooterView footerViewWithToolBarType:CPFooterItemShowDirection];
                            
                            _footerView.tag = CPFooterItemShowDirection;
                        }
                        if([menu.page.images count] > 0)
                        {
                            _footerView = [CPFooterView footerViewWithToolBarType:CPFooterItemTypeSDImage];
                            _footerView.tag = CPFooterItemTypeImage;
                        }
                        if([menu.page.videos count] > 0)
                        {
                            _footerView = [CPFooterView footerViewWithToolBarType:CPFooterItemTypeSDVideos];
                            _footerView.tag = CPFooterItemTypeVideo;
                        }
                        if([menu.page.images count] > 0 && [menu.page.videos count] > 0)
                        {
                            _footerView = [CPFooterView footerViewWithToolBarType:CPFooterItemTypeSDAll];
                            _footerView.tag = CPFooterItemTypeSDAll;
                        }
                    }
                    
                    _footerView.tintColor = configuration.color.footer;
                    _footerView.frame = CGRectMake(0.0, self.view.frame.size.height -44.0, _footerView.frame.size.width, _footerView.frame.size.height);
                    _footerView.delegate = self;
                    [self.view addSubview:_footerView];
                }
            }
            
            if(menu.page.image != nil)
            {
                _imgView.imageView.image = [UIImage imageNamed:@"ImagePlaceholderTwo.png"];
                _imgView.tag = menu.id.intValue;
                if(menu.page.image.image == nil)
                {
                    UIActivityIndicatorView *_activityView = (UIActivityIndicatorView *)[_imgView.imageView viewWithTag:200200];
                    if(_activityView == nil)
                    {
                        _activityView =  [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                        [_activityView setTag:200200];
                        [_imgView.imageView addSubview:_activityView];
                        [_activityView startAnimating];
                        
                        [_activityView sizeToFit];
                        CGRect rect = _activityView.frame;
                        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                        {
                            rect.origin.x = (_imgView.imageView.frame.size.width - rect.size.width) / 2;
                            rect.origin.y = (_imgView.imageView.frame.size.height - rect.size.height) / 2;
                        }
                        else
                        {
                            rect.origin.x = (_imgView.imageView.frame.size.width/2 - rect.size.width) / 2;
                            rect.origin.y = (_imgView.imageView.frame.size.height/2 - rect.size.height) / 2;
                        }
                        _activityView.frame = rect;
                    }
                    
                    [self getImageAtIndex:(int)_imgView.tag
                                   forURL:((CMPImage*)menu.page.image).imageUrl];
                }
                else if(menu.page.image.image != nil)
                {
                    UIActivityIndicatorView *_activityView = (UIActivityIndicatorView *)[_imgView.imageView viewWithTag:200200];
                    if(_activityView != nil)
                    {
                        [_activityView removeFromSuperview];
                    }
                    
                    if(_imgView.tag == menu.id.intValue)
                    {
                        _imgView.imageView.image = menu.page.image.image;
                    }
                }
                
                if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                {
                    
                    if(menu.is_map)
                    {
                        
                        _imgView.frame =  CGRectMake(0, 0, isLandScape?703:768, (isLandScape?HEIGHT-95:WIDTH-95)*0.6);
                        
                        _imgView.imageView.frame=CGRectMake(0, 0, _imgView.frame.size.width, _imgView.frame.size.height);
                        CGRect scrollViewFrame = _imgView.frame;
                        CGFloat scaleWidth = scrollViewFrame.size.width / _imgView.contentSize.width;
                        CGFloat scaleHeight = scrollViewFrame.size.height / _imgView.contentSize.height;
                        CGFloat minScale = MIN(scaleWidth, scaleHeight);
                        _imgView.minimumZoomScale = minScale;
                        _imgView.maximumZoomScale = 3.0f;
                        _imgView.zoomScale = minScale;
                    }
                    else{
                        
                        UIImage *image=[UIImage imageNamed:@"ImagePlaceholderTwo.png"];
                        //  _imgView.frame =  CGRectMake((self.view.frame.size.width - _imgView.frame.size.width)/2, 5.0, image.size.width,image.size.height);
                        
                        _imgView.frame =  CGRectMake((self.view.frame.size.width - image.size.width)/2, 5.0, image.size.width,image.size.height); //This here is where the frame for where the page image is placed. -Austin
                        
                        _imgView.imageView.frame=CGRectMake(0, 5.0, _imgView.frame.size.width, _imgView.frame.size.height);
                        
                        
                        
                        //_imgView.frame=normalFrame;
                    }
                }
                else
                {
                    _imgView.frame =  CGRectMake((self.view.frame.size.width - _imgView.frame.size.width/2.0)/2, 2.5, _imgView.frame.size.width/2.0, _imgView.frame.size.height/2.0);
                }
                
                _webView.frame = CGRectMake(0.0, _imgView.frame.size.height + 10.0, self.view.frame.size.width, self.view.frame.size.height -( _footerView.frame.size.height + _imgView.frame.size.height+EXTRA_HEIGHT8));
                
                if(_imgView.superview == nil)
                {
                    [self.view addSubview:_imgView];
                }
            }
            else
            {
                if(_imgView.superview != nil)
                {
                    [_imgView removeFromSuperview];
                }
                
                _webView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - _footerView.frame.size.height-EXTRA_HEIGHT8);
            }
        }
        
    }
    if(_footerView == nil)
    {
        [self animateFooterView:YES];
    }
    else
    {
        /* if (![[NSUserDefaults standardUserDefaults] objectForKey:@"APP_LAUNCH"]) {
         [self animateFooterView:NO];
         }*/
        
        BOOL isAppLanuch=[[[NSUserDefaults standardUserDefaults] objectForKey:@"APP_LAUNCH"] boolValue];
        //gADBannerView.hidden=isAppLanuch?YES:NO;
        _footerView.hidden=isAppLanuch?YES:NO;
        
        if (!isAppLanuch) {
            [self animateFooterView:NO];
        }
        // [self animateFooterView:NO];
    }
    
    
    
    if(menu.is_map){
        _imgView.userInteractionEnabled=YES;
        _imgView.contentMode = UIViewContentModeRedraw;
        
        [_imgView.imageView sizeToFit];
    }
    else{
        _imgView.userInteractionEnabled=NO;
        // _imgView.imageView.autoresizingMask = UIViewAutoresizingNone;
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    
    
    _imgView.delegate=self;
    //_imgView.userInteractionEnabled=YES;
    _imgView.contentSize=_imgView.frame.size;
    // _imgView.center = CGPointMake(320.0f, 320.0f);
    _imgView.showsHorizontalScrollIndicator=NO;
    _imgView.showsVerticalScrollIndicator=NO;
    
    CGRect scrollViewFrame = _imgView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / _imgView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / _imgView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    _imgView.minimumZoomScale = minScale;
    _imgView.maximumZoomScale = 10.0f;
    _imgView.zoomScale = minScale;
    _imgView.contentMode = UIViewContentModeCenter;
    
    
}

//slide up/slide down UIView animation on footerview
- (void)animateFooterView:(BOOL)animated
{
    
    [UIView beginAnimations:@"animateAdBannerOn"
                    context:NULL];
    [UIView setAnimationDuration:0.0];
    CGRect rect = self.view.frame;
    
    rect.size.height = self.view.frame.size.height - _footerView.frame.size.height;
    rect.origin.y = 0.0;
    
    if(_imgView.superview != nil)
    {
        rect.origin.y = _imgView.frame.size.height+10;
        rect.size.height = self.view.frame.size.height - (_footerView.frame.size.height +  _imgView.frame.size.height+BANNER_HEIGHT+EXTRA_HEIGHT8);
    }else{
        rect.size.height = self.view.frame.size.height - _footerView.frame.size.height-BANNER_HEIGHT;
    }
    
    _webView.frame = rect;
    
    
    
    rect = _footerView.frame;
    rect.origin.y = self.view.frame.size.height - 44;
    _footerView.frame = rect;
    
    bgBannerView.frame=CGRectMake(0, self.view.frame.size.height-(BANNER_HEIGHT+_footerView.frame.size.height), self.view.frame.size.width, BANNER_HEIGHT);
    
    
    [UIView commitAnimations];
    //NSLog(@"_footerView.hidden: %d",_footerView.hidden);
    
    //NSLog(@"_footerView.frame: %@",NSStringFromCGRect(_footerView.frame));
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        BOOL isAppLanuch=[[[NSUserDefaults standardUserDefaults] objectForKey:@"APP_LAUNCH"] boolValue];
        //gADBannerView.hidden=isAppLanuch?YES:NO;
        _footerView.hidden=isAppLanuch?YES:NO;
    }
    
}

//Depending upon FooterType,navigate to next view
- (void)initializeNextViewControllerAndDisplay:(CPFooterItemType)type
{
    CPMenu *menu = [[CPDataManger sharedDataManager] selectedMenu];
    
    //go to MapView
    if(type == CPFooterItemShowDirection)
    {
        if(mapViewController==nil){
            mapViewController = [[RootViewController alloc] initWithNibName:nil bundle:nil] ;
        }
        else{
            if(mapViewController.mapView!=nil){
                [mapViewController.mapView removeAnnotations:[mapViewController.mapView annotations]];
                [mapViewController.mapView removeOverlays:[mapViewController.mapView overlays]];
            }
        }
        
        mapViewController.isRoot=YES;
        mapViewController.isAtCampus=NO;
        mapViewController.isDirectionSelected=NO;
        mapViewController.isGoogleAPI=NO;
        
        [self.navigationController pushViewController:mapViewController animated:YES];
    }
    
    //go to galleryView with type "Images"
    else if(type == CPFooterItemTypeImage)
    {
        CPGalleryViewController * galleryViewController = [[CPGalleryViewController alloc] initWithNibName:nil bundle:nil];
        galleryViewController.footerType = CPFooterItemTypeImage;
        galleryViewController.dataGallary = menu.page.images;
        [self.navigationController pushViewController:galleryViewController animated:YES];
    }
    
    //go to galleryView with type "Videos"
    else if(type == CPFooterItemTypeVideo)
    {
        CPGalleryViewController * galleryViewController = [[CPGalleryViewController alloc] initWithNibName:nil bundle:nil];
        galleryViewController.footerType = CPFooterItemTypeVideo;
        galleryViewController.dataGallary = menu.page.videos;
        [self.navigationController pushViewController:galleryViewController animated:YES];
    }
    
    //go to galleryView with type "ImagesVideos"
    else if(type == CPFooterItemTypeImagesVideos)
    {
        CPGalleryViewController * galleryViewController = [[CPGalleryViewController alloc] initWithNibName:nil bundle:nil];
        galleryViewController.footerType = CPFooterItemTypeImagesVideos;
        [self.navigationController pushViewController:galleryViewController animated:YES];
    }
    
    //go to galleryView with type "Default",basically the QRCode scan
    else if(type == CPFooterItemTypeDefault)
    {
        ZBarReaderViewController *reader = [ZBarReaderViewController new];
        reader.readerDelegate = self;
        zbarReader=reader;
        isScanner=YES;
        reader.readerView.torchMode = 0;
        
        ZBarImageScanner *scanner = reader.scanner;
        
        // TODO: (optional) additional reader configuration here
        
        // EXAMPLE: disable rarely used I2/5 to improve performance
        [scanner setSymbology: ZBAR_I25
                       config: ZBAR_CFG_ENABLE
                           to: 0];
        
        
        // present and release the controller
        [self.navigationController presentViewController:reader animated:YES completion:nil];
//        [self.navigationController presentModalViewController: reader animated: YES];
        
    }
}

- (void)removeLoadingView
{
    [loadView removeView];
    if(loadView != nil)
    {
        loadView = nil;
    }
}

@end

@implementation CPPageViewController

//@synthesize orientation;
@synthesize mapViewController;
@synthesize qrContent = qrContent;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize isIPadUIConfigured;
@synthesize gADBannerView;

#pragma mark - init/dealloc -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        [self initializeAllMemberData];
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
// This is where subclasses should create their custom view hierarchy if they aren't using a nib. Should never be called directly.
- (void)loadView
{
    
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    view.autoresizesSubviews = YES;
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.view = view;
    
    [self initializeAllUIElement];
    bgBannerView=[[UIView alloc]init];
    bgBannerView.backgroundColor=[UIColor whiteColor];
    bgBannerView.frame=CGRectMake(0, self.view.frame.size.height-(BANNER_HEIGHT+_footerView.frame.size.height), self.view.frame.size.width, BANNER_HEIGHT);
    [self.view addSubview:bgBannerView];
    [self showBannarView];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"Page";
}


#pragma marks  - admob delegates
-(void)showBannarView{
    
    //Comment for them screenshots -Austin
    /*
    if (gADBannerView!=nil) {
        [gADBannerView removeFromSuperview];
    }
    gADBannerView=nil;
    gADBannerView.delegate=nil;
    gADBannerView = [CPAddBannerView sharedGADBannerView];
    
    gADBannerView.frame = CGRectMake(0.0, self.view.frame.size.height , self.view.frame.size.width, 44);
    gADBannerView.adSize = kGADAdSizeBanner;
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
    
    */
}




-(void)reloadAdd{
    GADRequest *r = [[GADRequest alloc] init];
//    r.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, nil]; // testDevices -Austin
    [gADBannerView loadRequest:r];
}


-(void)adViewDidReceiveAd:(GADBannerView *)view{
    CGRect rect=view.frame;
    rect.origin.y=self.view.frame.size.height - (_footerView.frame.size.height+BANNER_HEIGHT);
    rect.size.height=50;
    view.frame=rect;
    
    //  if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
    
    rect=_webView.frame;
    if (_imgView.superview!=nil) {
        rect.size.height = self.view.frame.size.height - (_footerView.frame.size.height +  _imgView.frame.size.height+BANNER_HEIGHT+EXTRA_HEIGHT8);
    }else{
        rect.size.height = self.view.frame.size.height - (_footerView.frame.size.height +BANNER_HEIGHT+EXTRA_HEIGHT8);
    }
    
    _webView.frame=rect;
    
    
    // bgBannerView.frame=CGRectMake(0, self.view.frame.size.height-(BANNER_HEIGHT+_footerView.frame.size.height ), self.view.frame.size.width, BANNER_HEIGHT);
    
    
    
    // }else{
    
    //   }
    //NSLog(@"NSStringFromCGRect: %@",NSStringFromCGRect(view.frame));
}

-(void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error{
    
    CGRect rect=view.frame;
    rect.origin.y=self.view.frame.size.height;
    view.frame=rect;
    
    // if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
    rect=_webView.frame;
    if (_imgView.superview!=nil) {
        rect.size.height = self.view.frame.size.height - (_footerView.frame.size.height +  _imgView.frame.size.height+BANNER_HEIGHT+8);
    }else{
        rect.size.height = self.view.frame.size.height - (_footerView.frame.size.height+BANNER_HEIGHT+8);
    }
    _webView.frame=rect;
    //}
    
}
-(void)adViewWillDismissScreen:(GADBannerView *)adView{
}


// Called when the view is about to made visible. Default does nothing
- (void)viewWillAppear:(BOOL)animated
{
    
    [self reloadAdd];
    
    
    //NSLog(@"self.view.frame: %@",NSStringFromCGRect(self.view.frame));
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor =  dtManager.configuration.color.header;
    self.navigationController.navigationBar.translucent = NO; //For fixing view on iPad -Austin
    
    //set frame for the Page contents,such as Banner,Footer,Webview,ImageView,according to thier Loading/Unloading
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        
        
        
        CGRect rect = self.view.frame;
        rect.size.height = self.view.frame.size.height - _footerView.frame.size.height;
        if(_imgView.superview != nil)
        {
            rect.origin.y = _imgView.frame.size.height;
            rect.size.height = self.view.frame.size.height - (_footerView.frame.size.height + _imgView.frame.size.height);
        }
        
        
        //qrcontent is set while ONLY during Scanning,else it's nil
        if (self.qrContent != nil)
        {
            rect.size.height = self.view.frame.size.height - _footerView.frame.size.height;
            
        }
        _webView.frame = rect;
        
        rect = _footerView.frame;
        rect.origin.y = self.view.frame.size.height - rect.size.height;
        
        
        _footerView.frame = rect;
        [UIView commitAnimations];
        
        if(self.qrContent == nil)
        {
            CPMenu *menu = [[CPDataManger sharedDataManager] selectedMenu];
            if(menu.page == nil)
            {
                CPAppDelegate *appDelegate= (CPAppDelegate *)[[UIApplication sharedApplication] delegate];
                if((appDelegate.reachability.reachable == NO) && ([appDelegate isReachableWiFi] ==  NO))
                {
                    [self showActivityIndicator:NO];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:NSLocalizedString(@"NetworkCheck","")
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles: nil];
                    [alert show];
                }
                else
                {
                    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                    {
                        [activityView startAnimating];
                    }
                    
                    [self callServicePage];
                }
            }
            else
            {
                [self dataDisplay];
            }
        }
        else
        {
            [self dataDisplay];
        }
    }
    else
    {
        
        
        CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
        
        if(!appDelegate.isRootViewController)
            [self dataDisplay];
        
        
    }
    
    [self upDateUI];
    
    [self animateFooterView:YES];
}





-(void)viewDidAppear:(BOOL)animated{
    if (self.interfaceOrientation==UIInterfaceOrientationLandscapeRight ||self.interfaceOrientation==UIInterfaceOrientationLandscapeLeft) {
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    }
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        
        // creating  default image view
        BOOL isAppLanuch=[[[NSUserDefaults standardUserDefaults] objectForKey:@"APP_LAUNCH"] boolValue];
        if (isAppLanuch) {
            if (startImageView==nil && startImageView.superview==nil) {
                
                startView=[[UIView alloc]init];
                startView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                startView.backgroundColor=[UIColor whiteColor];
                [self.view addSubview:startView];
                
                startImageView =[[UIImageView alloc]init];
                startImageView.frame=CGRectMake((startView.frame.size.width-704)/2,(startView.frame.size.height-704)/2,704,704);
                startImageView.image=[UIImage imageNamed:@"Photo-for-opening-screen.png"];
                startImageView.backgroundColor=[UIColor clearColor];
                [startView addSubview:startImageView];
                
            }
            [self.view bringSubviewToFront:startImageView];
        }else{
            if (startImageView!=nil) {
                [startImageView removeFromSuperview];
                [startView removeFromSuperview];
            }
        }
        
    }
    
    BOOL isAppLanuch=[[[NSUserDefaults standardUserDefaults] objectForKey:@"APP_LAUNCH"] boolValue];
    if (isAppLanuch &&isMenuPopUP) {
        //if (isMenuPopUP==YES) {
        UIInterfaceOrientation orientation=[[UIApplication sharedApplication] statusBarOrientation];
        if( orientation==UIInterfaceOrientationPortrait ||orientation==UIInterfaceOrientationPortraitUpsideDown){
            [self menuButtonAction];
        }
    }
    
    //NSLog(@"NSStringFromCGRect: %@",NSStringFromCGRect(self.view.frame));
}


- (void)viewWillDisappear:(BOOL)animated
{
    
    
    
    //[[CPConnectionManager sharedConnectionManager] closeAllConnections];
    _webView.delegate = nil;
    [_webView stopLoading];
    [super viewWillDisappear:animated];
    
}

//override if want to support orientations other than default portrait orientation
#pragma mark - UIInterfaceOrientation -
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return  (interfaceOrientation == UIInterfaceOrientationPortrait);
    }else{
        
        if([masterPopoverController isPopoverVisible]){
            [masterPopoverController dismissPopoverAnimated:NO];
        }
        
        
        if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait)||([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown)){
            isLandScape=NO;
        }
        else{
            isLandScape=YES;
        }
        
        CPAppDelegate *appDelegate= (CPAppDelegate*)[UIApplication sharedApplication].delegate;
        self.view.frame=CGRectMake(0, 0,  self.interfaceOrientation>2?(appDelegate.window.frame.size.height-320):appDelegate.window.frame.size.width,self.interfaceOrientation>2?(appDelegate.window.frame.size.width-64):(appDelegate.window.frame.size.height-64));
        
        if (startImageView!=nil) {
            startView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            startImageView.frame=CGRectMake((startView.frame.size.width-704)/2,(startView.frame.size.height-704)/2,704,704);
            [self.view bringSubviewToFront:startImageView];
        }
        
        BOOL isAppLanuch=[[[NSUserDefaults standardUserDefaults] objectForKey:@"APP_LAUNCH"] boolValue];
        gADBannerView.hidden=isAppLanuch?YES:NO;
        bgBannerView.hidden=isAppLanuch?YES:NO;
        _footerView.hidden=isAppLanuch?YES:NO;
        gADBannerView.frame = CGRectMake(0.0, self.view.frame.size.height , self.view.frame.size.width, 44);
        
        
        
        
    }
    
    return YES;
}
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        
        if([masterPopoverController isPopoverVisible]){
            [masterPopoverController dismissPopoverAnimated:NO];
        }
        
        
        if (startImageView!=nil) {
            startView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            startImageView.frame=CGRectMake((startView.frame.size.width-704)/2,(startView.frame.size.height-704)/2,704,704);
            [self.view bringSubviewToFront:startImageView];
        }
        
        BOOL isAppLanuch=[[[NSUserDefaults standardUserDefaults] objectForKey:@"APP_LAUNCH"] boolValue];
        gADBannerView.hidden=isAppLanuch?YES:NO;
        bgBannerView.hidden=isAppLanuch?YES:NO;
        _footerView.hidden=isAppLanuch?YES:NO;
        gADBannerView.frame = CGRectMake(0.0, self.view.frame.size.height , self.view.frame.size.width, 44);
        
        
        
        CPAppDelegate *appDelegate= (CPAppDelegate*)[UIApplication sharedApplication].delegate;
        self.view.frame=CGRectMake(0, 0,  self.interfaceOrientation>2?(appDelegate.window.frame.size.height-320):appDelegate.window.frame.size.width,self.interfaceOrientation>2?(appDelegate.window.frame.size.width-64):(appDelegate.window.frame.size.height-64));
        
        [self upDateUI];
        
        CPMenu *menu=[[CPDataManger sharedDataManager] selectedMenu];
        if(menu.is_map)
        {
            
            _imgView.frame =  CGRectMake(0, 0, isLandScape?703:768, (isLandScape?HEIGHT-95:WIDTH-95)*0.6);
            
            
            _imgView.imageView.frame=CGRectMake((_imgView.frame.size.width-_imgView.imageView.image.size.width)/2, (_imgView.frame.size.height-_imgView.imageView.image.size.height)/2, _imgView.imageView.image.size.width, _imgView.imageView.image.size.height);
            
            _imgView.userInteractionEnabled=YES;
            _imgView.contentMode = UIViewContentModeRedraw;
            
            [_imgView.imageView sizeToFit];
            
        }
        else{
            
            UIImage *image=[UIImage imageNamed:@"ImagePlaceholderTwo.png"];
            _imgView.frame =  CGRectMake((self.view.frame.size.width - image.size.width)/2, 5.0, image.size.width,image.size.height);
            // _imgView.imageView.frame=CGRectMake(0, 0, _imgView.frame.size.width, _imgView.frame.size.height);
            //_imgView.frame=normalFrame;
            _imgView.userInteractionEnabled=NO;
            // _imgView.imageView.autoresizingMask = UIViewAutoresizingNone;
            _imgView.contentMode = UIViewContentModeScaleAspectFill;
        }
        
        [self animateFooterView:YES];
        
    }
    
}


-(BOOL)shouldAutorotate{
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        return isScanner?NO:YES;
    }
    return NO;
}


-(void)upDateUI{
    
    
    
    
    CGRect rect = self.view.frame;
    rect.size.height = self.view.frame.size.height - _footerView.frame.size.height;
    rect.origin.y = 0.0;
    rect.origin.x = 0.0;
    
    if(_imgView.superview != nil)
    {
        rect.origin.y = _imgView.frame.size.height;
        rect.size.height = self.view.frame.size.height - (_footerView.frame.size.height +  _imgView.frame.size.height+BANNER_HEIGHT);
    }
    
    if(self.qrContent != nil)
    {
        rect.size.height = self.view.frame.size.height - _footerView.frame.size.height-BANNER_HEIGHT;
    }
    
    _webView.frame = rect;
    //NSLog(@"frames=%@",NSStringFromCGRect(_webView.frame));
    
    
    
    rect = _footerView.frame;
    rect.origin.y = self.view.frame.size.height - rect.size.height;
    
    
    
    _footerView.frame = rect;
    
    //[self animateFooterView:NO];
    BOOL isAppLanuch=[[[NSUserDefaults standardUserDefaults] objectForKey:@"APP_LAUNCH"] boolValue];
    gADBannerView.hidden=isAppLanuch?YES:NO;
    bgBannerView.hidden=isAppLanuch?YES:NO;
    _footerView.hidden=isAppLanuch?YES:NO;
    startView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    startImageView.frame=CGRectMake((startView.frame.size.width-704)/2,(startView.frame.size.height-704)/2,704,704);
    
    if (!isAppLanuch) {
        [self animateFooterView:NO];
    }
    
    [self showBannarView];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if([animationID isEqualToString:@"animateAdBannerOff"] == YES)
    {
        
        [self initializeNextViewControllerAndDisplay:fType];
    }
}


#pragma mark - CPFooterViewDelegate -
- (void)footerView:(CPFooterView*)footerView didClickItemWithType:(CPFooterItemType)type{
    fType = type;
    [UIView beginAnimations:@"animateAdBannerOff"
                    context:NULL];
    [UIView setAnimationDuration:0.0];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    
    
    //CPMenu *menu = [[CPDataManger sharedDataManager] selectedMenu];
    CGRect rect = self.view.frame;
    rect.size.height = self.view.frame.size.height - _footerView.frame.size.height;
    //if(menu.page.image != nil)
    if(_imgView.superview != nil)
    {
        rect.origin.y = _imgView.frame.size.height;
        rect.size.height = self.view.frame.size.height - (_footerView.frame.size.height +  _imgView.frame.size.height);
    }
    
    
    rect.origin.x = 0.0;
    _webView.frame = rect;
    
    
    
    rect = _footerView.frame;
    rect.origin.y = self.view.frame.size.height - rect.size.height;
    _footerView.frame = rect;
    
    [UIView commitAnimations];
}


#pragma mark - CPConnectionDelegate -
- (void)CPConnection:(CPConnection*)CPConnection didReceiveResponse:(id)response
{
    
    NSData *_data = [(NSDictionary*)response valueForKey:@"data"];
    if(CPConnection.request.type == CPRequestTypeImage)
    {
        if(CPConnection.request.identifier.intValue == _imgView.tag)
        {
            UIImage *img = [UIImage imageWithData:_data];
            
            CPMenu *menu = [[CPDataManger sharedDataManager] selectedMenu];
            menu.page.image.image = img;
            _imgView.imageView.image = img;
            
            if(menu.is_map){
                _imgView.imageView.frame=CGRectMake((_imgView.frame.size.width-_imgView.imageView.image.size.width)/2, (_imgView.frame.size.height-_imgView.imageView.image.size.height)/2, _imgView.imageView.image.size.width, _imgView.imageView.image.size.height);
                if(menu.is_map)
                    [_imgView.imageView sizeToFit];
                
            }
            
            UIActivityIndicatorView *_activityView = (UIActivityIndicatorView *)[_imgView.imageView viewWithTag:200200];
            if(_activityView != nil)
            {
                [_activityView removeFromSuperview];
            }
            
            
        }
        
        return;
    }
    
    CPMenu *menu = [[CPDataManger sharedDataManager] selectedMenu];
    if(CPConnection.request.identifier.intValue != menu.id.intValue)
    {
        _webView.delegate = nil;
        return;
    }
    
    NSString *strResponse = [[NSString alloc] initWithBytes:(const void*)[_data bytes]
                                                     length:[_data length]
                                                   encoding:NSASCIIStringEncoding];
    
    // Create SBJSON object to parse JSON
    SBJSON *parser = [[SBJSON alloc] init];
    
    // parse the JSON string into an object - assuming json_string is a NSString of JSON data
    NSError *err = nil;
    
    
    NSDictionary *parsedObject = [parser objectWithString:strResponse error:&err];
    
    
    
    
    if([parsedObject objectForKey:@"error"] != nil)
    {
        ADBannerView *banner = [CPAddBannerView sharedAddBannerView].adBannerView;
        CGRect rect = self.view.frame;
        rect.size.height += banner.frame.size.height;
        _webView.frame = rect;
        
        rect = banner.frame;
        rect.origin.y = self.view.frame.size.height;
        banner.frame = rect;
        
        
        if(errorAlert!=nil)
            //[errorAlert removeFromSuperview];
            [errorAlert dismissWithClickedButtonIndex:0 animated:YES];
        errorAlert=nil;
        //UIAlertView *errorAlert
        errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertTitle", @"")
                                                message:[parsedObject objectForKey:@"error"]
                                               delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"cancelButton", @"")
                                      otherButtonTitles:nil];
        
        
        errorAlert.tag=2222;
        [errorAlert show];
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            [activityView stopAnimating];
            [activityView removeFromSuperview];
        }
        else
        {
            [loadView removeFromSuperview];
        }
    }
    else
    {
        if(parsedObject != nil)
        {
            NSDictionary *content = [parsedObject objectForKey:@"content"];
            
            // get selected menu
            CPMenu *menu = [[CPDataManger sharedDataManager] selectedMenu];
            
            // add page for selected menu
            CMPPage *page = [CMPPage new];
            page.title = [parsedObject objectForKey:@"title"];
            page.subTitle = [parsedObject objectForKey:@"subtitle"];
            
            CMPImage *_image = [[CMPImage alloc] init];
            if(![[parsedObject objectForKey:@"image"] isEqualToString:@"nil"])
            {
                NSString *path = [NSString stringWithFormat:@"%@/iphone/%@/%@", dtManager.configuration.imagePath, [CPUtility deviceDensity], [parsedObject objectForKey:@"image"]];
                _image.imageUrl = [NSURL URLWithString:path];
                page.image = _image;
            }
            
            menu.page = page;
            
            // add page content
            CPContent *_content = [[CPContent alloc] init];
            _content.text = [content objectForKey:@"text"];
            _content.type = ([[[content objectForKey:@"type"] lowercaseString] isEqualToString:@"text"] == YES) ? CPContentTypeHTML : CPContentTypeURL;
            menu.page.content = _content;
            
            // add image information
            for(NSDictionary *dict in [parsedObject objectForKey:@"images"])
            {
                NSString *path = [NSString stringWithFormat:@"%@/iphone/%@/%@", dtManager.configuration.imagePath, [CPUtility deviceDensity], [dict objectForKey:@"name"]];
                CMPImage *_image = [[CMPImage alloc] init];
                _image.text = [dict objectForKey:@"image_text"];
                _image.imageUrl = [NSURL URLWithString:path];
                [menu.page.images addObject:_image];
            }
            
            // add video information
            for(NSDictionary *dict in [parsedObject objectForKey:@"videos"])
            {
                NSString *path = [NSString stringWithFormat:@"%@/iphone/%@/%@", dtManager.configuration.videoPath, [CPUtility deviceDensity], [dict objectForKey:@"name"]];
                NSString *pathThumb = [NSString stringWithFormat:@"%@/iphone/%@/%@", dtManager.configuration.videoPath, [CPUtility deviceDensity], [dict objectForKey:@"video_thumb"]];
                CPVideo *_video = [[CPVideo alloc] init];
                _video.text = [dict objectForKey:@"video_text"];
                _video.imageUrl = [NSURL URLWithString:pathThumb];
                _video.url = [NSURL URLWithString:path];
                [menu.page.videos addObject:_video];
            }
        }
        
        if(_webView.isLoading == YES)
        {
            [_webView stopLoading];
        }
        
        [self dataDisplay];
    }
    
}

- (void)CPConnection:(CPConnection*)CPConnection didFailWithError:(NSError*)error
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
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [activityView stopAnimating];
        [activityView removeFromSuperview];
    }
    
    UIActivityIndicatorView *_activityView = (UIActivityIndicatorView *)[_imgView.imageView viewWithTag:200200];
    if(_activityView != nil)
    {
        [_activityView removeFromSuperview];
    }
}

#pragma mark - UIAlertViewDelegate -
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    errorAlert=nil;
}

#pragma mark - UIWebviewDelegate -
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [self showActivityIndicator:YES];
    }
    else
    {
        if(loadView.superview == nil)
        {
            loadView = [LoadingView loadingViewInView:self.view withTitle:nil];
            loadView.backgroundColor = [UIColor clearColor];
        }
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [self showActivityIndicator:NO];
    }
    else
    {
        [self removeLoadingView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [self showActivityIndicator:NO];
    }
    else
    {
        [self removeLoadingView];
    }
}

#pragma mark - ADBannerViewDelegate -
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    
    if(banner.superview != nil)
    {
        banner.delegate = nil;
        [banner removeFromSuperview];
    }
    
    if(banner.superview == nil)
    {
        banner.delegate = self;
        [self.view addSubview:banner];
        [UIView beginAnimations:@"animateAdBannerOn"
                        context:NULL];
        [UIView setAnimationDuration:0.0];
        CGRect rect = self.view.frame;
        
        rect.size.height = self.view.frame.size.height - _footerView.frame.size.height;
        if(_imgView.superview != nil)
        {
            rect.origin.y = _imgView.frame.size.height;
            rect.size.height = self.view.frame.size.height - (_footerView.frame.size.height +  _imgView.frame.size.height);
            if(banner.isBannerLoaded == YES)
            {
                rect.size.height = self.view.frame.size.height - (banner.frame.size.height +  _footerView.frame.size.height + _imgView.frame.size.height);
            }
        }
        if (self.qrContent != nil)
        {
            rect.size.height = self.view.frame.size.height - _footerView.frame.size.height;
            if(banner.isBannerLoaded == YES)
            {
                rect.size.height = self.view.frame.size.height - (_footerView.frame.size.height + banner.frame.size.height);
            }
        }
        _webView.frame = rect;
        
        // set the banner origin.y to out of bound
        rect = banner.frame;
        rect.origin.y = self.view.frame.size.height + rect.size.height;
        if(banner.isBannerLoaded == YES)
        {
            rect.origin.y = self.view.frame.size.height - rect.size.height;
        }
        banner.frame = rect;
        
        rect = _footerView.frame;
        rect.origin.y = self.view.frame.size.height - rect.size.height;
        rect.size.width = 320.0;
        rect.size.height = 44.0;
        if(banner.isBannerLoaded == YES)
        {
            rect.origin.y = self.view.frame.size.height - (rect.size.height + banner.frame.size.height);
        }
        
        
        
        _footerView.frame = rect;
        [UIView commitAnimations];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    
    if(banner == [[CPAddBannerView sharedAddBannerView] adBannerView])
    {
        [UIView beginAnimations:@"animateAdBannerOn"
                        context:NULL];
        [UIView setAnimationDuration:0.0];
        
        CGRect rect = self.view.frame;
        rect.size.height = self.view.frame.size.height - _footerView.frame.size.height;
        if(_imgView.superview != nil)
        {
            rect.origin.y = _imgView.frame.size.height;
            rect.size.height = self.view.frame.size.height - (_footerView.frame.size.height + _imgView.frame.size.height);
        }
        
        if (self.qrContent != nil)
        {
            rect.size.height = self.view.frame.size.height;
        }
        
        _webView.frame = rect;
        
        // set the banner origin.y to out of bound
        rect = banner.frame;
        rect.origin.y = self.view.frame.size.height + rect.size.height;
        banner.frame = rect;
        
        rect = _footerView.frame;
        rect.origin.y = self.view.frame.size.height - rect.size.height;
        if (self.qrContent != nil)
        {
            rect.origin.y = self.view.frame.size.height + rect.size.height;
        }
        
        _footerView.frame = rect;
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

#pragma mark - ZBarReaderDelegate -
- (void) readerControllerDidFailToRead: (ZBarReaderController*) reader
                             withRetry: (BOOL) retry
{
    isScanner=NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Campus Publishers"
                                                    message:@"the image picker failing to read"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)initializeAndDisplayPageViewControllerWithQRContent:(NSString*)content
{
    CPContent *_qrContent = [[CPContent alloc] init];
    _qrContent.type = CPContentTypeURL;
    _qrContent.text = content;
    isScanner=YES;
    CPPageViewController *_pageViewController = [[CPPageViewController alloc] initWithNibName:nil bundle:nil];
    _pageViewController.title = @"Results";
    _pageViewController.qrContent = _qrContent;
    [self.navigationController pushViewController:_pageViewController
                                         animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate -
- (void) imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    
    //NSLog(@"orientations=%d",reader.interfaceOrientation);
    CPAppDelegate *appDelegate= (CPAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate upDateViewFramewithPicker:reader toReplaceView:self.view];
    
    isScanner=NO;
    // ADD: get the decode results
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
        self.qrContent = nil;
        _pageViewController.title = @"Results";
//        [reader dismissModalViewControllerAnimated: NO];
                [reader dismissViewControllerAnimated:NO completion:nil];
        [self.navigationController pushViewController:_pageViewController animated:NO];
        
    }
    else
    {
        qrContent = [[CPContent alloc] init];
        qrContent.type = CPContentTypeHTML;
        qrContent.text = hiddenData;
        CPPageViewController *_pageViewController = [[CPPageViewController alloc] initWithNibName:nil bundle:nil];
        _pageViewController.qrContent = qrContent;
        self.qrContent = nil;
        _pageViewController.title = @"Results";
        [self.navigationController pushViewController:_pageViewController animated:NO];
//        [reader dismissModalViewControllerAnimated:NO];
        [reader dismissViewControllerAnimated:NO completion:nil];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    isScanner=NO;
    CPAppDelegate *appDelegate= (CPAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate upDateViewFramewithPicker:picker toReplaceView:self.view];
//    [picker dismissModalViewControllerAnimated: NO];
    [picker dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - UISplitViewControllerDelegate -
- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    isMenuPopUP=YES;
    barButtonItem.title = NSLocalizedString(@"Menu", @"Menu");
    
    masterPopoverController=popoverController;
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    //[self menuButtonAction];
    CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.masterPopoverController=popoverController;
    appDelegate.isLandScape=NO;
    
}


-(void)menuButtonAction{
    CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.isLandScape=YES;
    
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    if (version>=6.0) {
        if (appDelegate.splitViewController!=nil) {
            if (appDelegate.isSetUpViewClosed==YES) {
                [appDelegate.splitViewController performSelector:@selector(toggleMasterVisible:)];
                appDelegate.isSetUpViewClosed=NO;
            }
        }
    }
    else{
        if (masterPopoverController!=nil) {
            
            [masterPopoverController presentPopoverFromBarButtonItem:[self.navigationItem leftBarButtonItem] permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];
        }
    }
}


- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    isMenuPopUP=NO;
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    if (self.masterPopoverController!=nil) {
        [self.masterPopoverController dismissPopoverAnimated:NO];
    }
    self.masterPopoverController = nil;
}

#pragma mark - iPad Specific -
- (void)updateAndDisplayPageContent
{
    
    // creating  default image view
    BOOL isAppLanuch=[[[NSUserDefaults standardUserDefaults] objectForKey:@"APP_LAUNCH"] boolValue];
    if (!isAppLanuch) {
        if (startImageView!=nil) {
            [startImageView removeFromSuperview];
            [startView removeFromSuperview];
        }
    }
    
    CPMenu *menu = [[CPDataManger sharedDataManager] selectedMenu];
    if(self.qrContent == nil)
    {
        if(loadView != nil)
        {
            [self removeLoadingView];
        }
        
        if(menu.page == nil)
        {
            CPAppDelegate *appDelegate= (CPAppDelegate *)[[UIApplication sharedApplication] delegate];
            if((appDelegate.reachability.reachable == NO) && ([appDelegate isReachableWiFi] ==  NO))
            {
                [self showActivityIndicator:NO];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:NSLocalizedString(@"NetworkCheck","")
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
                [alert show];
            }
            else
            {
                if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                {
                    
                    
                    BOOL isAppLanuch=[[[NSUserDefaults standardUserDefaults] objectForKey:@"APP_LAUNCH"] boolValue];
                    gADBannerView.hidden=isAppLanuch?YES:NO;
                    bgBannerView.hidden=isAppLanuch?YES:NO;
                    _footerView.hidden=isAppLanuch?YES:NO;
                    
                    /* if (!isAppLanuch) {
                     [self animateFooterView:NO];
                     }*/
                    
                    if(loadView != nil)
                    {
                        [self removeLoadingView];
                    }
                    
                    
                    if(menu.is_tourmap){
                        
                        
                        
                        if(pageViewController==nil){
                            pageViewController = [[CpTourGuideIPhone alloc] initWithNibName:nil bundle:nil];
                            pageViewController.isTourGuide=YES;
                            
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
                            
                            pageViewController.isTourGuide=YES;
                            pageViewController.isDirectionSelected=NO;
                            pageViewController.pathLoopCount=0;
                            pageViewController.isGoogleAPI=NO;
                            
                            [pageViewController upDAteCall];
                            
                            
                            
                            
                        }
                        
                        
                        pageViewController.pathLoopCount=0;
                        
                        pageViewController.isTourGuide=YES;
                        pageViewController.isBackButtonHiden=YES;
                        [pageViewController setTitle:[[[CPDataManger sharedDataManager] selectedMenu] name]];
                        
                        
                        
                        
                        [self.navigationController pushViewController:pageViewController animated:NO];
                        
                        //   pageViewController.isRoot=YES;
                        
                        
                        //[pageViewController release];
                    }
                    else{
                        
                        
                        
                        [[CPConnectionManager sharedConnectionManager] closeAllConnections];
                        
                        loadView = [LoadingView loadingViewInView:self.view withTitle:nil];
                        loadView.backgroundColor = [UIColor clearColor];
                        
                        //[self callServicePage];
                        [self performSelector:@selector(callServicePage) withObject:nil afterDelay:0.1];
                    }
                }
            }
        }
        else
        {
            [self dataDisplay];
        }
    }
    else
    {
        [self dataDisplay];
    }
    
    
    
    
}

- (void)initializeFirstLoad
{
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        if(self.isIPadUIConfigured == NO)
        {
            self.isIPadUIConfigured = YES;
            if(dtManager.datasource.count > 0)
            {
                CPMenu *menu = [dtManager.datasource objectAtIndex:0];
                if(menu.subMenu.count > 0)
                {
                    dtManager.selectedMenu = [menu.subMenu objectAtIndex:0];
                }
                else
                {
                    dtManager.selectedMenu = menu;
                }
                
                self.navigationItem.title = dtManager.selectedMenu.name;
                _footerView.tintColor = dtManager.configuration.color.footer;
                [self updateAndDisplayPageContent];
            }
        }
    }
}






- (UIImageView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that we want to zoom
    // return _imgView.imageView;
    return _imgView.imageView;
    
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = _imgView.bounds.size;
    CGRect contentsFrame = _imgView.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    _imgView.imageView.frame = contentsFrame;
}


- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    // Get the location within the image view where we tapped
    CGPoint pointInView = [recognizer locationInView:_imgView.imageView];
    
    // Get a zoom scale that's zoomed in slightly, capped at the maximum zoom scale specified by the scroll view
    CGFloat newZoomScale = _imgView.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, _imgView.maximumZoomScale);
    
    // Figure out the rect we want to zoom to, then zoom to it
    CGSize scrollViewSize = _imgView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    [_imgView zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = _imgView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, _imgView.minimumZoomScale);
    [_imgView setZoomScale:newZoomScale animated:YES];
}

@end
