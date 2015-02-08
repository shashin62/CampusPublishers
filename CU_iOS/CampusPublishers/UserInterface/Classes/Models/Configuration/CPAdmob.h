//
//  CPAdmob.h
//  CampusPublishers
//
//  Created by Austin Bookheimer on 2/13/14.
//
//

#import <Foundation/Foundation.h>

@interface CPAdmob : NSObject {
@private
    
    NSString *_admobid;
    NSString *_id;
    NSDictionary *dictInfo;
}

@property (nonatomic, strong) NSString *admobid;
@property (nonatomic, strong) NSString *id;
@property(nonatomic, strong) NSDictionary *dictionary;

@end
