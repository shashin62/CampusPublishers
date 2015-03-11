//
//  CPGalleryViewController.m
//  CampusPublishers
//
//  Created by V2Solutions on 04/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CPGalleryViewController.h"
#import "CPSwipeView.h"
#import "CMPImage.h"
#import "CMPPage.h"
#import "CPContent.h"
#import "CPDataManger.h"
#import "CPVideo.h"
#import "CPConfiguration.h"
#import "CPMenu.h"
#import "AFOpenFlowView.h"
#import "CPAddBannerView.h"
#import "CPConstants.h"
#import "CPPageViewController.h"
#import "CPUtility.h"
#import "CPAppDelegate.h"
@interface CPGalleryViewController (PRIVATE)

- (void)initializeAllMemberData;
- (void)initializeAllUIElement;

- (void)getImageRequest:(NSIndexPath*)indexPath;

@end

@implementation CPGalleryViewController (PRIVATE)

-(void)initializeAllMemberData;
{
    
}


- (void)initializeAllUIElement
{   
    dtManager = [CPDataManger sharedDataManager];

    self.bannerIsVisible = NO;
        
    //get the selected menu item & its related page
    
    //loading logo image of university  
    UIImage *logoImage = [UIImage imageNamed:@"logo.png"];
    UIImageView *logoImageView = [[UIImageView alloc ]initWithImage:logoImage];
    logoImageView.frame = CGRectMake(0.0, 0.0, logoImage.size.width, logoImage.size.height);
    UIBarButtonItem *rightBUtton = [[UIBarButtonItem alloc] initWithCustomView:logoImageView];
    self.navigationItem.rightBarButtonItem = rightBUtton;
    self.navigationController.navigationBar.translucent = NO; //Otherwise gallery elements rendered under nav -Austin
    
    currentIndex = 0;
    
    //setting header title view for gallery view
    headerTitleView = [[CPHeaderTitleView alloc] initWithFrame:CGRectMake(117.0, 5.0, 75.0, 35.0)];
    
    headerTitleView.delegate = self;
    [headerTitleView setTitle:@"0 of 0"];
    headerTitleView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.navigationItem.titleView = headerTitleView;
    
    //customized swipeview for gallery displaying images or videos
    CGRect frame = self.view.frame;
    self.view.backgroundColor =  [UIColor whiteColor];//dtManager.configuration.color.background;
    
//    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//    {
        imgPlaceholder = [UIImage imageNamed:@"ImagePlaceholderTwo.png"];
//    }
//    else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
//    {
//        imgPlaceholder = [UIImage imageNamed:@"ImagePlaceholder.png"];
//    }
    
    //framing of swipview & webview as per current device interface (iPhone/iPad)iamge
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//    {
    CGRect rect = CGRectZero;
//    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//    {
        rect = CGRectMake((frame.size.width - imgPlaceholder.size.width)/2,
                          5.0, 
                          imgPlaceholder.size.width, 
                          imgPlaceholder.size.height);
//    }
//    else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
//    {
//        rect = CGRectMake((frame.size.width - imgPlaceholder.size.width)/2,
//                          5.0*2, 
//                          imgPlaceholder.size.width, 
//                          imgPlaceholder.size.height);
//    }
    
        swipeView = [[CPSwipeView alloc] initWithFrame:rect];
//    swipeView.backgroundColor = [UIColor redColor];
        swipeView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:swipeView];
//    }
//    else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
//    {    
//       
//        CGRect rect = CGRectZero;
//        rect.size.width = imgPlaceholder.size.width * 2;
//        rect.size.height = imgPlaceholder.size.height * 2;
//        rect.origin.y =  -100.0;        
//        rect.origin.x = (self.view.frame.size.width - rect.size.width) / 2;
//        
//        //added for coverFlow,for iPad
//        openFlow = [[AFOpenFlowView alloc] initWithFrame:rect];
//        openFlow.viewDelegate = self;
//        openFlow.dataSource = self;
//        openFlow.selectedCover = 0;
//        [self.view addSubview:openFlow];
//        
//        if(self.footerType == CPFooterItemTypeVideo)
//        {
//            //---need to add it on each iamge view instead of adding it at center-------
//            videoIcon = [UIButton buttonWithType:UIButtonTypeCustom];
//            videoIcon.hidden = YES;
//            [videoIcon setImage:[UIImage imageNamed:@"playIcon.png"] 
//                       forState:UIControlStateNormal];
//            [videoIcon addTarget:self 
//                          action:@selector(playVideo:) 
//                forControlEvents:UIControlEventTouchUpInside];
//            [videoIcon sizeToFit];
//            
//            CGPoint point = openFlow.center;
//            point.y += 25.0;
//            videoIcon.center = point;
//            [openFlow addSubview:videoIcon];
//        }
//    }
   
    //depending upon device interface,webview is added
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//    {
        webView = [[UIWebView alloc] initWithFrame:CGRectMake((frame.size.width - imgPlaceholder.size.width)/2,
                                                              swipeView.frame.size.height,
                                                              swipeView.frame.size.width, 
                                                              416.0)];
//    }
//    else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
//    {
//        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0,
//                                                  openFlow.frame.size.height, 
//                                                  self.view.frame.size.width, 
//                                                  frame.size.height  - self.navigationController.navigationBar.frame.size.height)];
//    }
    
    [self.view addSubview:webView];
    webView.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
    webView.backgroundColor = dtManager.configuration.color.background;
    
    //depending upon footerType,display the text related to images/videos
    if(self.dataGallary.count > 0)
    {
        if(self.footerType == CPFooterItemTypeImage)
        {
             [webView loadHTMLString:((CMPImage*)([self.dataGallary objectAtIndex:0])).text baseURL:nil];
        }
        else if(self.footerType == CPFooterItemTypeVideo)
        {
             [webView loadHTMLString:((CPVideo*)([self.dataGallary objectAtIndex:0])).text baseURL:nil];
        }
    }
}



//getting Images for Particualr index
- (void)getImageRequest:(NSIndexPath*)indexPath
{
    @autoreleasepool {
    
        CPConnectionManager *manager = [CPConnectionManager sharedConnectionManager];
        
        NSURL *url = nil;
        if (self.footerType == CPFooterItemTypeImage) 
        {
            url = ((CMPImage*)[self.dataGallary objectAtIndex:indexPath.row]).imageUrl;
        }
        else if (self.footerType == CPFooterItemTypeVideo)
        {
            url = ((CPVideo*)[self.dataGallary objectAtIndex:indexPath.row]).imageUrl;
        }
        

        
        CPRequest*request = [[CPRequest alloc] initWithURL:url 
                                           withRequestType:CPRequestTypeImage];
        [manager spawnConnectionWithRequest:request delegate:self];
        request.identifier = [NSNumber numberWithInteger:indexPath.row];
    }
}

@end

@implementation CPGalleryViewController
@synthesize footerType = _footerType;
@synthesize bannerIsVisible;
@synthesize dataGallary = _dataGallary;

#pragma mark - init/dealloc -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) 
    {

    }
    return self;
}


#pragma mark -Memory Management -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
}
- (void)viewDidUnload
{
    [super viewDidUnload]; 
   }

#pragma mark - View lifecycle -
// This is where subclasses should create their custom view hierarchy if they aren't using a nib. Should never be called directly.
- (void)loadView
{
    [super loadView];
    
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    view.autoresizesSubviews = YES;
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.view = view;
    
    [self initializeAllMemberData];
    [self initializeAllUIElement];
    
    //swipview basic configuration as per requirement
    swipeView.delegate = self;
    swipeView.dataSource = self;
    swipeView.pagingEnabled = YES;
    [headerTitleView.previous setEnabled:NO];
    swipeView.tableViewOrientation = CPGTableViewOrientationHorizontal;
    [swipeView setShowsVerticalScrollIndicator:NO];
    
     loadImagesOperationQueue = [[NSOperationQueue alloc] init];
    
    _footerView = [CPFooterView footerViewWithToolBarType:CPFooterItemTypeDefault];
    _footerView.tag = CPFooterItemTypeDefault;//---------default FooterType is Scan------
    _footerView.delegate = self;
    _footerView.frame = CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, _footerView.frame.size.height);

    [self.view addSubview:_footerView];
    bgBannerView=[[UIView alloc]init];
    bgBannerView.backgroundColor=[UIColor whiteColor];
    bgBannerView.frame=CGRectMake(0, self.view.frame.size.height-(BANNER_HEIGHT+44), self.view.frame.size.width, BANNER_HEIGHT);
    [self.view addSubview:bgBannerView];
    [self showBannarView];
   // swipeView.backgroundColor=[UIColor greenColor];
 //   webView.backgroundColor=[UIColor blueColor];

}


#pragma marks  - admob delegates
-(void)showBannarView{
    gADBannerView = [CPAddBannerView sharedGADBannerView];
    gADBannerView.frame = CGRectMake(0.0, self.view.frame.size.height , _footerView.frame.size.width, _footerView.frame.size.height);
    
   
        gADBannerView.adSize = kGADAdSizeBanner;
    
    gADBannerView.center =CGPointMake(self.view.center.x, gADBannerView.center.y);
    
    gADBannerView.delegate = self;
    [gADBannerView setRootViewController:self];
    [self.view addSubview:gADBannerView];
    GADRequest *r = [[GADRequest alloc] init];
//    r.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, nil]; // testDevices -Austin
    [gADBannerView loadRequest:r];
}

-(void)reloadAdd{
    GADRequest *r = [[GADRequest alloc] init];
//    r.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, nil]; // testDevices -Austin
    [gADBannerView loadRequest:r];
}


-(void)adViewDidReceiveAd:(GADBannerView *)view{
    view.frame = CGRectMake(0.0, self.view.frame.size.height - (_footerView.frame.size.height+BANNER_HEIGHT), _footerView.frame.size.width, view.frame.size.height);
    CGRect rect=webView.frame;
    rect.size.height = self.view.frame.size.height - (BANNER_HEIGHT +  _footerView.frame.size.height + swipeView.frame.size.height);
    webView.frame=rect;
}

-(void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error{
    //GADBannerView *adBanner = [CPAddBannerView sharedAddBannerView].adBanner;
    view.frame = CGRectMake(0.0, self.view.frame.size.height , _footerView.frame.size.width, _footerView.frame.size.height);
    CGRect rect=webView.frame;
    rect.size.height = self.view.frame.size.height - ( _footerView.frame.size.height + swipeView.frame.size.height+BANNER_HEIGHT);
    webView.frame=rect;
}
-(void)adViewWillDismissScreen:(GADBannerView *)adView{
}
// Called when the view is about to made visible. Default does nothing
-(void) viewWillAppear:(BOOL)animated
{
    [self reloadAdd];
    //NSLog(@"(self.view.frame): %@", NSStringFromCGRect(self.view.frame));

    CPConfiguration *configuration = (CPConfiguration*)dtManager.configuration;
    _footerView.tintColor = configuration.color.footer;
    [self upDateUI];

//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
//    {
//        [openFlow setNumberOfImages:self.dataGallary.count];
//    }
}


-(void)viewDidAppear:(BOOL)animated{
    
    
    currentIndex = [[[swipeView indexPathsForVisibleRows] objectAtIndex:0] row];
    
    NSArray *itemArray = nil;
    if(self.footerType == CPFooterItemTypeImage)
    {
        itemArray = self.dataGallary;
    }
    else if(self.footerType == CPFooterItemTypeVideo)
    {
        itemArray = self.dataGallary;
    }
    
    [headerTitleView setTitle:[NSString stringWithFormat:@"%d of %d", (currentIndex + 1), itemArray.count]];
    [webView loadHTMLString:[[itemArray objectAtIndex:currentIndex] text]
                    baseURL:nil];
    headerTitleView.next.enabled = !(currentIndex == itemArray.count -1);
    headerTitleView.previous.enabled = !(currentIndex == 0);
    [swipeView reloadData];
}

// Called when the view has been fully transitioned onto the screen. Default does nothing
/*- (void)viewDidAppear:(BOOL)animated
{
    [self upDateUI];
}*/

- (void)viewWillDisappear:(BOOL)animated
{
    //[self upDateUI];
 

    [[CPConnectionManager sharedConnectionManager] closeAllConnections];
}

//override if want to support orientations other than default portrait orientation
#pragma mark - UIInterfaceOrientation -
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } 
    [self upDateUI];
    return YES;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return ;
    }
       [self upDateUI];
}


-(void)upDateUI{
    
    CPAppDelegate *appDelegate= (CPAppDelegate*)[UIApplication sharedApplication].delegate;
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
    self.view.frame=CGRectMake(0, 0,  self.interfaceOrientation>2?(appDelegate.window.frame.size.height-320):appDelegate.window.frame.size.width,self.interfaceOrientation>2?(appDelegate.window.frame.size.width-64):(appDelegate.window.frame.size.height-64));
    }
    
    
        CGRect rect = self.view.frame;
        rect.size.height = self.view.frame.size.height - (_footerView.frame.size.height + swipeView.frame.size.height+BANNER_HEIGHT);
        
        //rect.origin.y = openFlow.frame.size.height;
        rect.origin.y = swipeView.frame.size.height;
        webView.frame = rect;
        //NSLog(@"NSStringFromCGRect: %@", NSStringFromCGRect(webView.frame));
        
        
    bgBannerView.frame=CGRectMake(0, self.view.frame.size.height-(BANNER_HEIGHT+44), self.view.frame.size.width, BANNER_HEIGHT);
    
        rect = _footerView.frame;
        rect.origin.y = self.view.frame.size.height - rect.size.height;
        rect.size.width = self.view.frame.size.width;
        rect.size.height = 44.0;
        
        
        _footerView.frame = rect;
    
    currentIndex=0;
    if(currentIndex < self.dataGallary.count)
    {
        [swipeView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndex  inSection:0]
                         atScrollPosition:UITableViewScrollPositionNone
                                 animated:YES];
    }
    
}


   
#pragma mark - UITableViewDelegate -
//customize cell height 
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return imgPlaceholder.size.width;
}

#pragma mark = UITableViewDelegate -
//variable number of rows as per footerview type(images/videos) 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [self.dataGallary count];
}

//customize cell appearance
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.transform = CGAffineTransformMakeRotation(M_PI/2.0);
        
        CGRect rect = CGRectZero;
//        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
//        {
//            rect = CGRectMake(0.0, 0.0, imgPlaceholder.size.width*2, imgPlaceholder.size.height*2);
//        }
//        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//        {
            rect = CGRectMake(0.0, 0.0, imgPlaceholder.size.width, imgPlaceholder.size.height);
//        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
        imageView.userInteractionEnabled = YES;
        imageView.tag = 400400;
        imageView.contentMode = UIViewContentModeScaleAspectFit; 
        [cell.contentView addSubview: imageView];
    }
    
    UIImageView *imageView = (UIImageView*)[cell.contentView viewWithTag:400400];
    imageView.image = imgPlaceholder;
    if(self.footerType == CPFooterItemTypeImage)
    {
        if(((CMPImage*)[self.dataGallary objectAtIndex:indexPath.row]).image == nil) 
        {
            if(imageView.subviews.count == 0)
            {
                UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                [activityView sizeToFit];
                activityView.center = imageView.center;
                [imageView addSubview:activityView];
                [activityView startAnimating];
            }
            
            [self getImageRequest:indexPath];
        } 
        else
        {
            //as soon as images are fetched,load them as images on cell
            if(imageView.subviews.count > 0)
            {
                UIActivityIndicatorView *_activityView = (UIActivityIndicatorView*)[imageView.subviews objectAtIndex:0];
                [_activityView stopAnimating];
                [_activityView removeFromSuperview];
            }
            
            imageView.image = ((CPMenu*)[self.dataGallary objectAtIndex:indexPath.row]).image;
        }
    }
    else if(self.footerType == CPFooterItemTypeVideo)
    {
        if(((CPVideo*)[self.dataGallary objectAtIndex:indexPath.row]).image == nil)
        {
            if(imageView.subviews.count == 0)
            {
                UIActivityIndicatorView *activityView =  [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                [activityView sizeToFit];
                activityView.center = imageView.center;
                [imageView addSubview:activityView];
                [activityView startAnimating];
            }
            
            [self getImageRequest:indexPath];
        }
        else
        {
            //as soon as iamges are fetched,load them as images on cell
            CGPoint center = CGPointZero;
            if(imageView.subviews.count > 0)
            {
                UIView *view = (UIView*)[imageView.subviews objectAtIndex:0];
                center = view.center;
                [view removeFromSuperview];
            }
            
            imageView.image = ((CPMenu*)[self.dataGallary objectAtIndex:indexPath.row]).image;
            
            UIButton *_videoIcon = [UIButton buttonWithType:UIButtonTypeCustom];
            [_videoIcon setImage:[UIImage imageNamed:@"playIcon.png"] 
                       forState:UIControlStateNormal];
            [_videoIcon sizeToFit];
            _videoIcon.center = imageView.center;
            [_videoIcon setTag:indexPath.row];
            _videoIcon.showsTouchWhenHighlighted = YES;
            [_videoIcon addTarget:self 
                          action:@selector(playVideo:) 
                forControlEvents:UIControlEventTouchUpInside];
            [imageView addSubview:_videoIcon];
        }
    }
    return cell;
}

////select/deselect a row
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//}

#pragma mark - UIScorllViewDelegate - 
//when user scrolls images,related actions are performed 
        //such as setting header title as per current index or as per total images count
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if([swipeView indexPathsForVisibleRows].count == 0)
    {
        return;
    }
    
    currentIndex = [[[swipeView indexPathsForVisibleRows] objectAtIndex:0] row];
    
    NSArray *itemArray = nil;
    if(self.footerType == CPFooterItemTypeImage)
    {
        itemArray = self.dataGallary;
    }
    else if(self.footerType == CPFooterItemTypeVideo)
    {
        itemArray = self.dataGallary;
    }
    
    [headerTitleView setTitle:[NSString stringWithFormat:@"%d of %d", (currentIndex + 1), itemArray.count]];
    [webView loadHTMLString:[[itemArray objectAtIndex:currentIndex] text]
                    baseURL:nil];
    headerTitleView.next.enabled = !(currentIndex == itemArray.count -1);
    headerTitleView.previous.enabled = !(currentIndex == 0);      
}

#pragma mark - CPHeaderTitleViewDelegate -
//method called when clicked on next arrow on header title view
- (void)nextItem:(id)sender
{
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//    {
    if([swipeView indexPathsForVisibleRows].count == 0)
        return;
    
        currentIndex = [[[swipeView indexPathsForVisibleRows] objectAtIndex:0] row];
        currentIndex += 1;
        
        if(self.footerType == CPFooterItemTypeImage)
        {
            if(currentIndex < self.dataGallary.count)
            {
                [swipeView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndex  inSection:0]
                                 atScrollPosition:UITableViewScrollPositionNone
                                         animated:YES];
            }
        }
        else if(self.footerType == CPFooterItemTypeVideo)
        {
            if(currentIndex < self.dataGallary.count)
            {
                [swipeView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0]
                                 atScrollPosition:UITableViewScrollPositionNone
                                         animated:YES];
            }
        }
//    }
//    else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
//    {
//        int selectedCover = openFlow.selectedCover;
//        selectedCover += 1;
//        if(selectedCover < self.dataGallary.count)
//        {
//            [self openFlowView:openFlow selectionDidChange:selectedCover];                
//            [openFlow setSelectedCover:selectedCover];
//        }
//    }
}

//method called when clicked on previous arrow on header title view
- (void)previousItem:(id)sender
{
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//    {
        if([swipeView indexPathsForVisibleRows].count == 0)
            return;
        
        currentIndex = [[[swipeView indexPathsForVisibleRows] objectAtIndex:0] row];
        currentIndex -= 1;
        
        if(self.footerType == CPFooterItemTypeImage)
        {
            if(currentIndex >= 0)
            {
                [swipeView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0]
                                 atScrollPosition:UITableViewScrollPositionNone
                                         animated:YES];
                [headerTitleView setTitle:[NSString stringWithFormat:@"%d of %d", (currentIndex + 1), self.dataGallary.count]];
                [webView loadHTMLString:((CMPImage*)([self.dataGallary objectAtIndex:currentIndex])).text baseURL:nil];
                if(currentIndex == 0)
                {
                    [headerTitleView.previous setEnabled:NO];
                }
                CMPImage *_imageGallary =  [self.dataGallary objectAtIndex:currentIndex];
                UITableViewCell *cell = [swipeView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndex
                                                                                            inSection:0]];
                [cell.imageView setImage:_imageGallary.image];
            }
            [headerTitleView.next setEnabled:YES];
        }
        else if(self.footerType == CPFooterItemTypeVideo)
        {
            if(currentIndex >= 0)
            {
                [swipeView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0]
                                 atScrollPosition:UITableViewScrollPositionNone
                                         animated:YES];
                [headerTitleView setTitle:[NSString stringWithFormat:@"%d of %d", (currentIndex + 1), self.dataGallary.count]];
                [webView loadHTMLString:((CPVideo*)([self.dataGallary objectAtIndex:currentIndex])).text baseURL:nil];
                if(currentIndex == 0)
                {
                    [headerTitleView.previous setEnabled:NO];
                }
                CPVideo *_videoGallary =  [self.dataGallary objectAtIndex:currentIndex];
                UITableViewCell *cell = [swipeView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndex
                                                                                            inSection:0]];
                [cell.imageView setImage:_videoGallary.image];
            }
            [headerTitleView.next setEnabled:YES];
        }
//     }
//    else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
//    {
//        int selectedCover = openFlow.selectedCover;
//        selectedCover -= 1;
//        
////        if(self.footerType == CPFooterItemTypeImage)
////        {
//            if(selectedCover >= 0)
//            {
//                [self openFlowView:openFlow selectionDidChange:selectedCover];
//                [openFlow setSelectedCover:selectedCover];
////                [headerTitleView setTitle:[NSString stringWithFormat:@"%d of %d", (selectedCover + 1), self.dataGallary.count]];
////                [webView loadHTMLString:((CPImage*)([self.dataGallary objectAtIndex:selectedCover])).text baseURL:nil];
////                if(selectedCover == 0)
////                {
////                    [headerTitleView.previous setEnabled:NO];
////                }
//            }
////            [headerTitleView.next setEnabled:YES];
////        }
////        else if(self.footerType == CPFooterItemTypeVideo)
////        {
////            if(selectedCover >= 0)
////            {
////                [openFlow setSelectedCover:selectedCover];
////                videoIcon.tag = selectedCover;
////                [headerTitleView setTitle:[NSString stringWithFormat:@"%d of %d", (selectedCover + 1), self.dataGallary.count]];
////                [webView loadHTMLString:((CPVideo*)([self.dataGallary objectAtIndex:selectedCover])).text baseURL:nil];
////                if(selectedCover == 0)
////                {
////                    [headerTitleView.previous setEnabled:NO];
////                }
////            }
////            [headerTitleView.next setEnabled:YES];
////        }
//    }
}

#pragma mark - Other Methods -
//on clicking Play icon for Video,MoviePalyer plays particular Video 
-(void)playVideo:(id)sender
{
    NSURL *_videoUrl = ((CPVideo*)([self.dataGallary objectAtIndex:[sender tag]])).url;
  
   // //NSLog(@"%@",_videoUrl);
    MPMoviePlayerViewController *playerController = [[MPMoviePlayerViewController alloc] initWithContentURL:_videoUrl];
    [[self navigationController] presentMoviePlayerViewControllerAnimated:(MPMoviePlayerViewController *)playerController];
    playerController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [playerController.moviePlayer play];
}


//#pragma mark - AFOpenFlowDelegate -
//- (void)openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index
//{
//    CPImage *cpImage = [self.dataGallary objectAtIndex:index];
//    if(cpImage.image == nil)
//    {
//        // send image request
//        UIImage *image = [UIImage imageNamed:@"ImagePlaceholder.png"];
//        [openFlowView setImage:image forIndex:index];
//        
//        AFItemView *itemView = [openFlowView coverItemForIndex:index];
//        if(itemView != nil)
//        {
//            UIActivityIndicatorView *activityView = (UIActivityIndicatorView *)[itemView viewWithTag:100100];
//            if(activityView == nil)
//            {
//                activityView =  [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//                [activityView setTag:100100];
//                [itemView addSubview:activityView];
//                [activityView release];
//                [activityView startAnimating];
//                
//                [activityView sizeToFit];
//                CGRect rect = activityView.frame;
//                rect.origin.x = (itemView.frame.size.width - rect.size.width) / 2;
//                rect.origin.y = (itemView.frame.size.height - rect.size.height) / 2 - 45.0;
//                activityView.frame = rect;
//            }
//        }
//        
//        if(self.footerType == CPFooterItemTypeVideo)
//        {
//            videoIcon.hidden = YES;
//        }
//        
//        [self getImageRequest:[NSIndexPath indexPathForRow:index inSection:0]];
//    }
//    else
//    {
//        if(self.footerType == CPFooterItemTypeVideo)
//        {
//            videoIcon.hidden = NO;
//        }
//        
//        [openFlowView setImage:cpImage.image 
//                      forIndex:index];
//    }
//    
//    if(self.footerType == CPFooterItemTypeVideo)
//    {
//        videoIcon.tag = index;
//    }
//    
//    [headerTitleView setTitle:[NSString stringWithFormat:@"%d of %d", (index + 1), self.dataGallary.count]];
//    [webView loadHTMLString:[[self.dataGallary objectAtIndex:index] text]
//                    baseURL:nil];
//    headerTitleView.next.enabled = !(index == self.dataGallary.count -1);
//    headerTitleView.previous.enabled = !(index == 0); 
//}
//
//#pragma mark - AFOpenFlowViewDataSource -
////if needed request for particular image
//- (void)openFlowView:(AFOpenFlowView *)openFlowView requestImageForIndex:(int)index
//{
//    CPImage *cpImage = [self.dataGallary objectAtIndex:index];
//    if(cpImage.image == nil)
//    {
//        // send image request
//        UIImage *image = [UIImage imageNamed:@"ImagePlaceholder.png"];
//        [openFlowView setImage:image forIndex:index];
//        if(index == 0)
//        {
//            AFItemView *itemView = [openFlowView coverItemForIndex:index];
//            if(itemView != nil)
//            {
//                UIActivityIndicatorView *activityView = (UIActivityIndicatorView *)[itemView viewWithTag:100100];
//                if(activityView == nil)
//                {
//                    activityView =  [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//                    [activityView setTag:100100];
//                    [itemView addSubview:activityView];
//                    [activityView release];
//                    [activityView startAnimating];
//                    
//                    [activityView sizeToFit];
//                    CGRect rect = activityView.frame;
//                    rect.origin.x = (itemView.frame.size.width - rect.size.width) / 2;
//                    rect.origin.y = (itemView.frame.size.height - rect.size.height) / 2 - 45.0;
//                    activityView.frame = rect;
//                }
//            }
//            
//            if(self.footerType == CPFooterItemTypeVideo)
//            {
//                videoIcon.hidden = YES;
//                videoIcon.tag = 0;
//            }
//            
//            [self getImageRequest:[NSIndexPath indexPathForRow:index inSection:0]];
//        }
//    }
//    else
//    {
//        [openFlowView setImage:cpImage.image 
//                      forIndex:index];
//        
//        if(self.footerType == CPFooterItemTypeVideo)
//        {
//            videoIcon.hidden = NO;
//        }
//    }
//}
//
////load default image for coverflow,if image data not found from server
//- (UIImage *)defaultImage
//{
//    return [UIImage imageNamed:@"ImagePlaceholder.png"];
//}

#pragma mark - ADBannerViewDelegate -
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if(banner == [[CPAddBannerView sharedAddBannerView] adBannerView])
    {
        [UIView beginAnimations:@"animateAdBannerOn" 
                        context:NULL];
        [UIView setAnimationDuration:0.0];
        
        // set the banner origin visible
        CGRect rect = banner.frame;
        rect.origin.y = self.view.frame.size.height - rect.size.height;
        banner.frame = rect;
        
        // set table view size to occupy full screen
        rect = webView.frame;
        
//        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//        {
            rect.size.height = self.view.frame.size.height - (banner.frame.size.height + _footerView.frame.size.height+ swipeView.frame.size.height);
//        }
//        else
//        {
//            rect.size.height = self.view.frame.size.height - (banner.frame.size.height + _footerView.frame.size.height+ openFlow.frame.size.height);
//        
//        }
            rect.origin.x = 0.0;
            rect.size.width = self.view.frame.size.width;
            webView.frame = rect;
            
            rect = _footerView.frame;
            rect.origin.y = self.view.frame.size.height - rect.size.height -banner.frame.size.height;
            _footerView.frame = rect;
            [UIView commitAnimations];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if(banner == [[CPAddBannerView sharedAddBannerView] adBannerView])
    {
        [UIView beginAnimations:@"animateAdBannerOn" 
                        context:NULL];
        [UIView setAnimationDuration:0.0];
        
        CGRect rect =  webView.frame;
        
//        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//        {
            rect.size.height = self.view.frame.size.height - (_footerView.frame.size.height + swipeView.frame.size.height);
//        }
//        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
//        {
//            rect.size.height = self.view.frame.size.height - (_footerView.frame.size.height + openFlow.frame.size.height);
//        }
            
        rect.origin.x = 0.0;
        rect.size.width = self.view.frame.size.width;
            webView.frame = rect;
            
            // set the banner origin.y to out of bound
            rect = banner.frame;
            rect.origin.y = self.view.frame.size.height + rect.size.height;
            banner.frame = rect;
            
            rect = _footerView.frame;
            rect.origin.y = self.view.frame.size.height - rect.size.height;
            _footerView.frame = rect;
            [UIView commitAnimations];
    }
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    BOOL shouldExecuteAction = YES;
    
    if (!willLeave && shouldExecuteAction)
    {
        // stop all interactive processes in the app
        // [video pause];
        // [audio pause];
    }
    return shouldExecuteAction;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner  
{
    // resume everything you've stopped
    // [video resume];
    // [audio resume];
}

#pragma mark - CPConnectionDelegate -
- (void)CPConnection:(CPConnection*)CPConnection didReceiveResponse:(id)response
{    
    CPRequestType _type = CPConnection.request.type;
    if(_type == CPRequestTypeImage)
    {
        NSData *_data = [(NSDictionary*)response valueForKey:@"data"];
        int index = [CPConnection.request.identifier intValue];
        UIImage *image = [UIImage imageWithData:_data];
        ((CPMenu*)[self.dataGallary objectAtIndex:index]).image = image;
//        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//        {
            [swipeView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index 
                                                                                          inSection:0]] 
                             withRowAnimation:UITableViewRowAnimationNone];
//        }
//        else 
//        {
//            [openFlow setImage:image forIndex:index];
//            AFItemView *itemView = [openFlow coverItemForIndex:index];
//            UIActivityIndicatorView *activityView = (UIActivityIndicatorView *)[itemView viewWithTag:100100];
//            if(activityView != nil)
//            {
//                [activityView removeFromSuperview];
//            }
//            
//            if(self.footerType == CPFooterItemTypeVideo)
//            {
//                videoIcon.hidden = NO;
//            }
//        }
    }
  
    
    currentIndex = [[[swipeView indexPathsForVisibleRows] objectAtIndex:0] row];
    
    NSArray *itemArray = nil;
    if(self.footerType == CPFooterItemTypeImage)
    {
        itemArray = self.dataGallary;
    }
    else if(self.footerType == CPFooterItemTypeVideo)
    {
        itemArray = self.dataGallary;
    }
    
    [headerTitleView setTitle:[NSString stringWithFormat:@"%d of %d", (currentIndex + 1), itemArray.count]];
    [webView loadHTMLString:[[itemArray objectAtIndex:currentIndex] text]
                    baseURL:nil];
    headerTitleView.next.enabled = !(currentIndex == itemArray.count -1);
    headerTitleView.previous.enabled = !(currentIndex == 0);
    [swipeView reloadData];
}

- (void)CPConnection:(CPConnection*)CPConnection didFailWithError:(NSError*)error
{
    CPRequestType _type = CPConnection.request.type;
    if(_type == CPRequestTypeImage)
    {
        int index = [CPConnection.request.identifier intValue];
//        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//        {
            UITableViewCell *cell = [swipeView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index
                                                                                                 inSection:0]];
            if(cell.imageView.subviews.count > 0)
            {
                UIActivityIndicatorView *_activityView = (UIActivityIndicatorView*)[cell.imageView.subviews objectAtIndex:0];
                [_activityView stopAnimating];
                [_activityView removeFromSuperview];
            }
//        }
//        else 
//        {
//            AFItemView *itemView = [openFlow coverItemForIndex:index];
//            UIActivityIndicatorView *activityView = (UIActivityIndicatorView *)[itemView viewWithTag:100100];
//            if(activityView != nil)
//            {
//                [activityView removeFromSuperview];
//            }
//            
//            if(self.footerType == CPFooterItemTypeVideo)
//            {
//                videoIcon.hidden = NO;
//            }
//        }
     }
    else
    {
        NSString *message = nil;
        if(error.code == 403)
        {
            message = @"The operation could not be completed this time. Please check your network connection and try again.";
        }
        else if(error.code == 202)
        {
            message = @"Data not found!!!";
        }
        else
        {
            message = error.localizedDescription;
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"UMD" 
                                                        message:message
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];	
    }
}

#pragma mark - CPFooterViewDelegate -
- (void)footerView:(CPFooterView*)footerView didClickItemWithType:(CPFooterItemType)type
{
    if(type == CPFooterItemTypeDefault)
    {
        ZBarReaderViewController *reader = [ZBarReaderViewController new];
        reader.readerDelegate = self;
        
        reader.readerView.torchMode = 0;
        
        ZBarImageScanner *scanner = reader.scanner;
        // TODO: (optional) additional reader configuration here
        
        // EXAMPLE: disable rarely used I2/5 to improve performance
        [scanner setSymbology: ZBAR_I25
                       config: ZBAR_CFG_ENABLE
                           to: 0];
        
        // present and release the controller
        [self presentModalViewController: reader
                                animated: YES];
    }

}

#pragma mark - UIImagePickerControllerDelegate -
- (void) imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    CPAppDelegate *appDelegate= (CPAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate upDateViewFramewithPicker:reader toReplaceView:self.view];
    
	// ADD: get the decode results
	id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
	ZBarSymbol *symbol = nil;
	NSString *hiddenData = nil;
	for(symbol in results)
		hiddenData=[NSString stringWithString:symbol.data];
    
    NSURL *url = [NSURL URLWithString:hiddenData];
    if ([[[url scheme] lowercaseString] isEqualToString:@"http"]) 
    {
        CPContent *qrContent = [[CPContent alloc] init];
        qrContent.type = CPContentTypeURL;
        qrContent.text = hiddenData;
        CPPageViewController *_pageViewController = [[CPPageViewController alloc] initWithNibName:nil bundle:nil];
        _pageViewController.qrContent = qrContent;
        _pageViewController.title = @"Results";
        [self.navigationController pushViewController:_pageViewController animated:NO];
//        [reader dismissModalViewControllerAnimated: YES];
        [reader dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        CPContent *qrContent = [[CPContent alloc] init];
        qrContent.type = CPContentTypeHTML;
        qrContent.text = hiddenData;
        CPPageViewController *_pageViewController = [[CPPageViewController alloc] initWithNibName:nil bundle:nil];
        _pageViewController.qrContent = qrContent;
        _pageViewController.title = @"Results";
//        [reader dismissModalViewControllerAnimated: YES];
        [reader dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController pushViewController:_pageViewController animated:NO];
    }

}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    CPAppDelegate *appDelegate= (CPAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate upDateViewFramewithPicker:picker toReplaceView:self.view];
//    [picker dismissModalViewControllerAnimated:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
