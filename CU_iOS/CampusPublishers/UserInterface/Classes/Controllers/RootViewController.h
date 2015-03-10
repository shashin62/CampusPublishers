//
//  CPMAPRootViewController.h
//  GoogleMapWithDirections
//
//  Created by v2solutions on 21/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Place.h"
#import "MyAnnotation.h"
//#import "DataConnection.h"
#import "PointObject.h"
#import "CustomMapItem.h"
#import "CPFooterView.h"
#import "CPDataManger.h"
#import "ZBarReaderViewController.h"
#import "CPConnectionManager.h"
#import "CPRequest.h"
#import "CPQRCodeViewController.h"
#import "CPAddBannerView.h"
#import "CPContent.h"
#import "ScanResultsPage.h"
#import <GoogleMobileAds/GADBannerView.h>
@class LoadingView;
@class DescriptionViewController;

@interface RootViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate,CPFooterViewDelegate,ZBarReaderDelegate,CPConnectionDelegate,NSURLConnectionDelegate,ADBannerViewDelegate,NSURLConnectionDataDelegate,GADBannerViewDelegate>
{
    MKMapView *mapView;
    CLLocationManager *locationManager;
    CLLocation* location;   // current location
    MKPolyline *polyline;
    
    Place* home;
    Place* office;
    MyAnnotation* from ;
	MyAnnotation* to ;
    MyAnnotation *annotationForCurrentLocation;

    NSMutableData *responseData;
    NSMutableString* tempString;
    
    CPFooterView *_footerView;
    BOOL isIPhone;    
    
    BOOL isStatus;
    
    NSURLConnection* connectionURL;
    NSMutableArray *arrayForPoints;
    NSMutableString* polylineString;
  //  NSMutableString* longtitude;
    PointObject* coOrdinate;

     
    NSMutableArray *pathObjectsArray;
    NSMutableArray *annotationsArray;
    int checkPointCount;
    
    NSMutableArray *titleArray;
    NSArray *imageName;
    CustomMapItem *callOutAnnotation;
    NSMutableArray *placeArray;

    NSMutableArray *placeArrayForTourGuide;

    // object for draw path to university
    BOOL isCampusTour;
    
    CPDataManger* dtManager ;

    BOOL isQRCodeScan;
    LoadingView *loadView;
    
    BOOL isInteractionEnabled;
    
    CPAddBannerView *addBaner;
    
    UIImageView *_imgView;
    
    CPContent *qrContent;
    BOOL isGoogleAPI;
    UIActivityIndicatorView* _activityView ;
    
    
    BOOL isSelectedPin;
    BOOL isDeSelectedPin;

    
    int selectedPinIndex;
    NSMutableDictionary *customImagesDict;
    NSString *selectedAnnotaion;
    
    BOOL isPotrait;
    NSMutableArray*categoryIdArray;
    NSMutableArray*categoryObjectArray;

    
    BOOL isDrivingMode;
    BOOL isDirectionSelected;

    GADBannerView *gADBannerView;

}
@property(nonatomic,strong)NSMutableArray*categoryIdArray;
@property(nonatomic,strong)NSMutableArray*categoryObjectArray;
@property(nonatomic,assign)BOOL isDirectionSelected;
@property(nonatomic,assign) BOOL isGoogleAPI;


@property(nonatomic,strong)DescriptionViewController * descriptionViewController;
@property(nonatomic,assign)BOOL isRootView;
@property(nonatomic,assign)BOOL isAtCampus;


@property(nonatomic,strong)CLLocationManager *locationManager;
@property(nonatomic,strong)MKMapView *mapView;
@property(nonatomic,assign)BOOL isRoot;


- (void)getImageAtIndex:(int)index forURL:(NSURL*)url;

-(int)getIndexOfAnnotaionForTitle:(NSString*)title;
- (void)getImageAtIndex:(int)index forURL:(NSURL*)url;
-(Place*)getPlaceObjectForIndex:(NSString*)title;
-(void)chageColor:(UIButton*)button;
-(void)buttonAction:(UIButton*)button;

-(void)imageButtonAction:(UIButton*)button;

-(void)parsingJSONstring;
- (void)removeLoadingView;

-(void)createMapUI;
-(MKPolyline *) drawMapPath;
- (MKPolyline *)polylineWithEncodedString:(NSString *)encodedString ;

-(void)upDateUI;
-(void)dataLoadingFinished:(NSString*)responseString withHttpResponse:(int)statusCode withData:(NSMutableData *)data;
-(void)interNetConnectionError;
-(void)urlConnectionError:(NSError*)error;
-(void)sortArry:(NSMutableArray *)arry;   
-(MKPolyline*)getPolylineOjbect;
- (void)animateFooterView:(BOOL)animated;

- (void)callServicePage;

@end
