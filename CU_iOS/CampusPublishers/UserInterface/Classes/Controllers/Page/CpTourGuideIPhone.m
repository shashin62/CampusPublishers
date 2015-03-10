




//
//  CpTourGuideIPhone.m
//  GoogleMapWithDirections
//
//  Created by v2solutions on 21/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// beta V1.1

#import "CPConfiguration.h"
#import "CPMapCategories.h"
#import "PikerContrller.h"
#import "CPUtility.h"
#import "CpTourGuideIPhone.h"
#import "CPNetworkConstant.h"
#import "PointObject.h"
#import "CustomAnnotationView.h"
#import "CustomMapItem.h"
#import "CPConfiguration.h"
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
#import "RootViewController.h"
#import "DescriptionViewController.h"
#import "CPPageViewController.h"
#import "ScanResultsPage.h"
///@"current.png",@"green.png",@"red.png",@"visited.png",@"marker_icon_blue.png",
#import "CPGalleryViewController.h"
#import "CMPPage.h"
#import "CPRequest.h"
#import "CPUtility.h"


#define CURRENT 0
#define GREEN_FLAG 1
#define RED_FLAG 2
#define CHECK_MARK 3
#define PIN_BLUE 4

#define IMAGEVIEW 101
#define CELL_LABEL 102




@implementation CpTourGuideIPhone
{
    UIActivityIndicatorView* _activityView ;
    UIBarButtonItem *menuButton;
}
@synthesize isPathAdded;
@synthesize annotationsArray;
@synthesize rootViewController;
@synthesize placeArrayForTourGuide;
@synthesize locationManager;
@synthesize mapView;
@synthesize checkPointCount;
@synthesize descriptionViewController;
@synthesize customImagesDict;
@synthesize isTourGuide;
@synthesize isViewController;
@synthesize isBackButtonHiden;
@synthesize categoryIdArray,categoryObjectArray;
@synthesize isDirectionSelected;
@synthesize masterPopoverController;
@synthesize pathLoopCount;
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


-(void)backButtonDidPressed:(UIButton*)button{
    // //NSLog(@"pressed");
    [[CPConnectionManager sharedConnectionManager] closeAllConnections];
    
    
    CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.isRootViewController=NO;
}

- (void)footerView:(CPFooterView*)footerView didClickItemWithType:(CPFooterItemType)type{
    
    //if(isInteractionEnabled){
    if(type==CPFooterItemToureGuide){
    }
    else
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
    // }
    // else
    // {
    
    // }
    
}



-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
    CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
    
    
    if(! appDelegate.isPlay){
        if((rootViewController==nil) || rootViewController.isRootView==NO){
            location=[[CLLocation alloc]initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
            
            //if(checkPointCount+1<annotationsArray.count){
            if(checkPointCount<annotationsArray.count){
                
                if(pathObjectsArray!=nil &&pathObjectsArray.count>0){
                    Place *currentPlace=[pathObjectsArray objectAtIndex:checkPointCount];
                    
                    CLLocation *destinationLocation=[[CLLocation alloc]initWithLatitude:currentPlace.latitude longitude:currentPlace.longitude];
                    
                    CLLocationDistance distance=[location distanceFromLocation:destinationLocation];
                    if(distance <=30){
                        
                        isVisited=YES;
                        
                        
                        if(checkPointCount==0){
                            [self pathFromUniversity];
                            
                        }
                        else  if(checkPointCount>0){
                            [self pathFromCurrentPoint:checkPointCount];
                            
                        }
                        
                        checkPointCount++;
                    }
                }
            }
            // else if(checkPointCount==annotationsArray.count-1){
            else if(checkPointCount==annotationsArray.count){
                
                if(pathObjectsArray!=nil &&pathObjectsArray.count>0){
                    
                    if(!isTourCompleted){
                        isTourCompleted=YES;
                        
                        UIAlertView *alert;
                        
                        if([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone){
                            
                            
                            alert= [[UIAlertView alloc] initWithTitle:@""
                                                              message:@"Thanks for taking the Mobile Tour! Your tour has now ended.\n Go back to?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Tour menu"
                                                    otherButtonTitles:@"Main menu",nil];
                            CGRect rect;
                            
                            NSArray *views = [alert subviews];
                            for (UIView *view in views){
                                if ([view isKindOfClass:[UIButton class]]) {
                                    rect = view.frame;
                                    rect.size.height=rect.size.height+20;
                                    view.frame=rect;
                                }
                                
                            }
                            
                        }
                        else{
                            alert = [[UIAlertView alloc] initWithTitle:@""
                                                               message:@"Thanks for taking the Mobile Tour! Your tour has now ended."
                                                              delegate:self
                                                     cancelButtonTitle:@"Ok"
                                                     otherButtonTitles:nil];
                            
                            //for()
                        }
                        alert.tag=11111;
                        [alert show];
                        
                        
                    }
                }
            }
            
            if(mapView!=nil){
                if(annotationForCurrentLocation!=nil){
                    [mapView removeAnnotation:annotationForCurrentLocation];
                    // annotationForCurrentLocation=nil;
                }
                
                if(annotationForCurrentLocation==nil){
                    annotationForCurrentLocation=[[MyAnnotation alloc]init];
                    annotationForCurrentLocation.place=[[Place alloc]init];
                }
                annotationForCurrentLocation.place.name=@"You";
                annotationForCurrentLocation.place.description=@"Current position";
                //Current Position
                annotationForCurrentLocation.place.latitude=newLocation.coordinate.latitude;
                annotationForCurrentLocation.place.longitude=newLocation.coordinate.longitude;
                annotationForCurrentLocation.coordinate=newLocation.coordinate;
                [mapView addAnnotation:annotationForCurrentLocation];
                
                
                
                // [mapView setCenterCoordinate:newLocation.coordinate animated:YES];
            }
        }
    }
    
}


-(void)distance{
    
    CLLocation *destinationLocation1=[[CLLocation alloc]initWithLatitude:40.0243 longitude:-105.22074];
    CLLocation *destinationLocation2=[[CLLocation alloc]initWithLatitude:40.02322 longitude:-105.21904];
    
    CLLocationDistance distance1=[destinationLocation1 distanceFromLocation:destinationLocation2];
    
    //NSLog(@"destination1: %f",distance1);
    
    
    CLLocationDistance distance2=[destinationLocation2 distanceFromLocation:destinationLocation1];
    
    //NSLog(@"destination2: %f",distance2);
    
}


-(void)addPathToFirstPoint{
    
    Place *currentPlace=[pathObjectsArray objectAtIndex:checkPointCount];
    
    CLLocation *destinationLocation=[[CLLocation alloc]initWithLatitude:currentPlace.latitude longitude:currentPlace.longitude];
    
    CLLocationDistance distance=[location distanceFromLocation:destinationLocation];
    // //NSLog(@"distance: %f",distance);
    
    if(distance <=30){
        //   //NSLog(@"checkPointCount: %d",checkPointCount);
        
        
        
        MyAnnotation *annotation1=[annotationsArray objectAtIndex:checkPointCount];
        if(annotation1!=nil)
            [mapView removeAnnotation:annotation1];
        annotation1.colorCode=CHECK_MARK;
        [mapView addAnnotation:annotation1];
        
        // increasing count for next place
        MyAnnotation *annotation2=[annotationsArray objectAtIndex:checkPointCount+1];
        if(annotation2!=nil)
            [mapView removeAnnotation:annotation2];
        annotation2.colorCode=PIN_BLUE;
        [mapView addAnnotation:annotation2];
    }
    
}

- (MKPolyline *)getPolylineOjbect{
    MKMapPoint *coords = calloc(placeArray.count, sizeof(CLLocationCoordinate2D));
    
    
    int count=0;
    
    for (Place *item in placeArray) {
        
        CLLocationCoordinate2D coord;
        coord = CLLocationCoordinate2DMake(item.latitude, item.longitude);
        // //NSLog(@"%f %f %d" ,item.latitude, item.longitude,count);
        
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
        //   //NSLog(@"%f",deltaLat);
        
        shift = 0;
        res = 0;
        
        do {
            byte = bytes[idx++] - 0x3F;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLon = ((res & 1) ? ~(res >> 1) : (res >> 1));
        longitude += deltaLon;
        
        //  //NSLog(@"%f",deltaLon);
        
        // //NSLog(@"%f %f",latitude,longitude);
        
        
        float finalLat = latitude * 1E-5;
        float finalLon = longitude * 1E-5;
        
        // //NSLog(@"%f %f",finalLat,finalLon);
        CLLocationCoordinate2D coord;
        coord = CLLocationCoordinate2DMake(finalLat, finalLon);
        
        // if(!(latitude<10 &&latitude>-10)&&!(longitude<10 &&longitude>-10) )
        // {
        
        MKMapPoint point = MKMapPointForCoordinate(coord);
        
        coords[coordIdx++] = point;
        
        
        
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



#pragma marks  - admob delegates
-(void)showBannarView{
    //Comment out for screenshots -Austin
    
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
    rect.origin.y=self.view.frame.size.height - (_footerView.frame.size.height+view.frame.size.height);
    view.frame=rect;
    [self.view bringSubviewToFront:loadView];
    
}

-(void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error{
    CGRect rect=view.frame;
    rect.origin.y=self.view.frame.size.height ;
    view.frame=rect;
}
-(void)adViewWillDismissScreen:(GADBannerView *)adView{
}

-(void)viewWillAppear:(BOOL)animated{
    [self upDateUI];
    [self reloadAdd];
    
    CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
    if (isBackButtonHiden) {
        [self.navigationItem setHidesBackButton:YES animated:NO];
        //[self.navigationController.navigationItem  setHidesBackButton:YES];
    }
    
    isViewController=YES;
    rootViewController.isRootView=NO;
    self.navigationController.navigationBar.tintColor =  dtManager.configuration.color.header;
    isQRCodeScan=NO;
    appDelegate.isRootViewController=YES;
    [self animateFooterView:YES];
    [self.view bringSubviewToFront:loadView];
    [[CPConnectionManager sharedConnectionManager] closeAllConnections];
    //NSLog(@"1:%@",NSStringFromCGRect(self.view.frame));
    
}


-(void)viewDidAppear:(BOOL)animated{
    [self.view bringSubviewToFront:loadView];
}


-(void)upDAteCall{
    if(pathObjectsArray!=nil)
        [pathObjectsArray removeAllObjects];
    CPMenu *_menu = [[CPDataManger sharedDataManager] selectedMenu];
    
    keyButton.hidden=_menu.category_id?YES:NO;
    selectedAnnotaion=@"";
    
    if(isTourGuide){
        isTourCompleted=NO;
        isTourGuide=NO;
        isGoogleAPI=NO;
        if(loadView!=nil)
            [self removeLoadingView];
        
        if(categoryArray!=nil)
            categoryIdArray=nil;
        //[categoryIdArray release];
        
        if(categoryObjectArray!=nil)
            categoryObjectArray=nil;
        //[categoryObjectArray  release];
        
        
        categoryIdArray=[[NSMutableArray alloc]init];
        categoryObjectArray=[[NSMutableArray alloc]init];
        
        //loadView = [[LoadingView loadingViewInView:self.view withTitle:nil] retain];
        
        // [[UIApplication sharedApplication] ]
        
        if(loadView != nil)
        {
            //  [self removeLoadingView];
        }
        
        //loadView = [[LoadingView loadingViewInView:self.view withTitle:nil] retain];
        CPAppDelegate *appdelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
        
        if([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone){
            loadView = [LoadingView loadingViewInView:appdelegate.window withTitle:nil] ;
        }
        else{
            loadView = [LoadingView loadingViewInView:self.view withTitle:nil] ;
        }
        loadView.backgroundColor = [UIColor clearColor];
        
        checkPointCount=0;
        [self performSelector:@selector(callServicePage) withObject:nil afterDelay:0.2];
        [self animateFooterView:YES];
        [self.view bringSubviewToFront:loadView];
    }
    
}
-(void)menuButtonAction{
    
    //NSLog(@"test 1");
    CPAppDelegate *appdelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    if (version>=6.0) {
        if (appdelegate.splitViewController!=nil) {
            [appdelegate.splitViewController performSelector:@selector(toggleMasterVisible:)];
            appdelegate.isSetUpViewClosed=NO;
        }
    }
    else{
        if (masterPopoverController==nil) {
            
            masterPopoverController=[[UIPopoverController alloc]initWithContentViewController:appdelegate.cpMenuViewController];
            
        }
        [self.masterPopoverController presentPopoverFromRect:CGRectMake(0,0, 1, 1) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    
    //NSLog(@"test 2");
    
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    if (([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad)) {
        menuButton=[[UIBarButtonItem alloc]initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(menuButtonAction)];
        
        
        UIInterfaceOrientation orientation=[[UIApplication sharedApplication] statusBarOrientation];
        if( orientation==UIInterfaceOrientationPortrait ||orientation==UIInterfaceOrientationPortraitUpsideDown){
            self.navigationItem.leftBarButtonItem=menuButton;
        }
        
    }
    
    CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
    
    
    appDelegate.cpTourGuideIPhone=self;
    
    Place *point1=[[Place alloc]init];
    point1.latitude = [((CPUniversity*)(dtManager.configuration.university)).latitude doubleValue];
    point1.longitude = [((CPUniversity*)(dtManager.configuration.university)).longitude doubleValue];
    point1.name=@"Start";
    point1.description=@"Start point of the tour";
    from = [[MyAnnotation alloc] initWithPlace:point1] ;
    
    // locationManager=rootViewController.locationManager;
    customImagesDict=[[NSMutableDictionary alloc]init];
    pinImagesDict=[[NSMutableDictionary alloc]init];
    polylineArray=[[NSMutableArray alloc]init];
    
    selectedAnnotaion=@"";
    dtManager = [CPDataManger sharedDataManager];
    
    
    if(!isIPhone){
        
        _activityView =  [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_activityView sizeToFit];
        _activityView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        // _activityView.center=self.view.center;
        // [self.view addSubview:_activityView];
        
    }
    
    
    
    appDelegate.isRootViewController=YES;
    
    
    titleArray=[[NSMutableArray alloc]init];
    
    placeArray=[[NSMutableArray alloc]init];
    
    pathObjectsArray=[[NSMutableArray alloc]init];
    
    annotationsArray=[[NSMutableArray alloc]init];
    
    
    
    selectedAnnotaion=@"";
    customImagesDict=[[NSMutableDictionary alloc]init];
    categoryIdArray=[[NSMutableArray alloc]init];
    categoryObjectArray=[[NSMutableArray alloc]init];
    
    
    
    
    
    
    // titleArray=[[NSArray alloc]initWithObjects:@"NC",@"MM",@"UPL",@"AS",@"ICICI",@"BS",@"BA",@"TC",@"CP",@"MP1",@"CP2",@"LP", nil];
    imageName=[[NSArray alloc]initWithObjects:@"current.png",@"green.png",@"red.png",@"visited.png",@"marker_icon_blue.png",nil];
    //  titleArray=[NSArray arrayWithObjects:@"NC",@"NC",@"MM",@"UPL",@"AS",@"ICICI",@"AB",@"BS",@"BA",@"TC",@"CP",@"CP1",@"MP1",@"LP", nil];
    
    //imageName=[NSArray arrayWithObjects:@"current.png",@"green.png",@"red.png",@"visited.png",nil];
    
    checkPointCount=0;
    
    
    
    
    [self createMapUI];
    [self showBannarView];
    [super viewDidLoad];
}





-(void)createMapUI{
    positionIndex=0;
    
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height-_footerView.frame.size.height)] ;
    
    //  mapView.showsUserLocation = YES;
    // mapView.userLocationVisible=NO;
    
    mapView.zoomEnabled=YES;
    MKCoordinateRegion region;
    region.center.latitude     = home.latitude;
    region.center.longitude    = home.longitude;
    
    region.span.latitudeDelta  = 0.03;
    region.span.longitudeDelta = 0.03;
    [mapView setRegion:region animated:YES];
    mapView.delegate=self;
    [self.view addSubview:mapView];
    
    
    keyButton=[UIButton buttonWithType:UIButtonTypeCustom];
    keyButton.frame=CGRectMake(self.view.frame.size.width-80, 20, 60, 30);
    [keyButton setBackgroundImage:[UIImage imageNamed:@"keyImage.png"] forState:UIControlStateNormal];
    [keyButton addTarget:self action:@selector(keyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    // keyButton.backgroundColor=[UIColor redColor];
    [self.view addSubview:keyButton];
    
    
    
    
    
    _footerView = [CPFooterView footerViewWithToolBarType:CPFooterItemTypeDefault];
    _footerView.tag = CPFooterItemTypeDefault;//---------default FooterType is Scan------
    _footerView.delegate = self;
    _footerView.frame = CGRectMake(0.0, self.view.frame.size.height-44, self.view.frame.size.width, _footerView.frame.size.height);
    
    //isInteractionEnabled=NO;
    
    
    
    
    
    CPConfiguration *configuration = (CPConfiguration*)dtManager.configuration;
    _footerView.tintColor = configuration.color.footer;
    [self.view addSubview:_footerView];
    
    /*
     
     if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
     {
     if(loadView!=nil)
     [self removeLoadingView];
     loadView = [[LoadingView loadingViewInView:self.view withTitle:nil] retain];
     loadView.backgroundColor = [UIColor clearColor];
     }
     else{
     _activityView.center=mapView.center;
     [mapView addSubview:_activityView];
     
     [_activityView startAnimating];
     }
     */
    
    
    
    
    
    
    
    
    //[self performSelector:@selector(callServicePage) withObject:nil afterDelay:3];
}

-(void)keyButtonAction:(UIButton *)button{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        [self createPikcerUI];
    else{
        PikerContrller *viewController=[[PikerContrller alloc]init];
        viewController.target=self;
        viewController.action=@selector(closeButtonAction:);
        viewController.rootViewController=rootViewController;
        viewController.tourGuideIPhone=self;
        
        
        UINavigationController *navigationController=[[UINavigationController alloc]initWithRootViewController:viewController];
        // navigationController.navigationBar.tintColor =  dtManager.configuration.color.header;
        
        
        
        popView=[[UIPopoverController alloc]initWithContentViewController:navigationController];
        popView.delegate=self;
        
        [popView setPopoverContentSize:CGSizeMake(280,320) animated:YES ];
        CGRect rect=CGRectMake(self.view.frame.size.width-50,50,240,0);
        
        [popView presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    
}



-(void)closeButtonAction:(UIButton*)button{
    if(keyView!=nil)
        [keyView removeFromSuperview];
    [popView dismissPopoverAnimated:YES];
}

-(void)createPikcerUI{
    if(keyView==nil)
        keyView=[[UIView alloc] init];
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        keyView.frame=CGRectMake(20, 10, self.view.frame.size.width-40, self.view.frame.size.height-93);
    else
        keyView.frame=CGRectMake(20, 20, (self.view.frame.size.width-40)/2, (self.view.frame.size.height-40)/2);
    keyView.backgroundColor=[UIColor grayColor];
    [self.view addSubview:keyView];
    
    
    UIToolbar *toolBar=[[UIToolbar alloc]init];
    toolBar.frame=CGRectMake(0, 0, keyView.frame.size.width, 44);
    //toolBar.items=[NSArray ];
    //toolBar.barStyle=UIBarStyleBlackTranslucent;
    toolBar.barStyle=UIBarStyleDefault;
    //  toolBar.tintColor=  dtManager.configuration.color.header;
    // UIBarButtonItem *doneButton=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonAction)];
    UIBarButtonItem *closeButton=[[UIBarButtonItem alloc]initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(closeButtonAction:)];
    
    UILabel* titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(70,5,140,30)];
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.textAlignment=UITextAlignmentCenter;
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.font=[UIFont fontWithName:@"ArialMT" size:16];
    titleLabel.text=@"Key";
    [toolBar addSubview:titleLabel];
    
    
    UIBarButtonItem *flexbleSpace=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    
    
    toolBar.items=[NSArray arrayWithObjects:flexbleSpace,flexbleSpace,closeButton,nil];
    [keyView addSubview:toolBar];
    
    tableView=[[UITableView alloc]initWithFrame:keyView.frame style:UITableViewStylePlain];
    tableView.frame=CGRectMake(0, 44, keyView.frame.size.width, keyView.frame.size.height-44);
    tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    //tableView.rowHeight=46;
    tableView.delegate=self;
    tableView.dataSource=self;
    // tableView.backgroundColor=[UIColor greenColor];
    // tableView.rowHeight=TABLE_HEIGHT/(rows);
    [keyView addSubview:tableView ];
    
    
}

#pragma mark - tableView delegate


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return categoryObjectArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView1 heightForHeaderInSection:(NSInteger)section{
    return tableView1.rowHeight;
}


-(UIView*)tableView:(UITableView *)tableView1 viewForHeaderInSection:(NSInteger)section{
    
    
    UIView *view=[[UIView alloc]init];;
    view.frame=CGRectMake(0, 0, 280, tableView1.rowHeight);
    view.backgroundColor=[UIColor grayColor];
    
    // Pin label
    UILabel* pinLabel=[[UILabel alloc]initWithFrame:CGRectMake(10,5,130,30)];
    
    pinLabel.frame=CGRectMake(10,5,tableView.rowHeight-5,30);
    ///(10,0,tableView.rowHeight-5,tableView.rowHeight-5)
    pinLabel.backgroundColor=[UIColor clearColor];
    pinLabel.textAlignment=UITextAlignmentCenter;
    pinLabel.textColor=[UIColor blackColor];
    pinLabel.font=[UIFont fontWithName:@"ArialMT" size:16];
    pinLabel.text=@"Pin";
    
    //catagoryLabel.tag=CELL_LABEL;
    [view addSubview:pinLabel];
    
    
    
    // catagories label
    UILabel* catagoryLabel=[[UILabel alloc]initWithFrame:CGRectMake(140,5,130,30)];
    
    catagoryLabel.frame=CGRectMake(70,5,205,30);
    
    catagoryLabel.backgroundColor=[UIColor clearColor];
    catagoryLabel.textAlignment=UITextAlignmentCenter;
    catagoryLabel.textColor=[UIColor blackColor];
    catagoryLabel.font=[UIFont fontWithName:@"ArialMT" size:16];
    catagoryLabel.text=@"Category";
    
    //catagoryLabel.tag=CELL_LABEL;
    [view addSubview:catagoryLabel];
    
    
    
    return view;
    
}


-(UITableViewCell*)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellId=@"KEY_TABLE";
    UITableViewCell *cell=[tableView1 dequeueReusableCellWithIdentifier:cellId];
    if(cell==nil){
        
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        
        [self createCellUI:cell forIndexPath:indexPath];
    }
    
    [self upDateCell:cell forIndexPath:indexPath];
    
    return cell;
}

-(void)createCellUI:(UITableViewCell*)cell forIndexPath:(NSIndexPath*)indexPath{
    // ImageView
    UIImageView* catagoryImageView=[[UIImageView alloc]initWithFrame:CGRectMake(10,5,tableView.rowHeight-5,tableView.rowHeight-10)];
    
    catagoryImageView.backgroundColor=[UIColor clearColor];
    catagoryImageView.tag=IMAGEVIEW;
    [cell addSubview:catagoryImageView];
    
    
    // catagories label
    UILabel* catagoryLabel=[[UILabel alloc]initWithFrame:CGRectMake(70,5,205,30)];
    catagoryLabel.backgroundColor=[UIColor clearColor];
    catagoryLabel.textAlignment=UITextAlignmentCenter;
    catagoryLabel.textColor=[UIColor blackColor];
    catagoryLabel.font=[UIFont fontWithName:@"ArialMT" size:16];
    //catagoryLabel.text=@"Key";
    
    catagoryLabel.tag=CELL_LABEL;
    [cell addSubview:catagoryLabel];
    
    
    
    
    
    
}



-(void)upDateCell:(UITableViewCell*)cell forIndexPath:(NSIndexPath*)indexPath{
    UIImageView* catagoryImageView=(UIImageView *)[cell viewWithTag:IMAGEVIEW];
    
    UILabel* catagoryLabel=(UILabel*)[cell viewWithTag:CELL_LABEL];
    
    CPMapCategories * category=[categoryObjectArray objectAtIndex:indexPath.row];
    catagoryLabel.text=category.category_name;
    
    
    UIImage *image=[pinImagesDict objectForKey:category.device_image];
    if(image!=nil){
        catagoryImageView.image=image;
    }
    
    else{
        
        NSString *tempImageName=@"";
        tempImageName=category.device_image;
        //    //NSLog(@"tempImageName: %@  device_image:%@ ",tempImageName,category.device_image);
        
        if(tempImageName.length>0){
            NSString *imageUrl=[NSString stringWithFormat:@"%@/iphone/%@/%@",dtManager.configuration.imagePath,[CPUtility deviceDensity],tempImageName];
            
            [self getImageAtIndex:indexPath.row forKey:[NSURL URLWithString:imageUrl]];
        }
        
    }
}


//get the image as per index,with the related URL
- (void)getImageAtIndex:(int)index forKey:(NSURL*)url
{
    
    CPConnectionManager *manager = [CPConnectionManager sharedConnectionManager];
    CPRequest*request = [[CPRequest alloc] initWithURL:url
                                       withRequestType:CPRequestTypeTourKeyImage];
    request.identifier=[NSNumber numberWithInt:index];
    
    [manager spawnConnectionWithRequest:request delegate:self];
    request.identifier = [NSNumber numberWithInteger:index];
}


-(void)addingPoints{
    if(annotationsArray!=nil )
        [annotationsArray removeAllObjects];
    if(titleArray!=nil)
        [titleArray removeAllObjects];
    
    
    int count=0;
    for(Place *place in placeArrayForTourGuide){
        // //NSLog(@"%d",place.tourmap_id);
        
        
        [titleArray addObject:place.name];
        [pathObjectsArray addObject:place];
        
        // MyAnnotation *A1=[[[MyAnnotation alloc] initWithPlace:place] autorelease];
        MyAnnotation *A1=[[MyAnnotation alloc] initWithPlace:place] ;
        
        //  if(count==0)
        //       A1.colorCode=1;
        // else
        
        A1.colorCode=PIN_BLUE;
        [annotationsArray addObject:A1];
        // [mapView addAnnotation:A1];
        count++; //this is used for first point is green
    }
    
    
    
    
    for(MyAnnotation *annotation in annotationsArray){
        [mapView addAnnotation:annotation];
    }
    
    
    CPMenu *menu = [[CPDataManger sharedDataManager] selectedMenu];
    if(menu.is_map){
        
        Place *temp=[placeArrayForTourGuide lastObject];
        Place *last=[[Place alloc]init] ;
        last.name=@"End";
        last.description=@"End of the tour";
        last.latitude=temp.latitude-0.000200;
        last.longitude=temp.longitude+0.000200;
        MyAnnotation *lastAnnotation=[[MyAnnotation alloc] initWithPlace:last] ;
        lastAnnotation.colorCode=RED_FLAG;
        [annotationsArray addObject:lastAnnotation];
        [mapView addAnnotation:lastAnnotation];
    }
}

- (void)callServicePage
{
    
    
    if(!isGoogleAPI){
        
        CPMenu *menu = [[CPDataManger sharedDataManager] selectedMenu];
        
        
        
        NSString *strURL=@"";
        
        
        
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            
            strURL=[NSString stringWithFormat:@"%@tourmaps?method=getMapPointName&univId=%@&deviceId=%d&categoryId=%d",SERVER_URL,dtManager.configuration.university.id,CPDeviceTypeiPhone,menu.category_id];
        else
            strURL=[NSString stringWithFormat:@"%@tourmaps?method=getMapPointName&univId=%@&deviceId=%d&categoryId=%d",SERVER_URL,dtManager.configuration.university.id,CPDeviceTypeiPad,menu.category_id];
        
        
        
        
        
        CPConnectionManager *manager = [CPConnectionManager sharedConnectionManager];
        
        NSURL *urlServer = [NSURL URLWithString:strURL];
        CPRequest*request = [[CPRequest alloc] initWithURL:urlServer withRequestType:CPRequestTypeTour];
        //  request.identifier = menu.id;
        [manager spawnConnectionWithRequest:request delegate:self];
        // [request release];
        
        //   //NSLog(@"%f %f",location.coordinate.latitude,location.coordinate.longitude);
        
    }
    else{
        
        
        
        
        
        if(placeArrayForTourGuide.count>0){
            
            Place *point1=[[Place alloc]init];
            point1.latitude = [((CPUniversity*)(dtManager.configuration.university)).latitude doubleValue];
            point1.longitude = [((CPUniversity*)(dtManager.configuration.university)).longitude doubleValue];
            point1.name=@"Start";
            point1.description=@"Start point of the tour";
            from = [[MyAnnotation alloc] initWithPlace:point1] ;
            
            from.colorCode=GREEN_FLAG;
            //[mapView removeAnnotation:from];
            [mapView addAnnotation:from];
            CLLocationCoordinate2D coOrdinate1=CLLocationCoordinate2DMake(point1.latitude, point1.longitude);
            
            
            
            MKCoordinateRegion region;
            region.center.latitude     = coOrdinate1.latitude;
            region.center.longitude    = coOrdinate1.longitude;
            
            region.span.latitudeDelta  = 0.03;
            region.span.longitudeDelta = 0.03;
            [mapView setRegion:region animated:YES];
            
            
            
            
            
            if(annotationsArray.count>0){
                if(annotationForCurrentLocation!=nil){
                    [mapView removeAnnotation:annotationForCurrentLocation];
                    [mapView addAnnotation:annotationForCurrentLocation];
                }
                
                CPMenu *menu = [[CPDataManger sharedDataManager] selectedMenu];
                if(menu.is_map){
                    MyAnnotation *end = [annotationsArray objectAtIndex:checkPointCount];
                    if(end!=nil)
                        [mapView removeAnnotation:end];
                    end.colorCode=RED_FLAG;
                    
                    [mapView addAnnotation:end];
                    
                }
            }
            
            [self callPathAPI];
            
            
        }
        else{
            if(loadView!=nil)
                [self removeLoadingView];
        }
        
    }
}




-(void)callPathAPI{
    
    //if(pathLoopCount%4==0)
    //sleep(2);
    
    Place *point1;
    Place *point2;
    if(pathLoopCount==0){
        point1=[[Place alloc]init];
        point1.latitude = [((CPUniversity*)(dtManager.configuration.university)).latitude doubleValue];
        point1.longitude = [((CPUniversity*)(dtManager.configuration.university)).longitude doubleValue];
        point2=[placeArrayForTourGuide objectAtIndex:0];
        if(placeArrayForTourGuide.count>0)
            [self showTourGuideFrom:point1 To:point2 index:0];
        pathLoopCount++;
    }
    else{
        
        if(placeArrayForTourGuide.count>0&&placeArrayForTourGuide.count>pathLoopCount){
            
            point1=[placeArrayForTourGuide objectAtIndex:pathLoopCount-1];
            point2=[placeArrayForTourGuide objectAtIndex:pathLoopCount];
            
            //  //NSLog(@"%f %f",point1.latitude,point1.longitude);
            
            [self showTourGuideFrom:point1 To:point2 index:1];
            pathLoopCount++;
        }
        
        
    }
}


-(void)pathFromUniversity{
    
    Place *point1=[[Place alloc]init];
    point1.latitude = [((CPUniversity*)(dtManager.configuration.university)).latitude doubleValue];
    point1.longitude = [((CPUniversity*)(dtManager.configuration.university)).longitude doubleValue];
    
    Place*point2=[placeArrayForTourGuide objectAtIndex:0];
    
    if(polylineArray.count>0){
        if([polylineArray objectAtIndex:0]!=nil){
            [mapView removeOverlay:[polylineArray objectAtIndex:0]];
            //  sleep(1);
            //  [mapView addOverlay:[polylineArray objectAtIndex:0]];
        }
    }
    [self showTourGuideFrom:point1 To:point2 index:0];
    
    
}



-(void)pathFromCurrentPoint:(int)index{
    if(index<polylineArray.count){
        if([polylineArray objectAtIndex:index]!=nil){
            [mapView removeOverlay:[polylineArray objectAtIndex:index]];
            //sleep(1);
            // [mapView addOverlay:[polylineArray objectAtIndex:index]];
        }
    }
    if(index-1>=0){
        //   else{
        Place*point1=[placeArrayForTourGuide objectAtIndex:index-1];
        Place*point2=[placeArrayForTourGuide objectAtIndex:index];
        [self showTourGuideFrom:point1 To:point2 index:1];
    }
    //}
}






//get the image as per index,with the related URL
- (void)getImageAtIndex:(int)index forURL:(NSURL*)url
{
    CPConnectionManager *manager = [CPConnectionManager sharedConnectionManager];
    CPRequest*request = [[CPRequest alloc] initWithURL:url
                                       withRequestType:CPRequestTypeImage];
    request.identifier=[NSNumber numberWithInt:index];
    
    [manager spawnConnectionWithRequest:request delegate:self];
    request.identifier = [NSNumber numberWithInteger:index];
    
}



//get the image as per index,with the related URL
- (void)getImageAtIndex:(int)index forPinView:(NSURL*)url
{
    
    CPConnectionManager *manager = [CPConnectionManager sharedConnectionManager];
    CPRequest*request = [[CPRequest alloc] initWithURL:url
                                       withRequestType:CPRequestTypeTourPinImage];
    request.identifier=[NSNumber numberWithInt:index];
    
    [manager spawnConnectionWithRequest:request delegate:self];
    request.identifier = [NSNumber numberWithInteger:index];
    
}


-(void)showTourGuideFrom:(Place*)point1 To:(Place*)point2 index:(int)indexForOverLay{
    
    
    
    CPConnectionManager *manager = [CPConnectionManager sharedConnectionManager];
    CPMenu *menu = [[CPDataManger sharedDataManager] selectedMenu];
    NSString *strURL = nil;
    
    
    
    
    //    strURL=[NSString stringWithFormat:@"http://maps.google.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=true&mode=driving",point1.latitude,point1.longitude,point2.latitude,point2.longitude];
    
    NSString *modeString=isDrivingMode?@"driving":@"walking";
    
    strURL=[NSString stringWithFormat:@"http://maps.google.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=true&mode=%@",point1.latitude,point1.longitude,point2.latitude,point2.longitude,modeString];
    
    
    
    
    NSURL *urlServer = [NSURL URLWithString:strURL];
    CPRequest*request = [[CPRequest alloc] initWithURL:urlServer withRequestType:isGoogleAPI?CPRequestTypeTourPath :CPRequestTypeTour];
    
    request.identifier = menu.id;
    request.indexForOverLay=indexForOverLay;
    [manager spawnConnectionWithRequest:request delegate:self];
    
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



-(void)parsingJSONstring:(int)index{
    
    
    NSError *error;
    NSDictionary *dictionary=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    
    if(dictionary!=nil){
        NSString *status=[dictionary objectForKey:@"status"];
        if(status!=nil &&[ status isEqualToString:@"OK" ])
            isStatus=TRUE;
        // //NSLog(@"status: %d",isStatus);
        
        if(isStatus==YES){
            isStatus=NO;
            NSArray *items=[dictionary valueForKey:@"routes"];
            if(items!=nil){
                NSDictionary *dict=[items objectAtIndex:0];
                //   //NSLog(@"%@",[dict allKeys]);
                NSDictionary *overViewDict= [dict objectForKey:@"overview_polyline"];
                NSString *overview_polylineString=[overViewDict objectForKey:@"points"];
                
                //  //NSLog(@"%@",overview_polylineString);
                if(mapView!=nil){
                    //if([mapView overlays].count>0)
                    //   [mapView removeOverlays:[mapView overlays]];
                }
                if(overview_polylineString!=nil)           {
                    polyline=nil;
                    polyline=[self polylineWithEncodedString:overview_polylineString];
                    [mapView setNeedsLayout];
                    [mapView addOverlay:polyline];
                    
                    
                    if(!isVisited){
                        [polylineArray addObject:polyline];
                        //[polylineArray insertObject:polyline atIndex:index];
                        //  //NSLog(@"index: %d",index);
                    }
                    [mapView setClipsToBounds:YES];
                    
                }
            }
        }
        
        
    }
}


- (void)CPConnection:(CPConnection*)CPConnection didReceiveResponse:(id)response
{
    
    if(!isGoogleAPI){
        if(CPConnection.request.type == CPRequestTypeTour){
            
            isGoogleAPI=YES;
            NSData *_data = [(NSDictionary*)response valueForKey:@"data"];
            
            
            NSError *error;
            NSDictionary * tempDict=[NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableContainers error:&error];
            
            
            // //NSLog(@"NSDictionary");
            if([tempDict objectForKey:@"error"] != nil)
            {
                
                
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertTitle", @"")
                                                                     message:[tempDict objectForKey:@"error"]
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"cancelButton", @"")
                                                           otherButtonTitles:nil];
                [errorAlert show];
                
                
                
                
                return;
            }
            
            NSArray * tempArray;
            
            
            tempArray=[tempDict objectForKey:@"tourmaps"];
            ////NSLog(@"NSArray");
            
            //tourmaps
            
            if(placeArrayForTourGuide!=nil)
                [placeArrayForTourGuide removeAllObjects];
            placeArrayForTourGuide=[[NSMutableArray alloc]init];
            // //NSLog(@"tempArray: %d",tempArray.count);
            
            
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
                        ////NSLog(@"place.map_image: %@  ",place.map_image);
                        
                        NSString *tourmap_id=[dict objectForKey:@"tourmap_id"];
                        if(tourmap_id!=nil)
                            place.tourmap_id=[tourmap_id intValue];
                        
                        NSString *map_order=[dict objectForKey:@"map_order"];
                        if(map_order!=nil)
                            place.map_order=[map_order intValue];
                        
                        
                        place.media_type=[[dict objectForKey:@"media_type"] intValue];
                        
                        //  //NSLog(@"media_type: %d",place.media_type);
                        
                        
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
                            //   //NSLog(@"%d %d %d",tempCategories.category_id,index,categoryIdArray.count);
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
                    
                    
                    
                    //  //NSLog(@"categoryIdArray: %@",categoryIdArray);
                    
                    for (CPMapCategories *temp in categoryObjectArray) {
                        //   //NSLog(@"categoryIdArray: %d",temp.category_id);
                        // //NSLog(@"categoryIdArray: %@",temp.device_image);
                        
                    }
                    
                }
                
                
                
                
                
                if(placeArrayForTourGuide!=nil && placeArrayForTourGuide.count>0){
                    
                    
                    
                    for(Place *place in placeArrayForTourGuide){
                        /*   //NSLog(@"place.tourmap_id: %d",place.tourmap_id);
                         //NSLog(@"media_type: %d",place.media_type);
                         //NSLog(@"video_name: %@",place.video_name);
                         //NSLog(@"map_image: %@",place.map_image);
                         //NSLog(@"video_thumb: %@",place.video_thumb);
                         //NSLog(@"category_ipad_image: %@",place.categories.category_name);
                         
                         //NSLog(@"category_ipad_image: %@",place.categories.category_ipad_image);
                         //NSLog(@"device_image: %@",place.categories.device_image);
                         */
                    }
                    
                    
                    [self sortArry:placeArrayForTourGuide];
                    // //NSLog(@"placeArrayForTourGuide: %d",placeArrayForTourGuide.count);
                    
                    for(Place *place in placeArrayForTourGuide){
                        /* //NSLog(@"place.tourmap_id: %d",place.tourmap_id);
                         //NSLog(@"media_type: %d",place.media_type);
                         //NSLog(@"video_name: %@",place.video_name);
                         //NSLog(@"map_image: %@",place.map_image);
                         //NSLog(@"video_thumb: %@",place.video_thumb);
                         //NSLog(@"category_ipad_image: %@",place.categories.category_name);
                         
                         //NSLog(@"category_ipad_image: %@",place.categories.category_ipad_image);
                         //NSLog(@"device_image: %@",place.categories.device_image);
                         */
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
                    
                    [self animateFooterView:YES];
                    
                    
                    
                    //  //NSLog(@"location: %f %f",location.coordinate.latitude,location.coordinate.longitude);
                    
                }
                
            }
            
            
            [self addingPoints];
            
            if(isDirectionSelected)
                [self callServicePage];
            else
            {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Directions"
                                                                message:@"Select mode of travel"
                                                               delegate:self
                                                      cancelButtonTitle:@"Driving"
                                                      otherButtonTitles:@"Walking",nil];
                alert.tag=22222;
                [alert show];
                
                
            }
        }
    }
    else{
        
        NSData *_data = [(NSDictionary*)response valueForKey:@"data"];
        
        if(CPConnection.request.type == CPRequestTypeImage)
        {
            
            //  //NSLog(@"CPConnection.request.identifier: %@",CPConnection.request.identifier);
            
            NSArray *array=[mapView annotations];
            
            for(int i=0;i<array.count;i++){
                
                int tag=[CPConnection.request.identifier intValue];
                
                if(tag<titleArray.count){
                    
                    if([[array objectAtIndex:i] isKindOfClass:[CustomMapItem class]]){
                        CustomMapItem *annoatation=(CustomMapItem*)[array objectAtIndex:i];
                        
                        //    //NSLog(@"title: %@ an title: %@",selectedAnnotaion,[annoatation title]);
                        
                        if([selectedAnnotaion isEqualToString:[annoatation title]]){
                            CustomAnnotationView *view=(CustomAnnotationView*)[mapView viewForAnnotation:annoatation];
                            
                            [customImagesDict setObject:[UIImage imageWithData:_data] forKey:selectedAnnotaion];
                            view.annotationImage.image=[UIImage imageWithData:_data];
                        }
                    }
                    
                    
                }
            }
            
            
            return;
        }
        else if(CPConnection.request.type == CPRequestTypeTourPinImage)
        {
            
            // //NSLog(@"CPConnection.request.identifier: %@",CPConnection.request.identifier);
            
            NSArray *array=[mapView annotations];
            int tag=[CPConnection.request.identifier intValue];
            
            if(tag<pathObjectsArray.count){
                
                Place *tempPlace=[pathObjectsArray objectAtIndex:tag];
                for(int i=0;i<array.count;i++){
                    
                    
                    if([[array objectAtIndex:i] isKindOfClass:[MyAnnotation class]]){
                        MyAnnotation *myAnnotation=(MyAnnotation*)[array objectAtIndex:i];
                        
                        //   //NSLog(@"%@",CPConnection.)
                        
                        NSString *selectedAnnotaion1=[titleArray objectAtIndex:tag];
                        //    //NSLog(@"title: %@ an title: %@",selectedAnnotaion1,[myAnnotation title]);
                        
                        
                        if([selectedAnnotaion1 isEqualToString:[myAnnotation title]]){
                            MKAnnotationView *view=(MKAnnotationView*)[mapView viewForAnnotation:myAnnotation];
                            
                            //  [pinImagesDict setObject:[UIImage imageWithData:_data] forKey:tempPlace.categories.device_image];
                            
                            [pinImagesDict setObject:[UIImage imageWithData:_data] forKey:tempPlace.map_image];
                            
                            view.image=[UIImage imageWithData:_data];
                        }
                    }
                    
                }
            }
            
            
            
            
            return;
        }
        else if(CPConnection.request.type == CPRequestTypeTourKeyImage)
        {
            
            //  //NSLog(@"CPConnection.request.identifier: %@",CPConnection.request.identifier);
            
            int tag=[CPConnection.request.identifier intValue];
            
            if(tag<categoryObjectArray.count){
                
                UITableViewCell *cell=(UITableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tag inSection:0]];
                UIImageView* catagoryImageView=(UIImageView *)[cell viewWithTag:IMAGEVIEW];
                CPMapCategories * category=[categoryObjectArray objectAtIndex:tag];
                
                [pinImagesDict setObject:[UIImage imageWithData:_data] forKey:category.device_image];
                
                catagoryImageView.image=[UIImage imageWithData:_data];
                
            }
            
            
            return;
        }
        else if(CPConnection.request.type == CPRequestTypeTourPath){
            
            NSError*error;
            
            NSDictionary * dict=[NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableContainers error:&error];
            BOOL isStatus1;
            isStatus1=NO;
            NSString *status=[dict objectForKey:@"status"];
            if(status!=nil &&[ status isEqualToString:@"OK" ])
                isStatus1=YES;
            // //NSLog(@"status: %d",isStatus);
            
            if(isStatus1!=YES){
                
                if(loadView != nil)
                {
                    [self removeLoadingView];
                }
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                     message:@"Unable to find the route"
                                                                    delegate:self
                                                           cancelButtonTitle:@"Ok"
                                                           otherButtonTitles:nil];
                errorAlert.tag=11111;
                [errorAlert show];
                
                
                
                
                return;
            }
            
            
            //[self parsingJSONstring];
            responseData=nil;
            responseData=[[NSMutableData alloc]initWithData:_data];
            [self parsingJSONstring:CPConnection.request.indexForOverLay];
            
            
            if(pathLoopCount==pathObjectsArray.count){
                if(loadView != nil)
                {
                    [self removeLoadingView];
                }
            }
            else{
                if(pathLoopCount%4==0)
                    sleep(2);
                //[self performSelector:@selector(callPathAPI) withObject:nil afterDelay:2];
                //else
                [self callPathAPI];
                
                // [self performSelector:@selector(callPathAPI) withObject:nil afterDelay:2];
                
            }
            
        }
        
    }
    
    
    
    
    [self.view bringSubviewToFront:loadView];
    
}
- (void)CPConnection:(CPConnection*)CPConnection didFailWithError:(NSError*)error
{
    /*
     if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
     {
     if(loadView != nil)
     {
     [self removeLoadingView];
     }
     }
     else{
     if(_activityView!=nil)
     [_activityView removeFromSuperview];
     
     }    */
    
    
    
    if(loadView != nil)
    {
        [self removeLoadingView];
    }
    
    
    if((CPConnection.request.type != CPRequestTypeImage)&&(CPConnection.request.type != CPRequestTypeTourPinImage))
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
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertTitle","")
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        
        //alert.tag=
        [alert show];
        
    }
    
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
        ScanResultsPage *_pageViewController = [[ScanResultsPage alloc] initWithNibName:nil bundle:nil];
        _pageViewController.cpTourGuideIPhone=self;
        
        
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
        ScanResultsPage *_pageViewController = [[ScanResultsPage alloc] initWithNibName:nil bundle:nil];
        _pageViewController.qrContent = qrContent;
        _pageViewController.cpTourGuideIPhone=self;
        
        qrContent = nil;
        _pageViewController.title = @"Results";
        [self.navigationController pushViewController:_pageViewController animated:NO];
        
        [reader dismissModalViewControllerAnimated: NO];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    CPAppDelegate *appDelegate= (CPAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate upDateViewFramewithPicker:picker toReplaceView:self.view];
    [picker dismissModalViewControllerAnimated:YES];
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
        /*  if(_imgView.superview != nil)
         {
         rect.origin.y = _imgView.frame.size.height;
         rect.size.height = self.view.frame.size.height - (_footerView.frame.size.height +  _imgView.frame.size.height);
         if(banner.isBannerLoaded == YES)
         {
         rect.size.height = self.view.frame.size.height - (banner.frame.size.height +  _footerView.frame.size.height + _imgView.frame.size.height);
         }
         }*/
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
    BOOL shouldExecuteAction = YES;
    
    if (!willLeave && shouldExecuteAction)
    {
        // stop all interactive processes in the app
        // [video pause];
        // [audio pause];
    }
    return shouldExecuteAction;
}



#pragma marks - mapview delegates
-(MKAnnotationView *)mapView:(MKMapView *)mapView1 viewForAnnotation:(id<MKAnnotation>)annotation{
    
    // mapView.userLocation
    
    if ([annotation isKindOfClass:[CustomMapItem class]])
    {
        static NSString *TeaGardenAnnotationIdentifier1 = @"TeaGardenAnnotationIdentifier1";
        
        CustomAnnotationView *annotationView =
        (CustomAnnotationView *)[mapView1 dequeueReusableAnnotationViewWithIdentifier:TeaGardenAnnotationIdentifier1];
        if (annotationView == nil)
        {
            annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:TeaGardenAnnotationIdentifier1] ;
            
            //[annotationView.closeButton setImage:[UIImage imageNamed:@"playIcon.png"] forState:UIControlStateNormal];
            
            annotationView.videoIcon = [[UIImageView alloc] init];
            annotationView.videoIcon.frame=CGRectMake(10,10,20,20);
            annotationView.videoIcon.image=[UIImage imageNamed:@"playIcon_pin.png"];
            annotationView.videoIcon.contentMode = UIViewContentModeScaleAspectFit;
            [annotationView addSubview:annotationView.videoIcon];
            [annotationView bringSubviewToFront:annotationView.videoIcon];
            annotationView.userInteractionEnabled=YES;
            
            
        }
        annotationView.videoIcon.center=annotationView.annotationImage.center;
        
        if([selectedAnnotaion isEqualToString:[annotation title]])
        {
            
            int imageTag=[titleArray indexOfObject:[NSString stringWithFormat:@"%@",[annotation title]]];
            if(imageTag<pathObjectsArray.count){
                Place *imagePlae=[pathObjectsArray objectAtIndex:imageTag];
                
                if(imagePlae.media_type==2)
                    annotationView.videoIcon.hidden=NO;
                else
                    annotationView.videoIcon.hidden=YES;
                
                
                
                
                
                
                UIImage *image=[customImagesDict objectForKey:selectedAnnotaion];
                if(image!=nil){
                    isImageOrVideoView=YES;
                    annotationView.annotationImage.image=image;
                }
                
                else
                {
                    annotationView.annotationImage.image=[UIImage imageNamed:@"ImagePlaceholder.png"];
                    
                    
                    NSString *tempImageName=@"";
                    
                    
                    if(imagePlae!=nil){
                        
                        if(imagePlae.media_type==2){
                            tempImageName=imagePlae.video_thumb?imagePlae.video_thumb:@"";
                            //annotationView.closeButton.hidden=NO;
                        }
                        else
                            tempImageName=imagePlae.map_image?imagePlae.map_image:@"";
                        //annotationView.closeButton.hidden=YES;
                        
                    }
                    
                    
                    
                    
                    
                    if(tempImageName.length>0){
                        isImageOrVideoView=YES;
                        
                        
                        
                        NSString *imageUrl=[NSString stringWithFormat:@"%@/iphone/%@/%@",(imagePlae.media_type==2)? dtManager.configuration.videoPath :dtManager.configuration.imagePath,[CPUtility deviceDensity],tempImageName];
                        
                        
                        
                        [self getImageAtIndex:1 forURL:[NSURL URLWithString:imageUrl]];
                    }
                    else{
                        isImageOrVideoView=NO;
                    }
                    
                    
                }
                //
                
                
            }
            else{
                if([[annotation title] isEqualToString:@"You"]||[[annotation title] isEqualToString:@"Start"]||
                   [[annotation title] isEqualToString:@"End"])
                    annotationView.annotationImage.image=[UIImage imageNamed:@""];
                
                annotationView.videoIcon.hidden=YES;
            }
            
            
        }
        
        
        annotationView.frame=CGRectMake(0, 0, 200, 100);
        
        //   annotationView.centerOffset=CGPointMake(0, -50);
        annotationView.centerOffset=CGPointMake(0, -100);
        
        
        annotationView.titleLabel.text=[annotation title];
        //annotationView.annotationLabel.text=[annotation subtitle];
        /*
        NSMutableString *tempstring = [[NSMutableString stringWithString:[annotation subtitle]] mutableCopy];
        NSMutableString *newtempstring = [[tempstring stringByReplacingOccurrencesOfString:@"<p" withString:@"<p style=\"font-family:arial;\""] mutableCopy]; //TODO refactor the view method and replace this cheap hack.
        */
        //[_webView loadHTMLString:newtempstring baseURL:nil];
        [annotationView.annotationLabel loadHTMLString:[annotation subtitle]baseURL:nil];
        
        annotationView.closeButtonBg.image=[UIImage imageNamed:@"gray_back.png"];
        
        // Modified By V2
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
        [tapGestureRecognizer setNumberOfTapsRequired:1];
        tapGestureRecognizer.delegate = self;
        [annotationView.closeButtonBg addGestureRecognizer:tapGestureRecognizer];
        [annotationView.imageButton addTarget:self action:@selector(imageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        return annotationView;
    }
    
    
    [mapView1 annotationVisibleRect];
    
    
    MKAnnotationView *pinAnnotationView;
    pinAnnotationView=(MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"sharath"];
    
    if(pinAnnotationView==nil)
        pinAnnotationView=[[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"sharath"] ;
    else
        [pinAnnotationView prepareForReuse];
    
    
    if([[annotation title] isEqualToString:@"Start"])
    {
        NSString *name=@"";
        name=[imageName objectAtIndex:from.colorCode];
        pinAnnotationView.image=[UIImage imageNamed:name];
        pinAnnotationView.centerOffset=CGPointMake(20,-25);
        
        
    }
    else if([[annotation title] isEqualToString:@"End"])
    {
        CPMenu *menu = [[CPDataManger sharedDataManager] selectedMenu];
        if(menu.is_map){
            NSString *name=@"";
            name=[imageName objectAtIndex:RED_FLAG];
            pinAnnotationView.image=[UIImage imageNamed:name];
            pinAnnotationView.centerOffset=CGPointMake(20,-25);
        }
        
    }
    else{
        NSString *name=@"";
        
        if(titleArray!=nil){
            
            int tag=[titleArray indexOfObject:[NSString stringWithFormat:@"%@",[annotation title]]];
            
            
            
            
            if([[annotation title] isEqualToString:@"You"]){
                name=[imageName objectAtIndex:0];
                pinAnnotationView.centerOffset=CGPointMake(0, -25);
                
            }
            else{
                pinAnnotationView.centerOffset=CGPointMake(20,-25);
                
            }
            
            
            
            
            MyAnnotation *temp;
            if(tag<annotationsArray.count){
                
                Place *imagePlae=[pathObjectsArray objectAtIndex:tag];
                
                NSString *tempImageName=@"";
                
                if(imagePlae!=nil){
                    
                    tempImageName=imagePlae.categories.device_image?imagePlae.categories.device_image:@"";
                    
                }
                
                // tempImageName=imagePlae.map_image;
                
                
                
                
                UIImage *image=[pinImagesDict objectForKey:tempImageName];
                if(image!=nil){
                    //  isImageOrVideoView=YES;
                    pinAnnotationView.image=image;
                }
                
                else{
                    name=[imageName objectAtIndex:PIN_BLUE];
                    pinAnnotationView.image=[UIImage imageNamed:name];
                    
                    
                    
                    if(tempImageName.length>0){
                        
                        
                        NSString *imageUrl=[NSString stringWithFormat:@"%@/iphone/%@/%@",dtManager.configuration.imagePath,[CPUtility deviceDensity],tempImageName];
                        
                        
                        [self getImageAtIndex:tag forPinView:[NSURL URLWithString:imageUrl]];
                    }
                    
                    
                    temp=[annotationsArray objectAtIndex:tag];
                    name=[imageName objectAtIndex:temp.colorCode];
                    
                    if(temp.colorCode==4)
                        pinAnnotationView.centerOffset=CGPointMake(0,-25);
                    
                    
                }
            }
            else{
                name=[imageName objectAtIndex:2];
                if([[annotation title] isEqualToString:@"You"]){
                    name=[imageName objectAtIndex:0];
                    pinAnnotationView.centerOffset=CGPointMake(0, -25);
                    pinAnnotationView.image=[UIImage imageNamed:name];
                }
                
            }
            
        }
        
        
        [pinAnnotationView setBackgroundColor:[UIColor clearColor]];
    }
    [pinAnnotationView setCanShowCallout:NO];
    return pinAnnotationView;
    
    
}

// Added by v2

- (void)gotoDetailPage {
    
    [[CPConnectionManager sharedConnectionManager] closeAllConnections];
    
    if(descriptionViewController==nil)
        descriptionViewController=[[DescriptionViewController alloc]init];
    descriptionViewController.customImagesDict=customImagesDict;
    int imageTag=[titleArray indexOfObject:[NSString stringWithFormat:@"%@",selectedAnnotaion]];
    //  int imageTag=[titleArray indexOfObject:[NSString stringWithFormat:@"%@",[view.annotation title]]];
    
    if(imageTag<pathObjectsArray.count){
        Place *imagePlae=[pathObjectsArray objectAtIndex:imageTag];
        descriptionViewController.place=[[Place alloc]init];
        
        NSString *tempImageName=@"";
        if(imagePlae.media_type==2){
            tempImageName=imagePlae.video_thumb?imagePlae.video_thumb:@"";
            if(tempImageName!=nil && tempImageName.length>0)
                descriptionViewController.isVideoUrl=YES;
            else
                descriptionViewController.isVideoUrl=NO;
        }
        else{
            tempImageName=imagePlae.map_image?imagePlae.map_image:@"";
            if(tempImageName!=nil && tempImageName.length>0)
                descriptionViewController.isImageUrl=YES;
            else
                descriptionViewController.isImageUrl=NO;
        }
        
        
        descriptionViewController.place.name=imagePlae.name;
        descriptionViewController.place.description=imagePlae.description;
        descriptionViewController.place.map_image=imagePlae.map_image;
        
        descriptionViewController.place.media_type=imagePlae.media_type;
        
        descriptionViewController.place.video_name=imagePlae.video_name;
        
        descriptionViewController.place.video_thumb=imagePlae.video_thumb;
        
        descriptionViewController.place.video_text=imagePlae.video_text;
        
        
        
    }
    
    //  if(isImageOrVideoView==YES)
    //   descriptionViewController.imageView.hidden=NO;
    // else
    //    descriptionViewController.imageView.hidden=YES;
    //NSLog(@"Detail with first");
    
    if(!([preTitle isEqualToString:@"You"]||[preTitle isEqualToString:@"Start"]||
         [preTitle isEqualToString:@"End"])){
        //NSLog(@"Detailpage");
        
        [self.navigationController pushViewController:descriptionViewController animated:YES];
    }
    
    
}

// Added new method by v2
- (void) handleTapFrom:(UITapGestureRecognizer *)recognizer {
    
    [self performSelector:@selector(gotoDetailPage)];
}


-(void)buttonAction:(UIButton*)button{
    
    
    CustomAnnotationView *annotationView=(CustomAnnotationView*)[button superview] ;
    if(annotationView!=nil)
        // annotationView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"orange_back.png"]];
        //  [self performSelector:@selector(chageColor:) withObject:button afterDelay:1];
        annotationView.closeButtonBg.image=[UIImage imageNamed:@"orange_back.png"];
    // button.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"gray_back.png"]];
    
}



-(void)imageButtonAction:(UIButton *)button{
    
    // Modified By V2
    
    //    for (CustomMapItem *annotation in [mapView annotations]) {
    //        if ([annotation isKindOfClass:[CustomMapItem class]])
    //            [mapView removeAnnotation:annotation];
    //    }
    
    
    [self performSelector:@selector(gotoDetailPage)];
}


- (void)mapView:(MKMapView *)mapView1 didSelectAnnotationView:(MKAnnotationView *)view {
    
    //NSLog(@"SelectAnnotationView: %@",[[view annotation] title]);
    
    CLLocationCoordinate2D coOrdinate1=[view.annotation coordinate];
    
    if(view.annotation!=nil)
    {
        // if(![selectedAnnotaion isEqualToString:[view.annotation title]])
        {
            selectedAnnotaion=@"";
            [mapView setCenterCoordinate:[view.annotation coordinate]];
            selectedAnnotaion=[view.annotation title];
            
            Place* home1 = [[Place alloc] init]  ;
            home1.name = [view.annotation title];
            home1.description = [view.annotation subtitle];
            
            
            
            home1.latitude=coOrdinate1.latitude;
            home1.longitude=coOrdinate1.longitude;
            callOutAnnotation=[[CustomMapItem alloc] init] ;
            //   callOutAnnotation.coordinate=coOrdinate1;
            callOutAnnotation.latitude=coOrdinate1.latitude;
            callOutAnnotation.longitude=coOrdinate1.longitude;
            callOutAnnotation.place=home1;
            //   //NSLog(@"view: %@",[view.annotation title]);
            
            preTitle=[view.annotation title];
            [mapView addAnnotation:callOutAnnotation];
            
            //NSLog(@"callOutAnnotation");
            
        }
        //else{
        /*
         [[CPConnectionManager sharedConnectionManager] closeAllConnections];
         
         
         
         if(descriptionViewController==nil)
         descriptionViewController=[[DescriptionViewController alloc]init];
         descriptionViewController.customImagesDict=customImagesDict;
         int imageTag=[titleArray indexOfObject:[NSString stringWithFormat:@"%@",selectedAnnotaion]];
         //  int imageTag=[titleArray indexOfObject:[NSString stringWithFormat:@"%@",[view.annotation title]]];
         
         if(imageTag<pathObjectsArray.count){
         Place *imagePlae=[pathObjectsArray objectAtIndex:imageTag];
         descriptionViewController.place=[[Place alloc]init];
         
         NSString *tempImageName=@"";
         if(imagePlae.media_type==2){
         tempImageName=imagePlae.video_thumb?imagePlae.video_thumb:@"";
         if(tempImageName!=nil && tempImageName.length>0)
         descriptionViewController.isVideoUrl=YES;
         else
         descriptionViewController.isVideoUrl=NO;
         }
         else{
         tempImageName=imagePlae.map_image?imagePlae.map_image:@"";
         if(tempImageName!=nil && tempImageName.length>0)
         descriptionViewController.isImageUrl=YES;
         else
         descriptionViewController.isImageUrl=NO;
         }
         
         
         descriptionViewController.place.name=imagePlae.name;
         descriptionViewController.place.description=imagePlae.description;
         descriptionViewController.place.map_image=imagePlae.map_image;
         
         descriptionViewController.place.media_type=imagePlae.media_type;
         
         descriptionViewController.place.video_name=imagePlae.video_name;
         
         descriptionViewController.place.video_thumb=imagePlae.video_thumb;
         
         descriptionViewController.place.video_text=imagePlae.video_text;
         
         
         
         }
         
         //  if(isImageOrVideoView==YES)
         //   descriptionViewController.imageView.hidden=NO;
         // else
         //    descriptionViewController.imageView.hidden=YES;
         //NSLog(@"Detail with second");
         
         if(!([preTitle isEqualToString:@"You"]||[preTitle isEqualToString:@"Start"]||
         [preTitle isEqualToString:@"End"])){
         
         
         [self.navigationController pushViewController:descriptionViewController animated:YES];
         }
         
         
         
         }*/
    }
    else{
        
        // Modified  By V2
        //[self performSelector:@selector(gotoDetailPage)];
    }
    
}

-(void)mapView:(MKMapView *)mapView1 didDeselectAnnotationView:(MKAnnotationView *)view {
    
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
    // MKPolylineView* lineView = [[[MKPolylineView alloc] initWithPolyline:polyline] autorelease];
    
    
    MKPolylineView* lineView = [[MKPolylineView alloc] initWithOverlay:overlay] ;
    
    // lineView.fillColor = [UIColor greenColor];
    //lineView.strokeColor = [UIColor greenColor];
    dtManager = [CPDataManger sharedDataManager];
    
    lineView.fillColor =dtManager.configuration.color.tour_path_color?dtManager.configuration.color.tour_path_color:[CPUtility colorFromHexString:DEFAULT_PATH_COLOR];
    lineView.strokeColor=dtManager.configuration.color.tour_path_color?dtManager.configuration.color.tour_path_color:[CPUtility colorFromHexString:DEFAULT_PATH_COLOR];
    lineView.lineWidth = 4;
    
    
    if(isVisited==YES){
        isVisited=NO;
        
        lineView.fillColor =dtManager.configuration.color.visited_path_color?dtManager.configuration.color.visited_path_color:[CPUtility colorFromHexString:VISITED_PATH_COLOR];
        lineView.strokeColor=dtManager.configuration.color.visited_path_color?dtManager.configuration.color.visited_path_color:[CPUtility colorFromHexString:VISITED_PATH_COLOR];
        
    }
    return lineView;
}

- (void)MapView:(MKMapView*)mapView didFailLoadingMapView:(NSError*)error
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Unable to draw route at this time."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    alert.tag = 10001;
    [alert show];
}

#pragma mark - UIAlertViewdelegate -
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        if(alertView.tag == 22222)
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
        
        else  if(loadView != nil)
        {
            [self removeLoadingView];
        }
    }
    else{
        if(_activityView!=nil)
            [_activityView removeFromSuperview];
        
        if(alertView.tag == 11111)
        {
            if(buttonIndex==0)
            {
                
                [self.navigationController popViewControllerAnimated:YES];
                
            }
            else if(buttonIndex==1){
                [self.navigationController popToRootViewControllerAnimated:YES];
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
            [self.navigationController popViewControllerAnimated:YES];
        
        
    }
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
    rect = _footerView.frame;
    rect.origin.y = self.view.frame.size.height - rect.size.height;
    [UIView commitAnimations];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return  (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    
    
    CPAppDelegate *appDelegate= (CPAppDelegate*)[UIApplication sharedApplication].delegate;
    self.view.frame=CGRectMake(0, 0,  self.interfaceOrientation>2?(appDelegate.window.frame.size.height-320):appDelegate.window.frame.size.width,self.interfaceOrientation>2?(appDelegate.window.frame.size.width-64):(appDelegate.window.frame.size.height-64));
    
    if([masterPopoverController isPopoverVisible])
        [masterPopoverController dismissPopoverAnimated:NO];
    
    
    [self upDateUI];
    
    [self.view bringSubviewToFront:loadView];
    
    return YES;
}


-(BOOL)shouldAutorotate{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return  NO;
    }
    return  YES;
}



-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return ;
    }
    
    if([masterPopoverController isPopoverVisible])
        [masterPopoverController dismissPopoverAnimated:nil];
    
    CPAppDelegate *appDelegate= (CPAppDelegate*)[UIApplication sharedApplication].delegate;
    self.view.frame=CGRectMake(0, 0,  self.interfaceOrientation>2?(appDelegate.window.frame.size.height-320):appDelegate.window.frame.size.width,self.interfaceOrientation>2?(appDelegate.window.frame.size.width-64):(appDelegate.window.frame.size.height-64));
    
    [self upDateUIFrames:toInterfaceOrientation];
    
    [self.view bringSubviewToFront:loadView];
    
}



-(void)upDateUIFrames:(UIInterfaceOrientation)orientation{
    if([masterPopoverController isPopoverVisible]){
        [masterPopoverController dismissPopoverAnimated:NO];
    }
    if((orientation==UIInterfaceOrientationPortrait)||(orientation==UIInterfaceOrientationPortraitUpsideDown))    {
        self.navigationItem.leftBarButtonItem=menuButton;
        isPotrait=YES;
    }
    else{
        isPotrait=NO;
        self.navigationItem.leftBarButtonItem=nil;
    }
    [self upDateUI];
    
    [self.view bringSubviewToFront:loadView];
    
    
}



-(void)upDateUI{
    
    if((self.interfaceOrientation==UIInterfaceOrientationPortrait)||(self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown))
    {
        self.navigationItem.leftBarButtonItem=menuButton;
        isPotrait=YES;
    }
    else{
        isPotrait=NO;
        self.navigationItem.leftBarButtonItem=nil;
    }
    
    if(popView.isPopoverVisible==YES){
        
        CGRect rect=CGRectMake(self.view.frame.size.width-50,50,240,0);
        
        [popView presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    keyView.frame=CGRectMake(20, 20, self.view.frame.size.width-40, self.view.frame.size.height-40);
    
    
    keyButton.frame=CGRectMake(self.view.frame.size.width-80, 20, 60, 30);
    
    
    if(rootViewController!=nil)
        [self.rootViewController upDateUI];
    mapView.frame=CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height-_footerView.frame.size.height);
    _footerView.frame = CGRectMake(0.0, self.view.frame.size.height-44, self.view.frame.size.width, _footerView.frame.size.height);
    [self animateFooterView:YES];
}



#pragma marks- data connection delegates

-(void)sortArry:(NSMutableArray *)arry{
	NSString *sortingStr=@"map_order";
    NSSortDescriptor *lastNameSorter = [[NSSortDescriptor alloc] initWithKey:sortingStr ascending:YES];
    [arry sortUsingDescriptors:[NSArray arrayWithObject:lastNameSorter]];
    
}


-(void)interNetConnectionError{
    
}
-(void)urlConnectionError:(NSError*)error{
    
}

-(void)viewWillDisappear:(BOOL)animated{
    // if(mapView!=nil){
    //    [mapView removeAnnotations:[mapView annotations]];
    // }
    //[locationManager stopUpdatingLocation];
    
    
    if(keyView!=nil)
        [keyView removeFromSuperview];
    
    if(popView!=nil)
        [popView dismissPopoverAnimated:YES];
    
    
    
    
    if(loadView != nil)
    {
        [self removeLoadingView];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(callServicePage) object:nil];
    
    
    
    [[CPConnectionManager sharedConnectionManager] closeAllConnections];
    
    
    CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
    if(!isQRCodeScan)
        appDelegate.isRootViewController=NO;
}



#pragma mark - UISplitViewControllerDelegate -
- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    
    barButtonItem.title = NSLocalizedString(@"Menu", @"Menu");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    //self.masterPopoverController = nil;
}

@end
