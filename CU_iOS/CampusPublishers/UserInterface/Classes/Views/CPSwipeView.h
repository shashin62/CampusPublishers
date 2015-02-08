//
//  CPSwipeView.h
//  Campus Publishers
//
//  custom tableview,used for GalleryView in iPhone

//  Created by V2Solutions on 27/03/12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CPConstants.h"

@interface CPSwipeView : UITableView 
{

@private
    CPTableViewOrientation _tableViewOrientation;
    BOOL _playMode;
}
@property (nonatomic, assign) CPTableViewOrientation tableViewOrientation;
@property (nonatomic, assign) BOOL playMode;

@end
