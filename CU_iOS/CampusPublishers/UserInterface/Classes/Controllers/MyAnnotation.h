//
//  PlaceMark.h
//  Miller
//
//  Created by v2solutions on 19/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Place.h"

@interface MyAnnotation : NSObject <MKAnnotation> {
    
	CLLocationCoordinate2D coordinate;
	Place* place;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) Place* place;
@property (nonatomic, assign) int colorCode;

-(id) initWithPlace: (Place*) p;

@end
