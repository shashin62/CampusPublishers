//
//  ScanResultsPage.m
//  CampusPublishers
//
//  Created by v2solutions on 05/01/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ScanResultsPage.h"
#import "CPContent.h"
#import "CPMenu.h"
#import "CPDataManger.h"
#import "CMPPage.h"
#import "CPFooterView.h"
#import "ZBarReaderViewController.h"
#import "CPAddBannerView.h"
#import "CPConfiguration.h"
#import "ZBarReaderView.h"
#import "CPContent.h"
#import "CpTourGuideIPhone.h"
#import "DescriptionViewController.h"
#import "RootViewController.h"
#import "CPAppDelegate.h"
#import <GoogleMobileAds/GADBannerView.h>
@implementation ScanResultsPage
@synthesize qrContent;
@synthesize descriptionViewController,rootViewController;
@synthesize cpTourGuideIPhone;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        
        
        UIImage *myImage;
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            myImage = [UIImage imageNamed:@"logo.png"];
        else
            myImage = [UIImage imageNamed:@"logo.png"];
        
        UIImageView *imageView1 = [[UIImageView alloc ]initWithImage:myImage];
        imageView1.frame = CGRectMake(0.0, 0.0, myImage.size.width, myImage.size.height);
        
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:imageView1];
        
        self.navigationItem.rightBarButtonItem = rightButton;
       
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}




#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    dtManager = [CPDataManger sharedDataManager];
    
    [super viewDidLoad];
    
    CPMenu *menu = [[CPDataManger sharedDataManager] selectedMenu];
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height);
    
    
    
    
    _webView=[[UIWebView alloc]initWithFrame:frame];
    _webView.backgroundColor=dtManager.configuration.color.background;
    [self.view addSubview:_webView];
    
    
    //depending upontype of page content (HTML text/URL),load the page 
    if(qrContent != nil)
    {
        // [_webView stopLoading];
        if(qrContent.type == CPContentTypeHTML)
        {
            if(qrContent.text != nil)
            {
                [_webView loadHTMLString:self.qrContent.text baseURL:nil];
            }
        } 
        else if(qrContent.type == CPContentTypeURL)
        {
            if(qrContent.text != nil)
            {
                //NSLog(@"qrContent: %@",self.qrContent.text);
                [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.qrContent.text]]];
                
                
            }
        }
    }
    else 
    {
        
        // CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
        // appDelegate.isRootViewController=YES;
        
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
        
        
    }
    
    
    
    
    _footerView = [CPFooterView footerViewWithToolBarType:CPFooterItemTypeDefault];
    _footerView.tag = CPFooterItemTypeDefault;//---------default FooterType is Scan------
    _footerView.delegate = self;
    _footerView.frame = CGRectMake(0.0, self.view.frame.size.height-44, self.view.frame.size.width, _footerView.frame.size.height);
    
    
    //  _footerView.tintColor = configuration.color.footer;
    //   [self.view addSubview:_footerView];
    CPConfiguration *configuration = (CPConfiguration*)dtManager.configuration;
    _footerView.tintColor = configuration.color.footer;
   // [self.view addSubview:_footerView];
    
    bgBannerView=[[UIView alloc]init];
    bgBannerView.backgroundColor=[UIColor whiteColor];
    bgBannerView.frame=CGRectMake(0, self.view.frame.size.height-(BANNER_HEIGHT), self.view.frame.size.width, BANNER_HEIGHT);
    [self.view addSubview:bgBannerView];
    [self showBannarView];
}
    



-(void)loadRequest{
    
   
    
    CPMenu *menu = [[CPDataManger sharedDataManager] selectedMenu];

        if(qrContent != nil)
        {
            // [_webView stopLoading];
            if(qrContent.type == CPContentTypeHTML)
            {
                if(qrContent.text != nil)
                {
                    [_webView loadHTMLString:self.qrContent.text baseURL:nil];
                }
            } 
            else if(qrContent.type == CPContentTypeURL)
            {
                if(qrContent.text != nil)
                {
                    //NSLog(@"qrContent: %@",self.qrContent.text);
                    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.qrContent.text]]];
                    
                    
                }
            }
        }
        else 
        {
            
            // CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
            // appDelegate.isRootViewController=YES;
            
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
            

    }
    
    //NSLog(@"saved");
   
    

}

-(void)upDateUI{
   
    [descriptionViewController updateUI];
    [cpTourGuideIPhone upDateUI];
    
    [rootViewController upDateUI];
    
    
    CPConfiguration *configuration = (CPConfiguration*)dtManager.configuration;
    _footerView.tintColor = configuration.color.footer;

    
    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-BANNER_HEIGHT);

    _webView.frame=frame;
   // _footerView.frame = CGRectMake(0.0, self.view.frame.size.height-44, self.view.frame.size.width, _footerView.frame.size.height);

    bgBannerView.frame=CGRectMake(0, self.view.frame.size.height-(BANNER_HEIGHT), self.view.frame.size.width, BANNER_HEIGHT);

}





#pragma marks  - admob delegates
-(void)showBannarView{
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
    CGRect rect=view.frame;
    rect.origin.y=self.view.frame.size.height - (view.frame.size.height);
    view.frame=rect;
    
    rect=self.view.frame;
    rect.size.height-=(BANNER_HEIGHT);
    _webView.frame=rect;
    
    //_footerView.frame = CGRectMake(0.0, self.view.frame.size.height-44, self.view.frame.size.width, _footerView.frame.size.height);
    bgBannerView.frame=CGRectMake(0, self.view.frame.size.height-(BANNER_HEIGHT), self.view.frame.size.width, BANNER_HEIGHT);
}

-(void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error{
    CGRect rect=self.view.frame;
    rect.size.height-=(BANNER_HEIGHT);
    _webView.frame=rect;
    
   // _footerView.frame = CGRectMake(0.0, self.view.frame.size.height-44, self.view.frame.size.width, _footerView.frame.size.height);
    bgBannerView.frame=CGRectMake(0, self.view.frame.size.height-(BANNER_HEIGHT), self.view.frame.size.width, BANNER_HEIGHT);


}
-(void)adViewWillDismissScreen:(GADBannerView *)adView{
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.tintColor =  dtManager.configuration.color.header;
    
    [self upDateUI];
}


-(void)viewWillDisappear:(BOOL)animated{
    [self reloadAdd];

       
}





- (void)footerView:(CPFooterView*)footerView didClickItemWithType:(CPFooterItemType)type{
    
    
    if(type == CPFooterItemTypeDefault)
    {
       // isQRCodeScan=YES;
        
        ZBarReaderViewController *reader = [ZBarReaderViewController new];
        reader.readerDelegate = self;
        
        reader.readerView.torchMode = 0;
        
        ZBarImageScanner *scanner = reader.scanner;
        // TODO: (optional) additional reader configuration here
        
        // EXAMPLE: disable rarely used I2/5 to improve performance
        [scanner setSymbology: ZBAR_I25
                       config: ZBAR_CFG_ENABLE
                           to: 0];
        
      //  UIDevice *device=[UIDevice currentDevice];
        
        //[self.view ]
        
                // present and release the controller
        [self presentModalViewController: reader
                                animated: YES];
        }
    else
    {
        
    }
    
}




#pragma mark - UIImagePickerControllerDelegate -
- (void) imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    CPAppDelegate *appDelegate= (CPAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate upDateViewFramewithPicker:reader toReplaceView:self.view];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        /*if(isPotrait==NO){
            [reader dismissModalViewControllerAnimated: NO];
            
            return;
        }*/
        
        if(!([[UIDevice currentDevice] orientation]==UIDeviceOrientationPortrait)||([[UIDevice currentDevice] orientation]==UIDeviceOrientationPortraitUpsideDown)){
//            [reader dismissModalViewControllerAnimated: NO];
            [reader dismissViewControllerAnimated:NO completion:nil];
            return;
        }
        

        
    }
  
    

	// ADD: get the decode results
	id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
	ZBarSymbol *symbol = nil;
	NSString *hiddenData = nil;
	for(symbol in results)
		hiddenData=[NSString stringWithString:symbol.data];
    
    NSURL *url = [NSURL URLWithString:hiddenData];
    if ([[[url scheme] lowercaseString] isEqualToString:@"http"]) 
    {
        
            CPContent* qrContent1 = [[CPContent alloc] init];
            qrContent1.type = CPContentTypeURL;
        qrContent1.text = hiddenData;
        //   CPPageViewController *_pageViewController = [[CPPageViewController alloc] initWithNibName:nil bundle:nil];
//        [reader dismissModalViewControllerAnimated: NO];
        [reader dismissViewControllerAnimated:NO completion:nil];

        
       // if([self.navigationController.visibleViewController  isKindOfClass:[ScanResultsPage class]]){
            qrContent=qrContent1;
            
            [self loadRequest];
            
       /* }
        else{
        
    
        ScanResultsPage *_pageViewController = [[ScanResultsPage alloc] initWithNibName:nil bundle:nil];
        
        _pageViewController.qrContent = qrContent;
        qrContent = nil;
        _pageViewController.title = @"Results";
        [self.navigationController pushViewController:_pageViewController animated:NO];
        [_pageViewController release];
        }*/
    }
    else
    {
               
        CPContent* qrContent1 = [[CPContent alloc] init];
        qrContent1.type = CPContentTypeHTML;
        qrContent1.text = hiddenData;
        //   CPPageViewController *_pageViewController = [[CPPageViewController alloc] initWithNibName:nil bundle:nil];
//        [reader dismissModalViewControllerAnimated: NO];
        [reader dismissViewControllerAnimated:NO completion:nil];
        
        
        // if([self.navigationController.visibleViewController  isKindOfClass:[ScanResultsPage class]]){
        qrContent=qrContent1;
        
        [self loadRequest];

//        [reader dismissModalViewControllerAnimated: NO];
        [reader dismissViewControllerAnimated:NO completion:nil];
    }
    
   
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    CPAppDelegate *appDelegate= (CPAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate upDateViewFramewithPicker:picker toReplaceView:self.view];
//    [picker dismissModalViewControllerAnimated:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
}



-(void)upDateUIForScanner{
    CPConfiguration *configuration = (CPConfiguration*)dtManager.configuration;
    _footerView.tintColor = configuration.color.footer;
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height);
    
   // frame = CGRectMake(0, 0, 1024,768);

    
    _webView.frame=frame;
    
    
    self.view.frame=frame;
    
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    
  //  _webView.frame=frame;

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
        
               
        
        // set the banner origin.y to out of bound
        CGRect rect = banner.frame;
        rect.origin.y = self.view.frame.size.height - rect.size.height;
       // rect = _webView.frame;

        if(banner.isBannerLoaded == YES)
        {
            CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-banner.frame.size.height);
            rect.origin.y =frame.size.height;
        }
        banner.frame = rect;
        
        rect = _footerView.frame;
       // rect.origin.y = _webView.frame.size.height-44;
        rect.size.width = 320.0;
        rect.size.height = 44.0;
        if(banner.isBannerLoaded == YES)
        {
            CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-_footerView.frame.size.height-banner.frame.size.height);
            _webView.frame=frame;
            rect.origin.y =_webView.frame.size.height;
            _footerView.frame = rect;

        }
        
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
               // set the banner origin.y to out of bound
        rect = banner.frame;
        rect.origin.y = self.view.frame.size.height + rect.size.height;
        banner.frame = rect;
        
        rect = _footerView.frame;
      //  rect.origin.y = self.view.frame.size.height - rect.size.height;
        rect.origin.y = _webView.frame.size.height - rect.size.height;

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







-(void)webViewDidFinishLoad:(UIWebView *)webView{
    //NSLog(@"sucsess");
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    //NSLog(@"fail");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return  (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    
    
    if((interfaceOrientation==UIInterfaceOrientationPortrait)||(interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown))
        isPotrait=YES;
    else
        isPotrait=NO;
    
    
 
        CPAppDelegate *appDelegate= (CPAppDelegate*)[UIApplication sharedApplication].delegate;
        self.view.frame=CGRectMake(0, 0,  self.interfaceOrientation>2?(appDelegate.window.frame.size.height-320):appDelegate.window.frame.size.width,self.interfaceOrientation>2?(appDelegate.window.frame.size.width-64):(appDelegate.window.frame.size.height-64));
    [self upDateUI];
    return YES;
   //  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)shouldAutorotate{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return  NO;
    }
    return YES;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return;
    }
    
    
    if((toInterfaceOrientation==UIInterfaceOrientationPortrait)||(toInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown))
        isPotrait=YES;
    else
        isPotrait=NO;
 
    
    CPAppDelegate *appDelegate= (CPAppDelegate*)[UIApplication sharedApplication].delegate;
    self.view.frame=CGRectMake(0, 0,  self.interfaceOrientation>2?(appDelegate.window.frame.size.height-320):appDelegate.window.frame.size.width,self.interfaceOrientation>2?(appDelegate.window.frame.size.width-64):(appDelegate.window.frame.size.height-64));
    [self upDateUI];
}

@end
