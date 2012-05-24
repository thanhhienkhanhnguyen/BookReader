//
//  InfoBookViewController.m
//  BookReader
//
//  Created by mac on 4/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "InfoBookViewController.h"
#import "JSON.h"
#import "DetailBookViewController.h"
#import "ItemDownload.h"
#import "BookReaderAppDelegate.h"
#import "Facebook.h"
#import "Book.h"

@implementation InfoBookViewController

@synthesize dataBook = _dataBook;
@synthesize dataDownloadBook = _dataDownloadBook;
@synthesize dataSendIdBook = _dataSendIdBook;
@synthesize idBook;
@synthesize page, chapter;
@synthesize bookTitle = _bookTitle;
@synthesize filePath = _filePath;
@synthesize imageBig = _imageBig;
@synthesize description = _description;
@synthesize comments = _comments;
@synthesize author = _author;
@synthesize book = _book;
@synthesize strRating = _strRating;
@synthesize strRatingCount = _strRatingCount;

//@synthesize btnRead;

@synthesize connectionDetailBook = _connectionDetailBook;
@synthesize connectionDownloadBook = _connectionDownloadBook;
@synthesize connectionSendIdBook = _connectionSendIdBook;

@synthesize alertLoading = _alertLoading;
@synthesize loadIndicator = _loadIndicator;

@synthesize isDownloaded = _isDownloaded;
@synthesize isImgLoaded = _isImgLoaded;
@synthesize isLandscape = _isLandscape;
@synthesize isOwnBook = _isOwnBook;

@synthesize progressView = _progressView;

@synthesize fileSize = _fileSize;

@synthesize timer = _timer;

NSInteger modeRequest = 0;
// 0 - Get detail Info
// 1 - Download Book

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isOwnBook = NO;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)btnBackInfoIsPressed:(id)sender
{
    //[_dataBook release];
    //_dataBook = nil;
    
    //self.title = @"";
    
    
    if (_connectionDetailBook != nil) {
        [_connectionDetailBook cancel];
        self.connectionDetailBook = nil;
    }
    
    
    BookReaderAppDelegate *delegate = (BookReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    for (NSInteger idItem = 0; idItem < delegate.arrDownload.count; idItem++) {
        ItemDownload *item = [delegate.arrDownload objectAtIndex:idItem];
        
        NSNumber *resourceLength = [NSNumber numberWithUnsignedInteger:[item.fileData length]];
        
        NSNumber *numProgress = [NSNumber numberWithFloat:[resourceLength floatValue] / [item.fileSize floatValue]];
        
        if ([numProgress floatValue] <= 1.0 && [numProgress floatValue] > 0) {
            [item setIsHide:YES];
        }

    }
    
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Download
- (void)updateProgress:(NSNumber *)num
{
    UIProgressView *progressV = (UIProgressView *)[self.view viewWithTag:100];
    [progressV setProgress:[num floatValue] animated:YES];
    
    NSLog(@"tesstprogress:%f",progressV.progress);
    
}
- (void)checkDownloading
{
    BookReaderAppDelegate *delegate = (BookReaderAppDelegate *)[[UIApplication sharedApplication] delegate];

    // check if book is downloading or not
    NSInteger idItem = 0;
    NSLog(@"arrDownload = %i", [delegate.arrDownload count]);
    NSLog(@"check download file : %@", self.filePath);

    for (idItem = 0; idItem < [delegate.arrDownload count]; idItem++) {
        ItemDownload *itm = [delegate.arrDownload objectAtIndex:idItem];

        NSArray *arrPath = [itm.url componentsSeparatedByString:@"/"];
        NSString *fileName = [arrPath objectAtIndex:[arrPath count] - 1];

        NSArray *arrFPath = [self.filePath componentsSeparatedByString:@"/"];
        NSString *nameFPath = [arrFPath objectAtIndex:[arrFPath count] - 1];
        NSLog(@"filePath = %@ | url = %@", nameFPath, fileName);

        if ([nameFPath isEqualToString:fileName]) {
            break;
        }
    }

    if (idItem < [delegate.arrDownload count] && [delegate.arrDownload count] != 0) {
        NSLog(@"isDownloading");
        ItemDownload *itm = [delegate.arrDownload objectAtIndex:idItem];
        [itm setIsHide:NO];

        UIImage *img = [UIImage imageNamed:@"btnDownloading.png"];
        UIButton *btn = (UIButton *)[self.view viewWithTag:1000];
        [btn setTitle:@"Downloading" forState:UIControlStateDisabled];
        [btn setImage:img forState:UIControlStateNormal];
        [btn setEnabled:NO];

        NSNumber *resourceLength = [NSNumber numberWithUnsignedInteger:[itm.fileData length]];

        NSNumber *numProgress = [NSNumber numberWithFloat:[resourceLength floatValue] / [itm.fileSize floatValue]];
        
        if ([numProgress floatValue] == 1) {
            NSLog(@"File is Downloaded");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadNotification" object:nil userInfo:nil];
        }
        else {
            NSDictionary *dataInfo = [NSDictionary dictionaryWithObject:numProgress forKey:@"numProgress"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadNotification" object:nil userInfo:dataInfo];
        }

        UIProgressView *progressV = (UIProgressView *)[self.view viewWithTag:100];
        [progressV setHidden:NO];
        [progressV setProgress:[resourceLength floatValue] / [itm.fileSize floatValue] animated:YES];
    }
    else {
        NSLog(@"not downloading");
    }
}

- (void)downloadWithURL:(NSString *)urlDownload
{
    NSLog(@"THREAD");
    modeRequest = 1;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:  
                             [NSURL URLWithString:urlDownload]];
    NSURLConnection *test = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!test) {
        NSLog(@"AAAAA");
    }
    BOOL keepLoop = request != nil;
    while (keepLoop && ![[NSThread currentThread] isCancelled]) {
        NSDate *dt = [[NSDate alloc] initWithTimeIntervalSinceNow:1.0];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:dt];
        [dt release];
        NSLog(@"THREAD:%@",urlDownload);
    }
    [test release];
    [pool release];
    NSLog(@"aaaa");
}

#pragma mark - Thread Downloading
- (void)downloadBookWithFilePath:(NSString *)fPath
{
    NSLog(@"start thread download");
    BookReaderAppDelegate *delegate = (BookReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Add new
    ItemDownload *newItem = [[ItemDownload alloc] init];
    [newItem setUrl:fPath];
    [newItem setIsHide:NO];
    [delegate.arrDownload addObject:newItem];
    [newItem release];
    
    modeRequest = 1;
    NSString *urlDownload = [NSString stringWithFormat:@"ftp://%@:%@@%@", USERNAME, PASSWORD, fPath];
    NSLog(@"url = %@", urlDownload);
    NSURLRequest *request = [NSURLRequest requestWithURL:  
                             [NSURL URLWithString:urlDownload]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [connection start];
}


#pragma mark - Read
- (IBAction)btnReadIsPressed:(id)sender
{
    //[(UIButton *)sender setEnabled:NO];
    
    UIProgressView *progressV = (UIProgressView *)[self.view viewWithTag:100];
    UIButton *btnRead = (UIButton *)[self.view viewWithTag:1000];
    
    if ([[[(UIButton *)sender titleLabel] text] isEqualToString:@"DOWNLOAD"]) {
        
        BookReaderAppDelegate *delegate = (BookReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [btnRead setImage:[UIImage imageNamed:@"btnDownloading.png"] forState:UIControlStateNormal];
        
        //[btnRead setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        //[btnRead setTitle:@"Downloading" forState:UIControlStateNormal];
        //[btnRead setImage:[UIImage imageNamed:@"btnDownloading.png"] forState:UIControlStateDisabled];
        [btnRead setEnabled:NO];
        
        [progressV setProgress:0.0];
        [progressV setHidden:NO];
        
        //NSArray *arrPath = [self.filePath componentsSeparatedByString:@"/"];
        //NSString *fileName = [arrPath objectAtIndex:[arrPath count] - 1];
        //NSString *urlDownload = [NSString stringWithFormat:@"ftp://%@:%@@%@", USERNAME, PASSWORD, self.filePath];
        //self.filePath = [NSString stringWithFormat:@"ftp://%@:%@@%@", USERNAME, PASSWORD, self.filePath];
        NSString *urlDownload = [NSString stringWithFormat:@"http://%@", self.filePath];
        NSLog(@"urlDownload = %@", urlDownload);
        
        
        NSInteger idItem = 0;
        for (idItem = 0; idItem < [delegate.arrDownload count]; idItem++ ) {
            ItemDownload *itm = [delegate.arrDownload objectAtIndex:idItem];
            if ([itm.url isEqualToString:self.filePath]) {
                break;
            }
        }
        
        if (idItem == [delegate.arrDownload count]) {
            NSLog(@"not found - new download");
            // Add new
            ItemDownload *newItem = [[ItemDownload alloc] init];
            [newItem setUrl:self.filePath];
            [newItem setIsHide:NO];
            [newItem setIdBook:idBook];
            [delegate.arrDownload addObject:newItem];
            [newItem release];
            
            /*
            modeRequest = 1;
            NSURLRequest *request = [NSURLRequest requestWithURL:  
                                     [NSURL URLWithString:urlDownload]];
            [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
             */
            
            //NSThread *newthread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadWithURL:) object:urlDownload];
            //[newthread start];
            [NSThread detachNewThreadSelector:@selector(downloadWithURL:) toTarget:self withObject:urlDownload];
            
            
            /*
            NSThread *myThread = [[NSThread alloc] initWithTarget:self 
                                                         selector:@selector(downloadBookWithFilePath:) 
                                                           object:self.filePath];
            [myThread start]; */
        }
        else {
            NSLog(@"found - still downloading");
            // Existed - still downloading
            ItemDownload *itm = [delegate.arrDownload objectAtIndex:idItem];
            NSNumber *resourceLength = [NSNumber numberWithUnsignedInteger:[itm.fileData length]];
            //UIProgressView *progressV = (UIProgressView *)[self.view viewWithTag:100];
            [progressV setHidden:NO];
            [progressV setProgress:[resourceLength floatValue] / [itm.fileSize floatValue] animated:YES];
        }
        
        //;NSLog(@"filename = %@", fileName);
        //NSLog(@"filepath = %@", self.filePath);
        
        /*
        ItemDownload *itemDownload = [[ItemDownload alloc] init];
        [itemDownload setUrl:self.filePath];
        
        [delegate.arrDownload addObject:itemDownload];
        [itemDownload release];
        */
        
        NSLog(@"download: arrDownload = %i", [delegate.arrDownload count]);
    }
    else {
        NSArray *arrPath = [self.filePath componentsSeparatedByString:@"/"];
        NSString *fileName = [arrPath objectAtIndex:[arrPath count] - 1];
        NSArray *arrName = [fileName componentsSeparatedByString:@"."];
        NSString *type = [arrName objectAtIndex:[arrName count] - 1];
        NSLog(@"type = %@", type);
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:DIRECTORY_STORE_EBOOK];  
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, fileName];
        
        BOOL isLandScape;
        if (self.view.bounds.size.width > self.view.bounds.size.height) {
            isLandScape = YES;
        }
        else {
            isLandScape = NO;
        }
        
        if ([type isEqualToString:@"pdf"]) {
            DetailBookViewController *detailBookView = [[DetailBookViewController alloc] initWithNibName:@"DetailBookViewController" bundle:nil isLandScape:isLandScape nameDocument:filePath];
            NSLog(@"local file Path = %@", filePath);
            
            [self.navigationController pushViewController:detailBookView animated:YES];
            [detailBookView release];
        }
    }
}

#pragma mark - Draw screen

- (void)drawShelf
{
    NSLog(@"subviews = %i", [self.view.subviews count]);
    for (UIView *v in self.view.subviews) {
        if (v.tag != 101) {
            [v removeFromSuperview];
        }
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self]; 
    
    if (self.view.bounds.size.width > self.view.bounds.size.height || _isLandscape == YES) {
        NSLog(@"Landscape");
        // Add shelf
        UIImage *imgSheftLS = [UIImage imageNamed:@"info_shelf_land.png"];
        UIImageView *imgVShelftLS = [[UIImageView alloc] initWithImage:imgSheftLS];
        [imgVShelftLS setFrame:CGRectMake(0, 247, imgSheftLS.size.width , imgSheftLS.size.height)];
        [self.view addSubview:imgVShelftLS];
        [imgVShelftLS release];
        
        // Add Description
        UIImage *imgDescriptionLS = [UIImage imageNamed:@"info_des_box_land.png"];
        UIImageView *imgVDesLS = [[UIImageView alloc] initWithImage:imgDescriptionLS];
        [imgVDesLS setFrame:CGRectMake(75, 297, imgDescriptionLS.size.width, imgDescriptionLS.size.height)];
        [self.view addSubview:imgVDesLS];
        [imgVDesLS release];
        
        UIWebView *webViewDesc = [[UIWebView alloc] initWithFrame:CGRectMake(75, 297 + 39 + 4, imgDescriptionLS.size.width, imgDescriptionLS.size.height - 39 - 4 - 8)];
        webViewDesc.opaque = NO;
        webViewDesc.backgroundColor = [UIColor clearColor];
        [webViewDesc loadHTMLString:@"<html><body style='color:#FFFFFF;'></body></html>" baseURL:nil];
        [webViewDesc setTag:103];
        [self.view addSubview:webViewDesc];
        [webViewDesc release];
        
        
        // Add Customer
        UIImage *imgCustomerLS = [UIImage imageNamed:@"info_review_box_land.png"];
        UIImageView *imgVCustomerLS = [[UIImageView alloc] initWithImage:imgCustomerLS];
        [imgVCustomerLS setFrame:CGRectMake(516, 297, imgCustomerLS.size.width, imgCustomerLS.size.height)];
        [self.view addSubview:imgVCustomerLS];
        [imgVCustomerLS release];
        
        UIWebView *webViewCus = [[UIWebView alloc] initWithFrame:CGRectMake(516, 297 + 39 + 4, imgCustomerLS.size.width, imgCustomerLS.size.height - 39 - 4 - 8)];
        webViewCus.opaque = NO;
        webViewCus.backgroundColor = [UIColor clearColor];
        [webViewCus loadHTMLString:@"<html><body style='color:#FFFFFF;'></body></html>" baseURL:nil];
        [webViewCus setTag:104];
        [self.view addSubview:webViewCus];
        [webViewCus release];
    }
    else {
        NSLog(@"Portrait");
        // Add shelf
        UIImage *imgSheftPT = [UIImage imageNamed:@"info_shelf.png"];
        UIImageView *imgVShelftPT = [[UIImageView alloc] initWithImage:imgSheftPT];
        [imgVShelftPT setFrame:CGRectMake(0, 262, imgSheftPT.size.width , imgSheftPT.size.height)];
        [self.view addSubview:imgVShelftPT];
        [imgVShelftPT release];
        
        // Add Description
        UIImage *imgDescriptionPT = [UIImage imageNamed:@"info_des_box.png"];
        UIImageView *imgVDesPT = [[UIImageView alloc] initWithImage:imgDescriptionPT];
        [imgVDesPT setFrame:CGRectMake(60, 321, imgDescriptionPT.size.width, imgDescriptionPT.size.height)];
        [self.view addSubview:imgVDesPT];
        [imgVDesPT release];
        
        UIWebView *webViewDesc = [[UIWebView alloc] initWithFrame:CGRectMake(60, 321 + 39 + 4, imgDescriptionPT.size.width, imgDescriptionPT.size.height - 39 - 4 - 8)];
        webViewDesc.opaque = NO;
        webViewDesc.backgroundColor = [UIColor clearColor];
        [webViewDesc loadHTMLString:@"<html><body style='color:#FFFFFF;'></body></html>" baseURL:nil];
        [webViewDesc setTag:103];
        [self.view addSubview:webViewDesc];
        [webViewDesc release];
        
        // Add Customer
        UIImage *imgCustomerPT = [UIImage imageNamed:@"info_review_box.png"];
        UIImageView *imgVCustomerPT = [[UIImageView alloc] initWithImage:imgCustomerPT];
        [imgVCustomerPT setFrame:CGRectMake(60, 537 + 100, imgCustomerPT.size.width, imgCustomerPT.size.height)];
        [self.view addSubview:imgVCustomerPT];
        [imgVCustomerPT release];
        
        UIWebView *webViewCus = [[UIWebView alloc] initWithFrame:CGRectMake(60, 537 + 100 + 39 + 8, imgCustomerPT.size.width, imgCustomerPT.size.height - 39 - 8 - 8)];
        webViewCus.opaque = NO;
        webViewCus.backgroundColor = [UIColor clearColor];
        [webViewCus loadHTMLString:@"<html><body style='color:#FFFFFF;'></body></html>" baseURL:nil];
        [webViewCus setTag:104];
        [self.view addSubview:webViewCus];
        [webViewCus release];
    }
    
    [UIView commitAnimations];
    
}

- (void)drawScreen
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self]; 
    
    
    BookReaderAppDelegate *appDelegate = (BookReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSLog(@"array book = %i", [appDelegate.arrBooks count]);
    NSLog(@"idBook = %i", self.idBook);
    Book *book;
    
    BOOL isFound = NO;
    for (NSInteger idB = 0; idB < appDelegate.arrBooks.count; idB++) {
        book = [appDelegate.arrBooks objectAtIndex:idB];
        if (self.idBook == book.idBook) {
            isFound = YES;
            break;
        }
    }
    
    if (isFound == YES && book.isFilled == NO) {
        NSLog(@"NOT FILL");
        
        self.bookTitle = [self.book objectForKey:@"title"];
        self.page = [[self.book objectForKey:@"page"] intValue];
        self.chapter = [[self.book objectForKey:@"chapter"] intValue];
        self.imageBig = [[self.book objectForKey:@"image_big"] stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
        self.filePath = [[self.book objectForKey:@"file"] stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
        self.description = [self.book objectForKey:@"description"];
        self.comments = [self.book objectForKey:@"comment"];
        NSDictionary *vote = [self.book objectForKey:@"vote"];
        self.strRating = [vote objectForKey:@"rating"];
        self.strRatingCount = [vote objectForKey:@"rating_count"];
        
        NSArray *authors = [self.book objectForKey:@"authors"];
        self.author = @"";
        for (NSInteger idAu = 0; idAu < [authors count]; idAu++) {
            NSDictionary *authr = [authors objectAtIndex:idAu];
            NSString *comma;
            
            if (idAu == 0) {
                comma = @"";
            }
            else {
                comma = @", ";
            }
            self.author = [NSString stringWithFormat:@"%@%@%@", self.author, comma, [authr objectForKey:@"author_name"]];
        }
        
        //NSLog(@"title = %@ | page = %i | chapter = %i | imageBig = %@ | filePath = %@ | description = %@", self.bookTitle, self.page, self.chapter, self.imageBig, self.filePath, self.description);

        
        
        
        book.bookTitle = self.bookTitle;
        book.page = self.page;
        book.chapter = self.chapter;
        book.imageBig = self.imageBig;
        book.filePath = self.filePath;
        book.description = self.description;
        book.comments = self.comments;
        book.strRating = self.strRating;
        book.strRatingCount = self.strRatingCount;
        book.authors = self.author;
        
        book.isFilled = YES;
    }
    else if (isFound == YES && book.isFilled == YES){

        NSLog(@"FILLED");
        self.bookTitle = book.bookTitle;
        self.page = book.page;
        self.chapter = book.chapter;
        self.imageBig = book.imageBig;
        self.filePath = book.filePath;
        self.description = book.description;
        self.comments = book.comments;
        self.strRating = book.strRating;
        self.strRatingCount = book.strRatingCount;
        self.author = book.authors;
    }
    
        
    
    
    // author
    //[self.lbAuthor setText:self.author];
    UILabel *lbAthr = [[UILabel alloc] initWithFrame:CGRectMake(272, 35, 476, 31)];
    if (self.view.bounds.size.width > self.view.bounds.size.height || _isLandscape == YES) {
        [lbAthr setFrame:CGRectMake(272, 35, 476, 31)];
        [lbAthr setFont:[UIFont boldSystemFontOfSize:15]];
    }
    else {
        [lbAthr setFrame:CGRectMake(272, 35, 476, 31)];
        [lbAthr setFont:[UIFont boldSystemFontOfSize:15]];
    }
    [lbAthr setText:self.author];
    [lbAthr setTextColor:[UIColor lightGrayColor]];
    [lbAthr setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:lbAthr];
    [lbAthr release];
    
    
    
    // title
    //[self.lbNameBook setText:self.bookTitle];
    self.title = self.bookTitle;
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(272, 70, 476, 31)];
    if (self.view.bounds.size.width > self.view.bounds.size.height || _isLandscape == YES) {
        [lbTitle setFrame:CGRectMake(272, 70, 476, 31)];
        [lbTitle setFont:[UIFont boldSystemFontOfSize:25]];
    }
    else {
        [lbTitle setFrame:CGRectMake(272, 70, 476, 31)];
        [lbTitle setFont:[UIFont boldSystemFontOfSize:25]];
    }
    [lbTitle setText:self.bookTitle];
    [lbTitle setTextColor:[UIColor whiteColor]];
    [lbTitle setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:lbTitle];
    [lbTitle release];
    
    
    // button
    
    // check file existed or not
    NSArray *arrFilePath = [self.filePath componentsSeparatedByString:@"/"];
    NSString *fileName = [arrFilePath objectAtIndex:[arrFilePath count] - 1];
    
    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [[paths objectAtIndex:0] stringByAppendingPathComponent:DIRECTORY_STORE_EBOOK];
    path = [path stringByAppendingPathComponent:fileName];
    
    NSLog(@"FIND PATH = %@", path);
    NSString *titleBtn = @"";
    NSString *imgName = @"";
    BOOL isBtnEnable = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        
        if (self.isOwnBook) {
            titleBtn = @"DOWNLOAD";
            imgName = @"btnDownloading.png";
            isBtnEnable = NO;
        }
        else {
            titleBtn = @"DOWNLOAD";
            imgName = @"info_down_btn.png";
            isBtnEnable = YES;
        }
        
    }
    else {
        titleBtn = @"READ";
        imgName = @"btnRead.png";
        isBtnEnable = YES;
    }
    
    UIImage *imgBtn = [UIImage imageNamed:imgName];
    UIButton *btnDownload = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDownload setTitle:titleBtn forState:UIControlStateNormal];
    [btnDownload setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [btnDownload setImage:imgBtn forState:UIControlStateNormal];
    [btnDownload setEnabled:isBtnEnable];
    
    if (self.view.bounds.size.width > self.view.bounds.size.height || _isLandscape == YES) {
        [btnDownload setFrame:CGRectMake(272, 204, imgBtn.size.width, imgBtn.size.height)];
    }
    else {
        [btnDownload setFrame:CGRectMake(272, 218, imgBtn.size.width, imgBtn.size.height)];
    }
    [btnDownload addTarget:self action:@selector(btnReadIsPressed:) forControlEvents:UIControlEventTouchUpInside];
    [btnDownload setTag:1000];
    [self.view addSubview:btnDownload];
    
    
    // Progress view
    UIProgressView *tmpProgressV = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    //_progressView = tmpProgressV;
    //[tmpProgressV release];
    
    if (self.view.bounds.size.width > self.view.bounds.size.height || _isLandscape == YES) {
        [tmpProgressV setFrame:CGRectMake(272, 185, imgBtn.size.width, 5)];
    }
    else {
        [tmpProgressV setFrame:CGRectMake(272, 200, imgBtn.size.width, 5)];
    }
    
    [tmpProgressV setTag:100];
    [tmpProgressV setHidden:YES];
    
    [self.view addSubview:tmpProgressV];
    [tmpProgressV release];
    
    
    // rating
    NSInteger rating = [self.strRating intValue];
    NSLog(@"rating = %i", rating);
    UIImage *imgStar = [UIImage imageNamed:@"info_rate.png"];
    UIImage *imgStarHL = [UIImage imageNamed:@"info_rate_02.png"];
    for (NSInteger idSt = 0; idSt < rating; idSt++) {
        UIImageView *imgVStart = [[UIImageView alloc] initWithImage:imgStarHL];
        if (self.view.bounds.size.width > self.view.bounds.size.height || _isLandscape == YES) {
            [imgVStart setFrame:CGRectMake(510 + idSt * imgStarHL.size.width, 228, imgStarHL.size.width, imgStarHL.size.height)];
        }
        else {
            [imgVStart setFrame:CGRectMake(463 + idSt * imgStarHL.size.width, 242, imgStarHL.size.width, imgStarHL.size.height)];
        }
        
        
        [self.view addSubview:imgVStart];
        [imgVStart release];
    }
    
    for (NSInteger idNoSt = rating; idNoSt < 5; idNoSt++) {
        UIImageView *imgVNoStart = [[UIImageView alloc] initWithImage:imgStar];
        if (self.view.bounds.size.width > self.view.bounds.size.height || _isLandscape == YES) {
            [imgVNoStart setFrame:CGRectMake(510 + idNoSt * imgStar.size.width, 228, imgStar.size.width, imgStar.size.height)];
        }
        else {
            [imgVNoStart setFrame:CGRectMake(463 + idNoSt * imgStar.size.width, 242, imgStar.size.width, imgStar.size.height)];
        }
        
        [self.view addSubview:imgVNoStart];
        [imgVNoStart release];
    }
    
    
    // imageView
    
    /*
    NSLog(@"image = %@", self.imageBig);
    
    // get file name
    NSArray *filePaths = [self.imageBig componentsSeparatedByString:@"/"];
    NSString *fileName = [filePaths objectAtIndex:[filePaths count] - 1];
    NSArray *names = [fileName componentsSeparatedByString:@"."];
    NSString *extFile = [names objectAtIndex:[names count] - 1];
    NSString *nameImg = [names objectAtIndex:0];
    
    NSLog(@"length = %i", [self.imageBig length]);
    NSString *sourcePath = [self.imageBig substringToIndex:[self.imageBig length] - [fileName length]];
    NSLog(@"source = %@", sourcePath);
    
    NSString *pathToImg = [NSString stringWithFormat:@"%@%@", sourcePath, nameImg];
    NSLog(@"path = %@", pathToImg);
    NSLog(@"ext = %@", extFile);
    
    //NSString *fileLocation = [[NSBundle mainBundle] pathForResource:pathToImg ofType:extFile];
    //NSLog(@"location = %@", fileLocation);
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:self.imageBig];
    */
    if (self.isImgLoaded == NO) {
        NSURL *urlImg = [NSURL URLWithString:self.imageBig];
        NSData *data = [NSData dataWithContentsOfURL:urlImg];
        
        UIImage *img = [UIImage imageWithData:data];
        UIImageView *imgVBook = [[UIImageView alloc] initWithImage:img];
        
        if (self.view.bounds.size.width > self.view.bounds.size.height || _isLandscape == YES) {
            [imgVBook setFrame:CGRectMake(75, 29, img.size.width, img.size.height)];
        }
        else {
            [imgVBook setFrame:CGRectMake(60, 43, img.size.width, img.size.height)];
        }
        
        [imgVBook setTag:101];
        
        [self.view addSubview:imgVBook];
        [imgVBook release];
    } 
    else {
        UIImageView *imgVBook = (UIImageView *)[self.view viewWithTag:101] ;
        
        //[imgVBook removeFromSuperview];
        
        if (self.view.bounds.size.width > self.view.bounds.size.height || _isLandscape == YES) {
            [imgVBook setFrame:CGRectMake(75, 29, imgVBook.frame.size.width, imgVBook.frame.size.height)];
        }
        else {
            [imgVBook setFrame:CGRectMake(60, 43, imgVBook.frame.size.width, imgVBook.frame.size.height)];
        }
        
        //[self.view addSubview:imgVBook];
        [self.view bringSubviewToFront:imgVBook];
    }

    // instruction
    UIWebView *webVDes = (UIWebView *)[self.view viewWithTag:103];
    [webVDes loadHTMLString:self.description baseURL:nil];
    
    // comment
    UIWebView *webVReview = (UIWebView *)[self.view viewWithTag:104];
    [webVReview loadHTMLString:self.comments baseURL:nil];
    
    
    //[self performSelectorOnMainThread:@selector(setImageBook:) withObject:urlImg waitUntilDone:NO];
    
    //[self.imgBookView setImage:img];
    
    // instruction
    //[self.webViewDescription loadHTMLString:self.description baseURL:nil];
    
    //[self.lbAuthor setHidden:NO];
    //[self.lbNameBook setHidden:NO];
    //[self.lbDescription setHidden:NO];
    //[self.webViewDescription setHidden:NO];
    //[self.btnRead setHidden:NO];
    //[self.imgBookView setHidden:NO];
    
    [UIView commitAnimations];
    
    [_loadIndicator stopAnimating];
    
    [self checkDownloading];
}

#pragma mark - connection
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSLog(@"connectionDidFinishLoading");
    if (connection == self.connectionDetailBook) {
        NSLog(@"GET DETAIL");
        NSString *strData = [[[NSString alloc] initWithData:self.dataBook encoding:NSASCIIStringEncoding] autorelease];
        //NSLog(@"data = %@", strData);
        
        NSArray *jsonData = [strData JSONValue];
        
        self.book = [jsonData objectAtIndex:0];
        
        [self drawScreen];
    }
    else if (connection == self.connectionSendIdBook) {
        NSLog(@"SEND ID BOOK");
        NSString *strData = [[[NSString alloc] initWithData:self.dataSendIdBook encoding:NSASCIIStringEncoding] autorelease];
        NSLog(@"data = %@", strData);
        
        if ([strData isEqualToString:@"true"]) {
            NSLog(@"Add idBook to database successfully");
        }
        else if ([strData isEqualToString:@"false"]) {
            NSLog(@"idBook is existed on database");
        }
        else {
            NSDictionary *jsonData = [strData JSONValue];
            NSString *strResult = [jsonData objectForKey:@"success"];
            if ([strResult intValue] == 0) {
                NSLog(@"Add idBook to database successfully");
            }
            else {
                NSLog(@"idBook is existed on database");
            }
        }
        
    }
    else {
        NSLog(@"DOWNLOAD BOOK");
        BookReaderAppDelegate *delegate = (BookReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSInteger idItem = 0;
        for (idItem = 0; idItem < [delegate.arrDownload count]; idItem++) {
            ItemDownload *itm = [delegate.arrDownload objectAtIndex:idItem];
            if (itm.connection == connection) {
                break;
            }
        }
        
        if (idItem != [delegate.arrDownload count]) {
            ItemDownload *itm = [delegate.arrDownload objectAtIndex:idItem];
            
            NSArray *arrPath = [itm.url componentsSeparatedByString:@"/"];
            NSString *fileName = [arrPath objectAtIndex:[arrPath count] - 1];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:DIRECTORY_STORE_EBOOK];  
            
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, fileName];
            NSLog(@"WRITE TO FILE : %@", filePath);
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
                BOOL isSuccess = [itm.fileData writeToFile:filePath atomically:YES];
                
                if (isSuccess) {
                    [[NSThread currentThread] cancel];
                    NSLog(@"download file [%@] finish", fileName);
                    if (itm.isHide == NO) {
                        NSNumber *numIdBook = [NSNumber numberWithInt:itm.idBook];
                        NSDictionary *dataInfo = [NSDictionary dictionaryWithObject:numIdBook forKey:@"idBook"];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadNotification" object:nil userInfo:dataInfo];
                    }
                    
                    /*
                     [self.btnRead setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
                     [self.btnRead setEnabled:NO];
                     
                     [self.alertLoading dismissWithClickedButtonIndex:0 animated:YES];
                     [_alertLoading release];
                     */
                    
                    //NSArray *arrName = [fileName componentsSeparatedByString:@"."];
                    //NSString *type = [arrName objectAtIndex:[arrName count] - 1];
                    
                    self.isDownloaded = YES;
                    //UIProgressView *progressView = (UIProgressView *)[self.view viewWithTag:100];
                    //[progressView setProgress:1 animated:YES];
                    //[progressView setHidden:YES];
                    
                    //[self.btnRead setTitle:@"READ BOOK" forState:UIControlStateNormal];
                    //[self.btnRead setEnabled:YES];
                    //[self.progressView setHidden:YES];
                    
                    
                    //[delegate.arrDownload removeObjectAtIndex:idItem];
                    //NSLog(@"arr.num = %i", [delegate.arrDownload count]);
                    
                    /*
                     if ([type isEqualToString:@"pdf"]) {
                     DetailBookViewController *detailBookView = [[DetailBookViewController alloc] initWithNibName:@"DetailBookViewController" bundle:nil isLandScape:isLandScape nameDocument:filePath];
                     
                     [self.navigationController pushViewController:detailBookView animated:YES];
                     [detailBookView release];
                     }
                     */
                }
                else {
                    NSLog(@"download file [%@] fail", fileName);
                }

            }
            else {
                NSLog(@"File is existed on memory");
            }
            
        }
        [[NSThread currentThread] cancel];
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"connectionDidReceiveResponse");
    if (connection == self.connectionDetailBook) {
        self.dataBook = [[[NSMutableData alloc] init] autorelease];
    }
    else if (connection == self.connectionSendIdBook) {
        self.dataSendIdBook = [[[NSMutableData alloc] init] autorelease];
    }
	else {
        NSLog(@"start new download");
        BookReaderAppDelegate *delegate = (BookReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
        ItemDownload *newItem = [delegate.arrDownload objectAtIndex:[delegate.arrDownload count] - 1];
        [newItem setConnection:connection];
        [newItem setFileData:[[[NSMutableData alloc] init] autorelease]];
        [newItem setFileSize:[NSNumber numberWithLongLong:[response expectedContentLength]]];
        
        /*
        self.dataDownloadBook = [[NSMutableData alloc] init];
        self.fileSize = [NSNumber numberWithLongLong:[response expectedContentLength]];
         */
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSLog(@"connectionDidReceiveData:%@",[[connection currentRequest] URL]);
    if (connection == self.connectionDetailBook) {
        NSLog(@"DETAIL BOOK");
        [self.dataBook appendData:data];
        //NSString *str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        //NSLog(@"data = %@", str);
    }
    else if (connection == self.connectionSendIdBook) {
        [self.dataSendIdBook appendData:data];
    }
    else {
        NSLog(@"DOWNLOAD BOOK");
        BookReaderAppDelegate *delegate = (BookReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSInteger idItem = 0;
        for (idItem = 0; idItem < [delegate.arrDownload count] ; idItem++) {
            ItemDownload *itm = [delegate.arrDownload objectAtIndex:idItem];
            if (itm.connection == connection) {
                break;
            }
        }
        
        if (idItem != [delegate.arrDownload count]) {
            ItemDownload *itm = [delegate.arrDownload objectAtIndex:idItem];
            [itm.fileData appendData:data];
            
            
            if (itm.isHide == NO) {
                
                NSNumber *resourceLength = [NSNumber numberWithUnsignedInteger:[itm.fileData length]];
                UIProgressView *progressV = (UIProgressView *)[self.view viewWithTag:100];
                [progressV setHidden:NO];
                NSNumber *numberProgress = [NSNumber numberWithFloat:[resourceLength floatValue] / [itm.fileSize floatValue]];
                NSNumber *numberIdBook = [NSNumber numberWithInt:itm.idBook];
                //[progressV setProgress:[resourceLength floatValue] / [itm.fileSize floatValue] animated:YES];
                //[self performSelectorOnMainThread:@selector(updateProgress:) withObject:numberProgress waitUntilDone:NO];
                //NSDictionary *dataInfo = [NSDictionary dictionaryWithObject:numberProgress forKey:@"numProgress"];
                //NSDictionary *dataInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:numberProgress, itm.idBook , nil] forKeys:[NSArray arrayWithObjects:@"numProgress", @"idBook", nil]];
                NSDictionary *dataInfo = [NSDictionary dictionaryWithObjectsAndKeys:numberProgress, @"numProgress", numberIdBook, @"idBook", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadNotification" object:nil userInfo:dataInfo];
                NSLog(@"show percent: %f", [resourceLength floatValue] / [itm.fileSize floatValue]);
                /*
                [self.progressView setHidden:NO];
                [self.progressView setProgress:[resourceLength floatValue] / [itm.fileSize floatValue] animated:YES];
                 */
            }
            else {
                NSNumber *resourceLength = [NSNumber numberWithUnsignedInteger:[itm.fileData length]];
                NSLog(@"hide progress: %f", [resourceLength floatValue] / [itm.fileSize floatValue]);
            }
            
        }
        
        /*
        [self.dataDownloadBook appendData:data];
        NSNumber *resourceLength = [NSNumber numberWithUnsignedInteger:[self.dataDownloadBook length]];
        [self.progressView setProgress:[resourceLength floatValue] / [self.fileSize floatValue] animated:YES];
        NSLog(@"%f", [resourceLength floatValue] / [self.fileSize floatValue]);
         */
    }
	
	//resultField.text = str;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.loadIndicator stopAnimating];
    [[NSThread currentThread] cancel];
	NSLog(@"fail with error!!");
}

#pragma mark - Notification
- (void)receiveNotification:(NSNotification *)notification
{
    BOOL isDoneDownload = NO;
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *bookId = [userInfo objectForKey:@"idBook"];
    
    if ([userInfo count] == 2) {
        NSNumber *num = [userInfo objectForKey:@"numProgress"];
        UIProgressView *progressV = (UIProgressView *)[self.view viewWithTag:100];
        [progressV setProgress:[num floatValue] animated:YES];
        NSLog(@"tesstprogress:%f",progressV.progress);
        
        if ([num floatValue] == 1) {
            UIButton *btn = (UIButton *)[self.view viewWithTag:1000];
            [btn setImage:[UIImage imageNamed:@"btnRead.png"] forState:UIControlStateNormal];
            [btn setTitle:@"Read" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
            [btn setEnabled:YES];
            
            progressV = (UIProgressView *)[self.view viewWithTag:100];
            [progressV setHidden:YES];
            
            self.isDownloaded = YES;
            isDoneDownload = YES;
        }
        else {
            UIImage *img = [UIImage imageNamed:@"btnDownloading.png"];
            UIButton *btn = (UIButton *)[self.view viewWithTag:1000];
            [btn setTitle:@"Downloading" forState:UIControlStateDisabled];
            [btn setImage:img forState:UIControlStateNormal];
            [btn setEnabled:NO];
        }
    }
    else {
        NSLog(@"FinishDownloadNotification");
        
        UIButton *btn = (UIButton *)[self.view viewWithTag:1000];
        [btn setImage:[UIImage imageNamed:@"btnRead.png"] forState:UIControlStateNormal];
        [btn setTitle:@"Read" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [btn setEnabled:YES];
        
        UIProgressView *progressV = (UIProgressView *)[self.view viewWithTag:100];
        [progressV setHidden:YES];
        
        self.isDownloaded = YES;
        isDoneDownload = YES;
        
        if (isDoneDownload) {
            // send Request
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *userIDFB = [defaults stringForKey:@"FBUserId"];
            NSString *strIdBook = [NSString stringWithFormat:@"%i", [bookId intValue]];
            
            if (userIDFB != nil) {
                NSString *strRequest = [NSString stringWithFormat:@"%@&book_id=%@&account_id=%@", URL_SEND_ID_DOWNLOADED_BOOK_AND_USER_ID, strIdBook, userIDFB];
                NSLog(@"strRequest = %@", strRequest);
                
                NSURLRequest *sendIDBookRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:strRequest] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:REQUEST_TIME_OUT];
                
                //if (_connectionSendIdBook == nil) {
                
                /*
                if (_connectionDetailBook != nil) {
                    self.connectionDetailBook = nil;
                }
                */    
                _connectionSendIdBook = [[[NSURLConnection alloc] initWithRequest:sendIDBookRequest delegate:self startImmediately:NO] autorelease];
                [_connectionSendIdBook scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                [_connectionSendIdBook start];
                //}
            }
            
        }
    }
    
}


#pragma mark - View lifecycle

- (void)dealloc
{
    [_dataBook release], _dataBook = nil;
    [_dataDownloadBook release], _dataDownloadBook = nil;
    [_bookTitle release], _bookTitle = nil;
    [_imageBig release], _imageBig = nil;
    [_filePath release], _filePath = nil;
    [_description release], _description = nil;
    [_comments release], _comments = nil;
    [_author release], _author = nil;
    [_strRating release], _author = nil;
    [_strRatingCount release], _strRatingCount = nil;
    
    [_connectionDetailBook release], _connectionDetailBook = nil;
    [_connectionDownloadBook release], _connectionDownloadBook = nil;
    //[_connectionSendIdBook release], _connectionSendIdBook = nil;
    //self.connectionSendIdBook = nil;
    _connectionSendIdBook = nil;
    
    [_alertLoading release], _alertLoading = nil;
    [_loadIndicator release], _loadIndicator = nil;
    [_progressView release], _progressView = nil;
    [_fileSize release], _fileSize = nil;
    [_book release], _book = nil;
    
    self.timer = nil;
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"Info WILLAPPEAR");
    
    [self.navigationController setNavigationBarHidden:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"DownloadNotification" object:nil];
    
    if (self.isDownloaded == NO) {
        
        
        
        BookReaderAppDelegate *appDelegate = (BookReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSLog(@"arrBook = %i", appDelegate.arrBooks.count);
        NSLog(@"selected id book = %i", self.idBook);
        Book *book;
        
        BOOL isFound = NO;
        for (NSInteger idB = 0; idB < appDelegate.arrBooks.count; idB++) {
            book = [appDelegate.arrBooks objectAtIndex:idB];
            if (self.idBook == book.idBook) {
                isFound = YES;
                break;
            }
        }
        
        if (isFound) {
            self.loadIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
            //[self.loadIndicator setFrame:CGRectMake(0.0, 0.0, 40.0, 40.0)];
            
            //[self.loadIndicator setCenter:self.view.center];
            [self.loadIndicator setFrame:CGRectMake((self.view.bounds.size.width - 40) / 2 , (self.view.bounds.size.height - 40) / 2, 40, 40)];
            [self.loadIndicator setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
            
            self.loadIndicator.hidesWhenStopped = YES;
            [self.loadIndicator startAnimating];
            [self.view addSubview:self.loadIndicator];
        }
        
        

    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"Info VIEWDIDLOAD");
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top_nosd.png"] forBarMetrics:UIBarMetricsDefault];
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *imgBack = [UIImage imageNamed:@"back_btt.png"];
    [btnBack setFrame:CGRectMake(0, 0, imgBack.size.width, imgBack.size.height)];
    [btnBack setImage:imgBack forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(btnBackInfoIsPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *btnItemBack = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    self.navigationItem.leftBarButtonItem = btnItemBack;
    [btnItemBack release];
    
    self.isImgLoaded = NO;
    
    // Landscape
    if (self.view.bounds.size.width > self.view.bounds.size.height) {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Info_bg_land.png"]]];
    }
    // Portrait
    else {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Info_bg.png"]]];
    }
    
    [self drawShelf];
    
    
    BookReaderAppDelegate *appDelegate = (BookReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSLog(@"arrBook = %i", appDelegate.arrBooks.count);
    NSLog(@"selected id book = %i", self.idBook);
    Book *book;
    
    BOOL isFound = NO;
    for (NSInteger idB = 0; idB < appDelegate.arrBooks.count; idB++) {
        book = [appDelegate.arrBooks objectAtIndex:idB];
        if (self.idBook == book.idBook) {
            isFound = YES;
            break;
        }
    }
    
    if (isFound == YES && !book.isFilled) {
        modeRequest = 0;
        NSString *url = [NSString stringWithFormat:@"%@%i",URL_GET_BOOK_INFO, self.idBook];
        NSLog(@"url = %@", url);
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:REQUEST_TIME_OUT];
        //self.connectionDetailBook = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        self.connectionDetailBook = [NSURLConnection connectionWithRequest:request delegate:self];
        //book.isFilled = YES;
    }
    else if (isFound == YES && book.isFilled){
        [_loadIndicator stopAnimating];
        
        if ([self.timer isValid]) {
            [self.timer invalidate];
        }
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(drawScreen) userInfo:nil repeats:NO];
        
        //[self drawScreen];
    }
    
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"did rotate");
    
    if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)){
        _isLandscape = NO;
    }
    else {
        _isLandscape = YES;
    }
    
    self.isImgLoaded = YES;
    
    [self drawShelf];
    [self drawScreen];
    
    NSLog(@"end rotate");
}

@end
