//
//  RootViewController.m
//  GoogleMapWithDirections
//
//  Created by vector on 21/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "ViewController.h"
#import "RootViewController.h"
#import "PointObject.h"
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

@implementation RootViewController
{
    UIActivityIndicatorView* _activityView ;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        
        locationManager=[[CLLocationManager alloc]init];
        locationManager.delegate=self;
        locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        locationManager.distanceFilter=kCLLocationAccuracyNearestTenMeters;;
        [locationManager startUpdatingLocation];
		

        // Custom initialization
    }
    return self;
}


- (void)footerView:(CPFooterView*)footerView didClickItemWithType:(CPFooterItemType)type{
    isQRCodeScan=NO;

    
    if(type==CPFooterItemToureGuide){
  
        
        ViewController * mapViewController = [[[ViewController alloc] initWithNibName:nil bundle:nil] autorelease];
        [self.navigationController pushViewController:mapViewController animated:YES];

        
        
        /*
        UIAlertView *alert=[[[UIAlertView alloc]initWithTitle:@"hi" message:@"ur at campus" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil] autorelease];
        [alert show];
         */
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
            [reader release];
        }
}



-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
    
    location=[[CLLocation alloc]initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude]; 
    
    if(isCampusTour==YES)
    {
        if(checkPointCount+1<pathObjectsArray.count){
            
            Place *currentPlace=[pathObjectsArray objectAtIndex:checkPointCount+1];
            
            CLLocation *destinationLocation=[[CLLocation alloc]initWithLatitude:currentPlace.latitude longitude:currentPlace.longitude]; 
            
            CLLocationDistance distance=[location distanceFromLocation:destinationLocation];
            [destinationLocation release];
            NSLog(@"distance: %f",distance);
            
            if(distance <=30){
                NSLog(@"checkPointCount: %d",checkPointCount);
                
                MyAnnotation *annotation1=[annotationsArray objectAtIndex:checkPointCount];
                if(annotation1!=nil)
                    [mapView removeAnnotation:annotation1];
                annotation1.colorCode=3;
                [mapView addAnnotation:annotation1];
                
                
                checkPointCount++;
                MyAnnotation *annotation2;
                if(checkPointCount<annotationsArray.count)
                {
                    annotation2=[annotationsArray objectAtIndex:checkPointCount];
                    if(annotation2!=nil)
                        [mapView removeAnnotation:annotation2];
                    annotation2.colorCode=1;
                    [mapView addAnnotation:annotation2];
                }
                
            }
        }
        
    }
    
    else{
        CLLocation *destinationLocation=[[CLLocation alloc]initWithLatitude:office.latitude longitude:office.longitude]; 
        CLLocationDistance distance=[location distanceFromLocation:destinationLocation];

        
       if(distance<=30) {
            NSLog(@"checkPointCount: %d",checkPointCount);
            
           // start point
            MyAnnotation *annotation1=from;
            if(annotation1!=nil)
                [mapView removeAnnotation:annotation1];
            annotation1.colorCode=3;
            [mapView addAnnotation:annotation1];
            
            
            MyAnnotation *annotation2=to;
                           if(annotation2!=nil)
                    [mapView removeAnnotation:annotation2];
                annotation2.colorCode=1;
                [mapView addAnnotation:annotation2];
           
           
           NSArray *array=_footerView.items;
           if(array.count>=6){
               UIBarButtonItem *button=[array objectAtIndex:5];
               button.enabled=YES;
           }
            
        }
        
    }
        if(annotationForCurrentLocation!=nil){
            [mapView removeAnnotation:annotationForCurrentLocation];
            annotationForCurrentLocation=nil;
        }
    
    if(annotationForCurrentLocation==nil){
        annotationForCurrentLocation=[[[MyAnnotation alloc]init] autorelease];
        annotationForCurrentLocation.place=[[[Place alloc]init] autorelease];
    }
    annotationForCurrentLocation.place.name=@"current position";
    
    [mapView addAnnotation:annotationForCurrentLocation];
    annotationForCurrentLocation.place.latitude=newLocation.coordinate.latitude;
    annotationForCurrentLocation.place.longitude=newLocation.coordinate.longitude;
    annotationForCurrentLocation.coordinate=newLocation.coordinate;
    
    
    
    [mapView setCenterCoordinate:newLocation.coordinate animated:YES];
    
}

- (MKPolyline *)getPolylineOjbect{
    MKMapPoint *coords = calloc(placeArray.count, sizeof(CLLocationCoordinate2D));
    
    
       int count=0;
    
    for (Place *item in placeArray) {
        
        CLLocationCoordinate2D coord;
        coord = CLLocationCoordinate2DMake(item.latitude, item.longitude);
        NSLog(@"%f %f %d" ,item.latitude, item.longitude,count);
        
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
        NSLog(@"%f",deltaLat);
        
        shift = 0;
        res = 0;
        
        do {
            byte = bytes[idx++] - 0x3F;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLon = ((res & 1) ? ~(res >> 1) : (res >> 1));
        longitude += deltaLon;
        
        NSLog(@"%f",deltaLon);
        
        NSLog(@"%f %f",latitude,longitude);
        
        
        float finalLat = latitude * 1E-5;
        float finalLon = longitude * 1E-5;
        
        NSLog(@"%f %f",finalLat,finalLon);
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
        
        NSLog(@"%d %d %d",repeatCount,coordIdx,count);
        
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
       
        NSLog(@"%f %f",latitude, longitude);

        
        CLLocationCoordinate2D coord=CLLocationCoordinate2DMake(latitude, longitude);
        coords[i] = coord;
    
    }*/
    
    
    for(int i=0,j=0;i<arrayForPoints.count;i++,j++){
        
        PointObject *temp=[ arrayForPoints objectAtIndex:i];
        CLLocationDegrees latitude = [temp.latitude doubleValue];
        CLLocationDegrees longitude=[temp.longitude doubleValue];
        
        NSLog(@"%f %f",latitude, longitude);
        
            
        CLLocationCoordinate2D coord=CLLocationCoordinate2DMake(latitude, longitude);
        coords[j] = coord;
        
    }
    
         
    
    
     MKPolyline *polyline1 = [MKPolyline polylineWithCoordinates:coords count:arrayForPoints.count];
    
    free(coords);
    
    return polyline1;
}





- (void)didReceiveMemoryWarning
{
    [self releaseObjects ];
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

-(void)viewWillAppear:(BOOL)animated{
    isQRCodeScan=NO;

    CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.isRootViewController=YES;

     _footerView.frame = CGRectMake(0.0, self.view.frame.size.height-44, self.view.frame.size.width, _footerView.frame.size.height);  
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    
    
    
    
    
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
    
    home = [[Place alloc] init] ;
	home.name = @"From";
	home.description = @"Nagarjuna circle";
	home.latitude=17.425789;//panjagutta
	home.longitude=78.448883;
	
    //18.457115 , 79.446479
    //18.507049 , 79.422564
	
    office = [[Place alloc] init] ;
	office.name = @"To";
	office.description = @"bus - stop";
	office.latitude = 17.426603;//Khairathabad
	office.longitude = 78.451103;
    
    
        
    [self createMapUI];
      
    [super viewDidLoad];
}


-(void)createMapUI{
    
    
    
    mapView = [[[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height-_footerView.frame.size.height)] autorelease];
    mapView.showsUserLocation = YES;
    mapView.zoomEnabled=YES;
    MKCoordinateRegion region;
    region.center.latitude     = home.latitude;
    region.center.longitude    = home.longitude;
    
    region.span.latitudeDelta  = 0.001;
    region.span.longitudeDelta = 0.001;
    [mapView setRegion:region animated:YES];
    mapView.delegate=self;
    [self.view addSubview:mapView];
    
    
    
    _footerView = [CPFooterView footerViewWithToolBarType:CPFooterItemToureGuide];
    _footerView.tag = CPFooterItemTypeDefault;//---------default FooterType is Scan------
    _footerView.delegate = self;
    _footerView.frame = CGRectMake(0.0, self.view.frame.size.height-113, self.view.frame.size.width, _footerView.frame.size.height);  
    
    
    
    NSArray *array=_footerView.items;
    if(array.count>=6){
    UIBarButtonItem *button=[array objectAtIndex:5];
        button.enabled=YES;
    }
    CPConfiguration *configuration = (CPConfiguration*)dtManager.configuration;
    _footerView.tintColor = configuration.color.footer;
    [self.view addSubview:_footerView];

    
    
    // adding annotations
    
    from = [[[MyAnnotation alloc] initWithPlace:home] autorelease];
    from.colorCode=1;
    [mapView addAnnotation:from];

	to = [[[MyAnnotation alloc] initWithPlace:office] autorelease];
    to.colorCode=2;

	[mapView addAnnotation:to];
    
   
    /*

    Place *p1 = [[Place alloc] init]  ;
	p1.name = @"NC";
	p1.description = @"odela";
	p1.latitude=17.425789;//panjagutta
	p1.longitude=78.448883;
    
    [pathObjectsArray addObject:p1];
          
    MyAnnotation *A1=[[[MyAnnotation alloc] initWithPlace:p1] autorelease];
    A1.colorCode=2;
    [annotationsArray addObject:A1];

    [mapView addAnnotation:A1];
    [p1 release];
   // [A1 release];

    
    CustomMapItem *item = [[[CustomMapItem alloc] init] autorelease];
    item.place = @"NC";
    item.imageName = @"melt.png";
   // item.latitude = [NSNumber numberWithDouble:17.425968];
   // item.longitude = [NSNumber numberWithDouble:78.449049];
    //[self.mapAnnotations insertObject:item atIndex:kTeaGardenAnnotationIndex];

  //  [mapView addAnnotation:item];
    
    
    
    
    Place *p2 = [[Place alloc] init] ;
	p2.name = @"MM";
	p2.description = @"odela";
	p2.latitude=17.426043;//panjagutta
	p2.longitude=78.449294;
    [pathObjectsArray addObject:p2];
   
    
    
    MyAnnotation *A2=[[[MyAnnotation alloc] initWithPlace:p2] autorelease];
    A2.colorCode=1;
    [annotationsArray addObject:A2];
    [mapView addAnnotation:A2];
    [p2 release];

    
    Place *p3 = [[Place alloc] init] ;
	p3.name = @"UPL";
	p3.description = @"odela";
	p3.latitude=17.426104;//panjagutta
	p3.longitude=78.449548;
    [pathObjectsArray addObject:p3];
  
    
    MyAnnotation *A3=[[[MyAnnotation alloc] initWithPlace:p3] autorelease];
    A3.colorCode=2;
     [annotationsArray addObject:A3];
    [mapView addAnnotation:A3];
    [p3 release];

    
    Place *p4 = [[Place alloc] init] ;
	p4.name = @"AS";
	p4.description = @"odela";
	p4.latitude=17.426306;//panjagutta
	p4.longitude=78.450173;
    [pathObjectsArray addObject:p4];
    
    
    MyAnnotation *A4=[[[MyAnnotation alloc] initWithPlace:p4] autorelease];
    A4.colorCode=2;
    [annotationsArray addObject:A4];
    [mapView addAnnotation:A4];
    [p4 release];
    
    
    
    Place *p5 = [[Place alloc] init] ;
	p5.name = @"ICICI";
	p5.description = @"odela";
	p5.latitude=17.426478;//panjagutta
	p5.longitude=78.450659;
    [pathObjectsArray addObject:p5];
  
    MyAnnotation *A5=[[[MyAnnotation alloc] initWithPlace:p5] autorelease];
    A5.colorCode=2;
     [annotationsArray addObject:A5];
    [mapView addAnnotation:A5];
    [p5 release];
    
    
    Place *p6 = [[Place alloc] init] ;
	p6.name = @"AB";
	p6.description = @"odela";
	p6.latitude=17.425876;//panjagutta
	p6.longitude=78.450173;
    //[pathObjectsArray addObject:p6];
      
    
    MyAnnotation *A6=[[[MyAnnotation alloc] initWithPlace:p6] autorelease];
    A6.colorCode=2;
  //   [annotationsArray addObject:A6];
  //  [mapView addAnnotation:A6];
    [p6 release];
    
    
    Place *p7 = [[Place alloc] init] ;
	p7.name = @"BS";
	p7.description = @"odela";
	p7.latitude=17.426606;//panjagutta
	p7.longitude=78.451085;
    [pathObjectsArray addObject:p7];
      
    MyAnnotation *A7=[[[MyAnnotation alloc] initWithPlace:p7] autorelease];
    A7.colorCode=2;
     [annotationsArray addObject:A7];
    [mapView addAnnotation:A7];
    [p7 release];

    
    Place *p8 = [[Place alloc] init] ;
	p8.name = @"BA";
	p8.description = @"odela";
	p8.latitude=17.426982;//panjagutta
	p8.longitude=78.451075;
        [pathObjectsArray addObject:p8];
      
    MyAnnotation *A8=[[[MyAnnotation alloc] initWithPlace:p8] autorelease];
    A8.colorCode=2;
     [annotationsArray    addObject:A8];
    [mapView addAnnotation:A8];
    [p8 release];


    
    Place *p9 = [[Place alloc] init] ;
	p9.name = @"TC";
	p9.description = @"odela";
	p9.latitude=17.426992;//panjagutta
	p9.longitude=78.450755;
        [pathObjectsArray addObject:p9];
     
    MyAnnotation *A9=[[[MyAnnotation alloc] initWithPlace:p9] autorelease];
    A9.colorCode=2;
      [annotationsArray addObject:A9];
    [mapView addAnnotation:A9];
    [p9 release];

    
    
    Place *p10 = [[Place alloc] init] ;
	p10.name = @"CP";
	p10.description = @"odela";
	p10.latitude=17.426718;//panjagutta
	p10.longitude=78.450098;
        [pathObjectsArray addObject:p10];
       
    MyAnnotation *A10=[[[MyAnnotation alloc] initWithPlace:p10] autorelease];
    A10.colorCode=2;
    [annotationsArray addObject:A10];
    [mapView addAnnotation:A10];
    [p10 release];
    
    
    
    Place *p11 = [[Place alloc] init] ;
	p11.name = @"CP1";
	p11.description = @"odela";
	p11.latitude=17.427489;//panjagutta
	p11.longitude=78.450873;
     //   [pathObjectsArray addObject:p11];
          MyAnnotation *A11=[[[MyAnnotation alloc] initWithPlace:p11] autorelease];
    A11.colorCode=2;
   // [annotationsArray addObject:A11];

   // [mapView addAnnotation:A11];
    [p11 release];
    

    Place *p12 = [[Place alloc] init] ;
	p12.name = @"MP1";
	p12.description = @"odela";
	p12.latitude=17.427194;//panjagutta
	p12.longitude=78.450270;
        [pathObjectsArray addObject:p12];
       
    MyAnnotation *A12=[[[MyAnnotation alloc] initWithPlace:p12] autorelease];
    A12.colorCode=2;
    [annotationsArray addObject:A12];
    [mapView addAnnotation:A12];
    [p12 release];
    
    
    Place *p13 = [[Place alloc] init] ;
	p13.name = @"CP2";
	p13.description = @"odela";
	p13.latitude=17.426851;//panjagutta
	p13.longitude=78.449774;
        [pathObjectsArray addObject:p13];
      
    MyAnnotation *A13=[[[MyAnnotation alloc] initWithPlace:p13] autorelease];
    A13.colorCode=2;
     [annotationsArray addObject:A13];
    [mapView addAnnotation:A13];
    [p13 release];
    
    
    Place *p14 = [[Place alloc] init] ;
	p14.name = @"LP";
	p14.description = @"odela";
	p14.latitude=17.426580;//panjagutta
	p14.longitude=78.449876;
        [pathObjectsArray addObject:p14];
    
    MyAnnotation *A14=[[[MyAnnotation alloc] initWithPlace:p14] autorelease];
    A14.colorCode=2;
    [annotationsArray addObject:A14];

    [mapView addAnnotation:A14];
    [p14 release];
    
    
   // annotationsArray=[[NSMutableArray alloc]initWithArray:[mapView annotations]];

    MyAnnotation *annotation=[annotationsArray objectAtIndex:0];
    NSLog(@"%@",[annotation title]);
    
    
    
    // calling google api
    //18.457115 , 79.446479
    //18.507049 , 79.422564
    //connectionURL=[NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://maps.google.com/maps/api/directions/json?origin=17.425746,78.448872&destination=17.436939,78.443870&sensor=true&mode=driving"]] delegate:self];  
    
  */  
    
  /*  
    connectionURL=[NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://maps.google.com/maps/api/directions/json?origin=17.425746,78.448872&destination=17.436939,78.443870&sensor=true&mode=driving"]] delegate:self];  

    */
  /*
    DataConnection *dataConnection=[[DataConnection alloc]initWithUrlStringFromData:@"http://apps.v2solutions.com:4001/requestapi.php" withJsonString:@"" delegate:self isGet:YES];
    [dataConnection release];
   
   */
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        loadView = [[LoadingView loadingViewInView:self.view withTitle:nil] retain];
        loadView.backgroundColor = [UIColor clearColor];
    }
    else{
   _activityView.center=mapView.center;
    [mapView addSubview:_activityView];
    
    [_activityView startAnimating];
    }   
   // [self callServicePage];
    
    [self performSelector:@selector(callServicePage) withObject:nil afterDelay:3];
}


- (void)callServicePage
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    CPConnectionManager *manager = [CPConnectionManager sharedConnectionManager];
    CPMenu *menu = [[CPDataManger sharedDataManager] selectedMenu];
    
    NSString *strURL = nil;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
      //  strURL = [NSString stringWithFormat:@"%@pages?method=getPage&pageId=%d&deviceId=%d", SERVER_URL,[menu.id intValue] , CPDeviceTypeiPhone];
    }   
    else 
    {
      //  strURL = [NSString stringWithFormat:@"%@pages?method=getPage&pageId=%d&deviceId=%d", SERVER_URL,[menu.id intValue] , CPDeviceTypeiPad];
    }
    
   strURL=@"http://maps.google.com/maps/api/directions/json?origin=17.425746,78.448872&destination=17.436939,78.443870&sensor=true&mode=driving";
    
  //  strURL=@"http://apps.v2solutions.com:4001/requestapi.php";
    // DataConnection *dataConnection=[[DataConnection alloc]initWithUrlStringFromData:@"http://apps.v2solutions.com:4001/requestapi.php" withJsonString:@"" delegate:self isGet:YES];
    
    
    NSURL *urlServer = [NSURL URLWithString:strURL];
    CPRequest*request = [[CPRequest alloc] initWithURL:urlServer withRequestType:CPRequestTypeTour];
    request.identifier = menu.id;
    [manager spawnConnectionWithRequest:request delegate:self];
   // [request release];
    [pool release];
}
#pragma mark - CPConnectionDelegate -


- (void)removeLoadingView
{
	[loadView removeView];
	if(loadView != nil)
	{
		[loadView release];
		loadView = nil;
	}
}
 
 - (void)CPConnection:(CPConnection*)CPConnection didReceiveResponse:(id)response
 {
     NSLog(@"%@",response);

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
     }     
 NSData *_data = [(NSDictionary*)response valueForKey:@"data"];
     NSString *responseString=[[NSString alloc]initWithData:_data encoding:NSUTF8StringEncoding];
     NSLog(@"responseString: %@",responseString);
     responseData=[[NSMutableData alloc]initWithData:_data];
     [self parsingJSONstring];
     
     
     
     
     
     
     

     /*
     
 if(CPConnection.request.type == CPRequestTypeImage)
 {

  }
     
            //NSString *responseString=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
         //  NSLog(@"responseString: %@",responseString);
     int statusCode=0;
         NSLog(@"code:%d",statusCode);
        // if(statusCode==0){
             NSError *error;
             NSArray * tempArray=[NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableContainers error:&error];
             placeArray=[[NSMutableArray alloc]init];
             NSLog(@"%d",tempArray.count);
             
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
                 [place release];
                 
           }
             
             
             [self sortArry:placeArray];
             NSLog(@"%d",placeArray.count);
             
             int cout=0;
             for(Place *place in placeArray){
                 NSLog(@"%d",place.tourmap_id);
                 
                 /* 
                  Place *p1 = [[Place alloc] init]  ;
                  p1.name = @"NC";
                  p1.description = @"odela";
                  p1.latitude=17.425789;//panjagutta
                  p1.longitude=78.448883;
                  */ 
       /*          [pathObjectsArray addObject:place];
                 
                 MyAnnotation *A1=[[[MyAnnotation alloc] initWithPlace:place] autorelease];
                 if(cout==0)
                     A1.colorCode=1;
                 else
                     A1.colorCode=2;
                 [annotationsArray addObject:A1];
                 [mapView addAnnotation:A1];
                 cout++; //this is used for first point is green
             }
             
         */    
             
             /*   polyline=[self getPolylineOjbect];
              [mapView setNeedsLayout];
              [mapView addOverlay:polyline];
              [mapView setClipsToBounds:YES];
              */ 
        // }
         
         
         
     
     
 /*
 UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertTitle", @"")
 message:[parsedObject objectForKey:@"error"]
 delegate:self 
 cancelButtonTitle:NSLocalizedString(@"cancelButton", @"") 
 otherButtonTitles:nil];
 [errorAlert show];
 [errorAlert release];
 */
     
     
 }
 
 - (void)CPConnection:(CPConnection*)CPConnection didFailWithError:(NSError*)error
 {
     
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
     
     }     
     
     
     
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
 [alert release];
 
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
    NSLog(@"responseString: %@",responseString);
    [self parsingJSONstring];
    [responseString release];  
    
    
    
   
}


-(void)parsingJSONstring{
    NSError *error;
    NSDictionary *dictionary=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    
    if(dictionary!=nil){
        NSString *status=[dictionary objectForKey:@"status"];
        if(status!=nil &&[ status isEqualToString:@"OK" ])
            isStatus=TRUE;
        NSLog(@"status: %d",isStatus);
        
        
    
        NSArray *items=[dictionary valueForKey:@"routes"];

       NSDictionary *dict=[items objectAtIndex:0];
     //   NSLog(@"%@",[dict allKeys]);
        NSDictionary *overViewDict= [dict objectForKey:@"overview_polyline"];
        NSString *overview_polylineString=[overViewDict objectForKey:@"points"];

        NSLog(@"%@",overview_polylineString);
        
        if(overview_polylineString!=nil)           {
            polyline=[self polylineWithEncodedString:overview_polylineString];
            
            [mapView setNeedsLayout];
            [mapView addOverlay:polyline];
            [mapView setClipsToBounds:YES];
        }
    }
        
}











#pragma marks - mapview delegates
-(MKAnnotationView *)mapView:(MKMapView *)mapView1 viewForAnnotation:(id<MKAnnotation>)annotation{
    
    NSLog(@"%@",titleArray);
    
     if ([annotation isKindOfClass:[CustomMapItem class]])  
     {
        static NSString *TeaGardenAnnotationIdentifier1 = @"TeaGardenAnnotationIdentifier1";
        
        CustomAnnotationView *annotationView =
        (CustomAnnotationView *)[mapView1 dequeueReusableAnnotationViewWithIdentifier:TeaGardenAnnotationIdentifier1];
        if (annotationView == nil)
        {
            annotationView = [[[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:TeaGardenAnnotationIdentifier1] autorelease];
        }
         annotationView.centerOffset=CGPointMake(-60, -60);
         
         NSLog(@"%@",[annotation subtitle]);
         annotationView.titleLabel.text=[annotation title];
         annotationView.annotationLabel.text=[annotation subtitle];
         annotationView.frame=CGRectMake(0, 0, 200, 70);
        return annotationView;
    }

    
    
    
    MKAnnotationView *pinAnnotationView;
    NSLog(@"%@",[annotation title]);
    pinAnnotationView=(MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"sharath"];
    
    if(pinAnnotationView==nil)
        pinAnnotationView=[[[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"sharath"] autorelease];
    else
        [pinAnnotationView prepareForReuse];
    
    
    if([[annotation title] isEqualToString:@"Current Location"])
    {
       
    }
    else if([[annotation title] isEqualToString:@"From"])
    {
        NSString *name=@"";
        name=[imageName objectAtIndex:from.colorCode];
        pinAnnotationView.image=[UIImage imageNamed:name];

    }
    else if([[annotation title] isEqualToString:@"To"])
    {
        NSString *name=@"";
        name=[imageName objectAtIndex:to.colorCode];
        pinAnnotationView.image=[UIImage imageNamed:name];

    }
    else{
       int tag=[titleArray indexOfObject:[NSString stringWithFormat:@"%@",[annotation title]]];

        
        MyAnnotation *temp;
        NSString *name=@"";
        if(tag<annotationsArray.count){
         temp=[annotationsArray objectAtIndex:tag];
                name=[imageName objectAtIndex:temp.colorCode];

        }
        else{
            name=[imageName objectAtIndex:2];

        }
        
        if([[annotation title] isEqualToString:@"current position"]){
            name=[imageName objectAtIndex:0];
        pinAnnotationView.centerOffset=CGPointMake(0, 0);

        }
        if([[annotation title] isEqualToString:@"call"]){
            name=[imageName objectAtIndex:3];
            pinAnnotationView.centerOffset=CGPointMake(25, -25);
            
        }

        else{
            pinAnnotationView.centerOffset=CGPointMake(-25, -25);

        }
        
    pinAnnotationView.frame=CGRectMake(0, 0, 50, 50);
        
        pinAnnotationView.centerOffset=CGPointMake(25, -25);

    pinAnnotationView.image=[UIImage imageNamed:name];
    [pinAnnotationView setBackgroundColor:[UIColor clearColor]];
    }
    [pinAnnotationView setCanShowCallout:NO];
    return pinAnnotationView;


    /* 
    
    
        if([[annotation title] isEqualToString:@"Current Location"])
    {
        
    }
    else
    {
        
        pinAnnotationView.frame=CGRectMake(0, 0, 20, 20);
        pinAnnotationView.image=[UIImage imageNamed:@"Icon.png"];
        [pinAnnotationView setBackgroundColor:[UIColor redColor]];
        
        
        
    }
    /*  else{
     pinAnnotationView=[[[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"reddy"] autorelease];
     pinAnnotationView.frame=CGRectMake(0, 0, 20, 20);
     pinAnnotationView.image=[UIImage imageNamed:@"Icon.png"];
     [pinAnnotationView setBackgroundColor:[UIColor greenColor]];
     }
     */
  /*  [pinAnnotationView setCanShowCallout:YES];
    [pinAnnotationView calloutOffset];
    return pinAnnotationView;
    */
}


- (void)mapView:(MKMapView *)mapView1 didSelectAnnotationView:(MKAnnotationView *)view {
    
    home = [[Place alloc] init] ;
	home.name = [view.annotation title];
	home.description = [view.annotation subtitle];
    CLLocationCoordinate2D coOrdinate1=[view.annotation coordinate];
    
    NSLog(@"%@",[view.annotation subtitle]);
    
    
	home.latitude=coOrdinate1.latitude;//panjagutta
	home.longitude=coOrdinate1.longitude;
    callOutAnnotation=[[CustomMapItem alloc] init];
 //   callOutAnnotation.coordinate=coOrdinate1;
    callOutAnnotation.latitude=coOrdinate1.latitude;
    callOutAnnotation.longitude=coOrdinate1.longitude;
    callOutAnnotation.place=home;
   // callOutAnnotation.subtitle=
   

    [mapView addAnnotation:callOutAnnotation];
    [home release];
    }

-(void)mapView:(MKMapView *)mapView1 didDeselectAnnotationView:(MKAnnotationView *)view{
    if(callOutAnnotation!=nil)
    [mapView1 removeAnnotation:callOutAnnotation];

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
    MKPolylineView* lineView = [[[MKPolylineView alloc] initWithPolyline:polyline] autorelease];
    
    lineView.fillColor = [UIColor blueColor];
    lineView.strokeColor = [UIColor blueColor];
    lineView.lineWidth = 4;
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
    [alert release];
}

#pragma mark - UIAlertViewdelegate -
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 10001)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
    else{
        mapView.frame=CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height-_footerView.frame.size.height);
        _footerView.frame = CGRectMake(0.0, self.view.frame.size.height-44, self.view.frame.size.width, _footerView.frame.size.height);  
    }
    
    return YES;
}


-(void)upDateUI{
    mapView.frame=CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height-_footerView.frame.size.height);
    _footerView.frame = CGRectMake(0.0, self.view.frame.size.height-44, self.view.frame.size.width, _footerView.frame.size.height);  
}


/*
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    mapView.frame=CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height-_footerView.frame.size.height);
    _footerView.frame = CGRectMake(0.0, self.view.frame.size.height-44, self.view.frame.size.width, _footerView.frame.size.height);  
    [self animateFooterView:YES];
}

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
    
        
        if (mapView!= nil) 
        {
            mapView.frame=rect;     
            mapView.frame=CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height-_footerView.frame.size.height);
              _footerView.frame = CGRectMake(0.0, self.view.frame.size.height-44, self.view.frame.size.width, _footerView.frame.size.height);  
        }
        
                [UIView commitAnimations];
    }
}
*/
#pragma marks- data connection delegates

-(void)dataLoadingFinished:(NSString*)responseString1 withHttpResponse:(int)statusCode  withData:(NSMutableData *)data
{    
    //NSString *responseString=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    //  NSLog(@"responseString: %@",responseString);
    
    NSLog(@"code:%d",statusCode);
    if(statusCode==200){
        NSError *error;
        NSArray * tempArray=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        placeArray=[[NSMutableArray alloc]init];
        NSLog(@"%@",tempArray);
        
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
            [place release];
            
        }
        
        
        [self sortArry:placeArray];
        NSLog(@"%d",placeArray.count);
        
        int cout=0;
        for(Place *place in placeArray){
            NSLog(@"%d",place.tourmap_id);
            
           /* 
            Place *p1 = [[Place alloc] init]  ;
            p1.name = @"NC";
            p1.description = @"odela";
            p1.latitude=17.425789;//panjagutta
            p1.longitude=78.448883;
           */ 
            [pathObjectsArray addObject:place];
            
            MyAnnotation *A1=[[[MyAnnotation alloc] initWithPlace:place] autorelease];
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

-(void)releaseObjects{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        if(loadView != nil)
        {
            [loadView release];
        }
    }
    else{

    if(_activityView!=nil)
        [_activityView release];
    }
    if(placeArray!=nil)
    [placeArray release];
    if(mapView!=nil)
    [mapView release];
    if(locationManager!=nil)
[locationManager release];
    if(location!=nil)
[location  release];   // current location
  
    
    if(home!=nil)
[home release];
    if(office!=nil)
[office release];
    
   
    
    if(responseData!=nil)
[responseData release];
    if(tempString!=nil)
[tempString release];
    
    
    // [connectionURL  release];
    if(arrayForPoints!=nil)
[arrayForPoints release];
    if(polylineString!=nil)
[polylineString release];
    if(coOrdinate!=nil)
[coOrdinate release];
    
    
    if(pathObjectsArray!=nil)
[pathObjectsArray release];
    if(annotationsArray!=nil)
[annotationsArray release];
    
    if(titleArray!=nil)
[titleArray release];
    if(imageName!=nil)
[imageName  release];
    
    
    if(callOutAnnotation!=nil)
[callOutAnnotation  release];
   // [placeArray  release];
   
}

-(void)dealloc{
    [self releaseObjects];
}

-(void)sortArry:(NSMutableArray *)arry{
	
    for(Place *place in arry){
        NSLog(@"%d",place.tourmap_id);
    }
    
	
           
        NSString *sortingStr=@"tourmap_id";
        
        NSSortDescriptor *lastNameSorter = [[NSSortDescriptor alloc] initWithKey:sortingStr ascending:YES];
        
            [arry sortUsingDescriptors:[NSArray arrayWithObject:lastNameSorter]];
            NSLog([NSString stringWithFormat:@"\n\n Sorted array count = %d",[arry count]]);
    [lastNameSorter release];
    
        
}


-(void)interNetConnectionError{
    
}
-(void)urlConnectionError:(NSError*)error{
    
}

-(void)viewWillDisappear:(BOOL)animated{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        if(loadView != nil)
        {
            [loadView release];
        }
    }
    else{
    if(_activityView!=nil)
        [_activityView removeFromSuperview];
        
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(callServicePage) object:nil];
    
    [[CPConnectionManager sharedConnectionManager] closeAllConnections];

    
    CPAppDelegate *appDelegate=(CPAppDelegate*)[UIApplication sharedApplication].delegate;
    if(!isQRCodeScan)
    appDelegate.isRootViewController=NO;
}


@end
