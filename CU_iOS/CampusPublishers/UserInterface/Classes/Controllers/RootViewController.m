//
//  RootViewController.m
//  GoogleMapWithDirections
//
//  Created by v2solutions on 21/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



#import "PointObject.h"
#import "RootViewController.h"

#import "CustomAnnotationView.h"
#import "CustomMapItem.h"
//#import "DataConnection.h"
#import <Foundation/NSObject.h>
#import <Foundation/Foundation.h>
#import "CPConfiguration.h"
#import "CPDataManger.h"
#import "ZBarReaderViewController.h"
#import "ZBarReaderView.h"
#import "CPAddBannerView.h"
#import "CPAppDelegate.h"
#import "CPConnectionManager.h"
#import "CPMenu.h"
#import "LoadingView.h"
#import "CPUtility.h"
#import "CPContent.h"

#import "CPPageViewController.h"
#import "DescriptionViewController.h"
#import "ScanResultsPage.h"
#import "CPMapCategories.h"
@implementation RootViewController
{
    CustomAnnotationView *tempAnnotationView;
}
@synthesize categoryIdArray,categoryObjectArray;
@synthesize isAtCampus;
@synthesize locationManager;
@synthesize mapView;
@synthesize isRoot;
@synthesize descriptionViewController;
@synthesize isRootView,isDirectionSelected;
@synthesize isGoogleAPI;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        locationManager=[[CLLocationManager alloc]init];
        locationManager.delegate=self;
        locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        locationManager.distanceFilter=kCLLocationAccuracyNearestTenMeters;;
        [locationManager startUpdatingLocation];
		

        UIImage *myImage;
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            myImage = [UIImage imageNamed:@"logo.png"];
        else
            myImage = [UIImage imageNamed:@"logo.png"];
        
        UIImageView *imageView = [[UIImageView alloc ]initWithImage:myImage];
        imageView.frame = CGRectMake(0.0, 0.0, myImage.size.width, myImage.size.height);
        
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:imageView];
        
        self.navigationItem.rightBarButtonItem = rightButton;
        // Custom initialization
    }
    return self;
}



- (void)footerView:(CPFooterView*)footerView didClickItemWithType:(CPFooterItemType)type{
    isQRCodeScan=NO;

    //NSLog(@"%d",isInteractionEnabled);
   // if(isInteractionEnabled){
    if(type==CPFooterItemToureGuide){
  
      
    }
    else     

        if(type == CPFooterItemTypeDefault)
        {
          //  CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
           // appDelegate.isRootViewController=YES;
            
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
   // }
   // else
   // {
        
   // }
}
    

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
    location=[[CLLocation alloc]initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude]; 
    
    if(annotationForCurrentLocation!=nil){
        [mapView removeAnnotation:annotationForCurrentLocation];
    }
    //NSLog(@"l1");
    
    if(mapView!=nil){
        //NSLog(@"l1");
        
        if(annotationForCurrentLocation==nil){
            annotationForCurrentLocation=[[MyAnnotation alloc]init];
            annotationForCurrentLocation.place=[[Place alloc]init] ;
        }
        annotationForCurrentLocation.place.name=@"Current Position";
        
        annotationForCurrentLocation.place.latitude=newLocation.coordinate.latitude;
        annotationForCurrentLocation.place.longitude=newLocation.coordinate.longitude;
        annotationForCurrentLocation.coordinate=newLocation.coordinate;
        [mapView addAnnotation:annotationForCurrentLocation];
        
        
        // [mapView setCenterCoordinate:newLocation.coordinate animated:YES];
    }
    //NSLog(@"l2");
    
}


- (MKPolyline *)getPolylineOjbect{
    MKMapPoint *coords = calloc(placeArray.count, sizeof(CLLocationCoordinate2D));
    
    
       int count=0;
    
    for (Place *item in placeArray) {
        
        CLLocationCoordinate2D coord;
        coord = CLLocationCoordinate2DMake(item.latitude, item.longitude);
        //NSLog(@"%f %f %d" ,item.latitude, item.longitude,count);
        
        MKMapPoint point = MKMapPointForCoordinate(coord);
        coords[count++]=point;
    }

    MKPolyline *polyline1=[MKPolyline polylineWithPoints:coords count:placeArray.count];
    free(coords);
    return polyline1;
}

- (MKPolyline *)polylineWithEncodedString:(NSString *)encodedString {
    const char *bytes = [encodedString UTF8String];
    NSUInteger length = [encodedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger idx = 0;
    
    NSUInteger count = length / 4;
    MKMapPoint *coords = calloc(count, sizeof(CLLocationCoordinate2D));
    NSUInteger coordIdx = 0;
    
    int repeatCount=0;
    
    float latitude = 0;
    float longitude = 0;
    while (idx < length) {
        char byte = 0;
        int res = 0;
        char shift = 0;
        
        do {
            byte = bytes[idx++] - 63;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLat = ((res & 1) ? ~(res >> 1) : (res >> 1));
        latitude += deltaLat;
        //NSLog(@"%f",deltaLat);
        
        shift = 0;
        res = 0;
        
        do {
            byte = bytes[idx++] - 0x3F;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLon = ((res & 1) ? ~(res >> 1) : (res >> 1));
        longitude += deltaLon;
        
        //NSLog(@"%f",deltaLon);
        
        //NSLog(@"%f %f",latitude,longitude);
        
        
        float finalLat = latitude * 1E-5;
        float finalLon = longitude * 1E-5;
        
        //NSLog(@"%f %f",finalLat,finalLon);
        CLLocationCoordinate2D coord;
        coord = CLLocationCoordinate2DMake(finalLat, finalLon);
        
       // if(!(latitude<10 &&latitude>-10)&&!(longitude<10 &&longitude>-10) )
       // {
        
        MKMapPoint point = MKMapPointForCoordinate(coord);
        
        coords[coordIdx++] = point;
        
       // }
       // else{
       //     repeatCount++;
       // }
        
        //NSLog(@"%d %d %d",repeatCount,coordIdx,count);
        
        if (coordIdx == count) {
            NSUInteger newCount = count + 10;
            coords = realloc(coords, newCount * sizeof(CLLocationCoordinate2D));
            count = newCount;
        }
    }
    
    
    
    // MKPolyline *polyline1 = [MKPolyline polylineWithCoordinates:coords count:coordIdx];
    
    MKPolyline *polyline1= [MKPolyline polylineWithPoints:coords count:coordIdx];
    free(coords);
    
    return polyline1;
}

-(MKPolyline *) drawMapPath{
    
    
    
    CLLocationCoordinate2D *coords = calloc(arrayForPoints.count, sizeof(CLLocationCoordinate2D));
 /*   
    for(int i=0;i<arrayForPoints.count;i++){
      
        PointObject *temp=[ arrayForPoints objectAtIndex:i];
        CLLocationDegrees latitude = [temp.latitude doubleValue];
        CLLocationDegrees longitude=[temp.longitude doubleValue];
       
        //NSLog(@"%f %f",latitude, longitude);

        
        CLLocationCoordinate2D coord=CLLocationCoordinate2DMake(latitude, longitude);
        coords[i] = coord;
    
    }*/
    
    
    for(int i=0,j=0;i<arrayForPoints.count;i++,j++){
        
        PointObject *temp=[ arrayForPoints objectAtIndex:i];
        CLLocationDegrees latitude = [temp.latitude doubleValue];
        CLLocationDegrees longitude=[temp.longitude doubleValue];
        
        //NSLog(@"%f %f",latitude, longitude);
        
            
        CLLocationCoordinate2D coord=CLLocationCoordinate2DMake(latitude, longitude);
        coords[j] = coord;
        
    }
    
         
    
    
     MKPolyline *polyline1 = [MKPolyline polylineWithCoordinates:coords count:arrayForPoints.count];
    
    free(coords);
    
    return polyline1;
}





- (void)didReceiveMemoryWarning
{
    
    
   // if(placeArrayForTourGuide!=nil)
//[placeArrayForTourGuide release];
    
   // if(mapViewController!=nil)
   // [mapViewController release];
   // if(_footerView != nil) 
   // {
    //    [_footerView release];
    //}
    

    
    
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
    CGRect rect=view.frame;
    rect.origin.y=self.view.frame.size.height - (_footerView.frame.size.height+view.frame.size.height);
    view.frame=rect;
    [self.view bringSubviewToFront:loadView];

}

-(void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error{
    CGRect rect=view.frame;
    rect.origin.y=self.view.frame.size.height;
    view.frame=rect;
}
-(void)adViewWillDismissScreen:(GADBannerView *)adView{
}

-(void)viewWillAppear:(BOOL)animated{
    [self reloadAdd];
    [self upDateUI];
    isRootView=YES;
    
    self.navigationItem.title=@"Map";
    self.navigationController.navigationBar.tintColor =  dtManager.configuration.color.header;

    [self.view bringSubviewToFront:loadView];

    selectedAnnotaion=@"";
    isQRCodeScan=NO;
    locationManager.delegate=self;
    [locationManager startUpdatingLocation];
    if(isRoot)
    {
        isRoot=NO;
            
        if(loadView!=nil)
            [self removeLoadingView];
        loadView = [LoadingView loadingViewInView:self.view withTitle:nil];
        loadView.backgroundColor = [UIColor clearColor];
        
        
        [self.view bringSubviewToFront:loadView];
        
        if(isDirectionSelected)
            [self performSelector:@selector(callServicePage) withObject:nil afterDelay:3];
        else
        {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertTitle","") 
                                                            message:@"Select directions"
                                                           delegate:self 
                                                  cancelButtonTitle:@"Driving" 
                                                  otherButtonTitles:@"Walking",nil];
            alert.tag=22222;
            [alert show];	
            
            
        }
            
            
           if(_footerView!=nil){
            [_footerView removeFromSuperview];
            _footerView=nil;
        }
        _footerView = [CPFooterView footerViewWithToolBarType:CPFooterItemTypeDefault];
        _footerView.tag = CPFooterItemTypeDefault;
        //---------default FooterType is Scan------
        _footerView.delegate = self;
        _footerView.frame = CGRectMake(0.0, self.view.frame.size.height-44, self.view.frame.size.width, _footerView.frame.size.height);
        CPConfiguration *configuration = (CPConfiguration*)dtManager.configuration;
        _footerView.tintColor = configuration.color.footer;
        [self.view addSubview:_footerView];
        [self upDateUI];

    }
    else{
        [self upDateUI];
        [self animateFooterView:YES];

    }
    

    
    CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.isRootViewController=YES;

    //[locationManager startUpdatingLocation];
    [self.view bringSubviewToFront:loadView];
    
    [self animateFooterView:YES];

 
}


-(void)viewDidAppear:(BOOL)animated{
    [self.view bringSubviewToFront:loadView];
}
#pragma mark - ZBarReaderDelegate -
- (void) readerControllerDidFailToRead: (ZBarReaderController*) reader
                             withRetry: (BOOL) retry
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertTitle","")
                                                    message:@"the image picker failing to read"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


#pragma mark - UIImagePickerControllerDelegate -
- (void) imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    
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
        _pageViewController.rootViewController=self;

        
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
        _pageViewController.rootViewController=self;

        
        _pageViewController.qrContent = qrContent;
        qrContent = nil;
        _pageViewController.title = @"Results";
        [self.navigationController pushViewController:_pageViewController animated:NO];
        [reader dismissModalViewControllerAnimated: NO];
    }
}


-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
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
        [self.view bringSubviewToFront:loadView];

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
      /*  if (self.qrContent != nil) 
        {
            rect.size.height = self.view.frame.size.height - _footerView.frame.size.height; 
            if(banner.isBannerLoaded == YES)
            {
                rect.size.height = self.view.frame.size.height - (_footerView.frame.size.height + banner.frame.size.height);
            }
        }*/
        
        
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
    
    
    [self.view bringSubviewToFront:loadView];

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
    [self.view bringSubviewToFront:loadView];

}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{    [self.view bringSubviewToFront:loadView];

    BOOL shouldExecuteAction = YES;
    
    if (!willLeave && shouldExecuteAction)
    {
        // stop all interactive processes in the app
        // [video pause];
        // [audio pause];
    }
    return shouldExecuteAction;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad{
    
    selectedAnnotaion=@"";
    customImagesDict=[[NSMutableDictionary alloc]init];
    categoryIdArray=[[NSMutableArray alloc]init];
    categoryObjectArray=[[NSMutableArray alloc]init];

    
    
    if(!isIPhone){
    
    _activityView =  [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];    
    [_activityView sizeToFit];
    _activityView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
       // _activityView.center=self.view.center;
       // [self.view addSubview:_activityView];

    }
    
    
    dtManager = [CPDataManger sharedDataManager];


    
    CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.isRootViewController=YES;
    
    
    titleArray=[[NSMutableArray alloc]init];

    placeArray=[[NSMutableArray alloc]init];
    

    
    pathObjectsArray=[[NSMutableArray alloc]init];

    annotationsArray=[[NSMutableArray alloc]init];
    
   // titleArray=[[NSArray alloc]initWithObjects:@"NC",@"MM",@"UPL",@"AS",@"ICICI",@"BS",@"BA",@"TC",@"CP",@"MP1",@"CP2",@"LP", nil];
    imageName=[[NSArray alloc]initWithObjects:@"current.png",@"green.png",@"red.png",@"visited.png",nil];
  //  titleArray=[NSArray arrayWithObjects:@"NC",@"NC",@"MM",@"UPL",@"AS",@"ICICI",@"AB",@"BS",@"BA",@"TC",@"CP",@"CP1",@"MP1",@"LP", nil];
    
    //imageName=[NSArray arrayWithObjects:@"current.png",@"green.png",@"red.png",@"visited.png",nil];
    
    checkPointCount=0;
  /* 
    home = [[Place alloc] init] ;
	home.name = @"From";
	home.description = @"Nagarjuna circle";
	home.latitude=17.425789;//panjagutta
	home.longitude=78.448883;
	*/
    //18.457115 , 79.446479
    //18.507049 , 79.422564
	
    office = [[Place alloc] init] ;
	//office.name = @"To";
	//office.description = @"bus - stop";
	office.latitude = 17.437041;//Khairathabad
	office.longitude = 78.443878;
    
    
        
    [self createMapUI];
    [super viewDidLoad];
    [self showBannarView];
}


-(void)createMapUI{
        
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height-_footerView.frame.size.height)];
    //mapView.showsUserLocation = YES;
    mapView.zoomEnabled=YES;
    MKCoordinateRegion region;
    region.center.latitude     = home.latitude;
    region.center.longitude    = home.longitude;
    
    region.span.latitudeDelta  = 0.03;
    region.span.longitudeDelta = 0.03;
    [mapView setRegion:region animated:YES];
    mapView.delegate=self;
    [self.view addSubview:mapView];
    
    
    _footerView = [CPFooterView footerViewWithToolBarType:CPFooterItemTypeDefault];
    _footerView.tag = CPFooterItemTypeDefault;
    //---------default FooterType is Scan------
    _footerView.delegate = self;
    _footerView.frame = CGRectMake(0.0, self.view.frame.size.height-44, self.view.frame.size.width, _footerView.frame.size.height);
    
    
    CPConfiguration *configuration = (CPConfiguration*)dtManager.configuration;
    _footerView.tintColor = configuration.color.footer;
    [self.view addSubview:_footerView];

   // isInteractionEnabled=NO;
    
   
    NSArray *array=_footerView.items;
    //NSLog(@"fo array: %@",array);
    if(array.count>=6){
    UIBarButtonItem *button=[array objectAtIndex:5];
        [button setEnabled:FALSE];
      //  button.enabled=NO;
        //button.tag=2;
        
        UIBarButtonItem *button1=[array objectAtIndex:1];
        [button1 setEnabled:FALSE];
        //button1.enabled=NO;
    }
 
    

   
}




- (void)callServicePage
{
     
    @autoreleasepool {
        CPConnectionManager *manager = [CPConnectionManager sharedConnectionManager];
        CPMenu *menu = [[CPDataManger sharedDataManager] selectedMenu];
        
        NSString *strURL = nil;
        if(!isGoogleAPI)
        {
            MKCoordinateRegion region;
            region.center.latitude     = home.latitude;
            region.center.longitude    = home.longitude;
            
            region.span.latitudeDelta  = 0.03;
            region.span.longitudeDelta = 0.03;
            [mapView setRegion:region animated:YES];

            Place *point2=[[Place alloc]init];
            point2.latitude = [((CPUniversity*)(dtManager.configuration.university)).latitude doubleValue];
            point2.longitude = [((CPUniversity*)(dtManager.configuration.university)).longitude doubleValue];
            //NSLog(@"%f%f",[((CPUniversity*)(dtManager.configuration.university)).latitude doubleValue],[((CPUniversity*)(dtManager.configuration.university)).longitude doubleValue]);
          
            
            office.name = @"Destination";
            office.latitude = point2.latitude;
            office.longitude = point2.longitude;

                 
            
            strURL=[NSString stringWithFormat:@"http://maps.google.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=true&mode=driving",location.coordinate.latitude,location.coordinate.longitude,point2.latitude,point2.longitude];
            //NSLog(@"%f %f",location.coordinate.latitude,location.coordinate.longitude);
                 if(office!=nil){
                to = [[MyAnnotation alloc] initWithPlace:office] ;
                to.colorCode=2;
                [mapView removeAnnotation:to];
                [mapView addAnnotation:to];
            }
            else{
                [mapView removeAnnotation:to];
                [mapView addAnnotation:to];
                
            }
                  
            
            isGoogleAPI=YES;

        }   
        else 
        {
            isGoogleAPI=NO;
            
            //NSLog(@"universit %@",dtManager.configuration.university.id);
            
  
            if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)

             strURL=[NSString stringWithFormat:@"%@tourmaps?method=getMapPointName&univId=%@&deviceId=%d",SERVER_URL,dtManager.configuration.university.id,CPDeviceTypeiPhone];
            else
                strURL=[NSString stringWithFormat:@"%@tourmaps?method=getMapPointName&univId=%@&deviceId=%d",SERVER_URL,dtManager.configuration.university.id,CPDeviceTypeiPad];

            
        }
        
        if(home==nil){
            home=nil;
            home = [[Place alloc] init] ;
            home.name = @"Start Point";
           // home.description = @"Nagarjuna circle";
            home.latitude=location.coordinate.latitude;//panjagutta
            home.longitude=location.coordinate.longitude;
            from=nil;
            from = [[MyAnnotation alloc] initWithPlace:home] ;
            from.colorCode=1;
            [mapView removeAnnotation:from];
            [mapView addAnnotation:from];
            
                  
        }
        else{
            [mapView removeAnnotation:from];
            [mapView addAnnotation:from];
            
        }
        
        if(annotationForCurrentLocation!=nil){
            [mapView removeAnnotation:annotationForCurrentLocation];
            [mapView addAnnotation:annotationForCurrentLocation];
        }

   
         [mapView setCenterCoordinate:location.coordinate animated:YES];

        
        NSURL *urlServer = [NSURL URLWithString:strURL];
        CPRequest*request = [[CPRequest alloc] initWithURL:urlServer withRequestType:CPRequestTypeTour];
        request.identifier = menu.id;
        [manager spawnConnectionWithRequest:request delegate:self];
   // [request release];
    }
    
    //NSLog(@"%f %f",location.coordinate.latitude,location.coordinate.longitude);
  
    
   
}
#pragma mark - CPConnectionDelegate -


- (void)removeLoadingView
{
	[loadView removeView];
	if(loadView != nil)
	{
		loadView = nil;
	}
}
 
 - (void)CPConnection:(CPConnection*)CPConnection didReceiveResponse:(id)response
{
    
    
    // //NSLog(@"response: %@",response);
    NSData *_data = [(NSDictionary*)response valueForKey:@"data"];
    
    NSString *strResponse = [[NSString alloc] initWithBytes:(const void*)[_data bytes]
                                                     length:[_data length]
                                                   encoding:NSASCIIStringEncoding];
    //NSLog(@"%@",strResponse);
    
    
    
            
    if(isGoogleAPI==YES){
        
        
        
        NSString *responseString=[[NSString alloc]initWithData:_data encoding:NSUTF8StringEncoding];
        //NSLog(@"responseString: %@",responseString);
        
        responseData=nil;
        responseData=[[NSMutableData alloc]initWithData:_data];
        [self parsingJSONstring];
        
        
        if(_footerView!=nil){
            NSArray *array=_footerView.items;
            //NSLog(@"footer array:%@",array);
            if(array.count>=6){
                UIBarButtonItem *button=[array objectAtIndex:5];
                [button setEnabled:TRUE];
                
                
                UIBarButtonItem *button1=[array objectAtIndex:1];
                //button1.enabled=YES;
                [button1 setEnabled:TRUE];
                
            }
        }
        
        
        
        if(loadView != nil)
        {
            [self removeLoadingView];
        }
        
        
    }
    else{
        
        // condition for next API campus tour guide
        /*
         if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
         {
         if(loadView != nil)
         {
         [self removeLoadingView];
         }
         }
         else{
         if(_activityView.superview!=nil)
         [_activityView removeFromSuperview];
         
         }  */
        
        if(loadView != nil)
        {
            [self removeLoadingView];
        }
        
        
        
        NSError *error;
        NSDictionary * tempDict=[NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableContainers error:&error];
        
        
        if([tempDict isKindOfClass:[NSDictionary class]])
        {
            //  NSDictionary * tempDict=[NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableContainers error:&error];
            
            //NSLog(@"NSDictionary");
            if([tempDict objectForKey:@"error"] != nil) 
            {
                /*
                 
                 UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertTitle", @"")
                 message:[tempDict objectForKey:@"error"]
                 delegate:self 
                 cancelButtonTitle:NSLocalizedString(@"cancelButton", @"") 
                 otherButtonTitles:nil];
                 [errorAlert show];
                 [errorAlert release];
                 */
                
                
                return;
            }
        }
        
        
        
        
        NSArray * tempArray;
        
        // if([tempDict isKindOfClass:[NSArray class]]){
        
        tempArray=[tempDict objectForKey:@"tourmaps"];
        //NSLog(@"NSArray");
        
        //tourmaps
        
        if(placeArrayForTourGuide!=nil)
            [placeArrayForTourGuide removeAllObjects];
        placeArrayForTourGuide=[[NSMutableArray alloc]init];
        //NSLog(@"tempArray: %d",tempArray.count);
        
        
        
        if(tempArray!=nil&&tempArray.count>0){
            
            for(NSDictionary *dict in tempArray){
                
                
                
                if(dict!=nil){
                    
                    Place *place=[[Place alloc]init];
                    //map_point_name
                    NSString *map_point_name=[dict objectForKey:@"map_point_name"];
                    if(map_point_name!=nil){
                        place.name=map_point_name;
                        //  [titleArray addObject:place.name];
                    }
                    
                    
                    NSString *latitude=[dict objectForKey:@"latitude"];
                    if(latitude!=nil)
                        place.latitude=[latitude doubleValue];
                    NSString *longitude=[dict objectForKey:@"longitude"];
                    
                    if(longitude!=nil)
                        place.longitude=[longitude doubleValue];
                    
                    NSString *map_details=[dict objectForKey:@"map_details"];
                    if(map_details!=nil){
                        place.map_details=map_details;
                        place.description=map_details;
                    }
                    NSString *map_image=[dict objectForKey:@"map_image"];
                    if(map_image!=nil)
                        place.map_image=map_image;
                    //NSLog(@"place.map_image: %@  ",place.map_image);
                    
                    
                    NSString *tourmap_id=[dict objectForKey:@"tourmap_id"];
                    if(tourmap_id!=nil)
                        place.tourmap_id=[tourmap_id intValue];
                    
                    NSString *map_order=[dict objectForKey:@"map_order"];
                    if(map_order!=nil)
                        place.map_order=[map_order intValue];
                    //             NSString *media_type=[dict objectForKey:@"media_type"];
                    // if(media_type!=nil)
                    place.media_type=[[dict objectForKey:@"media_type"] intValue];
                    
                    //NSLog(@"media_type: %d",place.media_type);
                    
                    
                    
                    //               NSString *video_id=[dict objectForKey:@"video_id"];
                    // if(video_id!=nil)
                    place.video_id=[[dict objectForKey:@"video_id"] intValue];
                    
                    NSString *video_name=[dict objectForKey:@"video_name"];
                    if(video_name!=nil)
                        place.video_name=video_name;
                    
                    
                    NSString *video_thumb=[dict objectForKey:@"video_thumb"];
                    if(video_thumb!=nil)
                        place.video_thumb=video_thumb;
                    
                    NSString *video_text=[dict objectForKey:@"video_text"];
                    if(video_text!=nil)
                        place.video_text=video_text;
                    
                    
                    NSDictionary *category_details=[dict objectForKey:@"category_details"];
                    
                    if(category_details!=nil){
                        place.categories=[[CPMapCategories alloc]init];            
                        
                        NSString *category_id=[category_details objectForKey:@"category_id"];
                        if(category_id!=nil)
                            place.categories.category_id=[category_id intValue];
                        
                        NSString *category_name=[category_details objectForKey:@"category_name"];
                        if(category_name!=nil)
                            place.categories.category_name=category_name;
                        
                        NSString *category_iphone_color=[category_details objectForKey:@"category_iphone_color"];
                        if(category_iphone_color!=nil)
                            place.categories.category_iphone_color=category_iphone_color;
                        
                        NSString *category_ipad_color=[category_details objectForKey:@"category_ipad_color"];
                        if(category_ipad_color!=nil)
                            place.categories.category_ipad_color=category_ipad_color;
                        
                        NSString *category_ipad_image=[category_details objectForKey:@"category_ipad_image"];
                        if(category_ipad_image!=nil)
                            place.categories.category_ipad_image=category_ipad_image;
                        
                        NSString *device_image=[category_details objectForKey:@"device_image"];
                        if(device_image!=nil)
                            place.categories.device_image=device_image;
                        
                        
                    }
                    
                    
                    
                    if(category_details!=nil){
                        CPMapCategories* tempCategories=[[CPMapCategories alloc]init];            
                        
                        NSString *category_id=[category_details objectForKey:@"category_id"];
                        if(category_id!=nil)
                            tempCategories.category_id=[category_id intValue];
                        
                        NSString *category_name=[category_details objectForKey:@"category_name"];
                        if(category_name!=nil)
                            tempCategories.category_name=category_name;
                        
                                               
                        NSString *device_image=[category_details objectForKey:@"device_image"];
                        if(device_image!=nil)
                            tempCategories.device_image=device_image;
                        
                        int index=[categoryIdArray indexOfObject:category_id];
                        //NSLog(@"%d %d %d",tempCategories.category_id,index,categoryIdArray.count);
                        if(index<categoryIdArray.count)
                        {
                            
                        }
                        else{
                            [categoryIdArray addObject:category_id];
                            [categoryObjectArray addObject:tempCategories];

                        }

                    }
                    
                    [placeArrayForTourGuide addObject:place];
                    
                    
                }
                
                
                
                //NSLog(@"categoryIdArray: %@",categoryIdArray);
                
                for (CPMapCategories *temp in categoryObjectArray) {
                    //NSLog(@"categoryIdArray: %d",temp.category_id);
                    //NSLog(@"categoryIdArray: %@",temp.device_image);

                }

            }
            
            
            
            
            
            if(placeArrayForTourGuide!=nil && placeArrayForTourGuide.count>0){
                
                
                [self sortArry:placeArrayForTourGuide];
                //NSLog(@"placeArrayForTourGuide: %d",placeArrayForTourGuide.count);
                
                for(Place *place in placeArrayForTourGuide){
                    //NSLog(@"place.tourmap_id: %d",place.tourmap_id);
                    //NSLog(@"media_type: %d",place.media_type);
                    //NSLog(@"video_name: %@",place.video_name);
                    //NSLog(@"map_image: %@",place.map_image);
                    //NSLog(@"video_thumb: %@",place.video_thumb);
                    //NSLog(@"category_ipad_image: %@",place.categories.category_name);
                    
                    //NSLog(@"category_ipad_image: %@",place.categories.category_ipad_image);
                    //NSLog(@"device_image: %@",place.categories.device_image);
                    
                }   
                
                
                if(_footerView!=nil){
                    [_footerView removeFromSuperview];
                    _footerView=nil;
                }
                
                
                
                _footerView = [CPFooterView footerViewWithToolBarType:CPFooterItemToureGuide];
                _footerView.tag = CPFooterItemTypeDefault;
                //---------default FooterType is Scan------
                _footerView.delegate = self;
                _footerView.frame = CGRectMake(0.0, self.view.frame.size.height-44, self.view.frame.size.width, _footerView.frame.size.height);
                
                CPConfiguration *configuration = (CPConfiguration*)dtManager.configuration;
                _footerView.tintColor = configuration.color.footer;
                [self.view addSubview:_footerView];
                
                [self animateFooterView:YES];
                
                
                
                //NSLog(@"location: %f %f",location.coordinate.latitude,location.coordinate.longitude);
                
            }
            
        }
    }
    [self.view bringSubviewToFront:loadView];
 
    //}
}
     
      
     
 
 - (void)CPConnection:(CPConnection*)CPConnection didFailWithError:(NSError*)error{
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
 
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertTitle","") 
 message:message
 delegate:self 
 cancelButtonTitle:@"OK" 
 otherButtonTitles:nil];
 [alert show];	
     
     
     
          
 
 }
 
#pragma marks - mapview delegates

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    responseData=nil;
    responseData=[NSMutableData new];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [responseData appendData: data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *responseString=[[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    //NSLog(@"responseString: %@",responseString);
    [self parsingJSONstring];
    
    
    
   
}


-(void)parsingJSONstring{
    

    NSError *error;
    NSDictionary *dictionary=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    
    if(dictionary!=nil){
        NSString *status=[dictionary objectForKey:@"status"];
        if(status!=nil &&[ status isEqualToString:@"OK" ])
            isStatus=TRUE;
        //NSLog(@"status: %d",isStatus);
        
        
        if(isStatus==YES){
            
            isStatus=NO;
            NSArray *items=[dictionary valueForKey:@"routes"];
            if(items!=nil){
                NSDictionary *dict=[items objectAtIndex:0];
                //   //NSLog(@"%@",[dict allKeys]);
                NSDictionary *overViewDict= [dict objectForKey:@"overview_polyline"];
                NSString *overview_polylineString=[overViewDict objectForKey:@"points"];
                
                //NSLog(@"overview_polylineString: %@",overview_polylineString);
                
                if(overview_polylineString!=nil)           {
                    polyline=[self polylineWithEncodedString:overview_polylineString];
                   
                    [mapView setNeedsLayout];
                    [mapView addOverlay:polyline];
                    [mapView setClipsToBounds:YES];
                    
                }
            }
            else{
                isGoogleAPI=NO;

                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                     message:@"Unable to find the route"
                                                                    delegate:self 
                                                           cancelButtonTitle:@"Ok" 
                                                           otherButtonTitles:nil];
                [alert show];	
                return;
            }
        }
        else{
            isGoogleAPI=NO;

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                 message:@"Unable to find the route"
                                                                delegate:self 
                                                       cancelButtonTitle:@"Ok" 
                                                       otherButtonTitles:nil];
            [alert show];	
            return;
        }
        
    }
        
}





#pragma marks - mapview delegates
-(MKAnnotationView *)mapView:(MKMapView *)mapView1 viewForAnnotation:(id<MKAnnotation>)annotation{
    
      
    
    
    MKAnnotationView *pinAnnotationView;
    //NSLog(@"title2: %@",[annotation title]);
    pinAnnotationView=(MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"sharath"];
    
    if(pinAnnotationView==nil)
        pinAnnotationView=[[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"sharath"];
    else
        [pinAnnotationView prepareForReuse];
    //NSLog(@"break0");

   
     if([[annotation title] isEqualToString:@"Start Point"])
    {
        NSString *name=@"";
        name=[imageName objectAtIndex:from.colorCode];
        pinAnnotationView.image=[UIImage imageNamed:name];
        pinAnnotationView.centerOffset=CGPointMake(20,-25);

    }
    else if([[annotation title] isEqualToString:@"Destination"])
    {
        NSString *name=@"";
        name=[imageName objectAtIndex:to.colorCode];
        pinAnnotationView.image=[UIImage imageNamed:name];
        pinAnnotationView.centerOffset=CGPointMake(20,-25);


        
    }
    else{
        
        
       int tag=[titleArray indexOfObject:[NSString stringWithFormat:@"%@",[annotation title]]];
        //NSLog(@"break1");

        
        MyAnnotation *temp;
        NSString *name=@"";
        if(tag<annotationsArray.count){
         temp=[annotationsArray objectAtIndex:tag];
                name=[imageName objectAtIndex:temp.colorCode];

        }
        else{
            name=[imageName objectAtIndex:2];

        }
        
        if([[annotation title] isEqualToString:@"Current Position"]){
            //NSLog(@"break2");
            name=[imageName objectAtIndex:0];
            pinAnnotationView.centerOffset=CGPointMake(0, -25);

        }
        else{
            pinAnnotationView.centerOffset=CGPointMake(20,-25);

        }
        
 
    pinAnnotationView.image=[UIImage imageNamed:name];
    [pinAnnotationView setBackgroundColor:[UIColor clearColor]];
    }
    
      
    
    [pinAnnotationView setCanShowCallout:YES];
   
    return pinAnnotationView;

}



-(void)buttonAction:(UIButton*)button{
    

    CustomAnnotationView *annotationView=(CustomAnnotationView*)[button superview] ;
 
 
    [annotationView removeFromSuperview];
}



-(void)imageButtonAction:(UIButton *)button{
    
           
    for (CustomMapItem *annotation in [mapView annotations]) {
        if ([annotation isKindOfClass:[CustomMapItem class]])  
            [mapView removeAnnotation:annotation];
    }
    
    if(descriptionViewController==nil)
    descriptionViewController=[[DescriptionViewController alloc]init];
    
    [self.navigationController pushViewController:descriptionViewController animated:YES];
    
    
    
}



-(void)chageColor:(UIButton*)button{
    button.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"gray_back.png"]];
    
}



- (void)mapView:(MKMapView *)mapView1 didSelectAnnotationView:(MKAnnotationView *)view {
    
   // isSelectedPin=YES;
    
        
 /*   
    
        CLLocationCoordinate2D coOrdinate1=[view.annotation coordinate];

    //NSLog(@"%f %f",coOrdinate1.latitude,coOrdinate1.longitude);
    if(view.annotation!=nil)
    {    
        Place *place=[self getPlaceObjectForIndex:[view.annotation title]];
        //  //NSLog(@"%@",place.map_point_name);
        
       
            
            selectedPinIndex=[self getIndexOfAnnotaionForTitle:[view.annotation title]];

        
            selectedAnnotaion=[view.annotation title];

            if(place!=nil){ 
                // [self getImageAtIndex:1 forURL:[NSURL URLWithString:place.map_point_name?place.map_point_name:@""]];
                
                
                // //NSLog(@"map_point_name: %@",place.map_point_name);
            }
            
            [mapView setCenterCoordinate:[view.annotation coordinate]];    
            
            Place* home1 = [[[Place alloc] init] autorelease] ;
            home1.name = [view.annotation title];
            home1.description = [view.annotation subtitle];
            
            
            
            home1.latitude=coOrdinate1.latitude;//panjagutta
            home1.longitude=coOrdinate1.longitude;
                callOutAnnotation=[[CustomMapItem alloc] init] ;
                callOutAnnotation.latitude=coOrdinate1.latitude;
                callOutAnnotation.longitude=coOrdinate1.longitude;
                callOutAnnotation.place=home1;
                // callOutAnnotation.subtitle=
                //NSLog(@"view: %@",[view.annotation title]);
        [mapView addAnnotation:callOutAnnotation];
    
                
        }
    else{
        
        [[CPConnectionManager sharedConnectionManager] closeAllConnections];

        if(descriptionViewController==nil)
            descriptionViewController=[[DescriptionViewController alloc]init];
        
        [self.navigationController pushViewController:descriptionViewController animated:YES];
    }
  */
    
    
  
  
  
  }

-(Place*)getPlaceObjectForIndex:(NSString*)title{
    Place *place;
    int number=[titleArray indexOfObject:title];
    if(number<titleArray.count &&titleArray.count!=0){
        
        place=[titleArray objectAtIndex:number];
        if(place!=nil);
        //NSLog(@"%@ %@",title,place.name);

    }
    return place;
    
}




-(int)getIndexOfAnnotaionForTitle:(NSString*)title{
    int number=[titleArray indexOfObject:title];
    
    return number;
}    

//get the image as per index,with the related URL
- (void)getImageAtIndex:(int)index forURL:(NSURL*)url
{
    @autoreleasepool {
        CPConnectionManager *manager = [CPConnectionManager sharedConnectionManager];    
        CPRequest*request = [[CPRequest alloc] initWithURL:url 
                                           withRequestType:CPRequestTypeImage];
        [manager spawnConnectionWithRequest:request delegate:self];
        request.identifier = [NSNumber numberWithInteger:index];
    }
}


-(void)mapView:(MKMapView *)mapView1 didDeselectAnnotationView:(MKAnnotationView *)view{
   // isDeSelectedPin=YES;
   

   // [mapView1 removeAnnotation:[view annotation]];
   // if ([[view annotation] isKindOfClass:[CustomMapItem class]])  

    //[view removeFromSuperview];
    for (CustomMapItem *annotation in [mapView annotations]) {
        if ([annotation isKindOfClass:[CustomMapItem class]])  
            [mapView removeAnnotation:annotation];
    }
 
}

- (void)mapView:(MKMapView *)mapView1 regionWillChangeAnimated:(BOOL)animated
{	
    
    //routeView.hidden = NO;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
    // [self calculateRoutesFrom:from.coordinate to:to.coordinate];
    //[self updateRouteView];
	//routeView.hidden = NO;
    
}


- (MKOverlayView*)mapView:(MKMapView*)theMapView viewForOverlay:(id <MKOverlay>)overlay
{
    //NSLog(@"polyline:%@",polyline);
    MKPolylineView* lineView = [[MKPolylineView alloc] initWithPolyline:polyline];
    
    lineView.fillColor = [UIColor blueColor];
    lineView.strokeColor = [UIColor blueColor];
    
    
    dtManager = [CPDataManger sharedDataManager];
    
    lineView.fillColor =dtManager.configuration.color.tour_path_color;
    lineView.strokeColor=dtManager.configuration.color.tour_path_color;
    lineView.lineWidth = 3;
    return lineView;
}

/*
- (void)MapView:(MKMapView*)mapView didFailLoadingMapView:(NSError*)error
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertTitle","") 
                                                    message:@"Unable to draw route at this time."
                                                   delegate:self 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles:nil];
 
    [alert show];	
    [alert release];
}
*/



#pragma mark - UIAlertViewdelegate -
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //if(alertView.tag == 10001)
    
    if(alertView.tag == 11111)
    {  
        if(buttonIndex==0)
        {
        }
               
    }
    else  if(alertView.tag == 22222)
    {
        if(buttonIndex==0)
        {
            isDrivingMode=YES;
        }
        else if(buttonIndex==1){
            isDrivingMode=NO;
            
        }
        [self callServicePage];

    }
    else
    {
        isGoogleAPI=NO;

        [self.navigationController popViewControllerAnimated:YES];
    }
   // {
    //}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(BOOL)shouldAutorotate{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return NO;
    }
    return YES;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return NO;
    }
    
    
    if((interfaceOrientation==UIInterfaceOrientationPortrait)||(interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)){
        isPotrait=YES;
    }
    else{
        isPotrait=NO;
    }
    
    CPAppDelegate *appDelegate= (CPAppDelegate*)[UIApplication sharedApplication].delegate;
    self.view.frame=CGRectMake(0, 0,  self.interfaceOrientation>2?(appDelegate.window.frame.size.height-320):appDelegate.window.frame.size.width,self.interfaceOrientation>2?(appDelegate.window.frame.size.width-64):(appDelegate.window.frame.size.height-64));
    
    mapView.frame=CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height-_footerView.frame.size.height);
    _footerView.frame = CGRectMake(0.0, self.view.frame.size.height-44, self.view.frame.size.width, _footerView.frame.size.height);
    [self animateFooterView:YES];
    [self.view bringSubviewToFront:loadView];
    
    
    
    return YES;
}



-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        if((toInterfaceOrientation==UIInterfaceOrientationPortrait)||(toInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)){
            isPotrait=YES;
        }
        else{
            isPotrait=NO;
        }
        
        [self upDateUI];
        [self.view bringSubviewToFront:loadView];
    }
}


-(void)upDateUI{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return ;
    }
    else{
        CPAppDelegate *appDelegate= (CPAppDelegate*)[UIApplication sharedApplication].delegate;
        self.view.frame=CGRectMake(0, 0,  self.interfaceOrientation>2?(appDelegate.window.frame.size.height-320):appDelegate.window.frame.size.width,self.interfaceOrientation>2?(appDelegate.window.frame.size.width-64):(appDelegate.window.frame.size.height-64));
        
        if(mapView!=nil){
            mapView.frame=CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height-_footerView.frame.size.height);
            _footerView.frame = CGRectMake(0.0, self.view.frame.size.height-44, self.view.frame.size.width, _footerView.frame.size.height);
        }
        
    }
    [self animateFooterView:YES];
    [self.view bringSubviewToFront:loadView];
}

-(void)setValues{
    
}


#pragma marks- data connection delegates

-(void)dataLoadingFinished:(NSString*)responseString1 withHttpResponse:(int)statusCode  withData:(NSMutableData *)data
{    
    //NSString *responseString=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    //  //NSLog(@"responseString: %@",responseString);
   

    
    
    //NSLog(@"code:%d",statusCode);
    if(statusCode==200){
        NSError *error;
        NSArray * tempArray=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        placeArray=[[NSMutableArray alloc]init];
        //NSLog(@"tempArray: %@",tempArray);
        
        for(NSDictionary *dict in tempArray){
            
            Place *place=[[Place alloc]init];
            //map_point_name
            NSString *map_point_name=[dict objectForKey:@"map_point_name"];
            if(map_point_name!=nil)
                place.name=map_point_name;
            [titleArray addObject:place.name];
            NSString *latitude=[dict objectForKey:@"latitude"];
            if(latitude!=nil)
                place.latitude=[latitude doubleValue];
            NSString *longitude=[dict objectForKey:@"longitude"];
            if(longitude!=nil)
                place.longitude=[longitude doubleValue];
            
            NSString *map_details=[dict objectForKey:@"map_details"];
            if(map_details!=nil)
                place.map_details=map_details;
            NSString *map_image=[dict objectForKey:@"map_image"];
            if(map_image!=nil)
                place.map_image=map_image;
            NSString *tourmap_id=[dict objectForKey:@"tourmap_id"];
            if(tourmap_id!=nil)
                place.tourmap_id=[tourmap_id intValue];
            
            [placeArray addObject:place];
            
        }
        
        
        [self sortArry:placeArray];
        //NSLog(@"%d",placeArray.count);
        
        int cout=0;
        for(Place *place in placeArray){
            //NSLog(@"%d",place.tourmap_id);
            
           /* 
            Place *p1 = [[Place alloc] init]  ;
            p1.name = @"NC";
            p1.description = @"odela";
            p1.latitude=17.425789;//panjagutta
            p1.longitude=78.448883;
           */ 
            [pathObjectsArray addObject:place];
            
            MyAnnotation *A1=[[MyAnnotation alloc] initWithPlace:place];
            if(cout==0)
                A1.colorCode=1;
            else
                A1.colorCode=2;
            [annotationsArray addObject:A1];
            [mapView addAnnotation:A1];
            cout++; //this is used for first point is green
        }
        
        
        
     /*   polyline=[self getPolylineOjbect];
        [mapView setNeedsLayout];
        [mapView addOverlay:polyline];
        [mapView setClipsToBounds:YES];
       */ 
    }
    
       
}




-(void)sortArry:(NSMutableArray *)arry{
	
    for(Place *place in arry){
        //NSLog(@"%d",place.tourmap_id);
    }
    
	
           
        NSString *sortingStr=@"map_order";
        
        NSSortDescriptor *lastNameSorter = [[NSSortDescriptor alloc] initWithKey:sortingStr ascending:YES];
        
            [arry sortUsingDescriptors:[NSArray arrayWithObject:lastNameSorter]];
    
        
}


-(void)interNetConnectionError{
    
}
-(void)urlConnectionError:(NSError*)error{
    
}

-(void)viewWillDisappear:(BOOL)animated{
 
  
    isSelectedPin=NO;
    isDeSelectedPin=NO;
    
    
    
    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(callServicePage) object:nil];
    
    [[CPConnectionManager sharedConnectionManager] closeAllConnections];

    
    CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
    if(!isQRCodeScan )
    appDelegate.isRootViewController=NO;
    
    

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
            rect.origin.y = _imgView.frame.size.height;
            rect.size.height = self.view.frame.size.height - (_footerView.frame.size.height +  _imgView.frame.size.height);
        }
        
        rect = _footerView.frame;
        rect.origin.y = self.view.frame.size.height - rect.size.height;
        rect.size.width = 320.0;
        rect.size.height = 44.0;
               _footerView.frame = rect;
        [UIView commitAnimations];
}


@end
