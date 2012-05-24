//
//  BookReaderViewController.m
//  BookReader
//
//  Created by mac on 3/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BookReaderViewController.h"
#import "ListBookViewController.h"
#import "JSON.h"
#import "Book.h"
#import "FlurryAnalytics.h"
#import "UncaughtExceptionHandler.h"
#import "BookReaderAppDelegate.h"
#import "SearchViewController.h"

@implementation BookReaderViewController

@synthesize data = _data;
@synthesize responseData = _responseData;
@synthesize booksData = _booksData;

@synthesize facebook = _facebook;

@synthesize sendIDConnection = _sendIDConnection;

@synthesize getOwnBooksConnection = _getOwnBooksConnection;

@synthesize arrOwnBooks = _arrOwnBooks;

@synthesize spinner = _spinner;

@synthesize loadingView = _loadingView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - UIAlerView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex]) {
        [_facebook logout];
    }
}


#pragma mark - Connection

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSLog(@"connectionDidFinishLoading");
    
    [_loadingView setHidden:YES];
    
    if (connection == self.sendIDConnection) {
        NSLog(@"SEND ID");
        NSString *strData = [[[NSString alloc] initWithData:self.responseData encoding:NSASCIIStringEncoding] autorelease];
        NSLog(@"data = %@", strData);
        
        
        NSDictionary *jsonData = [strData JSONValue];
        NSString *strResult = [jsonData objectForKey:@"success"];
        NSLog(@"%@", strResult);
        if ([strResult intValue] != 0) {
            NSLog(@"Add User ID to database successfully");
        }
        else {
            NSLog(@"User ID is existed on database");
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *fbUserId = [defaults valueForKey:@"FBUserId"];
            
            NSString *urlGetOwnBook = [NSString stringWithFormat:@"%@%@", URL_GET_LIST_DOWNLOADED_BOOK, fbUserId];
            NSLog(@"urlGetOwnBook = %@", urlGetOwnBook);
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlGetOwnBook] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:REQUEST_TIME_OUT];
            
            self.getOwnBooksConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        }
        
        //self.sendIDConnection = nil;
    }
    else if (connection == self.getOwnBooksConnection) {
        NSLog(@"GET BOOK");
        NSString *strData = [[[NSString alloc] initWithData:self.booksData encoding:NSASCIIStringEncoding] autorelease];
        NSLog(@"ownbook = %@", strData);
        
        if ([[strData JSONValue] isKindOfClass:[NSMutableArray class]]) {
            NSLog(@"result is ARRAY");
            self.arrOwnBooks = [strData JSONValue];
            NSLog(@"num ownbook = %i", [self.arrOwnBooks count]);
        }
        else {
            NSLog(@"result is NOT ARRAY");
            self.arrOwnBooks = [[NSMutableArray alloc] initWithObjects:nil];
        }
        //[strData release];
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"connectionDidReceiveResponse");
    if (connection == self.sendIDConnection) {
        NSLog(@"SEND ID");
        self.responseData = [[[NSMutableData alloc] init] autorelease];
    }
	else if (connection == self.getOwnBooksConnection){
        NSLog(@"DOWNLOAD BOOK");
        self.booksData = [[[NSMutableData alloc] init] autorelease];
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSLog(@"connectionDidReceiveData");
    
    if (connection == self.sendIDConnection) {
        NSLog(@"SEND ID");
        [self.responseData appendData:data];
        
        NSString *str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"data = %@", str);
        [str release];
    }
    else if (connection == self.getOwnBooksConnection) {
        NSLog(@"DOWNLOAD BOOK");
        [self.booksData appendData:data];
        NSString *str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"own books = %@", str);
        [str release];
    }
	
	//resultField.text = str;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"fail with error!!");
    [_loadingView setHidden:YES];
    
    if (connection == self.sendIDConnection) {
        NSLog(@"SEND ID");
        self.sendIDConnection = nil;
    }
    else if (connection == self.getOwnBooksConnection) {
        NSLog(@"DOWNLOAD BOOK");
        self.getOwnBooksConnection = nil;
    }
}


#pragma mark - Button Category
- (void)btnCategoryIsPressed:(id)sender
{
    /*
    if ([(UIButton *)sender tag] == 4) {
        ListBookViewController *listBookView = [[ListBookViewController alloc] initWithNibName:@"ListBookViewController" bundle:nil];
        UINavigationController *listBookNavigationView = [[UINavigationController alloc] initWithRootViewController:listBookView];
        [listBookView release];
        
        [listBookNavigationView setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self presentModalViewController:listBookNavigationView animated:YES];
    }
     */
    
    NSLog(@"sender tag = %i", [(UIButton *)sender tag]);
    
    /*
    NSArray *categories = [self.data objectForKey:@"Categories"];
    
    NSInteger idCt = 0;
    for (idCt = 0; idCt < [categories count]; idCt++) {
        NSInteger idCat = [[[categories objectAtIndex:idCt] objectForKey:@"idCat"] intValue];
        NSLog(@"idCat = %i", idCat);
        if (idCat == [(UIButton *)sender tag]) {
            break;
        }
    }
    */

    /*
    NSString *url = [NSString stringWithFormat:@"%@%i",URL_GET_BOOKS_OF_CATEGORY, [(UIButton *)sender tag]];
    NSLog(@"url = %@", url);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:  
                             [NSURL URLWithString:url]];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
     */

    /*
    NSDictionary *category = [categories objectAtIndex:idCt];
    NSArray *books = [category objectForKey:@"books"];
    NSLog(@"num book = %i", [books count]);
    
    ListBookViewController *listBookView = [[ListBookViewController alloc] initWithNibName:@"ListBookViewController" bundle:nil];
    [listBookView setBooks:books];
    UINavigationController *listBookNavigationView = [[UINavigationController alloc] initWithRootViewController:listBookView];
    [listBookView release];
    
    [listBookNavigationView setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentModalViewController:listBookNavigationView animated:YES];
    */
    BookReaderAppDelegate *appDelegate = (BookReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.isDownloadOwnBooks = YES;
    //[appDelegate.arrBooks release];
    appDelegate.arrBooks = [[[NSMutableArray alloc] initWithObjects: nil] autorelease];
    
    //NSMutableArray *arrBooks = [[NSMutableArray alloc] initWithObjects: nil];
    ListBookViewController *listBookView = [[ListBookViewController alloc] initWithNibName:@"ListBookViewController" bundle:nil];
    //[listBookView setBooks:arrBooks];
    //[arrBooks release];
    
    [listBookView setIdCategory:[(UIButton *)sender tag]];
    [listBookView setTypeTable:DefaultStoreMode];
    [listBookView setArrOwnEbooks:_arrOwnBooks];
    
    
    UINavigationController *listBookNavigationView = [[UINavigationController alloc] initWithRootViewController:listBookView];
    [listBookView release];
    
    [listBookNavigationView setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentModalViewController:listBookNavigationView animated:YES];
    [listBookNavigationView release];
}

- (void)btnRightIsPressed:(id)sender
{
    NSLog(@"id = %i", [(UIButton *)sender tag]);
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userIDFB = [defaults stringForKey:@"FBUserId"];
    
    
    ListBookViewController *listBookView;
    SearchViewController *searchView;
    UINavigationController *searchNavi;
    
    switch ([(UIButton *)sender tag]) {
        case 1000:
            // Search book
            searchView = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
            searchNavi = [[UINavigationController alloc] initWithRootViewController:searchView];
            [searchView release];
            //[searchView setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
            [searchNavi setNavigationBarHidden:YES];
            [self presentModalViewController:searchNavi animated:YES];
            //[searchView release];
            
            break;
            
        case 1001:
            
            if (userIDFB != nil) {
                //My book
                listBookView = [[ListBookViewController alloc] initWithNibName:@"ListBookViewController" bundle:nil];
                //[listBookView setBooks:arrBooks];
                //[arrBooks release];
                
                //[listBookView setIdCategory:[(UIButton *)sender tag]];
                [listBookView setTypeTable:MyStoreMode];
                [listBookView setArrOwnEbooks:self.arrOwnBooks];
                UINavigationController *listBookNavigationView = [[UINavigationController alloc] initWithRootViewController:listBookView];
                [listBookView release];
                
                [listBookNavigationView setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
                [self presentModalViewController:listBookNavigationView animated:YES];
                [listBookNavigationView release];
            }
            
            break;
            
        case 1002:
            //Sign in
            
            if (self.facebook == nil) {
                _facebook = [[Facebook alloc] initWithAppId:FB_APP_ID andDelegate:self];
            }
            
            if (![self.facebook isSessionValid]) {
                NSArray *permissions = [NSArray arrayWithObjects:@"user_about_me", @"publish_stream", @"publish_actions", nil];
                [self.facebook authorize:permissions];
            }
            else {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *strName = [defaults objectForKey:@"FBFirstName"];
                NSString *strMess = [NSString stringWithFormat:@"You are login as %@. Do you want to Logout?", strName];
                
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: @"Login"
                                      message: strMess
                                      delegate: self
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:@"Logout", nil];
                [alert show];
                [alert release];
            }
            
            break;
            
        default:
            break;
    }
}

#pragma mark - Facebook

- (void)fbSessionInvalidated
{
    
}

- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt
{
    
}

- (void)fbDidLogin {
    NSLog(@"Facebook did login");
    
    [_loadingView setHidden:NO];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[_facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[_facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    [self getUserInfo];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    if (cancelled) {
        NSLog(@"cancel login");
    }
    else {
        NSLog(@"Failed to login");
    }
}

- (void)fbDidLogout
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults removeObjectForKey:@"FBUserId"];
        [defaults removeObjectForKey:@"FBFirstName"];
        [defaults synchronize];
    }    
    [defaults synchronize];
    
    self.arrOwnBooks = [[NSMutableArray alloc] initWithObjects:nil];
}

- (void)getUserInfo
{
    NSLog(@"get user info");
    [self.facebook requestWithGraphPath:@"me" andDelegate:self];
}

#pragma mark -
- (void)request:(FBRequest *)request didLoad:(id)result
{
    NSLog(@"Facebook request didload");
    NSLog(@"Facebook = %@", [result description]);
    
    NSString *idStr = [result objectForKey:@"id"];
    NSLog(@"id = %@", idStr);
    
    NSString *firstName = [result objectForKey:@"first_name"];
    NSLog(@"name = %@", firstName);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:idStr forKey:@"FBUserId"];
    [defaults setObject:firstName forKey:@"FBFirstName"];
    [defaults synchronize];
    
    // send full Name and user id to server
    NSString *urlRequest = [NSString stringWithFormat:@"%@&name=%@&username=%@&password=agile1280&token=%@&login_by=facebook&login_social_id=%@&email=%@@digi-gps.vn", URL_SEND_LOGIN_USER_ID, firstName, idStr, _facebook.accessToken, idStr, idStr]; 
    NSLog(@"url = %@", urlRequest);
    
    NSURLRequest *requestSendID = [NSURLRequest requestWithURL:[NSURL URLWithString:urlRequest] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:REQUEST_TIME_OUT]; //[NSURLRequest requestWithURL:[NSURL URLWithString:urlRequest]];

    //if (_sendIDConnection == nil) {
        _sendIDConnection = [[NSURLConnection alloc] initWithRequest:requestSendID delegate:self];
    //}
}

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"Facebook : receive response");
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Facebook : request didfail, error = %@", [error description]);
}


#pragma mark - Draw screen
- (void)drawScreen
{
    for (UIView *v in self.view.subviews) {
        [v removeFromSuperview];
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    //[UIView setAnimationDidStopSelector:@selector(beginDrawScreen)];
    
    
    // read data.plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]; 
    self.data = [[[NSDictionary alloc] initWithContentsOfFile:path] autorelease];
    NSDictionary *homeUI = [self.data objectForKey:@"HomeUI"];
    
    NSDictionary *UIOrentation;
    // Landscape
    if (self.view.bounds.size.width > self.view.bounds.size.height) {
        NSLog(@"Category landscape");
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
        UIOrentation = [homeUI objectForKey:@"Landscape"];
    }
    // Portrait
    else {
        NSLog(@"Category portrait");
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_pt.png"]];
        UIOrentation = [homeUI objectForKey:@"Portrait"];
    }
    
    // draw category button
    NSInteger top = [[UIOrentation objectForKey:@"top"] intValue];
    NSInteger left = [[UIOrentation objectForKey:@"left"] intValue];
    NSInteger space = [[UIOrentation objectForKey:@"space"] intValue];
    NSArray *components = [UIOrentation objectForKey:@"Components"];
    
    NSInteger x = left;
    NSInteger y = top;
    for (NSInteger idRow = 0; idRow < [components count]; idRow++) {
        NSArray *cols = [components objectAtIndex:idRow];
        x = left;
        for (NSInteger idCol = 0; idCol < [cols count]; idCol++) {
            NSDictionary *col = [cols objectAtIndex:idCol];
            NSInteger tagCat = [[col objectForKey:@"idCat"] intValue];
            NSString *imgCat = [col objectForKey:@"imageCat"];
            
            UIImage *img = [UIImage imageNamed:imgCat];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(x, y, img.size.width, img.size.height)];
            [btn setImage:img forState:UIControlStateNormal];
            [btn setTag:tagCat];
            [btn addTarget:self action:@selector(btnCategoryIsPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:btn];
            
            x += img.size.width + space;
            if (idCol == [cols count] - 1) {
                y += img.size.height + space;
            }
        }
    }
    
    // draw right button
    NSArray *buttons = [UIOrentation objectForKey:@"Buttons"];
    NSInteger idTagBtn = 1000;
    for (NSInteger idBtn = 0; idBtn < [buttons count]; idBtn++) {
        NSDictionary *dicBtn = [buttons objectAtIndex:idBtn];
        
        NSInteger topBtn = [[dicBtn objectForKey:@"top"] intValue];
        NSInteger leftBtn = [[dicBtn objectForKey:@"left"] intValue];
        NSString *imgName = [dicBtn objectForKey:@"imageBtn"];
        
        UIImage *imgBtn = [UIImage imageNamed:imgName];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [btn setTag:idTagBtn + idBtn];
        [btn addTarget:self action:@selector(btnRightIsPressed:) forControlEvents:UIControlEventTouchUpInside];
        [btn setFrame:CGRectMake(leftBtn, topBtn, imgBtn.size.width, imgBtn.size.height)];
        [btn setImage:imgBtn forState:UIControlStateNormal];
        
        [self.view addSubview:btn];
    }
    
    
    // create spinner
    
    
    
    _loadingView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 40, self.view.frame.size.height / 2 - 40, 100, 80)];
    [_loadingView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.9]];
    _loadingView.layer.cornerRadius = 15;
    [_loadingView setHidden:YES];
    
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.spinner setFrame:CGRectMake(_loadingView.frame.size.width / 2 - 20, _loadingView.frame.size.height / 2 - 20, 40, 40)];
    [self.spinner setHidesWhenStopped:YES];
    [self.spinner startAnimating];
    
    [_loadingView addSubview:_spinner];
    [_spinner release];
    
    [self.view addSubview:_loadingView];
    [_loadingView release];
    
    
    
    [UIView commitAnimations];
    
}


#pragma mark - View lifecycle

- (void)installUncaughtExceptionHandler
{
    #if TARGET_IPHONE_SIMULATOR
    #else
        InstallUncaughtExceptionHandler();
    #endif
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [self performSelector:@selector(installUncaughtExceptionHandler) withObject:nil afterDelay:0];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self drawScreen];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self drawScreen];
}

- (void)dealloc
{
    [_data release];
    _data = nil;
    
    [_facebook release];
    _facebook = nil;
    
    [_responseData release];
    _responseData = nil;
    
    [_sendIDConnection release];
    _sendIDConnection = nil;
    
    [super dealloc];
}

@end
