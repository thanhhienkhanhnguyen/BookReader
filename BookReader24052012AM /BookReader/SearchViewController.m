//
//  SearchViewController.m
//  BookReader
//
//  Created by mac on 5/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"
#import "JSON.h"
#import "InfoBookViewController.h"
#import "DetailBookViewController.h"
#import "Book.h"
#import "BookReaderAppDelegate.h"

@implementation SearchViewController

@synthesize searchDisplayController;
@synthesize searchBar;
@synthesize allItems;
@synthesize searchResults;
@synthesize dataResult;
@synthesize tbView;
@synthesize books = _books;
@synthesize loadingIndicator = _loadingIndicator;
@synthesize searchConnection = _searchConnection;

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

#pragma mark - Back button
- (void)btnBackDetailIsPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top_nosd.png"] forBarMetrics:UIBarMetricsDefault];
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *imgBack = [UIImage imageNamed:@"back_btt.png"];
    [btnBack setFrame:CGRectMake(0, 0, imgBack.size.width, imgBack.size.height)];
    [btnBack setImage:imgBack forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(btnBackDetailIsPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *btnItemBack = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    self.navigationItem.leftBarButtonItem = btnItemBack;
    [btnItemBack release];
    
    self.title = @"Search Book";
    
    
    [self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.searchDisplayController.searchResultsTableView setAllowsSelection:NO];
    
    //[self.tableView reloadData];

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
    
    //self.navigationController.navigationBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES];
    
    // Landscape
    if (self.tableView.bounds.size.width > self.tableView.bounds.size.height) {
        UIColor *bgTable = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_land.png"]];
        [self.searchDisplayController.searchResultsTableView setBackgroundColor:bgTable];    
        [self.tableView setBackgroundColor:bgTable];
    }
    else {
        UIColor *bgTable = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_portrait.png"]];
        [self.searchDisplayController.searchResultsTableView setBackgroundColor:bgTable];
        [self.tableView setBackgroundColor:bgTable];
    }
    
    
    [self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.searchDisplayController.searchResultsTableView setAllowsSelection:NO];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setAllowsSelection:NO];
    
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
    if (self.tableView.bounds.size.width > self.tableView.bounds.size.height) {
        UIColor *bgTable = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_land.png"]];
        [self.tableView setBackgroundColor:bgTable]; 
        [self.searchDisplayController.searchResultsTableView setBackgroundColor:bgTable];     }
    else {
        UIColor *bgTable = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_portrait.png"]];
        [self.tableView setBackgroundColor:bgTable];
        [self.searchDisplayController.searchResultsTableView setBackgroundColor:bgTable]; 
    }
    
    [self.searchDisplayController.searchResultsTableView reloadData];
}


- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HEIGHT_SHELF;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
//    [self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//    [self.searchDisplayController.searchResultsTableView setAllowsSelection:NO];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger rows = 0;
    
//    if ([tableView 
//         isEqual:self.searchDisplayController.searchResultsTableView]){
//        rows = [self.searchResults count];
//    }
//    else{
//        rows = [self.allItems count];
//    }
    
    rows = [self.searchResults count];
    NSLog(@"row of searchresult = %i", [self.searchResults count]);
    
    return rows + NUM_EXTRA_SHELF;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"Cell";
//    
//    UITableViewCell *cell = [tableView 
//                             dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] 
//                 initWithStyle:UITableViewCellStyleDefault 
//                 reuseIdentifier:CellIdentifier] autorelease];
//    }
    
//    /* Configure the cell. */
//    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]){
//        cell.textLabel.text = 
//        [self.searchResults objectAtIndex:indexPath.row];
//    }
//    else{
//        cell.textLabel.text =
//        [self.allItems objectAtIndex:indexPath.row];
//    }
    //NSString *txtResult = @"result";
    /*
    NSDictionary *book = [self.searchResults objectAtIndex:indexPath.row];
    //[cell.textLabel setText:[book objectForKey:@"title"]];
    NSLog(@"cell = %@", [book objectForKey:@"title"]);
    [cell.textLabel setText:[book objectForKey:@"title"]];
    */
    
    
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
    
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        // Add Book Button
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        
        NSInteger idBookStart = indexPath.row * numBookPerShelf;
        for (NSInteger idBook = idBookStart; idBook < idBookStart + numBookPerShelf && idBook < [self.books count]; idBook++) {
            
            
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
            
            /*
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
             */
            
            [btnBook addTarget:self action:@selector(bookBtnIsPressed:) forControlEvents:UIControlEventTouchUpInside];
            [btnBook setFrame:CGRectMake(xPadding, topPadding, BOOK_WIDTH, BOOK_HEIGHT)];
            [btnBook setTag:idBook];
            [btnBook setEnabled:YES];
            
            /*
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
             //}
             */
            
            [cell.contentView addSubview:btnBook];
            xPadding += BOOK_WIDTH + bookDistance;
        }
        
        [UIView commitAnimations];
    }
    
    
    
    
     
    return cell;
}


//- (void)filterContentForSearchText:(NSString*)searchText 
//                             scope:(NSString*)scope
//{
//    NSPredicate *resultPredicate = [NSPredicate 
//                                    predicateWithFormat:@"SELF contains[cd] %@",
//                                    searchText];
//    
//    self.searchResults = [self.allItems filteredArrayUsingPredicate:resultPredicate];
//}


#pragma mark - UISearchDisplayController delegate methods
//-(BOOL)searchDisplayController:(UISearchDisplayController *)controller 
//shouldReloadTableForSearchString:(NSString *)searchString
//{
//    [self filterContentForSearchText:searchString 
//                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
//                                      objectAtIndex:[self.searchDisplayController.searchBar
//                                                     selectedScopeButtonIndex]]];
//    
//    return YES;
//}

//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller 
//shouldReloadTableForSearchScope:(NSInteger)searchOption
//{
//    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] 
//                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
//                                      objectAtIndex:searchOption]];
//    
//    
//    
//    return YES;
//}



- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"text = %@", searchText);
    
    if (![searchText isEqualToString:@""]) {
        [self.loadingIndicator stopAnimating];
        
        NSString *strUrl = [NSString stringWithFormat:@"%@%@", URL_SEARCH_BOOK, searchText];
        NSLog(@"url = %@", strUrl);
        NSURLRequest *requestURL = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:REQUEST_TIME_OUT];
        
        if (_searchConnection != nil) {
            [_searchConnection cancel];
            self.searchConnection = nil;
        }
        
        self.loadingIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
        [self.loadingIndicator setFrame:CGRectMake(self.view.frame.size.width / 2 - 10, self.view.frame.size.height / 2 - 10, 40, 40)];
        [self.loadingIndicator setHidesWhenStopped:YES];
        [self.loadingIndicator startAnimating];
        [self.view addSubview:self.loadingIndicator];
        
        //[self.loadingIndicator stopAnimating];
         
        self.books = nil;
        self.searchConnection = [NSURLConnection connectionWithRequest:requestURL delegate:self];
    }
    

    //[self.tableView reloadData];
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

#pragma mark - connection
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSLog(@"connectionDidFinishLoading");
    [self.loadingIndicator stopAnimating];
    [self.loadingIndicator setHidden:YES];
    
    NSString *strData = [[[NSString alloc] initWithData:self.dataResult encoding:NSASCIIStringEncoding] autorelease];
    NSLog(@"data = %@", strData);
    
    self.searchResults = [strData JSONValue];
    NSLog(@"FOUND : %i", [self.searchResults count]);
    self.books = [[[NSMutableArray alloc] initWithObjects: nil] autorelease];
    if ([[strData JSONValue] isKindOfClass:[NSArray class]]) {
        NSArray *jsonData = [strData JSONValue];
        //[strData release];
        
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
        
        //self.responseData = nil;
        //self.getListConnection = nil;
        
        // start thread to download all downloaded file of users.
        //[self threadDownloadOwnEbooksWithId:0];
        
        //[self.tableView reloadData];
        
        //[self checkOwnEbooksDownloadOrNot];
        
        BookReaderAppDelegate *appDelegate = (BookReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
        //appDelegate.arrBooks = _books;
        [appDelegate setArrBooks:_books];
        //[_books release];
    }
     
    
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"connectionDidReceiveResponse");
    self.dataResult = [[[NSMutableData alloc] init] autorelease];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSLog(@"connectionDidReceiveData");
    [self.dataResult appendData:data];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.loadingIndicator stopAnimating];
    
	NSLog(@"fail with error!!");
}



#pragma mark - Book button
/*
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
            
            BOOL isLS = NO;
            if (self.view.bounds.size.width > self.view.bounds.size.height) {
                isLS = YES;
            }
            else {
                isLS = NO;
            }
            
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
    
}
*/

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


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:indexPath];
    NSString *titleCell = cell.textLabel.text;
    
    NSInteger idBook;
    for (NSInteger idResult = 0; idResult < self.searchResults.count; idResult++) {
        NSDictionary *b = [self.searchResults objectAtIndex:idResult];
        if ([titleCell isEqualToString:[b objectForKey:@"title"]]) {
            idBook = [[b objectForKey:@"id"] intValue];
            break;
        }
    }
    
    
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
            
            BOOL isLS = NO;
            if (self.view.bounds.size.width > self.view.bounds.size.height) {
                isLS = YES;
            }
            else {
                isLS = NO;
            }
            
            [infoBookView setIsLandscape:isLS];
            [infoBookView setIdBook:idBook];
            [infoBookView setIsDownloaded:NO];
            [self.navigationController pushViewController:infoBookView animated:YES];
            [infoBookView release];
        }
    }
    else {
        NSLog(@"folder exist");
        //NSString *filename = [self getFileNameFromFilePath:[book pathBook]];
        NSString *filename = @"web%20design.pdf";
        NSLog(@"file name = %@", filename);
        path = [path stringByAppendingPathComponent:filename];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSLog(@"file not exist");
            // detail ebook
            //if (self.infoBookView == nil) {
            InfoBookViewController *infoBookView = [[InfoBookViewController alloc] initWithNibName:@"InfoBookViewController" bundle:nil];
            //}
            
            BOOL isLS = NO;
            if (self.view.bounds.size.width > self.view.bounds.size.height) {
                isLS = YES;
            }
            else {
                isLS = NO;
            }
            
            [infoBookView setIsLandscape:isLS];
            [infoBookView setIdBook:idBook];
            [infoBookView setFilePath:filename];
            [infoBookView setIsDownloaded:NO];
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
    
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    /*
    
    UITableViewCell *cell = [self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:indexPath];
    NSString *titleCell = cell.textLabel.text;
    
    NSInteger idBook;
    for (NSInteger idResult = 0; idResult < self.searchResults.count; idResult++) {
        NSDictionary *b = [self.searchResults objectAtIndex:idResult];
        if ([titleCell isEqualToString:[b objectForKey:@"title"]]) {
            idBook = [[b objectForKey:@"id"] intValue];
            break;
        }
    }
    

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
            
            BOOL isLS = NO;
            if (self.view.bounds.size.width > self.view.bounds.size.height) {
                isLS = YES;
            }
            else {
                isLS = NO;
            }
            
            [infoBookView setIsLandscape:isLS];
            [infoBookView setIdBook:idBook];
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
            
            BOOL isLS = NO;
            if (self.view.bounds.size.width > self.view.bounds.size.height) {
                isLS = YES;
            }
            else {
                isLS = NO;
            }
            
            [infoBookView setIsLandscape:isLS];
            [infoBookView setIdBook:idBook];
            [infoBookView setFilePath:filename];
            [infoBookView setIsDownloaded:NO];
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
    */
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{	
//	searchBar.text = nil;	
//	[searchBar resignFirstResponder];
//	
//	[self filterContent:searchBar.text];
    
    NSLog(@"Cancel");
    [self dismissModalViewControllerAnimated:YES];
}

@end
