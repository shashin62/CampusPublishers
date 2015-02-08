//
//  CPAnalytics.h
//  CampusPublishersDEV
//
//  Created by August on 9/16/14.
//
//

#import <Foundation/Foundation.h>

@interface CPAnalytics: NSObject {
@private
    
    NSString *_analyticsid;
    NSString *_id;
    NSDictionary *dictInfo;
}

@property (nonatomic, strong) NSString *analyticsid;
@property (nonatomic, strong) NSString *id;
@property(nonatomic, strong) NSDictionary *dictionary;

@end
