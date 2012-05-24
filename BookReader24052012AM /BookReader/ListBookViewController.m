//
//  ListBookViewController.m
//  BookReader
//
//  Created by mac on 3/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ListBookViewController.h"
#import "CustomShelfPortrait.h"
#import "CustomShelfLandscape.h"
#import "DetailBookViewController.h"
#import "DetailBookWebViewController.h"
#import "DetailBookEpubViewController.h"
#import "Book.h"
#import "JSON.h"
#import "BookReaderAppDelegate.h"


@implementation ListBookViewController

@synthesize books = _books;
@synthesize idCategory = _idCategory;
@synthesize responseData = _responseData;
@synthesize bookData = _bookData;

@synthesize loadingIndicator = _loadingIndicator;
@synthesize getListConnection = _getListConnection;

@synthesize typeTable = _typeTable;
//@synthesize queueDownloadBook = _queueDownloadBook;
@synthesize downloadConnection = _downloadConnection;

@synthesize arrOwnEbooks = _arrOwnEbooks;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

- (void)threadDownloadOwnEbooksWithId:(NSInteger)idBook
{
    BookReaderAppDelegate *appDelegate = (BookReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.queueDownloadBook count] > 0) {
        NSLog(@"preparing download Book with id = %i", idBook);
        Book *book = [appDelegate.queueDownloadBook objectAtIndex:idBook];
        
        NSString *urlDownload = [NSString stringWithFormat:@"http://%@", book.pathBook];
        NSLog(@"url Download = %@", urlDownload);
        NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlDownload] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:REQUEST_TIME_OUT];
        self.downloadConnection = [[NSURLConnection alloc] initWithRequest:downloadRequest delegate:self];
    }
}

- (void)checkOwnEbooksDownloadOrNot
{
    
    BookReaderAppDelegate *appDelegate = (BookReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    if (appDelegate.isDownloadOwnBooks == NO) {
        appDelegate.isDownloadOwnBooks = YES;
        NSLog(@"not download own ebooks");
        appDelegate.queueDownloadBook = [[NSMutableArray alloc] initWithObjects:nil];
        // Check own ebooks exist
        for (NSInteger idB = 0; idB < self.books.count; idB++) {
            Book *b = [self.books objectAtIndex:idB];
            NSArray *componentFileName = [b.pathBook componentsSeparatedByString:@"/"];
            NSString *fileName = [componentFileName objectAtIndex:componentFileName.count - 1];
            NSLog(@"PATH = %@", fileName);
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:DIRECTORY_STORE_EBOOK];  
            
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, fileName];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                NSLog(@"file not exist. Add to queue");
                //Add to queue
                [appDelegate.queueDownloadBook addObject:b];
                NSLog(@"queue = %i", [appDelegate.queueDownloadBook count]);
            }
            else {
                NSLog(@"file is existed!");
            }
        }
        
        NSLog(@"queue download = %i", [appDelegate.queueDownloadBook count]);
        if ([appDelegate.queueDownloadBook count] > 0) {
            //begin start queue download
            [self threadDownloadOwnEbooksWithId:0];
        }
    }

}



#pragma mark - connection

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSLog(@"connectionDidFinishLoading");
    [self.loadingIndicator stopAnimating];
    
    if (connection == self.getListConnection) {
        NSLog(@"getListBook");
        NSString *strData = [[NSString alloc] initWithData:self.responseData encoding:NSASCIIStringEncoding];
        NSLog(@"data listbook = %@", strData);

        if ([[strData JSONValue] isKindOfClass:[NSArray class]]) {
            NSArray *jsonData = [strData JSONValue];
            
            self.books = [[[NSMutableArray alloc] initWithObjects: nil] autorelease];
            for (NSInteger idB = 0; idB < [jsonData count]; idB++) {
                NSDictionary *book = [jsonData objectAtIndex:idB];
                
                NSString *idBook = [book objectForKey:@"id"];
                NSString *nameBook = [book objectForKey:@"title"];
                NSString *imgPath = [[book objectForKey:@"image"] stringByReplacingOccurrencesOfString:@"\\/" withString:@"\\"];
                NSString *filePath = [[book objectForKey:@"file"] stringByReplacingOccurrencesOfString:@"\\/" withString:@"\\"];
                
                Book *newBook = [[Book alloc] initWithIdBook:[idBook intValue] NameBook:nameBook ImageCoverPath:imgPath FilePath:filePath];
                [self.books addObject:newBook];
                [newBook release];
            }
            
            BookReaderAppDelegate *appDelegate = (BookReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
            //appDelegate.arrBooks = _books;
            [appDelegate setArrBooks:_books];
            
            self.responseData = nil;
            //self.getListConnection = nil;
            
            // start thread to download all downloaded file of users.
            //[self threadDownloadOwnEbooksWithId:0];
            
            [self.tableView reloadData];
            
            [self checkOwnEbooksDownloadOrNot];
        }
        [strData release];
    }
    else if (connection == self.downloadConnection) {
        NSLog(@"downloadbook");
        //NSString *strData = [[[NSString alloc] initWithData:self.responseData encoding:NSASCIIStringEncoding] autorelease];
        //NSLog(@"download book = %@", strData);
        
        
        BookReaderAppDelegate *appDelegate = (BookReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        Book *book = [appDelegate.queueDownloadBook objectAtIndex:0];
        
        NSArray *arrPath = [book.pathBook componentsSeparatedByString:@"/"];
        NSString *fileName = [arrPath objectAtIndex:[arrPath count] - 1];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:DIRECTORY_STORE_EBOOK];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:documentsDirectory]) {
            NSLog(@"Foler is not existed");
            
            NSError *error;
            [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        }
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, fileName];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSLog(@"File is not existed. Begin write file");
            BOOL isSuccess = [self.bookData writeToFile:filePath atomically:YES];
            
            if (isSuccess) {
                NSLog(@"write file [%@] finish | file Path = %@", fileName, filePath);
                
                BookReaderAppDelegate *appDelegate = (BookReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
                if ([appDelegate.queueDownloadBook count] == 1) {
                    appDelegate.isDownloadOwnBooks = NO;
                }
                [appDelegate.queueDownloadBook removeObjectAtIndex:0];
                
                
                [self.tableView reloadData];
                
                [self threadDownloadOwnEbooksWithId:0];
            }
            else {
                NSLog(@"write file [%@] fail", fileName);
            }
            
        }
        else {
            NSLog(@"File is existed on memory");
        }
    }
    
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"connectionDidReceiveResponse");
    if (connection == self.getListConnection) {
        NSLog(@"getListBook");
        self.responseData = [[[NSMutableData alloc] init] autorelease];
    }
    else if (connection == self.downloadConnection) {
        NSLog(@"Start downloadBook");
        self.bookData = [[[NSMutableData alloc] init ] autorelease];
    }
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSLog(@"connectionDidReceiveData");
    
    if (connection == self.getListConnection) {
        NSLog(@"getListBook");
        [self.responseData appendData:data];
        
        NSString *str = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
        NSLog(@"data = %@", str);
        //resultField.text = str;
    }
    else if (connection == self.downloadConnection) {
        NSLog(@"downloadBook");
        [self.bookData appendData:data];
    }
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.loadingIndicator stopAnimating];
    
    if (connection == self.getListConnection) {
        NSLog(@"Getlistbook: fail");
        self.responseData = nil;
    }
    else if (connection == self.downloadConnection) {
        BookReaderAppDelegate *appDelegate = (BookReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.isDownloadOwnBooks = NO;
        
        NSLog(@"downloadBook: fail");
        self.bookData = nil;
    }
    //self.getListConnection = nil;
}

#pragma mark - Back Button
- (void)itemCategoryIsPressed:(id)sender
{
    if (_getListConnection != nil) {
        [_getListConnection cancel];
        self.getListConnection = nil;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Parse file name + extension

- (NSString *)getFileNameFromFilePath:(NSString *)filePath
{
    NSArray *arrPath = [filePath componentsSeparatedByString:@"/"];
    NSString *fileName = [arrPath objectAtIndex:[arrPath count] - 1];
    
    return fileName;
}

- (NSString *)getFileTypeFromFileName:(NSString *)fileName
{
    NSArray *arrName = [fileName componentsSeparatedByString:@"."];
    NSString *type = [arrName objectAtIndex:[arrName count] - 1];
    
    return type;
}

#pragma mark - Book button
- (void)bookBtnIsPressed:(id)sender
{
    NSLog(@"book is selected");
    
    Book *book = [self.books objectAtIndex:[(UIButton *)sender tag]];
    //NSString *typeBook = [book objectForKey:@"typeBook"];
   // NSString *nameBook = [book objectForKey:@"fileBook"];
    //NSLog(@"nameBook = %@", nameBook);
    
    BOOL isLandScape;
    if (self.tableView.bounds.size.width > self.tableView.bounds.size.height) {
        isLandScape = YES;
    }
    else {
        isLandScape = NO;
    }
    
    // Check ebook folder
    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [[paths objectAtIndex:0] stringByAppendingPathComponent:DIRECTORY_STORE_EBOOK];
    NSError *error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSLog(@"folder not exist");
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path
									   withIntermediateDirectories:NO
														attributes:nil
															 error:&error])
		{
			NSLog(@"Create directory error: %@", error);
		}
        else {
            // detail ebook
            //if (self.infoBookView == nil) {
            InfoBookViewController *infoBookView = [[InfoBookViewController alloc] initWithNibName:@"InfoBookViewController" bundle:nil];
            //}
            
            BookReaderAppDelegate *appDelegate = (BookReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            BOOL isOwnBookDownloading = NO;
            for (NSInteger idOwnB = 0 ; idOwnB < appDelegate.queueDownloadBook.count; idOwnB++) {
                Book *downloadBook = [appDelegate.queueDownloadBook objectAtIndex:idOwnB];
                NSLog(@"queue-filePath = %@ | select - filePath = %@", downloadBook.pathBook, book.pathBook);
                if ([downloadBook.pathBook isEqualToString:book.pathBook]) {
                    isOwnBookDownloading = YES;
                    break;
                }
            }
            
            BOOL isLS = NO;
            if (self.view.bounds.size.width > self.view.bounds.size.height) {
                isLS = YES;
            }
            else {
                isLS = NO;
            }
            
            [infoBookView setIsOwnBook:isOwnBookDownloading];
            [infoBookView setIsLandscape:isLS];
            [infoBookView setIdBook:[book idBook]];
            [infoBookView setIsDownloaded:NO];
            [self.navigationController pushViewController:infoBookView animated:YES];
            [infoBookView release];
        }
    }
    else {
        NSLog(@"folder exist");
        NSString *filename = [self getFileNameFromFilePath:[book pathBook]];
        NSLog(@"file name = %@", filename);
        path = [path stringByAppendingPathComponent:filename];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSLog(@"file not exist");
            // detail ebook
            //if (self.infoBookView == nil) {
                InfoBookViewController *infoBookView = [[InfoBookViewController alloc] initWithNibName:@"InfoBookViewController" bundle:nil];
            //}
            
            
            BookReaderAppDelegate *appDelegate = (BookReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            BOOL isOwnBookDownloading = NO;
            for (NSInteger idOwnB = 0 ; idOwnB < appDelegate.queueDownloadBook.count; idOwnB++) {
                Book *downloadBook = [appDelegate.queueDownloadBook objectAtIndex:idOwnB];
                
                if ([downloadBook.pathBook isEqualToString:book.pathBook]) {
                    isOwnBookDownloading = YES;
                    break;
                }
            }
            
            BOOL isLS = NO;
            if (self.view.bounds.size.width > self.view.bounds.size.height) {
                isLS = YES;
            }
            else {
                isLS = NO;
            }
            
            [infoBookView setIsLandscape:isLS];
            [infoBookView setIdBook:[book idBook]];
            [infoBookView setFilePath:filename];
            [infoBookView setIsDownloaded:NO];
            [infoBookView setIsOwnBook:isOwnBookDownloading];
            [self.navigationController pushViewController:infoBookView animated:YES];
            [infoBookView release];
        }
        else {
            NSLog(@"file exist");
            // start reading ebook
            NSString *type = [self getFileTypeFromFileName:filename];
            NSLog(@"local path = %@", path);
            if ([type isEqualToString:@"pdf"]) {
                DetailBookViewController *detailBookView = [[DetailBookViewController alloc] initWithNibName:@"DetailBookViewController" bundle:nil isLandScape:isLandScape nameDocument:path];
                
                [self.navigationController pushViewController:detailBookView animated:YES];
                [detailBookView release];
            }
        }
    }
    
    /*
    if ([typeBook isEqualToString:@"pdf"]) {
        DetailBookViewController *detailBookView = [[DetailBookViewController alloc] initWithNibName:@"DetailBookViewController" bundle:nil isLandScape:isLandScape nameDocument:nameBook];
        
        [self.navigationController pushViewController:detailBookView animated:YES];
        [detailBookView release];
    }
    else if ([typeBook isEqualToString:@"html"]){
        DetailBookWebViewController *detailBookWebView = [[DetailBookWebViewController alloc] initWithNibName:@"DetailBookWebViewController" bundle:nil nameWeb:nameBook];
        
        [self.navigationController pushViewController:detailBookWebView animated:YES];
        [detailBookWebView release];
    }
    else if ([typeBook isEqualToString:@"epub"]) {
        DetailBookEpubViewController *detailBookEpubView = [[DetailBookEpubViewController alloc] initWithNibName:@"DetailBookEpubViewController" bundle:nil nameDocument:nameBook];
        
        //[detailBookEpubView unzipAndParseFile];
        
        [self.navigationController pushViewController:detailBookEpubView animated:YES];
        [detailBookEpubView release];
    }
    */
     
    /*
    if ([(UIButton *)sender tag] == 10 || [(UIButton *)sender tag] == 11) {
        
    }
    else if ([(UIButton *)sender tag] == 12) {
        DetailBookWebViewController *detailBookWebView = [[DetailBookWebViewController alloc] initWithNibName:@"DetailBookWebViewController" bundle:nil nameWeb:name];
        
        [self.navigationController pushViewController:detailBookWebView animated:YES];
        [detailBookWebView release];
    }
    else if ([(UIButton *)sender tag] == 13) {
        DetailBookEpubViewController *detailBookEpubView = [[DetailBookEpubViewController alloc] initWithNibName:@"DetailBookEpubViewController" bundle:nil];
        
        [self.navigationController pushViewController:detailBookEpubView animated:YES];
        [detailBookEpubView release];
    }
     */
}

#pragma mark - Get First Page Image from PDF
- (UIImage *)imageFromPDFWithDocumentRef:(CGPDFDocumentRef)documentRef {
    CGPDFPageRef pageRef = CGPDFDocumentGetPage(documentRef, 1);
    CGRect pageRect = CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox);
    
    UIGraphicsBeginImageContext(pageRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, CGRectGetMinX(pageRect),CGRectGetMaxY(pageRect));
    CGContextScaleCTM(context, 1, -1);  
    CGContextTranslateCTM(context, -(pageRect.origin.x), -(pageRect.origin.y));
    CGContextDrawPDFPage(context, pageRef);
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalImage;
} 


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"viewdidload");
    

    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setAllowsSelection:NO];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSString *url;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userIDFB = [defaults stringForKey:@"FBUserId"];
    
    if (self.typeTable == DefaultStoreMode) {
        url = [NSString stringWithFormat:@"%@%i",URL_GET_LIST_BOOKS_OF_CATEGORY, self.idCategory];
    } else if (self.typeTable == MyStoreMode) {
        url = [NSString stringWithFormat:@"%@%@",URL_GET_LIST_DOWNLOADED_BOOK, userIDFB];
    }

    NSLog(@"url = %@", url);
    BookReaderAppDelegate *appDelegate = (BookReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (self.typeTable == MyStoreMode || (self.typeTable == DefaultStoreMode && [appDelegate.arrBooks count] == 0)) {
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:REQUEST_TIME_OUT];
        self.getListConnection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    }
    else if (self.typeTable == DefaultStoreMode && [appDelegate.arrBooks  count] > 0) {
        
        
        self.books = appDelegate.arrBooks;
        
        [self.tableView reloadData];
        
        //[_loadingIndicator stopAnimating];
    }
    
    //NSLog(@"num book = %i", [self.books count]);
    
    

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
    
    NSLog(@"ListBook viewWillAppear");
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top.png"] forBarMetrics:UIBarMetricsDefault];
    
    //[self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    //[self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"top.png"]]];
    //[self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    //[self.navigationController.navigationBar setTranslucent:NO];
    //[self.navigationController.navigationBar setOpaque:NO];
    
    if (self.typeTable == DefaultStoreMode) {
        self.title = @"Books";
    }
    else {
        self.title = @"My Books";
    }
        
    // Landscape
    if (self.tableView.bounds.size.width > self.tableView.bounds.size.height) {
        UIColor *bgTable = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_land.png"]];
        [self.tableView setBackgroundColor:bgTable];        
    }
    else {
        UIColor *bgTable = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_portrait.png"]];
        [self.tableView setBackgroundColor:bgTable];
    }
    
    // Add category button
    UIButton *btnCat = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *imgBackCat = [UIImage imageNamed:@"cate_btt.png"];
    [btnCat setFrame:CGRectMake(0, 0, imgBackCat.size.width, imgBackCat.size.height)];
    [btnCat setImage:imgBackCat forState:UIControlStateNormal];
    [btnCat addTarget:self action:@selector(itemCategoryIsPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *categoryBtn = [[UIBarButtonItem alloc] initWithCustomView:btnCat];
    self.navigationItem.leftBarButtonItem = categoryBtn;
    
    [categoryBtn release];
    

    BookReaderAppDelegate *appDelegate = (BookReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.arrBooks count] == 0) {
        self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_loadingIndicator setFrame:CGRectMake((self.view.bounds.size.width - 40) / 2 , (self.view.bounds.size.height - 40) / 2, 40, 40)];
        _loadingIndicator.hidesWhenStopped = YES;
        [_loadingIndicator startAnimating];
        [self.view addSubview:_loadingIndicator];
    }
    
    //if (_loadingIndicator == nil) {
        
    //}

    [self.tableView reloadData];
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

- (void)dealloc
{
    [_books release];
    _books = nil;
    
    [_responseData release];
    _responseData = nil;
    
    self.bookData = nil;
    
    [_loadingIndicator release];
    _loadingIndicator = nil;
    
    [_getListConnection retain];
    _getListConnection = nil;
    
    self.downloadConnection = nil;
    
    //self.queueDownloadBook = nil;
    
    [_arrOwnEbooks release];
    _arrOwnEbooks = nil;
    
    [super dealloc];
}

#pragma mark - Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (self.tableView.bounds.size.width > self.tableView.bounds.size.height) {
        UIColor *bgTable = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_land.png"]];
        [self.tableView setBackgroundColor:bgTable];        
    }
    else {
        UIColor *bgTable = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_portrait.png"]];
        [self.tableView setBackgroundColor:bgTable];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger num = 0;
    if ([self.books count] == 0) {
        num = 1;
    }
    NSLog(@"ListBook: num of books = %i", [self.books count]);
    // Landscape
    if (self.tableView.bounds.size.width > self.tableView.bounds.size.height) {
        NSLog(@"ListBook:landscape");
        num = [self.books count] / NUM_BOOK_LANDSCAPE;
        if ([self.books count] % NUM_BOOK_LANDSCAPE != 0) {
            num++;
        }
    }
    // Portrait
    else {
        NSLog(@"ListBook:portrait");
        num = [self.books count] / NUM_BOOK_PORTRAIT;
        if ([self.books count] % NUM_BOOK_PORTRAIT != 0) {
            num++;
        }
    }
    
    NSLog(@"ListBook: num row = %i", num);

    return num + NUM_EXTRA_SHELF;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HEIGHT_SHELF;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierPortrait = @"CellPortrait";
    static NSString *CellIdentifierLandscape = @"CellLandscape";
    
    UITableViewCell *cell = nil;
    
    float xPadding = 0;
    float topPadding = 0;
    float bookDistance = 0;
    NSInteger numBookPerShelf = 0;
    
    // Landscape
    if (tableView.bounds.size.width > self.view.bounds.size.height) {
        //NSLog(@"table view Landscape");
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierLandscape];
        if (cell == nil) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierLandscape];
            [cell autorelease];
        }

        xPadding = BOOK_PADDING_LEFT_LANDSCAPE;
        topPadding = BOOK_PADDING_TOP_LANDSCAPE;
        bookDistance = BOOK_DISTANCE_LANDSCAPE;
        numBookPerShelf = NUM_BOOK_LANDSCAPE;
        
        if (indexPath.row == 0) {
            UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shelf1_land1st.png"]];
            
            [cell setBackgroundView:imgV];
            [imgV release];
        }
        else {
            UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bookshelf_land.png"]];
            
            [cell setBackgroundView:imgV];
            [imgV release];
        }
    }
    else {
        //NSLog(@"table view portrait");
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierPortrait];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierPortrait];
            [cell autorelease];
        }

        xPadding = BOOK_PADDING_LEFT_PORTRAIT;
        topPadding = BOOK_PADDING_TOP_PORTRAIT;
        bookDistance = BOOK_DISTANCE_PORTRAIT;
        numBookPerShelf = NUM_BOOK_PORTRAIT;
        
        if (indexPath.row == 0) {
            UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shelf1_portrait1st.png"]];
            
            [cell setBackgroundView:imgV];
            [imgV release];
        }
        else {
            UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bookshelf_por.png"]];
            
            [cell setBackgroundView:imgV];
            [imgV release];
        }
    }
    
    // remove all subviews
    for (UIView *view in [cell.contentView subviews]) {
        [view removeFromSuperview];
    }
    
    // Add Book Button
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    
    NSInteger idBookStart = indexPath.row * numBookPerShelf;
    for (NSInteger idBook = idBookStart; idBook < idBookStart + numBookPerShelf && idBook < [self.books count]; idBook++) {
        /*
        NSDictionary *book = [self.books objectAtIndex:idBook];
        
        NSString *imgBook = [book objectForKey:@"imgBook"];
        UIButton *btnBook;
        if ([imgBook isEqualToString:@"none"]) {
            btnBook = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            NSString *nameBook = (NSString *)[book objectForKey:@"nameBook"];
            [btnBook setTitle:nameBook forState:UIControlStateNormal];
        }
        else {
            btnBook = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *imgBtn = [UIImage imageNamed:imgBook];
            [btnBook setImage:imgBtn forState:UIControlStateNormal];
        }
        */
        
        Book *book = [self.books objectAtIndex:idBook];
        
        NSString *imgBook = [book imgBook];
        UIButton *btnBook;
        
        if ([imgBook isEqualToString:@""]) {
            btnBook = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            NSString *nameBook = [book name];
            [btnBook setTitle:nameBook forState:UIControlStateNormal];
        }
        else {
            btnBook = [UIButton buttonWithType:UIButtonTypeCustom];
            if ([book imgSaveBook] == nil) {
                NSURL *urlImg = [NSURL URLWithString:imgBook];
                UIImage *imgBtn = [UIImage imageWithData:[NSData dataWithContentsOfURL:urlImg]];
                [btnBook setImage:imgBtn forState:UIControlStateNormal];
                [book setImgSaveBook:imgBtn];
            }
            else {
                UIImage *imgBtn = [book imgSaveBook];
                [btnBook setImage:imgBtn forState:UIControlStateNormal];
            }
        }
        
        
        for (NSInteger idOwnB = 0; idOwnB < [self.arrOwnEbooks count]; idOwnB++) {
            NSDictionary *dicBook = [self.arrOwnEbooks objectAtIndex:idOwnB];
            NSString *nameOwnB = [dicBook objectForKey:@"title"];
            
            NSLog(@"OwnBook name = %@ | book store name = %@", nameOwnB, book.name);
            if ([[book name] isEqualToString:nameOwnB]) {
                [btnBook setEnabled:NO];
            }
            else {
                [btnBook setEnabled:YES];
            }
        }
        
        
        [btnBook addTarget:self action:@selector(bookBtnIsPressed:) forControlEvents:UIControlEventTouchUpInside];
        [btnBook setFrame:CGRectMake(xPadding, topPadding, BOOK_WIDTH, BOOK_HEIGHT)];
        [btnBook setTag:idBook];
        [btnBook setEnabled:YES];
        
        if (self.typeTable == MyStoreMode) {
            NSArray *componentFileName = [book.pathBook componentsSeparatedByString:@"/"];
            NSString *fileName = [componentFileName objectAtIndex:componentFileName.count - 1];
            NSLog(@"PATH = %@", fileName);
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:DIRECTORY_STORE_EBOOK];  
            
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, fileName];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                [btnBook setEnabled:NO];
            }
            else {
                [btnBook setEnabled:YES];
            }
        }
        
        [cell.contentView addSubview:btnBook];
        xPadding += BOOK_WIDTH + bookDistance;
    }
     
    [UIView commitAnimations];
    
    return cell;
    
    /*
    // Landscape
    if (self.view.bounds.size.width > self.view.bounds.size.height) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierLandscape];
        if (cell == nil) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierLandscape];
        }
        
        for (UIView *view in [cell.contentView subviews]) {
            [view removeFromSuperview];
        }
        
        
        // Add Book Button
        if (indexPath.row == 0) {
        
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shelf1_land1st.png"]];
            
            float xPadding = BOOK_PADDING_LEFT_LANDSCAPE;
            for (NSInteger idNum = 0; idNum < NUM_BOOK_LANDSCAPE; idNum++) {
                UIButton *btnBook = [UIButton buttonWithType:UIButtonTypeCustom];
                UIImage *imgBtn;
                if (idNum == 0) {
                   imgBtn = [UIImage imageNamed:@"book.png"];
                    [btnBook setImage:imgBtn forState:UIControlStateNormal];
                    //[btnBook setTitle:@"Florida" forState:UIControlStateNormal];
                    //[btnBook setImage:imgBtn forState:UIControlStateNormal];
                    [btnBook addTarget:self action:@selector(bookBtnIsPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [btnBook setFrame:CGRectMake(xPadding, BOOK_PADDING_TOP_LANDSCAPE, BOOK_WIDTH, BOOK_HEIGHT)];
                    [btnBook setTag:10];
                    
                    [cell.contentView addSubview:btnBook];
                    xPadding += BOOK_WIDTH + BOOK_DISTANCE_LANDSCAPE;
                }
                else if (idNum == 1) {
                    imgBtn = [UIImage imageNamed:@"bookWGE.png"];
                    [btnBook setImage:imgBtn forState:UIControlStateNormal];
                    //[btnBook setTitle:@"Florida" forState:UIControlStateNormal];
                    //[btnBook setImage:imgBtn forState:UIControlStateNormal];
                    [btnBook addTarget:self action:@selector(bookBtnIsPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [btnBook setFrame:CGRectMake(xPadding, BOOK_PADDING_TOP_LANDSCAPE, BOOK_WIDTH, BOOK_HEIGHT)];
                    [btnBook setTag:11];
                    
                    [cell.contentView addSubview:btnBook];
                    xPadding += BOOK_WIDTH + BOOK_DISTANCE_LANDSCAPE;
                }
                else if (idNum == 2) {
                    btnBook = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    //[btnBook setImage:imgBtn forState:UIControlStateNormal];
                    [btnBook setTitle:@"New iPad" forState:UIControlStateNormal];
                    //[btnBook setImage:imgBtn forState:UIControlStateNormal];
                    [btnBook addTarget:self action:@selector(bookBtnIsPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [btnBook setFrame:CGRectMake(xPadding, BOOK_PADDING_TOP_LANDSCAPE, BOOK_WIDTH, BOOK_HEIGHT)];
                    [btnBook setTag:12];
                    
                    [cell.contentView addSubview:btnBook];
                    xPadding += BOOK_WIDTH + BOOK_DISTANCE_LANDSCAPE;
                }
                else if (idNum == 3) {
                    btnBook = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    //[btnBook setImage:imgBtn forState:UIControlStateNormal];
                    [btnBook setTitle:@"Bane" forState:UIControlStateNormal];
                    //[btnBook setImage:imgBtn forState:UIControlStateNormal];
                    [btnBook addTarget:self action:@selector(bookBtnIsPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [btnBook setFrame:CGRectMake(xPadding, BOOK_PADDING_TOP_LANDSCAPE, BOOK_WIDTH, BOOK_HEIGHT)];
                    [btnBook setTag:13];
                    
                    [cell.contentView addSubview:btnBook];
                    xPadding += BOOK_WIDTH + BOOK_DISTANCE_LANDSCAPE;
                }
            }
        }
        else {
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bookshelf_land.png"]];
        }
        
        return cell;
    }
    
    */
    

    // Portrait
    /*
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierPortrait];
        if (cell == nil) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierPortrait];
        }
        
        for (UIView *view in [cell.contentView subviews]) {
            [view removeFromSuperview];
        }

        // Add Book Button
        if (indexPath.row == 0) {

            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shelf1_portrait1st.png"]];
            
            float xPadding = BOOK_PADDING_LEFT_PORTRAIT;
            for (NSInteger idNum = 0; idNum < NUM_BOOK_PORTRAIT; idNum++) {
                
                UIButton *btnBook = [UIButton buttonWithType:UIButtonTypeCustom];
                UIImage *imgBtn;
                if (idNum == 0) {
                    imgBtn = [UIImage imageNamed:@"book.png"];
                    [btnBook setImage:imgBtn forState:UIControlStateNormal];
                    //[btnBook setTitle:@"Florida" forState:UIControlStateNormal];
                    //[btnBook setImage:imgBtn forState:UIControlStateNormal];
                    [btnBook addTarget:self action:@selector(bookBtnIsPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [btnBook setFrame:CGRectMake(xPadding, BOOK_PADDING_TOP_PORTRAIT, BOOK_WIDTH, BOOK_HEIGHT)];
                    [btnBook setTag:10];
                    
                    [cell.contentView addSubview:btnBook];
                    xPadding += BOOK_WIDTH + BOOK_DISTANCE_PORTRAIT;
                }
                else if (idNum == 1) {
                    imgBtn = [UIImage imageNamed:@"bookWGE.png"];
                    [btnBook setImage:imgBtn forState:UIControlStateNormal];
                    //[btnBook setTitle:@"Florida" forState:UIControlStateNormal];
                    //[btnBook setImage:imgBtn forState:UIControlStateNormal];
                    [btnBook addTarget:self action:@selector(bookBtnIsPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [btnBook setFrame:CGRectMake(xPadding, BOOK_PADDING_TOP_PORTRAIT, BOOK_WIDTH, BOOK_HEIGHT)];
                    [btnBook setTag:11];
                    
                    [cell.contentView addSubview:btnBook];
                    xPadding += BOOK_WIDTH + BOOK_DISTANCE_PORTRAIT;
                }
                else if (idNum == 2) {
                    btnBook = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    //[btnBook setImage:imgBtn forState:UIControlStateNormal];
                    [btnBook setTitle:@"New iPad" forState:UIControlStateNormal];
                    //[btnBook setImage:imgBtn forState:UIControlStateNormal];
                    [btnBook addTarget:self action:@selector(bookBtnIsPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [btnBook setFrame:CGRectMake(xPadding, BOOK_PADDING_TOP_PORTRAIT, BOOK_WIDTH, BOOK_HEIGHT)];
                    [btnBook setTag:12];
                    
                    [cell.contentView addSubview:btnBook];
                    xPadding += BOOK_WIDTH + BOOK_DISTANCE_PORTRAIT;
                }
                else if (idNum == 3) {
                    btnBook = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    //[btnBook setImage:imgBtn forState:UIControlStateNormal];
                    [btnBook setTitle:@"Bane" forState:UIControlStateNormal];
                    //[btnBook setImage:imgBtn forState:UIControlStateNormal];
                    [btnBook addTarget:self action:@selector(bookBtnIsPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [btnBook setFrame:CGRectMake(xPadding, BOOK_PADDING_TOP_PORTRAIT, BOOK_WIDTH, BOOK_HEIGHT)];
                    [btnBook setTag:13];
                    
                    [cell.contentView addSubview:btnBook];
                    xPadding += BOOK_WIDTH + BOOK_DISTANCE_PORTRAIT;
                }
            }
        }
        else {
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bookshelf_por.png"]];
        }
        
        return cell;
    }
     */
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
