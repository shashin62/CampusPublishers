//
//  CPNewPageViewController.m
//  CampusPublishers
//
//  Created by V2Solutions-05 on 17/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <GoogleMobileAds/GADBannerView.h>
#import "CPNewPageViewController.h"
#import "CPGalleryViewController.h"
#import "CPAddBannerView.h"
#import "CPAppDelegate.h"
#import "CPDataManger.h"
#import "CPUtility.h"
#import "JSON.h"

#import "CPConfiguration.h"
#import "CPContent.h"
#import "CPVideo.h"
#import "CPMenu.h"
#import "CMPPage.h"
#import "CustomImageView.h"
#import "CPPageViewController.h"
#import "RootViewController.h"

@interface CPNewPageViewController (HIDDEN)

- (void)prepareUIContent;
- (void)displayUIContent;
- (void)initializeAllUIElement;
- (void)updateWebViewToFitToContent;
- (void)initializePageContentRequest;
- (void)displayErrorMessage:(NSError*)error;
- (void)getImageAtIndex:(int)index forURL:(NSURL*)url;
- (void)initializeNextViewControllerAndDisplay:(CPFooterItemType)type;

@end



@implementation CPNewPageViewController (HIDDEN)

- (void)initializeAllUIElement
{
    _footerView = nil;
    self.qrContent = nil;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // set university logo
    UIImage *image = [UIImage imageNamed:@"logo.png"];
    UIImageView *imageView = [[UIImageView alloc ]initWithImage:image];
    imageView.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    // create image placeholder
    _imgView = nil;
  //  _imgView.backgroundColor=[UIColor greenColor];
    // create webview
    CGRect rect = self.view.frame;
    rect.size.height -= _imgView.imageView.image.size.height;
    _webView = [[UIWebView alloc] initWithFrame:rect];
    _webView.delegate = self;
    _webView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin 
                                | 
                                UIViewAutoresizingFlexibleTopMargin;
    
    // create table view
    rect = self.view.frame;
    rect.origin.y -= 15.0; // left 5px; so that image with no borders should be clearly visible from top
    _tblView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _tblView.separatorColor = [UIColor clearColor];
    _tblView.delegate = self;
    _tblView.backgroundColor = [UIColor clearColor];
    _tblView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin 
                                | 
                                UIViewAutoresizingFlexibleWidth 
                                | 
                                UIViewAutoresizingFlexibleRightMargin 
                                | 
                                UIViewAutoresizingFlexibleTopMargin
                                |
                                UIViewAutoresizingFlexibleHeight
                                |
                                UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_tblView];
    
    _activityView =  [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];    
    [_activityView sizeToFit];
    _activityView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}



- (void)updateWebViewToFitToContent
{
    CGRect bounds = _webView.bounds;
    bounds.size.height = [[_webView stringByEvaluatingJavaScriptFromString:@"document.height"] floatValue];
    _webView.bounds = bounds;
    
    if(_activityView.superview == self.view)
    {
        [_activityView removeFromSuperview];
    }
    
    self.view.userInteractionEnabled = YES;
    [_tblView reloadData];
}

- (void)prepareUIContent
{
      
    if(self.qrContent == nil)
    {
        CPMenu *menu = [[CPDataManger sharedDataManager] selectedMenu];
        if(menu.page == nil)
        {
            CPAppDelegate *appDelegate= (CPAppDelegate *)[[UIApplication sharedApplication] delegate];
            if((appDelegate.reachability.reachable == NO) && ([appDelegate isReachableWiFi] ==  NO))
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                                message:NSLocalizedString(@"NetworkCheck","")
                                                               delegate:nil 
                                                      cancelButtonTitle:@"OK" 
                                                      otherButtonTitles: nil];
                [alert show];	
                          }
            else 
            {
                self.view.userInteractionEnabled = NO;
                if(_activityView.superview == nil)
                {
                    [self.view addSubview:_activityView];
                    _activityView.center = self.view.center;
                    [_activityView startAnimating];
                }
                
                [self initializePageContentRequest];
            } 
        }
        else
        {
            [self displayUIContent];
        }
    }
    else
    {
        [self displayUIContent];
    }
}

- (void)displayUIContent
{
    //get the selected menu item
    CPMenu *menu = [[CPDataManger sharedDataManager] selectedMenu];
    CPConfiguration *configuration = (CPConfiguration*)[[CPDataManger sharedDataManager] configuration];
    
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
        [_webView stopLoading];
        if(menu.page.content.type == CPContentTypeHTML)
        {
            if(menu.page.content.text != nil)
            {
                /*
                NSMutableString *tempstring = [[NSMutableString stringWithString:menu.page.content.text] mutableCopy];
                NSMutableString *newtempstring = [[tempstring stringByReplacingOccurrencesOfString:@"<p" withString:@"<p style=\"font-family:arial;\""] mutableCopy]; //todo: refactor the view and replace this cheap hack.
                [_webView loadHTMLString:tempstring baseURL:nil];
                */
                [_webView loadHTMLString:menu.page.content.text baseURL:nil];
            }
        } 
        else if(menu.page.content.type == CPContentTypeURL)
        {
            if(menu.page.content.text != nil)
            {
                //This is where web pages are loaded --Austin
                [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:menu.page.content.text]]];
            }
        }
        
        //adding footerView depending upon its type,if its nil
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            if(_footerView == nil) 
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
                
               // if([[self.title lowercaseString] isEqualToString:@"map"])
                if(menu.is_map)
                {
                    if(configuration.university.showRoute == YES)
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
                    _imgView.userInteractionEnabled=YES;
                    
                }
                else{
                    _imgView.userInteractionEnabled=NO;

                }
                
                _footerView.tintColor = configuration.color.footer;
                    _footerView.frame = CGRectMake(0.0, self.view.frame.size.height - _footerView.frame.size.height, _footerView.frame.size.width, _footerView.frame.size.height);
                _footerView.delegate = self;
                [self.view addSubview:_footerView];
                
                CGRect frame = _tblView.frame;
                frame.size.height = _footerView.frame.origin.y;
                _tblView.frame = frame;
            }
        }
        
        if(menu.page.image != nil)
        {
            if(_imgView == nil)
            {
                UIImage *img = [UIImage imageNamed:@"ImagePlaceholderTwo.png"];
                _imgView = [[CustomImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, img.size.width, img.size.height)];
              /*  
                _imgView.frame=CGRectMake(0.0, 0.0, 320, (480-98-44)*0.6);

              //  _imgView.contentMode = UIViewContentModeScaleAspectFit;
                _imgView.imageView.image = img;
               // _imgView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin 
                                           // | 
                                           // UIViewAutoresizingFlexibleTopMargin;
                
                _imgView.delegate=self;
                //_imgView.userInteractionEnabled=YES;
                //_imgView.contentSize=CGSizeMake(320.0f, 320.0f);
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
                //_imgView.contentMode = UIViewContentModeCenter;
               // [_imgView.imageView sizeToFit];*/
                _imgView.imageView.image = img;

                _imgView.tag = menu.id.intValue;
            }
            
            
            _imgView.frame=CGRectMake(0.0, 0.0, 320, (480-98-44)*0.6);
            
            //  _imgView.contentMode = UIViewContentModeScaleAspectFit;
            // _imgView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin 
            // | 
            // UIViewAutoresizingFlexibleTopMargin;
            
            _imgView.delegate=self;
            //_imgView.userInteractionEnabled=YES;
            //_imgView.contentSize=CGSizeMake(320.0f, 320.0f);
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
            //_imgView.contentMode = UIViewContentModeCenter;
            // [_imgView.imageView sizeToFit];

            
            if(menu.page.image.image == nil)
            {
                _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
                [_imgView addSubview:_activityView];
                
                CGRect rect = _activityView.frame;
                rect.origin.x = (_imgView.frame.size.width - rect.size.width) / 2;
                rect.origin.y = (_imgView.frame.size.height - rect.size.height) / 2;        
                _activityView.frame = rect;
                [_activityView startAnimating];
                
                [self getImageAtIndex:(int)_imgView.tag
                               forURL:((CMPImage*)menu.page.image).imageUrl];
            }
            else if(menu.page.image.image != nil)
            {
                if(_imgView.tag == menu.id.intValue)
                {
                    _imgView.imageView.image = menu.page.image.image;
                }
            }
        }
        else
        {
            if(_imgView != nil)
            {
                _imgView = nil;
            }
        }
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
    
    
    
    [_tblView reloadData];
    

}


#pragma marks  - admob delegates
-(void)showBannarView{
    //comment this out for screenshots -Austin
    
    gADBannerView = [CPAddBannerView sharedGADBannerView];
    gADBannerView.frame = CGRectMake(0.0, self.view.frame.size.height , _footerView.frame.size.width, _footerView.frame.size.height);
    
    
        gADBannerView.adSize = kGADAdSizeBanner;
    
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
      view.frame = CGRectMake(0.0, self.view.frame.size.height - (_footerView.frame.size.height+BANNER_HEIGHT), _footerView.frame.size.width,view.frame.size.height);
    CGRect rect=self.view.frame;
    rect.size.height-=(_footerView.frame.size.height+44);
    _tblView.frame=rect;
 }

-(void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error{
    //GADBannerView *adBanner = [CPAddBannerView sharedAddBannerView].adBanner;
    view.frame = CGRectMake(0.0, self.view.frame.size.height , _footerView.frame.size.width, _footerView.frame.size.height);
    CGRect rect=self.view.frame;
    rect.size.height-=44;
    _tblView.frame=rect;
}
-(void)adViewWillDismissScreen:(GADBannerView *)adView{
    isAddOPen=YES;
}



- (void)initializePageContentRequest
{
    
    CPConnectionManager *manager = [CPConnectionManager sharedConnectionManager];
    CPMenu *menu = [[CPDataManger sharedDataManager] selectedMenu];
    
    NSString *strURL = nil;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        strURL = [NSString stringWithFormat:@"%@pages?method=getPage&pageId=%d&deviceId=%d", SERVER_URL,[menu.id intValue] , CPDeviceTypeiPhone];
    }
    
    NSURL *urlServer = [NSURL URLWithString:strURL];
    CPRequest*request = [[CPRequest alloc] initWithURL:urlServer withRequestType:CPRequestTypePage];
    request.identifier = menu.id;
    [manager spawnConnectionWithRequest:request delegate:self];
   }

- (void)displayErrorMessage:(NSError*)error
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

//get the image as per index,with the related URL
- (void)getImageAtIndex:(int)index forURL:(NSURL*)url
{
  
    CPConnectionManager *manager = [CPConnectionManager sharedConnectionManager];    
    CPRequest*request = [[CPRequest alloc] initWithURL:url 
                                       withRequestType:CPRequestTypeImage];
    [manager spawnConnectionWithRequest:request delegate:self];
    request.identifier = [NSNumber numberWithInteger:index];
  
}

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
        mapViewController.isDirectionSelected=NO;
        mapViewController.isRoot=YES;
        mapViewController.isAtCampus=NO;
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

@end

@implementation CPNewPageViewController
@synthesize qrContent = _qrContent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        // Custom initialization
        [self initializeAllUIElement];
        [self showBannarView];
    }
    
    return self;
}



- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    view.autoresizesSubviews = YES;
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.view = view;
   

 }

- (void)viewDidLoad
    {
        [super viewDidLoad];
        self.screenName = @"NewPage";
    }


- (void)viewWillAppear:(BOOL)animated
{
    [self reloadAdd];
    [super viewWillAppear:animated];
    [self prepareUIContent];

}
-(void)viewWillDisappear:(BOOL)animated{
    isAddOPen=NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIWebViewDelegate -
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self updateWebViewToFitToContent];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self updateWebViewToFitToContent];
}

#pragma mark - UITableViewDelegate -
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return _imgView.frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return _webView.frame.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _imgView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return _webView;
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
            
            if(menu.is_map)
                [_imgView.imageView sizeToFit];

            
            if(_activityView.superview == _imgView)
            {
                [_activityView removeFromSuperview];
            }
        }
    }
    else if(CPConnection.request.type == CPRequestTypePage)
    {    
        CPMenu *menu = [[CPDataManger sharedDataManager] selectedMenu];
        if(CPConnection.request.identifier.intValue == menu.id.intValue)
        {
            NSString *strResponse = [[NSString alloc] initWithBytes:(const void*)[_data bytes]
                                                             length:[_data length]
                                                           encoding:NSASCIIStringEncoding];
            SBJSON *parser = [[SBJSON alloc] init];
            
            NSError *err = nil;
           NSDictionary *parsedObject = [parser objectWithString:strResponse error:&err];
            
                  

            //NSLog(@"%@",parsedObject);
            
            if([parsedObject objectForKey:@"error"] != nil) 
            {
                ADBannerView *banner = [CPAddBannerView sharedAddBannerView].adBannerView;
                CGRect rect = self.view.frame;
                rect.size.height += banner.frame.size.height;
                _tblView.frame = rect;
                
                rect = banner.frame;
                rect.origin.y = self.view.frame.size.height;
                banner.frame = rect;
                
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertTitle", @"")
                                                                     message:[parsedObject objectForKey:@"error"]
                                                                    delegate:self 
                                                           cancelButtonTitle:NSLocalizedString(@"cancelButton", @"") 
                                                           otherButtonTitles:nil];
                [errorAlert show];
                
            }
            else
            {
                CPDataManger *dtManager = [CPDataManger sharedDataManager];
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
                //menu.page.content.font = [UIFont fontWithName:@"ArialMT" size:0];
                
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
                
                [self displayUIContent];
            }
            
                   }
    }
}

- (void)CPConnection:(CPConnection*)CPConnection didFailWithError:(NSError*)error
{
    if(_activityView.superview != nil)
    {
        [_activityView removeFromSuperview];
    }
    
    [self displayErrorMessage:error];    
}

#pragma mark - ADBannerViewDelegate -
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [UIView beginAnimations:@"animateAdBannerOn" 
                    context:NULL];
    [UIView setAnimationDuration:0.0];    

    if(banner.superview != self.view)
    {
        // remove from previous superview
        banner.delegate = nil;
        [banner removeFromSuperview];

        // add to current superview
        banner.delegate = self;
        [self.view addSubview:banner];
    }

    CGRect rect = banner.frame;
    rect.origin.y = self.view.frame.size.height - rect.size.height;
    banner.frame = rect;
    
    if(_footerView != nil)
    {
        rect = _footerView.frame;
        rect.origin.y = self.view.frame.size.height - banner.frame.size.height - rect.size.height;
        _footerView.frame = rect;
    }
    
    rect = _tblView.frame;
    rect.size.height = _footerView.frame.origin.y;
    _tblView.frame = rect;
    
    [UIView commitAnimations];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [UIView beginAnimations:@"animateAdBannerOff" 
                    context:NULL];
    [UIView setAnimationDuration:0.0];
    
    CGRect rect = banner.frame;
    rect.origin.y = self.view.frame.size.height + rect.size.height;
    banner.frame = rect;
    
    if(_footerView != nil)
    {
        rect = _footerView.frame;
        rect.origin.y = self.view.frame.size.height - rect.size.height;
        _footerView.frame = rect;
    }
    
    rect = _tblView.frame;
    rect.size.height = _footerView.frame.origin.y;
    _tblView.frame = rect;
    
    [UIView commitAnimations];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    BOOL shouldExecuteAction = YES;
    if(!willLeave && shouldExecuteAction)
    {
        // stop all interactive processes in the app
    }
    
    return shouldExecuteAction;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner  
{
    // resume everything you've stopped
}

#pragma mark - UIAlertViewDelegate -
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - CPFooterViewDelegate -
- (void)footerView:(CPFooterView*)footerView didClickItemWithType:(CPFooterItemType)type
{
    [self initializeNextViewControllerAndDisplay:type];
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





#pragma mark - UIImagePickerControllerDelegate -


-(void)imagePickerController:(UIImagePickerController *)reader didFinishPickingMediaWithInfo:(NSDictionary *)info{
	// ADD: get the decode results
    isAddOPen=YES;

    CPAppDelegate *appDelegate= (CPAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate upDateViewFramewithPicker:reader toReplaceView:self.view];
    
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

@end
