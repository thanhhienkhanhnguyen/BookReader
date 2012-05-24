//
//  DetailBookEpubViewController.m
//  BookReader
//
//  Created by mac on 3/30/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailBookEpubViewController.h"
#import "ChapterListEPubViewController.h"

@implementation DetailBookEpubViewController

@synthesize xmlHandler = _xmlHandler;
@synthesize ePubContent = _ePubContent;
@synthesize pagesPath = _pagePath;
@synthesize rtPath = _rtPath;
@synthesize strFileName = _strFileName;
@synthesize timer = _timer;
@synthesize tempArray = _tempArray;
@synthesize tempArrayPT = _tempArrayPT;
@synthesize isLoadTwoPages = _isLoadTwoPages;


//NSInteger currentPage = 0;
NSInteger currentPageInChap = 0;

//NSInteger currentChap = 0;

NSInteger currentPage1 = 0;
NSInteger currentPage2 = 0;

NSInteger countLoadPage = 0;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil nameDocument:(NSString *)name
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.strFileName = name;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Calculate number of pages
- (void)calculateNumberOfPages
{
    if (self.view.bounds.size.width > self.view.bounds.size.height) {
        numOfPages = totalPageAllChapters / 2;
        if (totalPageAllChapters % 2 != 0) {
            numOfPages++;
        }
    }
    else {
        numOfPages = totalPageAllChapters;
    }
}

#pragma mark - File

- (void)unzipAndParseFile
{
    // Unzip the epub file to documents directory
    [self unzipAndSaveFile];
    self.xmlHandler = [[XMLHandler alloc] init];
    self.xmlHandler.delegate = self;
    [self.xmlHandler parseXMLFileAt:[self getRootFilePath]];
}

/*Function Name : getRootFilePath
 *Return Type   : NSString - Returns the path to container.xml
 *Parameters    : nil
 *Purpose       : To find the path to container.xml.This file contains the file name which holds the epub informations
 */

- (NSString*)getRootFilePath{
	
	//check whether root file path exists
	NSFileManager *filemanager=[[NSFileManager alloc] init];
	NSString *strFilePath=[NSString stringWithFormat:@"%@/UnzippedEpub/META-INF/container.xml",[self applicationDocumentsDirectory]];
	if ([filemanager fileExistsAtPath:strFilePath]) {
		
		//valid ePub
		NSLog(@"Parse now");
		
		[filemanager release];
		filemanager=nil;
		
        NSLog(@"%@", strFilePath);
		return strFilePath;
	}
	else {
		
		//Invalid ePub file
		UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error"
													  message:@"Root File not Valid"
													 delegate:self
											cancelButtonTitle:@"OK"
											otherButtonTitles:nil];
		[alert show];
		[alert release];
		alert=nil;
		
	}
	[filemanager release];
	filemanager=nil;
	return @"";
}


/*Function Name : unzipAndSaveFile
 *Return Type   : void
 *Parameters    : nil
 *Purpose       : To unzip the epub file to documents directory
 */

- (void)unzipAndSaveFile{
	
	ZipArchive* za = [[ZipArchive alloc] init];
	if( [za UnzipOpenFile:[[NSBundle mainBundle] pathForResource:self.strFileName ofType:@"epub"]] ){
		
		NSString *strPath=[NSString stringWithFormat:@"%@/UnzippedEpub",[self applicationDocumentsDirectory]];
		//Delete all the previous files
		NSFileManager *filemanager=[[NSFileManager alloc] init];
		if ([filemanager fileExistsAtPath:strPath]) {
			
			NSError *error;
			[filemanager removeItemAtPath:strPath error:&error];
		}
		[filemanager release];
		filemanager=nil;

        //start unzip
        BOOL ret = [za UnzipFileTo:[NSString stringWithFormat:@"%@/",strPath] overWrite:YES];
        if( NO==ret ){
            // error handler here
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:@"An unknown error occured"
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
            [alert show];
            [alert release];
            alert=nil;
        }
        [za UnzipCloseFile];

	}					
	[za release];
}


/*Function Name : applicationDocumentsDirectory
 *Return Type   : NSString - Returns the path to documents directory
 *Parameters    : nil
 *Purpose       : To find the path to documents directory
 */

- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

#pragma mark XMLHandler Delegate Methods

- (void)foundRootPath:(NSString*)rootPath{
	
	//Found the path of *.opf file
	
	//get the full path of opf file
	NSString *strOpfFilePath=[NSString stringWithFormat:@"%@/UnzippedEpub/%@",[self applicationDocumentsDirectory],rootPath];
	NSFileManager *filemanager=[[NSFileManager alloc] init];
	
	self.rtPath=[strOpfFilePath stringByReplacingOccurrencesOfString:[strOpfFilePath lastPathComponent] withString:@""];
	NSLog(@"strOpfFilePath = %@", strOpfFilePath);
	if ([filemanager fileExistsAtPath:strOpfFilePath]) {
		
		//Now start parse this file
		[self.xmlHandler parseXMLFileAt:strOpfFilePath];
	}
	else {
		
		UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error"
													  message:@"OPF File not found"
													 delegate:self
											cancelButtonTitle:@"OK"
											otherButtonTitles:nil];
		[alert show];
		[alert release];
		alert=nil;
	}
	[filemanager release];
	filemanager=nil;
	
}

- (void)finishedParsing:(EpubContent*)ePubContents{
    
	//self.pagesPath=[NSString stringWithFormat:@"%@/%@",self.rtPath,[ePubContents._manifest valueForKey:[ePubContents._spine objectAtIndex:0]]];
	self.ePubContent=ePubContents;
	_pageNumber=0;
	//[self loadPage];
    NSLog(@"finish parsing: numePubContent.chapter = %i", [self.ePubContent.chapters count]);
    [self loadPage];
}

#pragma mark - reload webview
- (void)reloadWebView:(UIWebView *)webView WithPage:(NSInteger)pageId
{
    
    NSString *varMySheet = @"var mySheet = document.styleSheets[0];";
    
    
    NSString *addCSSRule =  @"function addCSSRule(selector, newRule) {"
    "if (mySheet.addRule) {"
    "mySheet.addRule(selector, newRule);"								// For Internet Explorer
    "} else {"
    "ruleIndex = mySheet.cssRules.length;"
    "mySheet.insertRule(selector + '{' + newRule + ';}', ruleIndex);"   // For Firefox, Chrome, etc.
    "}"
    "}";
    
    NSLog(@"w:%f h:%f", webView.bounds.size.width, webView.bounds.size.height);
    
    NSString *insertRule1 = [NSString stringWithFormat:@"addCSSRule('html', 'padding: 0px; height: %fpx; -webkit-column-gap: 0px; -webkit-column-width: %fpx;')", webView.frame.size.height, webView.frame.size.width];
    NSString *insertRule2 = [NSString stringWithFormat:@"addCSSRule('p', 'text-align: justify;')"];
    //NSString *setTextSizeRule = [NSString stringWithFormat:@"addCSSRule('body', '-webkit-text-size-adjust: %d%%;')",fontPercentSize];
    
    
    float pageOffset = pageId * webView.bounds.size.width;
    NSLog(@"scroll to page Id = %i", pageId);
    NSString* goToOffsetFunc = [NSString stringWithFormat:@" function pageScroll(xOffset){ window.scrollTo(xOffset,0); } "];
    NSString* goTo =[NSString stringWithFormat:@"pageScroll(%f)", pageOffset];
    
    
    [webView stringByEvaluatingJavaScriptFromString:varMySheet];
    
    [webView stringByEvaluatingJavaScriptFromString:addCSSRule];
    
    [webView stringByEvaluatingJavaScriptFromString:insertRule1];
    
    [webView stringByEvaluatingJavaScriptFromString:insertRule2];
    
    [webView stringByEvaluatingJavaScriptFromString:goToOffsetFunc];
    [webView stringByEvaluatingJavaScriptFromString:goTo];
    
    NSLog(@"END RELOAD PAGE");
}


#pragma mark - item button
- (void)listBtnIsPressed:(id)sender
{
    if (chaptersPopover == nil) {
        ChapterListEPubViewController *chapterListView = [[ChapterListEPubViewController alloc] initWithNibName:@"ChapterListEPubViewController" bundle:[NSBundle mainBundle]];
        chapterListView.ePubViewController = self;
        
        chaptersPopover = [[UIPopoverController alloc] initWithContentViewController:chapterListView];
        [chaptersPopover setPopoverContentSize:CGSizeMake(400, 600)];
        [chapterListView release];
    }
    
    if ([chaptersPopover isPopoverVisible]) {
        [chaptersPopover dismissPopoverAnimated:YES];
    }
    else {
        [chaptersPopover presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}


#pragma mark - Load Page


/*Function Name : loadPage
 *Return Type   : void 
 *Parameters    : nil
 *Purpose       : To load actual pages to webview
 */

- (void)loadPage{
/*	self.pagesPath=[NSString stringWithFormat:@"%@/%@",self.rtPath,[self.ePubContent._manifest valueForKey:[self.ePubContent._spine objectAtIndex:_pageNumber]]];
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:self.pagesPath]]]; */
    
    // Begin counting total pages
    NSLog(@"Begin paging");
    totalPageAllChapters = 0;
    [[self.ePubContent.chapters objectAtIndex:0] setDelegate:self];
    [[self.ePubContent.chapters objectAtIndex:0] loadChapterWithFrameSize:self.view.bounds];
}

- (void)createPage
{
    
    for (NSInteger idNum = 1; idNum <= 4; idNum++) {
        // Get chapter id + page id from currentpage
        NSInteger currentChap = 0;
        NSInteger currentPage = 0;
        NSInteger page = idNum;
        for (NSInteger idChap = 0; idChap < [self.ePubContent.chapters count]; idChap++) {
            if (page <= [[self.ePubContent.chapters objectAtIndex:idChap] numPages]) {
                currentChap = idChap;
                currentPage = page - 1;
                break;
            }
            else {
                page -= [[self.ePubContent.chapters objectAtIndex:idChap] numPages];
            }
        }
        
        NSLog(@"load chap = %i | page = %i", currentChap, currentPage);
        UIWebView *webViewPT;
        UIWebView *webViewLS;
        
        //if (self.view.bounds.size.width > self.view.bounds.size.height) {
        webViewLS = [[UIWebView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, WEBVIEW_WIDTH_LANDSCAPE / 2, WEBVIEW_HEIGHT_LANDSCAPE)];
        webViewLS.scrollView.scrollEnabled = NO;
        webViewLS.scrollView.bounces = NO;
        //webViewLS.scalesPageToFit = YES;
        [webViewLS setDelegate:self];
        [webViewLS setTag:currentPage];
        [webViewLS loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[self.ePubContent.chapters objectAtIndex:currentChap] spinePath]]]];
        [self.tempArray addObject:webViewLS];
        [webViewLS release];
        
        //}
        //else {
        webViewPT = [[UIWebView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, WEBVIEW_WIDTH_PORTRAIT, WEBVIEW_HEIGHT_PORTRAIT)];
        //}
        webViewPT.scrollView.scrollEnabled = NO;
        webViewPT.scrollView.bounces = NO;
        //webViewPT.scalesPageToFit = YES;
        [webViewPT setDelegate:self];
        [webViewPT setTag:currentPage];
        [webViewPT loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[self.ePubContent.chapters objectAtIndex:currentChap] spinePath]]]];
        [self.tempArrayPT addObject:webViewPT];
        [webViewPT release];
        
    }
    
    [flipper setDataSource:self];
    
    UIBarButtonItem *listBtn = [[UIBarButtonItem alloc] initWithTitle:@"Chapter" style:UIBarButtonItemStyleBordered target:self action:@selector(listBtnIsPressed:)];
    self.navigationItem.rightBarButtonItem = listBtn;
    
}

- (void)loadWebView:(UIWebView *)wView atPage:(NSInteger)page
{
    self.pagesPath=[NSString stringWithFormat:@"%@/%@",self.rtPath,[self.ePubContent._manifest valueForKey:[self.ePubContent._spine objectAtIndex:page]]];
    NSLog(@"pagePath = %@", self.pagesPath);
	[wView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:self.pagesPath]]];
}

- (NSString *)getChapterPath:(NSInteger)chapter
{
    NSString *chapterPath = [NSString stringWithFormat:@"%@/%@",self.rtPath,[self.ePubContent._manifest valueForKey:[self.ePubContent._spine objectAtIndex:chapter]]];
    
    return chapterPath;
}

#pragma mark - Number of Page
- (NSInteger) numOfChapters
{
    return [self.ePubContent._spine count] - 1;
}

- (NSInteger) numOfPages
{
    NSInteger numOriPages = totalPageAllChapters;
    NSInteger num = 0;
    if (self.view.bounds.size.width > self.view.bounds.size.height) {
        num = numOriPages / 2;
        if (numOriPages % 2 != 0) {
            num++;
        }
    }
    else {
        num = numOriPages;
    }

    return num;
}

#pragma mark - Epub Delegate
- (void)chapterEPubDidFinishLoad:(ChapterEPub *)chapter
{
    totalPageAllChapters += chapter.numPages;
    NSLog(@"chap id = %i", chapter.idChapter);
    NSLog(@"num chap = %i", [self.ePubContent.chapters count]);
    
    
    //NSLog(@"ID = %i | numPages = %i", [chapter idChapter], [chapter numPages]);
    //[self.tempArray addObject:chapter];
    
    /*
    if (chapter.idChapter == [self.ePubContent._spine count] - 1) {
        flipper.dataSource = self;
    } */
    
    if (chapter.idChapter + 1 < [self.ePubContent.chapters count]) {
        [[self.ePubContent.chapters objectAtIndex:chapter.idChapter + 1] setDelegate:self];
        [[self.ePubContent.chapters objectAtIndex:chapter.idChapter + 1] loadChapterWithFrameSize:self.view.bounds];
    }
    // final chapter
    else {
        NSLog(@"Pagination ended!");
        NSLog(@"total page all chapters = %i", totalPageAllChapters);
        /*
        NSLog(@"begin load page on chapter");
        [[self.ePubContent.chapters objectAtIndex:0] loadPageWithFrameSize:self.view.bounds];
         */
        //flipper.dataSource = self;
        
        //self.tempArray = [[NSMutableArray alloc] initWithObjects: nil];
        //self.tempArrayPT = [[NSMutableArray alloc] initWithObjects: nil];
        //self.isLoadTwoPages = YES;
        //[self createPage];
        flipper.dataSource = self;
    }
}

- (void)pageInChapEPubDidFinishLoad:(ChapterEPub *)chapter
{
    if ([chapter.pages count] < chapter.numPages) {
        // next page
        [chapter loadPageWithFrameSize:self.view.bounds];
    }
    // final page on chapter
    else {
        // final chapter -> end load page
        if (chapter.idChapter == [self.ePubContent.chapters count] - 1) {
            NSLog(@"Finish load all pages");
            NSLog(@"Begin load flipper");
            flipper.dataSource = self;
        }
        else {
            // next chapter
            [[self.ePubContent.chapters objectAtIndex:chapter.idChapter + 1] loadPageWithFrameSize:self.view.bounds];
        }
    }
}

#pragma mark -
#pragma mark PageFlipper datasource

- (NSInteger) numberOfPagesForPageFlipper:(AFKPageFlipper *)pageFlipper {
    
    //numberOfPages = self.view.bounds.size.width > self.view.bounds.size.height ? ceil((float) CGPDFDocumentGetNumberOfPages(pdfDocument) / 2) : CGPDFDocumentGetNumberOfPages(pdfDocument);
    //NSLog(@"num of page flipper= %i", [self numOfPages]);
	//return [self numOfPages];
    [self calculateNumberOfPages];
    
    return numOfPages;
}

- (UIView *) viewForPage:(NSInteger) page inFlipper:(AFKPageFlipper *) pageFlipper
{
    NSLog(@"view for page : %i", pageFlipper.currentPDFPage);
    
    NSInteger numIdPage = pageFlipper.currentPDFPage;
    NSInteger currentChap = 0;
    NSInteger currentPage = 0;
    
    // Get chapter id + page id from currentpage
    for (NSInteger idChap = 0; [self.ePubContent.chapters count]; idChap++) {
        if (numIdPage <= [[self.ePubContent.chapters objectAtIndex:idChap] numPages]) {
            currentChap = idChap;
            currentPage = numIdPage - 1;
            break;
        }
        else {
            numIdPage -= [[self.ePubContent.chapters objectAtIndex:idChap] numPages];
        }
    }
    
     
    NSLog(@"current chap = %i, current page = %i", currentChap, currentPage);
    
    UIView *viewPage = [[UIView alloc] initWithFrame:self.view.frame];
    
    // Landscape
    if (self.view.bounds.size.width > self.view.bounds.size.height) {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(pageFlipper.bounds.origin.x, pageFlipper.bounds.origin.y, pageFlipper.bounds.size.width / 2, pageFlipper.bounds.size.height)];
        webView.scrollView.scrollEnabled = NO;
        [webView setDelegate:self];
        [webView setTag:currentPage];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[self.ePubContent.chapters objectAtIndex:currentChap] spinePath]]]];
        
        [viewPage addSubview:webView];
        [webView release];
        
        if (pageFlipper.currentPDFPage + 1 <= numOfPages) {
            
            if (currentPage + 1 >= [[self.ePubContent.chapters objectAtIndex:currentChap] numPages]) {
                // final page
                if (currentChap < [self.ePubContent.chapters count] - 1) {
                    currentChap++;
                    currentPage = 0;
                }
                else {
                    
                }
            }
            else {
                currentPage++;
            } 
        }
        
        UIWebView *webView1 = [[UIWebView alloc] initWithFrame:CGRectMake(pageFlipper.bounds.size.width / 2, pageFlipper.bounds.origin.y, pageFlipper.bounds.size.width / 2, pageFlipper.bounds.size.height)];
        webView1.scrollView.scrollEnabled = NO;
        [webView1 setDelegate:self];
        [webView1 setTag:currentPage];
        [webView1 loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[self.ePubContent.chapters objectAtIndex:currentChap] spinePath]]]];
        
        [viewPage addSubview:webView1];
        [webView1 release];
    }
    // Portrait
    else {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(pageFlipper.bounds.origin.x, pageFlipper.bounds.origin.y, pageFlipper.bounds.size.width, pageFlipper.bounds.size.height)];
        webView.scrollView.scrollEnabled = NO;
        [webView setDelegate:self];
        [webView setTag:currentPage];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[self.ePubContent.chapters objectAtIndex:currentChap] spinePath]]]];
        
        [viewPage addSubview:webView];
        [webView release];
    }
    
    /*
    if (pageFlipper.currentPDFPage - 1 < [self.tempArray count]) {
        UIWebView *webView; 
        if (self.view.bounds.size.width > self.view.bounds.size.height) {
            NSLog(@"get uiview landscope");
            webView = [self.tempArray objectAtIndex:pageFlipper.currentPDFPage - 1];
            [webView setFrame:CGRectMake(pageFlipper.bounds.origin.x, pageFlipper.bounds.origin.y, pageFlipper.bounds.size.width / 2, pageFlipper.bounds.size.height)];
        }
        else {
            NSLog(@"get uiview portrait");
            webView = [self.tempArrayPT objectAtIndex:pageFlipper.currentPDFPage - 1];
            [webView setFrame:CGRectMake(pageFlipper.bounds.origin.x, pageFlipper.bounds.origin.y, pageFlipper.bounds.size.width, pageFlipper.bounds.size.height)];
        }
        //[webView reload];
        //[self webViewDidFinishLoad:webView];
        NSLog(@"tag = %i", webView.tag);
        //[self reloadWebView:webView WithPage:webView.tag];
        [viewPage addSubview:webView];
        //[self performSelectorOnMainThread:@selector(webViewDidFinishLoad:) withObject:webView waitUntilDone:YES];
        
        if (self.view.bounds.size.width > self.view.bounds.size.height) {
            UIWebView *nWebView;
            if (pageFlipper.currentPDFPage < [self.tempArray count]) {
                NSLog(@"current chap = %i, current page = %i", currentChap, currentPage);
                nWebView = [self.tempArray objectAtIndex:pageFlipper.currentPDFPage];
                [nWebView setFrame:CGRectMake(webView.frame.size.width, webView.frame.origin.y, pageFlipper.bounds.size.width / 2, pageFlipper.bounds.size.height)];
                //[nWebView reload];
                //[self webViewDidFinishLoad:nWebView];
                //[self performSelectorOnMainThread:@selector(reloadWebView:WithPage:) withObject:nWebView withObject:currentPage waitUntilDone:YES];
                NSLog(@"tag = %i", nWebView.tag);
                //[self reloadWebView:nWebView WithPage:nWebView.tag];
                [viewPage addSubview:nWebView];
            }
        }
        
        
        if (self.view.bounds.size.width > self.view.bounds.size.height) {
            
        }
        else {
            
        }
        
        NSLog(@"self.tempArray count - 1 = %i", [self.tempArray count] - 1);
        if ((pageFlipper.currentPDFPage == [self.tempArray count] - 1 && self.view.bounds.size.width <= self.view.bounds.size.height)
            || (self.view.bounds.size.width > self.view.bounds.size.height && pageFlipper.currentPDFPage == [self.tempArray count] - 2)
            || (self.view.bounds.size.width > self.view.bounds.size.height && pageFlipper.currentPDFPage == [self.tempArray count] - 1)
            ) {
            NSLog(@"Load next 2 pages");
            //NSLog(@"current page + 2 = %i | numarray = %i", pageFlipper.currentPDFPage + 2, [self.tempArray count]);
            NSInteger num = 0;
            if (self.view.bounds.size.width <= self.view.bounds.size.height) {
                num = 2;
            }
            else {
                if (pageFlipper.currentPDFPage == [self.tempArray count] - 2) {
                    num = 3;
                }
                else if (pageFlipper.currentPDFPage == [self.tempArray count] - 1) {
                    num = 2;
                }
            }
            //if (pageFlipper.currentPDFPage + 2 <= numOfPages) {
            if ([self.tempArray count] + 1 <= numOfPages) {
                
                for (NSInteger i = 0; i < num; i++) {
                    if (currentPage + 1 >= [[self.ePubContent.chapters objectAtIndex:currentChap] numPages]) {
                        // final page
                        if (currentChap < [self.ePubContent.chapters count] - 1) {
                            currentChap++;
                            currentPage = 0;
                        }
                        else {
                            
                        }
                    }
                    else {
                        currentPage++;
                    } 
                }
                
            }
            
            //countLoadPage = 0;
            //self.isLoadTwoPages = YES;
            NSLog(@"1 : chap = %i, page = %i", currentChap, currentPage);
            UIWebView *webView1LS = [[UIWebView alloc] initWithFrame:CGRectMake(pageFlipper.bounds.origin.x, pageFlipper.bounds.origin.y, WEBVIEW_WIDTH_LANDSCAPE / 2, WEBVIEW_HEIGHT_LANDSCAPE)];
            webView1LS.scrollView.scrollEnabled = NO;
            webView1LS.scrollView.bounces = NO;
            //webView1LS.scalesPageToFit = NO;
            [webView1LS setTag:currentPage];
            [webView1LS setDelegate:self];
            [webView1LS loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[self.ePubContent.chapters objectAtIndex:currentChap] spinePath]]]];
            [self.tempArray addObject:webView1LS];
            [webView1LS release];
            
            UIWebView *webView1PT = [[UIWebView alloc] initWithFrame:CGRectMake(pageFlipper.bounds.origin.x, pageFlipper.bounds.origin.y, WEBVIEW_WIDTH_PORTRAIT, WEBVIEW_HEIGHT_PORTRAIT)];
            webView1PT.scrollView.scrollEnabled = NO;
            webView1PT.scrollView.bounces = NO;
           // webView1PT.scalesPageToFit = NO;
            [webView1PT setTag:currentPage];
            [webView1PT setDelegate:self];
            [webView1PT loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[self.ePubContent.chapters objectAtIndex:currentChap] spinePath]]]];
            [self.tempArrayPT addObject:webView1PT];
            [webView1PT release];
            
            //if (pageFlipper.currentPDFPage + 3 <= numOfPages) {
            if ([self.tempArray count] + 1 <= numOfPages) {
            
                if (currentPage + 1 >= [[self.ePubContent.chapters objectAtIndex:currentChap] numPages]) {
                    // final page
                    if (currentChap < [self.ePubContent.chapters count] - 1) {
                        currentChap++;
                        currentPage = 0;
                    }
                    else {
                    }
                }
                else {
                    currentPage++;
                }  
                
                NSLog(@"2 : chap = %i, page = %i", currentChap, currentPage);
                UIWebView *webView2LS = [[UIWebView alloc] initWithFrame:CGRectMake(pageFlipper.bounds.origin.x, pageFlipper.bounds.origin.y, WEBVIEW_WIDTH_LANDSCAPE / 2, WEBVIEW_HEIGHT_LANDSCAPE)];
                [webView2LS setTag:currentPage];
                webView2LS.scrollView.scrollEnabled = NO;
                webView2LS.scrollView.bounces = NO;
                //webView2LS.scalesPageToFit = NO;
                [webView2LS setDelegate:self];
                [webView2LS loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[self.ePubContent.chapters objectAtIndex:currentChap] spinePath]]]];
                [self.tempArray addObject:webView2LS];
                [webView2LS release];
                
                
                UIWebView *webView2PT = [[UIWebView alloc] initWithFrame:CGRectMake(pageFlipper.bounds.origin.x, pageFlipper.bounds.origin.y, WEBVIEW_WIDTH_PORTRAIT, WEBVIEW_HEIGHT_PORTRAIT)];
                [webView2PT setTag:currentPage];
                webView2PT.scrollView.scrollEnabled = NO;
                webView2PT.scrollView.bounces = NO;
                //webView2PT.scalesPageToFit = NO;
                [webView2PT setDelegate:self];
                [webView2PT loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[self.ePubContent.chapters objectAtIndex:currentChap] spinePath]]]];
                [self.tempArrayPT addObject:webView2PT];
                [webView2PT release];
            }  
        }
        
        
    }
    */
    
    /*
    
    // Landscape
    if (self.view.bounds.size.width > self.view.bounds.size.height) {
        NSLog(@"Epub: landscape");
        viewPage = [[UIView alloc] initWithFrame:self.view.bounds];
        
        NSLog(@"current chap = %i, current page = %i", currentChap, currentPage);

        
        
        
                
        if (pageFlipper.currentPDFPage + 1 <= numOfPages) {
            
            
        }
    }
    else {
        
        NSLog(@"Epub: portrait");
        NSLog(@"current chap = %i, current page = %i", currentChap, currentPage);

        viewPage = [[UIView alloc] initWithFrame:self.view.bounds];
            
        
        if (pageFlipper.currentPDFPage - 1 < [self.tempArray count])
        {
            UIWebView *webView = [self.tempArray objectAtIndex:pageFlipper.currentPDFPage - 1];
            [webView setFrame:CGRectMake(pageFlipper.bounds.origin.x, pageFlipper.bounds.origin.y, pageFlipper.bounds.size.width, pageFlipper.bounds.size.height)];
            
            //[webView reload];
            //[self webViewDidFinishLoad:webView];
            NSLog(@"tag = %i", webView.tag);
            [self reloadWebView:webView WithPage:webView.tag];
            //[self performSelectorOnMainThread:@selector(webViewDidFinishLoad:) withObject:webView waitUntilDone:YES];
            [viewPage addSubview:webView];
            
            if (pageFlipper.currentPDFPage == [self.tempArray count] - 1) {
                NSLog(@"Load next 2 pages");
                if (pageFlipper.currentPDFPage + 2 <= numOfPages) {
                    
                    for (NSInteger i = 0; i < 2; i++) {
                        if (currentPage + 1 >= [[self.ePubContent.chapters objectAtIndex:currentChap] numPages]) {
                            // final page
                            if (currentChap < [self.ePubContent.chapters count] - 1) {
                                currentChap++;
                                currentPage = 0;
                            }
                            else {
                            }
                        }
                        else {
                            currentPage++;
                        } 
                    }
                    
                }
                
                countLoadPage = 0;
                self.isLoadTwoPages = YES;
                NSLog(@"1 : chap = %i, page = %i", currentChap, currentPage);
                UIWebView *webView1 = [[UIWebView alloc] initWithFrame:CGRectMake(pageFlipper.bounds.origin.x, pageFlipper.bounds.origin.y, pageFlipper.bounds.size.width, pageFlipper.bounds.size.height)];
                webView1.scrollView.scrollEnabled = NO;
                webView1.scrollView.bounces = NO;
                [webView1 setTag:currentPage];
                [webView1 setDelegate:self];
                [webView1 loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[self.ePubContent.chapters objectAtIndex:currentChap] spinePath]]]];
                
                
                if (pageFlipper.currentPDFPage + 3 <= numOfPages) {
                    
                    if (currentPage + 1 >= [[self.ePubContent.chapters objectAtIndex:currentChap] numPages]) {
                        // final page
                        if (currentChap < [self.ePubContent.chapters count] - 1) {
                            currentChap++;
                            currentPage = 0;
                        }
                        else {
                        }
                    }
                    else {
                        currentPage++;
                    }  
                    
                    NSLog(@"2 : chap = %i, page = %i", currentChap, currentPage);
                    UIWebView *webView2 = [[UIWebView alloc] initWithFrame:CGRectMake(pageFlipper.bounds.origin.x, pageFlipper.bounds.origin.y, pageFlipper.bounds.size.width, pageFlipper.bounds.size.height)];
                    [webView2 setTag:currentPage];
                    webView2.scrollView.scrollEnabled = NO;
                    webView2.scrollView.bounces = NO;
                    [webView2 setDelegate:self];
                    [webView2 loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[self.ePubContent.chapters objectAtIndex:currentChap] spinePath]]]];
                }  
            }
            
        }
    }
    */
     
    NSLog(@"END VIEW FOR PAGE");
	return viewPage;
}

#pragma mark - UIWebView
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"Epub webview finish load");
    
    NSString *varMySheet = @"var mySheet = document.styleSheets[0];";
    
    NSString *addCSSRule =  @"function addCSSRule(selector, newRule) {"
    "if (mySheet.addRule) {"
    "mySheet.addRule(selector, newRule);"								// For Internet Explorer
    "} else {"
    "ruleIndex = mySheet.cssRules.length;"
    "mySheet.insertRule(selector + '{' + newRule + ';}', ruleIndex);"   // For Firefox, Chrome, etc.
    "}"
    "}";
    
    NSLog(@"w:%f h:%f", webView.bounds.size.width, webView.bounds.size.height);
    NSString *insertRule1 = [NSString stringWithFormat:@"addCSSRule('html', 'padding: 0px; height: %fpx; -webkit-column-gap: 0px; -webkit-column-width: %fpx;')", webView.frame.size.height, webView.frame.size.width];
    NSString *insertRule2 = [NSString stringWithFormat:@"addCSSRule('p', 'text-align: justify;')"];
    //NSString *setTextSizeRule = [NSString stringWithFormat:@"addCSSRule('body', '-webkit-text-size-adjust: %d%%;')",fontPercentSize];
    NSLog(@"scroll to : %i", webView.tag);
    float pageOffset = webView.tag * webView.bounds.size.width;
    NSString* goToOffsetFunc = [NSString stringWithFormat:@" function pageScroll(xOffset){ window.scroll(xOffset,0); } "];
    NSString* goTo =[NSString stringWithFormat:@"pageScroll(%f)", pageOffset];
    
    
    [webView stringByEvaluatingJavaScriptFromString:varMySheet];
    
    [webView stringByEvaluatingJavaScriptFromString:addCSSRule];
    
    [webView stringByEvaluatingJavaScriptFromString:insertRule1];
    
    [webView stringByEvaluatingJavaScriptFromString:insertRule2];
    
    [webView stringByEvaluatingJavaScriptFromString:goToOffsetFunc];
    [webView stringByEvaluatingJavaScriptFromString:goTo];
    
    /*
    if (self.isLoadTwoPages) {
        //NSLog(@"webView.tag = %i", webView.tag);
        if ([self.tempArray count] <= 3) {
            [self.tempArray addObject:webView];
            //[webView release];
            NSLog(@"array num = %i", [self.tempArray count]);
            //load more page
            //NSLog(@"prepare next page = %i", webView.tag + 1);
            //[self createPage:webView.tag + 1];
            if ([self.tempArray count] == 4) {
                NSLog(@"CREATE PAGE done");
                self.isLoadTwoPages = NO;
                flipper.dataSource = self;
            }
        }
        else {
            //NSLog(@"CREATE PAGE done");
            //self.isLoadTwoPages = NO;
            //flipper.dataSource = self;
            
            [self.tempArray addObject:webView];
            //[webView release];
            countLoadPage++;
            
            if (countLoadPage == 2) {
                self.isLoadTwoPages = NO;
            }
        }
    }
     */
    /*
    NSLog(@"Epub current chap = %i, current page = %i", currentChap, currentPage);
    
    //[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var desiredHeight = 100;var desiredWidth = 768;var bodyID = document.getElementsByTagName('body')[0];totalHeight = bodyID.offsetHeight;pageCount = Math.floor(totalHeight/desiredHeight) + 1;bodyID.style.padding = 10;bodyID.style.width = desiredWidth * pageCount;//bodyID.style.height = desiredHeight;//bodyID.style.WebkitColumnCount = pageCount;"]];
    //[webView stringByEvaluatingJavaScriptFromString:@"alert(document.body.innerHTML)"];
    
    NSString *varMySheet = @"var mySheet = document.styleSheets[0];";
    
    NSString *addCSSRule =  @"function addCSSRule(selector, newRule) {"
    "if (mySheet.addRule) {"
    "mySheet.addRule(selector, newRule);"								// For Internet Explorer
    "} else {"
    "ruleIndex = mySheet.cssRules.length;"
    "mySheet.insertRule(selector + '{' + newRule + ';}', ruleIndex);"   // For Firefox, Chrome, etc.
    "}"
    "}";
    
    //	NSLog(@"w:%f h:%f", webView.bounds.size.width, webView.bounds.size.height);
    NSString *insertRule1 = [NSString stringWithFormat:@"addCSSRule('html', 'padding: 0px; height: %fpx; -webkit-column-gap: 0px; -webkit-column-width: %fpx;')", webView.frame.size.height, webView.frame.size.width];
    NSString *insertRule2 = [NSString stringWithFormat:@"addCSSRule('p', 'text-align: justify;')"];
    //NSString *setTextSizeRule = [NSString stringWithFormat:@"addCSSRule('body', '-webkit-text-size-adjust: %d%%;')",fontPercentSize];
    
    float pageOffset = currentPage * webView.bounds.size.width;
    NSString* goToOffsetFunc = [NSString stringWithFormat:@" function pageScroll(xOffset){ window.scroll(xOffset,0); } "];
    NSString* goTo =[NSString stringWithFormat:@"pageScroll(%f)", pageOffset];
    
    [webView stringByEvaluatingJavaScriptFromString:varMySheet];
    
    [webView stringByEvaluatingJavaScriptFromString:addCSSRule];
    
    [webView stringByEvaluatingJavaScriptFromString:insertRule1];
    
    [webView stringByEvaluatingJavaScriptFromString:insertRule2]; 
    
    [webView stringByEvaluatingJavaScriptFromString:goToOffsetFunc];
    [webView stringByEvaluatingJavaScriptFromString:goTo];
     */
    
    NSLog(@"END WEBVIEW FINISH LOAD");
}

#pragma mark - Back Button
- (void) btnBackDetailIsPressed: (id)sender
{
    //[self.ePubContent.chapters removeAllObjects];
    //[self.ePubContent.chapters release];
    //self.ePubContent.chapters = nil;
    
    [self.tempArray removeAllObjects];
    self.tempArray = nil;
    [self.tempArrayPT removeAllObjects];
    self.tempArrayPT = nil;
    
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - View lifecycle
- (void)viewWillAppear:(BOOL)animated
{
    self.isLoadTwoPages = YES;
    [self unzipAndParseFile];
    
    if (self.view.bounds.size.width > self.view.bounds.size.height) {
        NSLog(@"Landscape");
        [self.view setFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y - 32, self.view.bounds.size.height + 20, self.view.bounds.size.width)];
        flipper = [[[AFKPageFlipper alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height)] autorelease];
        NSLog(@"flipper : x = %f, y = %f", flipper.frame.origin.x, flipper.frame.origin.y);
    }
    else {
        NSLog(@"Portrait");
        [self.view setFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height)];
        flipper = [[[AFKPageFlipper alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height)] autorelease];
        NSLog(@"flipper : x = %f, y = %f", flipper.frame.origin.x, flipper.frame.origin.y);
    }
    
    
    // init array
    //self.tempArray = [[NSMutableArray alloc] initWithObjects:nil];

    // reset currentPDFPage
    flipper.currentPDFPage = 1;
    flipper.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //flipper.dataSource = self;    
    [self.view addSubview:flipper];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top_nosd.png"] forBarMetrics:UIBarMetricsDefault];
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *imgBack = [UIImage imageNamed:@"back_btt.png"];
    [btnBack setFrame:CGRectMake(0, 0, imgBack.size.width, imgBack.size.height)];
    [btnBack setImage:imgBack forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(btnBackDetailIsPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *btnItemBack = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    self.navigationItem.leftBarButtonItem = btnItemBack;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSLog(@"view did load");
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
    [self calculateNumberOfPages];
    
    if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)) {
        NSLog(@"Change to Portrait");
    }
    else {
        NSLog(@"Change to Landscape");
    }
    
    [flipper setCurrentPage:flipper.currentPage];
}

@end
