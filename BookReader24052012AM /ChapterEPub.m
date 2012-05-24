//
//  ChapterEPub.m
//  BookReader
//
//  Created by mac on 4/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ChapterEPub.h"

@implementation ChapterEPub

@synthesize delegate;
@synthesize spinePath;
@synthesize numPages;
@synthesize idChapter;
@synthesize chapWebView;
@synthesize frameSize;
@synthesize isLoaded;
@synthesize isLoadPages;
@synthesize isReload;
@synthesize totalHeight;
@synthesize pages;
@synthesize currentPage;

/*
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
*/

- (id)initWithPath:(NSString *)chapterPath IndexChapter:(NSInteger)indexChapter
{
    self = [super init];
    if (self) {
        // Initialization
        self.spinePath = chapterPath;
        self.idChapter = indexChapter;
        self.isLoaded = NO;
        self.isReload = NO;
        self.isLoadPages = NO;
        self.pages = [[NSMutableArray alloc] initWithObjects: nil];
    }
    return self;
}

- (void)gotoPageInChapter:(NSInteger)pageIndex
{
    float pageOffset = pageIndex * self.chapWebView.bounds.size.width;
    NSLog(@"chapWebView.width = %f | pageOffset = %f", self.chapWebView.bounds.size.width, pageOffset);
    
	NSString* goToOffsetFunc = [NSString stringWithFormat:@" function pageScroll(yOffset){ window.scroll(yOffset, 0); } "];
	NSString* goTo = [NSString stringWithFormat:@"pageScroll(%f)", pageOffset];
	
	[self.chapWebView stringByEvaluatingJavaScriptFromString:goToOffsetFunc];
	[self.chapWebView stringByEvaluatingJavaScriptFromString:goTo];
}


- (void)loadChapterWithFrameSize:(CGRect)theWindowSize
{
    /*
    self.chapWebView = [[UIWebView alloc] initWithFrame:self.frameSize];
    self.chapWebView.scrollView.scrollEnabled = NO;
    self.chapWebView.scrollView.bounces = NO;
    [self.chapWebView setDelegate:self];
    [self.chapWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:self.spinePath]]];
     */
    //self.isLoadPages = NO;
    NSLog(@"begin paging on chap with (height = %f | width = %f)", theWindowSize.size.height, theWindowSize.size.width);
    UIWebView *webView = [[UIWebView alloc] initWithFrame:theWindowSize];
    webView.scrollView.scrollEnabled = NO;
    webView.scrollView.bounces = NO;
    [webView setDelegate:self];
    //[webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:self.spinePath]]];
    NSLog(@"spinePath = %@", self.spinePath);
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:self.spinePath]]];
    
    [self.pages addObject:webView];
    [webView release];
}

- (void)loadPageWithFrameSize:(CGRect)theWindowSize
{
    self.isLoadPages = YES;
    
    if (self.numPages == 1) {
        [delegate pageInChapEPubDidFinishLoad:self];
    }
    else {
        NSLog(@"begin load page: %i on chapter: %i", [self.pages count], self.idChapter);
        UIWebView *webView = [[UIWebView alloc] initWithFrame:theWindowSize];
        webView.scrollView.scrollEnabled = NO;
        webView.scrollView.bounces = NO;
        [webView setDelegate:self];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:self.spinePath]]];
        
        [self.pages addObject:webView];
        [webView release];
    }
}


#pragma mark - WebView Delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (self.isReload == NO) {
        NSLog(@"webView finish load");
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
        
        
        [webView stringByEvaluatingJavaScriptFromString:varMySheet];
        
        [webView stringByEvaluatingJavaScriptFromString:addCSSRule];
        
        [webView stringByEvaluatingJavaScriptFromString:insertRule1];
        
        [webView stringByEvaluatingJavaScriptFromString:insertRule2];
        
        // Load page on chapter
        if (self.isLoadPages) {
            float pageOffset = ([self.pages count] - 1) * webView.bounds.size.width;
            
            NSString* goToOffsetFunc = [NSString stringWithFormat:@" function pageScroll(xOffset){ window.scroll(xOffset,0); } "];
            NSString* goTo =[NSString stringWithFormat:@"pageScroll(%f)", pageOffset];
            
            [webView stringByEvaluatingJavaScriptFromString:goToOffsetFunc];
            [webView stringByEvaluatingJavaScriptFromString:goTo];
            
            [delegate pageInChapEPubDidFinishLoad:self];
        }
        // Load chapter to cal num of pages
        else {
            NSInteger totalWidth = [[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollWidth"] intValue];
            NSLog(@"totalWidth = %i", totalWidth);
            NSLog(@"webviewWidth = %f", webView.bounds.size.width);
            NSLog(@"page = %f", totalWidth / webView.bounds.size.width);
            self.numPages = (int)roundf((float)totalWidth/webView.bounds.size.width);
            
            NSLog(@"Page %i, numPage = %i", self.idChapter, self.numPages);
            
            [delegate chapterEPubDidFinishLoad:self];
        }
    }
    else {
        NSLog(@"RELOAD");
        //self.isReload = NO;
        
        /*
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
        
        
        [webView stringByEvaluatingJavaScriptFromString:varMySheet];
        
        [webView stringByEvaluatingJavaScriptFromString:addCSSRule];
        
        [webView stringByEvaluatingJavaScriptFromString:insertRule1];
        
        [webView stringByEvaluatingJavaScriptFromString:insertRule2];
        
        
        float pageOffset = (self.currentPage - 1) * webView.bounds.size.width;
        
        NSString* goToOffsetFunc = [NSString stringWithFormat:@" function pageScroll(xOffset){ window.scroll(xOffset,0); } "];
        NSString* goTo =[NSString stringWithFormat:@"pageScroll(%f)", pageOffset];
        
        [webView stringByEvaluatingJavaScriptFromString:goToOffsetFunc];
        [webView stringByEvaluatingJavaScriptFromString:goTo];
        */
        
        
    }
}

@end
