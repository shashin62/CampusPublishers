//
//  PikerContrller.h
//  PikerSample
//
//  Created by v2solutions on 10/01/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

#import "CPDataManger.h"
#import "CPConnectionManager.h"
#import "CPRequest.h"
#import "CpTourGuideIPhone.h"
@interface PikerContrller : UIViewController<UITableViewDataSource,CPConnectionDelegate,UITableViewDelegate,UIPopoverControllerDelegate>
{
    UIView *keyView;
    UIBarButtonItem *closeButton;
    UIButton *keyButton;
    UITableView *tableView;
    NSMutableArray *categoryArray;
    UIPopoverController *popView;
    NSMutableDictionary *customImagesDict;
    NSMutableDictionary *pinImagesDict;

}


@property(nonatomic,retain)RootViewController *rootViewController;
@property(nonatomic,retain)CpTourGuideIPhone *tourGuideIPhone;

@property(nonatomic,assign)id target;
@property(nonatomic,assign)SEL action;
-(void)closeButtonAction:(UIButton*)button;
//-(void)keyButtonAction:(UIButton*)button;
-(void)createPikcerUI;
-(void)createCellUI:(UITableViewCell*)cell forIndexPath:(NSIndexPath*)indexPath;
-(void)upDateCell:(UITableViewCell*)cell forIndexPath:(NSIndexPath*)indexPath;

@end
