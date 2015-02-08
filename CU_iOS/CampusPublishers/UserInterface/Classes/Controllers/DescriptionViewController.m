//
//  DescriptionViewController.m
//  CampusPublishers
//
//  Created by v2solutions on 03/01/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//
#import "CPAppDelegate.h"
#import "DescriptionViewController.h"
#import "CPMenu.h"
#import "CPConfiguration.h"
#import "CPDataManger.h"
#import "CPPageViewController.h"
#import "CPAppDelegate.h"
#import "CPAddBannerView.h"
#import "CPUtility.h"
// saved 08/01/13
#define DESCRIPTION_FONT_SIZE 17
#define EXTRA_HEIGHT    9


@implementation DescriptionViewController
@synthesize isImageUrl,isVideoUrl;
@synthesize isLandScape;
@synthesize customImagesDict;
@synthesize place;
@synthesize pathObjectsArray;
@synthesize imageView;


- (void)viewDidLoad
{
    
    UIImage *myImage;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        myImage = [UIImage imageNamed:@"logo.png"];
    else
        myImage = [UIImage imageNamed:@"logo.png"];
    
    UIImageView *imageView1 = [[UIImageView alloc ]initWithImage:myImage];
    imageView1.frame = CGRectMake(0.0, 0.0, myImage.size.width, myImage.size.height);
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:imageView1];
    
    self.navigationItem.rightBarButtonItem = rightButton;
    
    [super viewDidLoad];
	self.view.backgroundColor=[UIColor whiteColor];
    dtManager = [CPDataManger sharedDataManager];
	[self createUI];
    bgBannerView=[[UIView alloc]init];
    bgBannerView.backgroundColor=[UIColor whiteColor];
    bgBannerView.frame=CGRectMake(0, self.view.frame.size.height-(BANNER_HEIGHT+_footerView.frame.size.height), self.view.frame.size.width, BANNER_HEIGHT);
    [self.view addSubview:bgBannerView];
    
    
    [self showBannarView];
	// Do any additional setup after loading the view, typically from a nib.
}





-(void)updateUI{
    
    if (isSubView!=YES) {
        imageView.image = [UIImage imageNamed:@"ImagePlaceholderTwo.png"];
    }
   
    imageView.frame=CGRectMake(isLandScape?234:372,10,256,202);

        
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {    
        imageView.frame=CGRectMake(isLandScape?234:372,10,256,202);
        _videoIcon1.frame=imageView.frame;

        imageView.frame =  CGRectMake((self.view.frame.size.width - imageView.frame.size.width)/2, 5.0, imageView.frame.size.width, imageView.frame.size.height);
        _webView.frame = CGRectMake(0.0, imageView.frame.size.height + 10.0, self.view.frame.size.width, self.view.frame.size.height -( _footerView.frame.size.height + imageView.frame.size.height));
        //[self animateFooterView:YES];
        _videoIcon1.frame=imageView.frame;

    }
    else 
    {

      //  imageView.frame =  CGRectMake((self.view.frame.size.width - imageView.frame.size.width/2.0)/2, 2.5, imageView.frame.size.width/2.0, imageView.frame.size.height/2.0);
      //  imageView.frame=CGRectMake(isLandScape?234:372,10,256,202);
        imageView.frame =  CGRectMake((self.view.frame.size.width - imageView.frame.size.width)/2, 5.0, imageView.frame.size.width, imageView.frame.size.height);
        _activityView.frame=CGRectMake((imageView.frame.size.width-_activityView.frame.size.width)/2, (imageView.frame.size.height-_activityView.frame.size.height)/2, 25, 25);

        _videoIcon1.frame=imageView.frame;

        _webView.frame = CGRectMake(0.0, imageView.frame.size.height + 10.0, self.view.frame.size.width, self.view.frame.size.height -(imageView.frame.size.height));

    }

    if(place.media_type!=2){
        if(_videoIcon!=nil && _videoIcon.superview!=nil)
            _videoIcon.hidden=YES;
        _videoIcon1.userInteractionEnabled=NO;
    }
    else
        _videoIcon1.userInteractionEnabled=YES;

	

    
    
}



-(void)orientationUpdateUI{
    imageView.frame=CGRectMake(isLandScape?234:372,10,256,202);
    
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {    
        imageView.frame=CGRectMake(isLandScape?234:372,10,256,202);
        _videoIcon1.frame=imageView.frame;
        
        imageView.frame =  CGRectMake((self.view.frame.size.width - imageView.frame.size.width)/2, 5.0, imageView.frame.size.width, imageView.frame.size.height);
        _webView.frame = CGRectMake(0.0, imageView.frame.size.height + 10.0, self.view.frame.size.width, self.view.frame.size.height -( _footerView.frame.size.height + imageView.frame.size.height+BANNER_HEIGHT+EXTRA_HEIGHT));
       // [self animateFooterView:YES];
        _videoIcon1.frame=imageView.frame;
        
    }
    else 
    {
        
        //  imageView.frame =  CGRectMake((self.view.frame.size.width - imageView.frame.size.width/2.0)/2, 2.5, imageView.frame.size.width/2.0, imageView.frame.size.height/2.0);
        //  imageView.frame=CGRectMake(isLandScape?234:372,10,256,202);
        imageView.frame =  CGRectMake((self.view.frame.size.width - imageView.frame.size.width)/2, 5.0, imageView.frame.size.width, imageView.frame.size.height);
        _videoIcon1.frame=imageView.frame;
        
        _webView.frame = CGRectMake(0.0, imageView.frame.size.height + 10.0, self.view.frame.size.width, self.view.frame.size.height -(imageView.frame.size.height+EXTRA_HEIGHT));
        
    }
    
    if(place.media_type!=2){
        if(_videoIcon!=nil && _videoIcon.superview!=nil)
            _videoIcon.hidden=YES;
    }
	
    
    bgBannerView.frame=CGRectMake(0, self.view.frame.size.height-(BANNER_HEIGHT+_footerView.frame.size.height), self.view.frame.size.width, BANNER_HEIGHT);

_footerView.frame = CGRectMake(0.0, self.view.frame.size.height-_footerView.frame.size.height, self.view.frame.size.width, _footerView.frame.size.height);
    
   // [self animateFooterView:YES];

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
    r.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, nil]; // testDevices -Austin
    [gADBannerView loadRequest:r];
}

-(void)reloadAdd{
    GADRequest *r = [[GADRequest alloc] init];
    r.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, nil]; // testDevices -Austin
    [gADBannerView loadRequest:r];
}


-(void)adViewDidReceiveAd:(GADBannerView *)view{
    
  /*  if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        CGRect rect=view.frame;
        rect.origin.y=self.view.frame.size.height - (_footerView.frame.size.height+BANNER_HEIGHT);
        view.frame=rect;
    }else{*/
        CGRect rect=view.frame;
        rect.origin.y=self.view.frame.size.height - (_footerView.frame.size.height+BANNER_HEIGHT);
        view.frame=rect;
        
        rect=_webView.frame ;
        rect.size.height=self.view.frame.size.height-(imageView.frame.size.height+_footerView.frame.size.height+BANNER_HEIGHT+EXTRA_HEIGHT);
        _webView.frame=rect;

  //  }
    bgBannerView.frame=CGRectMake(0, self.view.frame.size.height-(BANNER_HEIGHT+_footerView.frame.size.height), self.view.frame.size.width, BANNER_HEIGHT);
}

-(void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error{
  /*  if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        CGRect rect=_webView.frame ;
        rect.size.height=self.view.frame.size.height-_footerView.frame.size.height;
        _webView.frame=rect;
    }else{*/
        CGRect rect=_webView.frame ;
        rect.size.height=self.view.frame.size.height-(imageView.frame.size.height+_footerView.frame.size.height+EXTRA_HEIGHT);
        _webView.frame=rect;
   // }
    rect=view.frame;
    rect.origin.y=self.view.frame.size.height ;
    view.frame=rect;
    bgBannerView.frame=CGRectMake(0, self.view.frame.size.height-(BANNER_HEIGHT+_footerView.frame.size.height), self.view.frame.size.width, BANNER_HEIGHT);

}
-(void)adViewWillDismissScreen:(GADBannerView *)adView{
}

-(void)viewWillAppear:(BOOL)animated{
    [self reloadAdd];

     _footerView.frame = CGRectMake(0.0, self.view.frame.size.height-_footerView.frame.size.height, self.view.frame.size.width, _footerView.frame.size.height);
    [self orientationUpdateUI];
    if (isSubView==YES) {
        isSubView=NO;
        return;
    }
    
    
    
    if(!isPlay){
         imageView.image=[UIImage imageNamed:@"ImagePlaceholderTwo.png"];
        
/*
NSMutableString *tempstring = [[NSMutableString stringWithString:place.description] mutableCopy];
NSMutableString *newtempstring = [[tempstring stringByReplacingOccurrencesOfString:@"<p" withString:@"<p style=\"font-family:arial;\""] mutableCopy]; //TODO refactor the view method and replace this cheap hack.
*/
[_webView loadHTMLString:place.description baseURL:nil]; //-Austin
        
        
    [self updateUI];
    self.navigationItem.title=place.name?place.name:@"";
    self.navigationController.navigationBar.tintColor =  dtManager.configuration.color.header;
        
    [[CPConnectionManager sharedConnectionManager] closeAllConnections];
      [self getImageRequest];
    
    isQRCodeScan=NO;
    
    CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.isRootViewController=YES;
    
    
    
    [self.view bringSubviewToFront:_videoIcon1];
        [imageView addSubview:_activityView];
        [_activityView startAnimating];

   if(place.media_type==2)
       _videoIcon.hidden=NO;
   else
       _videoIcon.hidden=YES;
        
        
    }
    else{
        if(image!=nil)
        imageView.image=[UIImage imageWithData:image];   
        isPlay=NO;
        
    }
    
}

/*
-(void)viewDidAppear:(BOOL)animated{
    [self orientationUpdateUI];
    [self animateFooterView:YES];
    _footerView.frame = CGRectMake(0.0, self.view.frame.size.height-_footerView.frame.size.height, self.view.frame.size.width, _footerView.frame.size.height);
}*/



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return  (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
   
        _footerView.frame = CGRectMake(0.0, self.view.frame.size.height-_footerView.frame.size.height, self.view.frame.size.width, _footerView.frame.size.height);
        
		if (interfaceOrientation==UIInterfaceOrientationPortrait||interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown) {
            isLandScape=NO;
            isPotrait=YES;
        }
        else {
            isLandScape=YES;
            isPotrait=NO;
        }
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        CPAppDelegate *appDelegate= (CPAppDelegate*)[UIApplication sharedApplication].delegate;
        self.view.frame=CGRectMake(0, 0,  self.interfaceOrientation>2?(appDelegate.window.frame.size.height-320):appDelegate.window.frame.size.width,self.interfaceOrientation>2?(appDelegate.window.frame.size.width-64):(appDelegate.window.frame.size.height-64));
    }
		
        [self orientationUpdateUI];
        return YES;
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
        return ;
    }
        CPAppDelegate *appDelegate= (CPAppDelegate*)[UIApplication sharedApplication].delegate;
        self.view.frame=CGRectMake(0, 0,  self.interfaceOrientation>2?(appDelegate.window.frame.size.height-320):appDelegate.window.frame.size.width,self.interfaceOrientation>2?(appDelegate.window.frame.size.width-64):(appDelegate.window.frame.size.height-64));
        
        _footerView.frame = CGRectMake(0.0, self.view.frame.size.height-_footerView.frame.size.height, self.view.frame.size.width, _footerView.frame.size.height);
        
		if (toInterfaceOrientation==UIInterfaceOrientationPortrait||toInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown) {
            isLandScape=NO;
            isPotrait=YES;
        }
        else {
            isLandScape=YES;
            isPotrait=NO;
        }
		
	
        [self orientationUpdateUI];
}




-(void)createUI{

    
    
    _activityView =  [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_activityView sizeToFit];
    _activityView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.navigationController.navigationBar.translucent = NO; // For image cutoff fix -Austin

    [_activityView startAnimating];
    
	if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	{
        
        
               
        
		imageView=[[UIImageView alloc]init];
		imageView.frame=CGRectMake(isLandScape?234:372,10,256,202);
        imageView.frame=CGRectMake((self.view.frame.size.width-imageView.frame.size.width)/2, 5.0,300, 202);
		_activityView.frame=CGRectMake((imageView.frame.size.width-_activityView.frame.size.width)/2-12, (imageView.frame.size.height-_activityView.frame.size.height)/2, 25, 25);

		[imageView addSubview:_activityView];
        
        imageView.image=[UIImage imageNamed:@"ImagePlaceholderTwo.png"];

		[self.view addSubview:imageView];
        
       
	        
        
        _webView=[[UIWebView alloc]initWithFrame:textView.frame];
        _webView.frame = CGRectMake(0.0, imageView.frame.size.height + 10.0, self.view.frame.size.width, self.view.frame.size.height -( _footerView.frame.size.height + imageView.frame.size.height));

        _webView.backgroundColor=dtManager.configuration.color.background;
        [self.view addSubview:_webView];
        
        
        
	
		scrollView.contentSize= CGSizeMake(isLandScape?1024:768,(imageView.frame.size.height + textView.frame.size.height +20));
        
		[_activityView startAnimating];
        
        

        _footerView = [CPFooterView footerViewWithToolBarType:CPFooterItemTypeDefault];
        _footerView.tag = CPFooterItemTypeDefault;//---------default FooterType is Scan------
        _footerView.delegate = self;
        
        _footerView.frame = CGRectMake(0.0, self.view.frame.size.height-_footerView.frame.size.height, self.view.frame.size.width, _footerView.frame.size.height);
        //  _footerView.tintColor = configuration.color.footer;
        CPConfiguration *configuration = (CPConfiguration*)dtManager.configuration;
        _footerView.tintColor = configuration.color.footer;
         [self.view addSubview:_footerView];
        
        
       // if(isVideoUrl==YES){
            _videoIcon = [[UIButton alloc]init];
            [_videoIcon setImage:[UIImage imageNamed:@"playIcon.png"] forState:UIControlStateNormal];
            [_videoIcon sizeToFit];
            _videoIcon.frame = CGRectMake((256-56)/2,(202-56)/2,56,56);
            
            [_videoIcon setTag:1];
            _videoIcon.showsTouchWhenHighlighted = YES;
            _videoIcon.userInteractionEnabled=NO;
          //  [_videoIcon addTarget:self action:@selector(playVideo:)  forControlEvents: UIControlEventTouchUpInside];
            
            [imageView addSubview:_videoIcon];
            _videoIcon1 = [[UIButton alloc]init];
            _videoIcon1.frame=imageView.frame;
            //_videoIcon1.frame=CGRectMake(isLandScape?234:372,10,256,202);
            [_videoIcon1 addTarget:self action:@selector(playVideo:)  forControlEvents: UIControlEventTouchUpInside];
            _videoIcon1.backgroundColor=[UIColor clearColor];
            [self.view addSubview:_videoIcon1];
            [self.view bringSubviewToFront:_videoIcon1];

            
       // }
	}
    
	else{
		
        if(_videoIcon!=nil && _videoIcon.superview!=nil){
            _videoIcon1.hidden=YES;
        }
        
        
		scrollView=[[UIScrollView alloc]init];
		scrollView.frame=CGRectMake(0,0,320,480);
		scrollView.backgroundColor=[UIColor whiteColor];
		scrollView.scrollEnabled=YES;
		//[self.view addSubview:scrollView];

		imageView=[[UIImageView alloc]init];
		imageView.frame=CGRectMake(isLandScape?234:372,10,256,202);
		imageView.backgroundColor=[UIColor clearColor];
        _activityView.frame=CGRectMake((imageView.frame.size.width-_activityView.frame.size.width)/2-12, (imageView.frame.size.height-_activityView.frame.size.height)/2, 25, 25);

        _activityView.center=imageView.center;
        
		[imageView addSubview:_activityView];
		[_activityView startAnimating];

            [self.view addSubview:imageView];
        
        _webView=[[UIWebView alloc]initWithFrame:textView.frame];
        [_webView sizeToFit];
        _webView.frame = CGRectMake(0.0, imageView.frame.size.height + 10.0, self.view.frame.size.width, self.view.frame.size.height -( _footerView.frame.size.height + imageView.frame.size.height));

        _webView.backgroundColor=dtManager.configuration.color.background;
        //[scrollView addSubview:_webView];
        [self.view addSubview:_webView];

        textView.font=[UIFont fontWithName:@"ArialMT" size:DESCRIPTION_FONT_SIZE];
        
        scrollView.contentSize= CGSizeMake(320,(imageView.frame.size.height + textView.frame.size.height +20));
		
		
		
		
		//_activityView.center=imageView.center;
		//[imageView addSubview:_activityView];
        
		[_activityView startAnimating];
        
        
        
        _footerView = [CPFooterView footerViewWithToolBarType:CPFooterItemTypeDefault];
        _footerView.tag = CPFooterItemTypeDefault;//---------default FooterType is Scan------
        _footerView.delegate = self;
        _footerView.frame = CGRectMake(0.0, self.view.frame.size.height-_footerView.frame.size.height, self.view.frame.size.width, _footerView.frame.size.height);
        //  _footerView.tintColor = configuration.color.footer;
           [self.view addSubview:_footerView];
        CPConfiguration *configuration = (CPConfiguration*)dtManager.configuration;
        _footerView.tintColor = configuration.color.footer;
        
        
        
        
        //if(isVideoUrl==YES){
            _videoIcon = [[UIButton alloc]init];
            [_videoIcon setImage:[UIImage imageNamed:@"playIcon.png"] forState:UIControlStateNormal];
            [_videoIcon sizeToFit];
            _videoIcon.frame = CGRectMake((256-56)/2,(202-56)/2,56,56);
            
            [_videoIcon setTag:1];
            _videoIcon.showsTouchWhenHighlighted = YES;
            _videoIcon.userInteractionEnabled=NO;
            //[_videoIcon addTarget:self action:@selector(playVideo:)  forControlEvents: UIControlEventTouchUpInside];
            
            [imageView addSubview:_videoIcon];
             _videoIcon1 = [[UIButton alloc]init];
           // _videoIcon1.frame=CGRectMake(isLandScape?234:372,10,256,202);
          //  _videoIcon1.frame=imageView.frame;
            [_videoIcon1 addTarget:self action:@selector(playVideo:)  forControlEvents: UIControlEventTouchUpInside];
            _videoIcon1.backgroundColor=[UIColor clearColor];
            
            [self.view addSubview:_videoIcon1];
            [self.view bringSubviewToFront:_videoIcon1];
            
        //}
	}
    
  
    
}
	
    



-(void)viewWillDisappear:(BOOL)animated{
    
}

- (void)footerView:(CPFooterView*)footerView didClickItemWithType:(CPFooterItemType)type{
    
   
            if(type == CPFooterItemTypeDefault)
            {
                isQRCodeScan=YES;
                
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
    else
    {
        
    }
    
}




//getting Images for Particualr index
- (void)getImageRequest
{
    [[CPConnectionManager sharedConnectionManager] closeAllConnections];

   
    
    
    CPConnectionManager *manager = [CPConnectionManager sharedConnectionManager];
    
 
  
   
    NSURL *url;
        if (isImageUrl) 
        {
            isImageUrl=NO;
            
                     
    
            if(place.map_image.length>0){

            
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/iphone/%@/%@",dtManager.configuration.imagePath,[CPUtility deviceDensity],place.map_image?place.map_image:@""] ];

            ////NSLog(@"%@",[NSURL URLWithString:[NSString stringWithFormat:@"%@/iphone/%@/%@",dtManager.configuration.imagePath,[CPUtility deviceDensity],place.map_image?place.map_image:@""] ]);
            }
            else{
                [_activityView removeFromSuperview];

            }
        }
        else if (isVideoUrl)
        {
            
            isVideoUrl=NO;
                                   
            

            if(place.video_thumb.length>0){

            
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/iphone/%@/%@",dtManager.configuration.videoPath,[CPUtility deviceDensity],place.video_thumb?place.video_thumb:@""] ];
            
         //   //NSLog(@"%@",[NSURL URLWithString:[NSString stringWithFormat:@"%@/iphone/%@/%@",dtManager.configuration.videoPath,[CPUtility deviceDensity],place.video_thumb?place.video_thumb:@""] ]);
            }
            else
            {
                [_activityView removeFromSuperview];
            }
        }
        else
        {
            [_activityView removeFromSuperview];
            return;
        }
    
        CPRequest*request = [[CPRequest alloc] initWithURL:url  withRequestType:CPRequestTypeImage];
        [manager spawnConnectionWithRequest:request delegate:self];
  
}




- (void)CPConnection:(CPConnection*)CPConnection didReceiveResponse:(id)response
{
    if(_activityView!=nil){
        [_activityView removeFromSuperview];
    }
   

    NSData *_data = [(NSDictionary*)response valueForKey:@"data"];
      
    if(CPConnection.request.type == CPRequestTypeImage)
    {   
          imageView.image=[UIImage imageWithData:_data];
        if(_data!=nil)
        image=[[NSData alloc]initWithData:_data ];

    }
    [self.view bringSubviewToFront:_videoIcon1];

                
        return;
    
} 
    
- (void)CPConnection:(CPConnection*)CPConnection didFailWithError:(NSError*)error
{
    if(_activityView!=nil){
        [_activityView removeFromSuperview];
    }
    /* if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
     {
     if(loadView != nil)
     {
     [self removeLoadingView];
     }
     }
     else{
     if(_activityView.superview!=nil)
     [_activityView removeFromSuperview];
     
     }     */
    
    
    if(CPConnection.request.type != CPRequestTypeImage)
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
        
    }
    
}





-(void)playVideo:(id)sender
{
    isPlay=YES;
       
    
    NSURL *_videoUrl;
    
    _videoUrl=[NSURL URLWithString:[NSString stringWithFormat:@"%@/iphone/%@/%@",dtManager.configuration.videoPath,[CPUtility deviceDensity],place.video_name?place.video_name:@""] ];
    

   
    
  
    
    MPMoviePlayerViewController *playerController = [[MPMoviePlayerViewController alloc] initWithContentURL:_videoUrl ];
      
    
    
    playerController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    
    
    [playerController.moviePlayer play];
    
    [self.navigationController presentMoviePlayerViewControllerAnimated:playerController ];

}



#pragma mark - UIImagePickerControllerDelegate -
- (void) imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    isSubView=YES;
    CPAppDelegate *appDelegate= (CPAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate upDateViewFramewithPicker:reader toReplaceView:self.view];
    
    
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
        //   CPPageViewController *_pageViewController = [[CPPageViewController alloc] initWithNibName:nil bundle:nil];
        ScanResultsPage *_pageViewController = [[ScanResultsPage alloc] initWithNibName:nil bundle:nil];
        _pageViewController.descriptionViewController=self;
        _pageViewController.qrContent = qrContent;
        qrContent = nil;
        _pageViewController.title = @"Results";
        [self.navigationController pushViewController:_pageViewController animated:NO];
      
        [reader dismissModalViewControllerAnimated: NO];
    }
    else
    {
        qrContent = [[CPContent alloc] init];
        qrContent.type = CPContentTypeHTML;
        qrContent.text = hiddenData;
        // CPPageViewController *_pageViewController = [[CPPageViewController alloc] initWithNibName:nil bundle:nil];
        ScanResultsPage *_pageViewController = [[ScanResultsPage alloc] initWithNibName:nil bundle:nil];
        
        _pageViewController.descriptionViewController=self;

        _pageViewController.qrContent = qrContent;
        qrContent = nil;
        _pageViewController.title = @"Results";
        [self.navigationController pushViewController:_pageViewController animated:NO];
      
        [reader dismissModalViewControllerAnimated: NO];
    }
}


-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
        isSubView=YES;
        CPAppDelegate *appDelegate= (CPAppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate upDateViewFramewithPicker:picker toReplaceView:self.view];
        [picker dismissModalViewControllerAnimated:NO];
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
        if(imageView.superview != nil)
        {
            rect.size.height = self.view.frame.size.height - (_footerView.frame.size.height +  imageView.frame.size.height);
            if(banner.isBannerLoaded == YES)
            {
                
                if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
                    rect.origin.y = imageView.frame.size.height;

                rect.size.height = self.view.frame.size.height - (banner.frame.size.height +  _footerView.frame.size.height + imageView.frame.size.height);
                }
                else
                rect.size.height = self.view.frame.size.height - (banner.frame.size.height +  _footerView.frame.size.height );

            }
        }
      /*  if (self.qrContent != nil) 
        {
            rect.size.height = self.view.frame.size.height - _footerView.frame.size.height; 
            if(banner.isBannerLoaded == YES)
            {
                rect.size.height = self.view.frame.size.height - (_footerView.frame.size.height + banner.frame.size.height);
            }
        }*/
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            textView.frame = rect;
        else
            scrollView.frame=rect; 
        
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
        rect.size.height = _footerView.frame.size.height;
        if(banner.isBannerLoaded == YES)
        {
            rect.origin.y = self.view.frame.size.height - (rect.size.height + banner.frame.size.height);
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
        /*if(_imgView.superview != nil)
         {
         rect.origin.y = _imgView.frame.size.height;
         rect.size.height = self.view.frame.size.height - (_footerView.frame.size.height + _imgView.frame.size.height);
         }
         */ 
        /*  if (self.qrContent != nil) 
         {
         rect.size.height = self.view.frame.size.height; 
         }
         
         _webView.frame = rect;
         */
        
        
        // set the banner origin.y to out of bound
        rect = banner.frame;
        rect.origin.y = self.view.frame.size.height + rect.size.height;
        banner.frame = rect;
        
        rect = _footerView.frame;
        rect.origin.y = self.view.frame.size.height - rect.size.height;
        /*   if (self.qrContent != nil) 
         {
         rect.origin.y = self.view.frame.size.height + rect.size.height;
         }
         */  
        _footerView.frame = rect;
        [UIView commitAnimations];
    }
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    isSubView=YES;
    BOOL shouldExecuteAction = YES;
    
    if (!willLeave && shouldExecuteAction)
    {
        // stop all interactive processes in the app
        // [video pause];
        // [audio pause];
    }
    return shouldExecuteAction;
}

/*
- (void)animateFooterView:(BOOL)animated
{
    ADBannerView *banner = [CPAddBannerView sharedAddBannerView].adBannerView;
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
        rect.origin.y = 0.0;
        
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

*/


@end
