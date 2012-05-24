//
//  DetailBookWebViewController.m
//  BookReader
//
//  Created by mac on 3/29/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailBookWebViewController.h"

@implementation DetailBookWebViewController

@synthesize webView = _webView;
@synthesize urlView = _urlView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil nameWeb:(NSString *)url
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.urlView = url;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Back Button 
- (void)btnBackWebDetailIsPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top_nosd.png"] forBarMetrics:UIBarMetricsDefault];
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *imgBack = [UIImage imageNamed:@"back_btt.png"];
    [btnBack setFrame:CGRectMake(0, 0, imgBack.size.width, imgBack.size.height)];
    [btnBack setImage:imgBack forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(btnBackWebDetailIsPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *btnItemBack = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    self.navigationItem.leftBarButtonItem = btnItemBack;
    
    //load url
    //Create a URL object.
    NSURL *url = [NSURL URLWithString:self.urlView];
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    //Load the request in the UIWebView.
    [self.webView loadRequest:requestObj];
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
	return YES;
}

@end
