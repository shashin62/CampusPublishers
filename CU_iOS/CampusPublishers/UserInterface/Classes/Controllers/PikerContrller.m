//
//  PikerContrller.m
//  PikerSample
//
//  Created by v2solutions on 10/01/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "PikerContrller.h"
#import "RootViewController.h"
#import "CPUtility.h"
#import "CPDataManger.h"
#import "CPConfiguration.h"
#import "CPConfigurationColor.h"
#import "CpTourGuideIPhone.h"
@implementation PikerContrller
@synthesize target,action;
@synthesize rootViewController;
@synthesize tourGuideIPhone;
#define IMAGEVIEW 101
#define CELL_LABEL 102

//saved Beta V0.6

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    
    categoryArray=[[NSMutableArray alloc]init];
    
    if(keyView==nil)
        keyView=[[UIView alloc] init];
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        keyView.frame=CGRectMake(20, 10, self.view.frame.size.width-40, self.view.frame.size.height-93);
    else
        keyView.frame=CGRectMake(20, 20, (self.view.frame.size.width-40)/2, (self.view.frame.size.height-40)/2);
    keyView.backgroundColor=[UIColor grayColor];
    //[self.view addSubview:keyView];
    
    
     closeButton=[[UIBarButtonItem alloc]initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:target    action:action];
    self.navigationItem.rightBarButtonItem=closeButton;
    
    self.navigationItem.title=@"Key";
    
    tableView=[[UITableView alloc]initWithFrame:keyView.frame style:UITableViewStylePlain];
   // tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    tableView.frame=CGRectMake(0, 0, 280, 320-44);

    tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    
    tableView.delegate=self;
    tableView.dataSource=self;
    // tableView.backgroundColor=[UIColor greenColor];
    // tableView.rowHeight=TABLE_HEIGHT/(rows);
    [self.view addSubview:tableView ];

   // [self createPikcerUI];

    [super viewDidLoad];
}


//get the image as per index,with the related URL
- (void)getImageAtIndex:(int)index forKey:(NSURL*)url
{
    CPConnectionManager *manager = [CPConnectionManager sharedConnectionManager];    
    CPRequest*request = [[CPRequest alloc] initWithURL:url 
                                       withRequestType:CPRequestTypeTourKeyImage];
    request.identifier=[NSNumber numberWithInt:index];
    
    [manager spawnConnectionWithRequest:request delegate:self];
    request.identifier = [NSNumber numberWithInteger:index];
 
}


-(void)closeButtonAction:(UIButton*)button{
  
    
    
}


-(void)createPikcerUI{
    
   /* 
    UIToolbar *toolBar=[[UIToolbar alloc]init];
    toolBar.frame=CGRectMake(0, 0, keyView.frame.size.width, 44);
    toolBar.barStyle=UIBarStyleBlackTranslucent;
    // UIBarButtonItem *doneButton=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonAction)];
   
    
    UILabel* titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(90,5,140,30)];
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.textAlignment=UITextAlignmentCenter;
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.font=[UIFont boldSystemFontOfSize:16];
    titleLabel.text=@"Key";
    [toolBar addSubview:titleLabel];        
    
    
    UIBarButtonItem *flexbleSpace=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolBar.items=[NSArray arrayWithObjects:closeButton,nil];
    [keyView addSubview:toolBar];
    
    */
    
    
       
    
}



#pragma mark - tableView delegate


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return tourGuideIPhone.categoryObjectArray.count;
}


-(CGFloat)tableView:(UITableView *)tableView1 heightForHeaderInSection:(NSInteger)section{
    return tableView1.rowHeight;
}


-(UIView*)tableView:(UITableView *)tableView1 viewForHeaderInSection:(NSInteger)section{
    
    
    UIView *view=[[UIView alloc]init];;
    view.frame=CGRectMake(0, 0, 280, tableView1.rowHeight);
    view.backgroundColor=[UIColor grayColor];
    
    // Pin label
    UILabel* pinLabel=[[UILabel alloc]initWithFrame:CGRectMake(10,5,130,30)];
    
    pinLabel.frame=CGRectMake(10,5,tableView.rowHeight-5,30);
    ///(10,0,tableView.rowHeight-5,tableView.rowHeight-5)
    pinLabel.backgroundColor=[UIColor clearColor];
    pinLabel.textAlignment=UITextAlignmentCenter;
    pinLabel.textColor=[UIColor blackColor];
    pinLabel.font=[UIFont fontWithName:@"Arial-BoldMT" size:15];
    pinLabel.text=@"Pin";
    
    //textView.font=[UIFont fontWithName:@"Arial" size:15]; --font
    //used to be
    //catagoryLabel.font=[UIFont boldSystemFontOfSize:16];
    
    //catagoryLabel.tag=CELL_LABEL;
    [view addSubview:pinLabel];
    
    
    // catagories label
    UILabel* catagoryLabel=[[UILabel alloc]initWithFrame:CGRectMake(140,5,130,30)];
    
    catagoryLabel.frame=CGRectMake(70,5,205,30);
    
    catagoryLabel.backgroundColor=[UIColor clearColor];
    catagoryLabel.textAlignment=UITextAlignmentCenter;
    catagoryLabel.textColor=[UIColor blackColor];
    catagoryLabel.font=[UIFont fontWithName:@"Arial-BoldMT" size:15]; //--font
    catagoryLabel.text=@"Category";
    
    //catagoryLabel.tag=CELL_LABEL;
    [view addSubview:catagoryLabel];
    
    
    
    return view;
    
}


-(UITableViewCell*)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellId=@"KEY_TABLE";
    UITableViewCell *cell=[tableView1 dequeueReusableCellWithIdentifier:cellId];
    if(cell==nil){
        
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        [self createCellUI:cell forIndexPath:indexPath];

    }
    [self upDateCell:cell forIndexPath:indexPath];
    
    return cell;
}


-(void)createCellUI:(UITableViewCell*)cell forIndexPath:(NSIndexPath*)indexPath{
    // ImageView
    UIImageView* catagoryImageView=[[UIImageView alloc]initWithFrame:CGRectMake(10,5,tableView.rowHeight-5,tableView.rowHeight-10)];
    
    catagoryImageView.backgroundColor=[UIColor clearColor];
    catagoryImageView.tag=IMAGEVIEW;
    [cell addSubview:catagoryImageView];
    
    // catagories label
    UILabel* catagoryLabel=[[UILabel alloc]initWithFrame:CGRectMake(70,5,205,30)];
    catagoryLabel.backgroundColor=[UIColor clearColor];
    catagoryLabel.textAlignment=UITextAlignmentCenter;
    catagoryLabel.textColor=[UIColor blackColor];
    catagoryLabel.font=[UIFont fontWithName:@"Arial-BoldMT" size:15]; //--font
    //catagoryLabel.text=@"Key";
    
    catagoryLabel.tag=CELL_LABEL;
    [cell addSubview:catagoryLabel];
    
    
    
    
    
}



-(void)upDateCell:(UITableViewCell*)cell forIndexPath:(NSIndexPath*)indexPath{
    UIImageView* catagoryImageView=(UIImageView *)[cell viewWithTag:IMAGEVIEW];
    
    UILabel* catagoryLabel=(UILabel*)[cell viewWithTag:CELL_LABEL];
    
    CPMapCategories * category=[tourGuideIPhone.categoryObjectArray objectAtIndex:indexPath.row];
    catagoryLabel.text=category.category_name;
    
    
    UIImage *image=[pinImagesDict objectForKey:category.device_image];
    if(image!=nil){
        catagoryImageView.image=image;
    }
    
    else{
        
        NSString *tempImageName=@"";
        tempImageName=category.device_image;
             
        if(tempImageName.length>0){
             
            
            CPDataManger*  dtManager = [CPDataManger sharedDataManager];

            
            NSString *imageUrl=[NSString stringWithFormat:@"%@/iphone/%@/%@",dtManager.configuration.imagePath,[CPUtility deviceDensity],tempImageName];                 

         
            [self getImageAtIndex:indexPath.row forKey:[NSURL URLWithString:imageUrl]];
        }
        
    }
}
-(void)viewWillAppear:(BOOL)animated{
  CPDataManger*  dtManager = [CPDataManger sharedDataManager];

    self.navigationController.navigationBar.tintColor =  dtManager.configuration.color.header;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)CPConnection:(CPConnection*)CPConnection didReceiveResponse:(id)response
{
   
   
    
      
    NSData *_data = [(NSDictionary*)response valueForKey:@"data"];
    NSString *responseString=[[NSString alloc]initWithData:_data encoding:NSUTF8StringEncoding];
    
    
    //NSLog(@"responseString: %@",responseString);
    
    
    
     if(CPConnection.request.type == CPRequestTypeTourKeyImage)
    {
        
        //NSLog(@"CPConnection.request.identifier: %@",CPConnection.request.identifier);
        
        int tag=[CPConnection.request.identifier intValue];
        
        if(tag<tourGuideIPhone.categoryObjectArray.count){
            
            UITableViewCell *cell=(UITableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tag inSection:0]];
            UIImageView* catagoryImageView=(UIImageView *)[cell viewWithTag:IMAGEVIEW];
            CPMapCategories * category=[tourGuideIPhone.categoryObjectArray objectAtIndex:tag];
            
            [pinImagesDict setObject:[UIImage imageWithData:_data] forKey:category.device_image];
            
            catagoryImageView.image=[UIImage imageWithData:_data];
            
        }
        
        
        return;
    }
}
    - (void)CPConnection:(CPConnection*)CPConnection didFailWithError:(NSError*)error
    {
    }


@end
