//
//  CPQRCodeViewController.m
//  CampusPublishers
//
//  Created by V2Solutions on 15/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CPQRCodeViewController.h"

@interface CPQRCodeViewController (PRIVATE)

- (void)initializeAllMemberData;
- (void)releaseAllMemberData;
- (void)initializeAllUIElement;
- (void)releaseAllUIElement;
-(void)scan;
@end

@implementation CPQRCodeViewController (PRIVATE)

- (void)initializeAllMemberData
{
    
}

- (void)releaseAllMemberData
{
    
}

- (void)initializeAllUIElement
{
    CGRect frame = CGRectZero;
    frame.origin.x = 20;
    frame.origin.y = 50;
    frame.size.width = 250;
    frame.size.height = 80.0;
    txtView = [[UITextView alloc] initWithFrame:frame];
    txtView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:txtView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect rect = CGRectZero;
    rect.origin.x = 120;
    rect.origin.y = 250;
    rect.size.width = 50;
    rect.size.height = 31.0;
    scanButton = [[UIButton alloc] initWithFrame:rect];
    scanButton.backgroundColor = [UIColor grayColor];
    [scanButton setTitle:@"scan" forState:UIControlStateNormal];
    NSLog(@"scanbutton.frame :%@",NSStringFromCGRect(scanButton.frame));
    [scanButton addTarget:self action:@selector(scan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanButton];
}
- (void)releaseAllUIElement
{
    
}

-(void)scan
{
    NSLog(@"scanning ");
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
	[reader release];
	
	//resultTextView.hidden = NO;
}
@end

@implementation CPQRCodeViewController
@synthesize footerType = _footerType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
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


// Implement loadView to create a view hierarchy programmatically, without using a nib.
//- (void)loadView
//{
//    [self initializeAllMemberData];
//    [self initializeAllUIElement];
//}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeAllUIElement];
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

@end
