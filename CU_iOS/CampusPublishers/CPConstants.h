//
//  TNConstants.h
//  TableNow
//
//  Created by V2Solutions on 28/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//#define IPAD_ADMOB_ID @"ca-app-pub-7903757883844902/2102658984"
//#define IPHONE_ADMOB_ID @"ca-app-pub-7903757883844902/2102658984"

#define VISITED_PATH_COLOR @"#ff0000"

#define DEFAULT_PATH_COLOR @"#008000"
#define BANNER_HEIGHT 50

typedef enum _CPContentType
{
    
    CPContentTypeNone = -1,
    CPContentTypeURL,
    CPContentTypeHTML,
    
}CPContentType;


typedef enum _CPFooterItemType
{
    CPFooterItemTypeDefault = 0,
    CPFooterItemTypeImage,
    CPFooterItemTypeVideo,
    CPFooterItemTypeImagesVideos,
    CPFooterItemShowDirection,
    CPFooterItemTypeSDImage,
    CPFooterItemTypeSDVideos,
    CPFooterItemTypeSDAll,
    CPFooterItemToureGuide,
}CPFooterItemType;

enum
{
    CPTableViewOrientationVertical = 0,
    CPGTableViewOrientationHorizontal,
};
typedef NSUInteger CPTableViewOrientation;


typedef enum _CPDeviceType
{
    CPDeviceTypeNone = 0,
    CPDeviceTypeAndroid = 1,
    CPDeviceTypeiPhone,
    CPDeviceTypeiPad,
    CPDeviceTypeTablet,
    
}CPDeviceType;

