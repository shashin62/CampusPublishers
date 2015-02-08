//
//  CPNetworkConstant.h
//  CampusPublishers
//
//  Created by V2Solutions on 26/07/11.
//  Copyright 2011 V2Solutions. All rights reserved.
//
// IPA build

#define	TIME_OUT_INTERVAL       60
#define	HTTP_METHOD_POST        @"POST"
#define	HTTP_METHOD_GET         @"GET"


//#define SERVER_URL          @"http://192.168.30.15:83/api/"         // internal server

//#define SERVER_URL @"http://apps.v2solutions.com:4001/api/"            // External server

//#define SERVER_URL @"http://app.campuspublishers.com:8080/api/"      // Beta server

#define SERVER_URL          @"http://app.campuspublishers.com/api/"      // production

#define AUTH_KEY            @"campuspublisher"
#define SECKET_KEY          @"v2CPApi"
#define CONTENT_TYPE        @"json"

#define REQUEST @"{\"authkey\":\"campuspublisher\",\"secretkey\":\"47f508b6f303bae44cd28ec0ce1b25039956ada7\",\"method\":\"get\",\"content-type\":\"json\"}"

#define COMPRESSION         @"gzip"
//#define COMPRESSION         @"deflate"

typedef enum _CPRequestType
{
	CPRequestTypeNone = -1, 
	CPRequestTypeMenuList,
    CPRequestTypeConfiguration,
	CPRequestTypePage,
    CPRequestTypeImage,
    CPRequestTypeDirection,
    CPRequestTypeTour,
    CPRequestTypeTourPinImage,
    CPRequestTypeTourKeyImage,
    CPRequestTypeTourPath

} CPRequestType;