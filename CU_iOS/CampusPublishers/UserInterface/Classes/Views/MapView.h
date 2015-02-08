//
//  MapViewController.h
//
//  Created by kadir pekel on 2/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RegexKitLite.h"
#import "Place.h"
#import "PlaceMark.h"

@class MapView;
@protocol MapViewDelegate <NSObject>

@optional
- (void)MapView:(MapView*)mapView didFailLoadingMapView:(NSError*)error;
@end

@interface MapView : UIView<MKMapViewDelegate> {
    MKMapView* mapView;
	UIImageView* routeView;
	
	NSArray* routes;
	
	UIColor* lineColor;

@private
    NSObject <MapViewDelegate> *__unsafe_unretained delegate;
}

@property (nonatomic, strong) UIColor* lineColor;
@property (nonatomic, unsafe_unretained) NSObject <MapViewDelegate>*delegate;

-(void) showRouteFrom: (Place*) f to:(Place*) t;


@end
