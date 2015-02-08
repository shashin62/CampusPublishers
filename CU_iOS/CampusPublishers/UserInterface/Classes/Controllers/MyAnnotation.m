//
//  PlaceMark.m
//  Miller
//
//  Created by v2solutions on 19/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import "MyAnnotation.h"


@implementation MyAnnotation

@synthesize coordinate;
@synthesize place;
@synthesize colorCode;


-(id) initWithPlace: (Place*) p
{
	self = [super init];
	if (self != nil) {
		coordinate.latitude = p.latitude;
		coordinate.longitude = p.longitude;
		self.place = p;
	}
	return self;
}

- (NSString *)subtitle
{
	return self.place.description;
}
- (NSString *)title
{
	return self.place.name;
}


-(CLLocationCoordinate2D)coordinate{
    return coordinate;
}



@end
