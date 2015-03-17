//
//  CpTourGuideIPhone.h
//  GoogleMapWithDirections
//
//  Created by v2solutions on 21/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Place.h"
#import "MyAnnotation.h"

#import "CPContent.h"
#import "PointObject.h"
#import "CustomMapItem.h"
#import "CPFooterView.h"
#import "CPDataManger.h"
#import "ZBarReaderViewController.h"
#import "CPConnectionManager.h"
#import "CPRequest.h"

#import <GoogleMobileAds/GADBannerView.h>
#import <iAd/ADBannerView.h>

#import "CPAddBannerView.h"
//#import "GADBannerView.h"

//@class CPAddBannerView;

@class CpTourGuideIPhone;

// saved1


@class DescriptionViewController;

@class RootViewController;
@class LoadingView;
@class CPContent;
//@class DataConnection;connectionProtocolDelegate
@interface CpTourGuideIPhone : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate,CPFooterViewDelegate,ZBarReaderDelegate,CPConnectionDelegate,NSURLConnectionDelegate,ADBannerViewDelegate,NSURLConnectionDataDelegate,UITableViewDelegate,UITableViewDataSource,UIPopoverControllerDelegate,UISplitViewControllerDelegate,GADBannerViewDelegate,UIGestureRecognizerDelegate>
{
    MKMapView *mapView;
    CLLocationManager *locationManager;
    CLLocation* location;   // current location
    MKPolyline *polyline;
    CPContent *qrContent;
    
    Place* home;
    Place* office;
    MyAnnotation* from ;
	MyAnnotation* to ;
    MyAnnotation *annotationForCurrentLocation;
    
    NSMutableString* tempString;
    
    CPFooterView *_footerView;
    BOOL isIPhone;    
    
    BOOL isStatus;
    
    NSURLConnection* connectionURL;
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
    
    BOOL isQRCodeScan;
    LoadingView *loadView;
    
    // object for draw path to university
    BOOL isCampusTour;
    
    CPDataManger* dtManager ;
    
    BOOL isInteractionEnabled;
    NSMutableData *responseData;
    
    int positionIndex;
    MyAnnotation *tempLocation;
    NSMutableDictionary *customImagesDict;
    NSMutableDictionary *pinImagesDict;
    
    UIPopoverController *masterPopoverController;

    NSString *selectedAnnotaion;
    
    BOOL isPotrait;
    BOOL isImageOrVideoView;
    BOOL isFirstTime;

    
    
    
    UIButton *keyButton;
    UIView *keyView;
    UIButton *closeButton1;
    UITableView *tableView;
    NSMutableArray *categoryArray;
    UIPopoverController *popView;
    
    BOOL isGoogleAPI;
    
    
    NSMutableArray*categoryIdArray;
    NSMutableArray*categoryObjectArray;
    NSMutableArray*polylineArray;
    BOOL isVisited;
    
    
    BOOL isTourCompleted;
    
    BOOL isDrivingMode;
    BOOL isDirectionSelected;
    NSString *preTitle;
    GADBannerView *gADBannerView;

}
@property(nonatomic,strong)NSMutableArray*categoryIdArray;
@property(nonatomic,strong)NSMutableArray*categoryObjectArray;
@property(nonatomic,assign)BOOL isTourGuide;
@property(nonatomic,assign)BOOL isViewController;

@property(nonatomic,strong)DescriptionViewController * descriptionViewController;
@property(nonatomic,retain)RootViewController *rootViewController;
@property(nonatomic,strong) NSMutableArray *placeArrayForTourGuide;
@property(nonatomic,strong) NSMutableArray *annotationsArray;
@property(nonatomic,strong)CLLocationManager *locationManager;
@property(nonatomic,strong)MKMapView *mapView;

@property(nonatomic,assign)int checkPointCount;
@property(nonatomic,strong)NSMutableDictionary *customImagesDict;
@property(nonatomic,assign)BOOL isBackButtonHiden;
@property(nonatomic,strong)UIPopoverController *masterPopoverController;
@property(nonatomic,assign)BOOL isDirectionSelected;

@property(nonatomic,assign)int pathLoopCount;
@property(nonatomic,assign)BOOL isPathAdded;
 @property(nonatomic,assign) BOOL isGoogleAPI;

-(void)pathFromUniversity;
-(void)pathFromCurrentPoint:(int)index;
-(void)callPathAPI;

-(void)upDAteCall;
-(void)createPikcerUI;
-(void)createCellUI:(UITableViewCell*)cell forIndexPath:(NSIndexPath*)indexPath;
-(void)upDateCell:(UITableViewCell*)cell forIndexPath:(NSIndexPath*)indexPath;

-(void)closeButtonAction:(UIButton*)button;
-(void)keyButtonAction:(UIButton*)button;
-(void)createPikcerUI;
-(void)keyButtonAction:(UIButton *)button;

- (void)getImageAtIndex:(int)index forPinView:(NSURL*)url;

-(void)buttonAction:(UIButton*)button;
-(void)addPathToFirstPoint;
-(void)imageButtonAction:(UIButton*)button;
-(void)addingPoints;
-(void)upDateUI;
//-(void)parsingJSONstring;


-(void)parsingJSONstring:(int)index;

- (void)removeLoadingView;
-(void)createMapUI;
//-(MKPolyline *) drawMapPath;
- (MKPolyline *)polylineWithEncodedString:(NSString *)encodedString ;
//-(void)dataLoadingFinished:(NSString*)resposeString withHttpResponse:(int)statusCode withData:(NSMutableData*)data;


//-(void)dataLoadingFinished:(NSString*)responseString1 withHttpResponse:(int)statusCode  withData:(NSMutableData *)data;
-(void)interNetConnectionError;
-(void)urlConnectionError:(NSError*)error;
-(void)sortArry:(NSMutableArray *)arry;   
-(MKPolyline*)getPolylineOjbect;
- (void)animateFooterView:(BOOL)animated;
- (void)getImageAtIndex:(int)index forURL:(NSURL*)url;
- (void)getImageAtIndex:(int)index forKey:(NSURL*)url;
- (void)callServicePage;
-(void)backButtonDidPressed:(UIButton*)button;
- (void)animateFooterView:(BOOL)animated;
//-(void)showTourGuideFrom:(Place*)latitude To:(Place*)longtitude;

-(void)showTourGuideFrom:(Place*)point1 To:(Place*)point2 index:(int)indexForOverLay;

@end
