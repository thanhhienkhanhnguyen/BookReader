//
//  DetailBookViewController.m
//  BookReader
//
//  Created by mac on 3/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailBookViewController.h"
#import "PDFRendererView.h"
#import "ChapterListPdfViewController.h"

@implementation DetailBookViewController

@synthesize pinchRecognizer = _pinchRecognizer;
@synthesize numberOfPages;
@synthesize zoomScrollView;
@synthesize pdfDocument;
@synthesize flipper = _flipper;
@synthesize isGoToPage;
@synthesize currentIdPage = _currentIdPage;

float lastScale = 0.0;
CGRect oldFrame;
NSInteger tagView = 0;


@synthesize contentView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isLandScape:(BOOL)value nameDocument:(NSString *)path
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //pdfDocument = CGPDFDocumentCreateWithURL((CFURLRef) [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:name ofType:@"pdf"]]);
        self.pdfDocument = CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path]);
        isLandScape = value;
        isGoToPage = NO;
        [self loadView];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Button navigation bar

- (void)setCurrentIdPage:(NSInteger)data
{
    _currentIdPage = data;
    NSLog(@"new value = %i,set current id page = %i", data, _currentIdPage);
    
    if (self.isGoToPage) {
        if (data != self.flipper.currentPDFPage) {
            [pagesPopover dismissPopoverAnimated:YES];
            
            self.flipper.currentPDFPage = _currentIdPage;
            [self.flipper setCurrentPage:self.flipper.currentPDFPage animated:YES];
            
        }
        self.isGoToPage = NO;
    }
}

- (void)btnPagesListIsPressed:(id)sender
{
    
    if (pagesPopover == nil) {
        /*
        ChapterListEPubViewController *chapterListView = [[ChapterListEPubViewController alloc] initWithNibName:@"ChapterListEPubViewController" bundle:[NSBundle mainBundle]];
        chapterListView.ePubViewController = self;
        
        pagesPopover = [[UIPopoverController alloc] initWithContentViewController:chapterListView];
        [pagesPopover setPopoverContentSize:CGSizeMake(400, 600)];
        [chapterListView release];
         */
        //isGoToPage = NO;
        NSLog(@"create pagepover");
        ChapterListPdfViewController *pageListView = [[ChapterListPdfViewController alloc] initWithNibName:@"ChapterListPdfViewController" bundle:[NSBundle mainBundle]];
        pageListView.pdfViewController = self;
        pagesPopover = [[UIPopoverController alloc] initWithContentViewController:pageListView];
        [pagesPopover setPopoverContentSize:CGSizeMake(150, 50)];
        [pageListView release];
    }
    
    if ([pagesPopover isPopoverVisible]) {
        //isGoToPage = NO;
        [pagesPopover dismissPopoverAnimated:YES];
    }
    else {
        NSLog(@"btnPage: current page = %i", self.flipper.currentPDFPage);
        self.isGoToPage = NO;
        self.currentIdPage = self.flipper.currentPDFPage;
        //[self setCurrentIdPage:self.flipper.currentPDFPage];
        NSLog(@"after set : idPage = %i", currentIdPage);
        //isGoToPage = YES;
        [pagesPopover presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

#pragma mark - Back Button
- (void) btnBackDetailIsPressed: (id)sender
{
    /*
    if (self.zoomScrollView != nil) {
        [self.zoomScrollView removeFromSuperview];
        self.zoomScrollView = nil;
    }
    */
    if ([pagesPopover isPopoverVisible]) {
        //isGoToPage = NO;
        [pagesPopover dismissPopoverAnimated:YES];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark ScrollView

- (void)exitZoom
{   
    /*
    for (UIView *view in [self.zoomScrollView subviews]) {
        [view removeFromSuperview];
    }
     */
    [self.zoomScrollView removeFromSuperview];
    self.zoomScrollView = nil;
}

- (void)beginZoom
{
    PDFRendererView *tempView;
    
    if (self.view.bounds.size.width > self.view.bounds.size.height) {
        tempView = [[PDFRendererView alloc] initWithFrame:CGRectMake(self.flipper.bounds.origin.x, self.flipper.bounds.origin.y, self.self.flipper.bounds.size.width, self.flipper.bounds.size.height * 2)];
    }
    else {
        tempView = [[PDFRendererView alloc] initWithFrame:CGRectMake(self.flipper.bounds.origin.x, self.flipper.bounds.origin.y, self.flipper.bounds.size.width * 1.5, self.flipper.bounds.size.height * 1.5)];
    }
    
    tempView.pdfDocument = pdfDocument;
    tempView.pageNumber = 2;
    tempView.pagePdfNumber = tagView;
    
    //self.contentView = tempView;
    [self setContentView:tempView];
    
    [self.zoomScrollView addSubview:self.contentView];
    [contentView release];
    
    self.zoomScrollView.showsHorizontalScrollIndicator = YES;
    self.zoomScrollView.showsVerticalScrollIndicator = YES;
    
    [self.zoomScrollView setContentSize:self.contentView.frame.size];
    [self.zoomScrollView setMaximumZoomScale:5.0];
    [self.zoomScrollView setMinimumZoomScale:0.6];
    
    if (self.view.bounds.size.width > self.view.bounds.size.height) {
        self.zoomScrollView.zoomScale = 1.0;
    }
    else {
        self.zoomScrollView.zoomScale = lastScale;
        NSLog(@"portrait zoom scale = %f", lastScale);
    }
    
    
    self.zoomScrollView.delegate = self;
    self.zoomScrollView.clipsToBounds = YES;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    NSLog(@"zoom");
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    NSLog(@"scale zoom : %f", scale);
    if (scale < 0.7) {
        NSLog(@"END");
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(exitZoom)];
        
    
        for (UIView *view in [self.zoomScrollView subviews]) {
            [view removeFromSuperview];
        }
        
        
        [self.zoomScrollView setFrame:oldFrame];
        [self.zoomScrollView setContentSize:oldFrame.size];
        
        [UIView commitAnimations];
 
    }
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return contentView;
}

#pragma mark -
#pragma mark Gesture
- (void) pinched:(UIPinchGestureRecognizer *) recognizer
{
    NSLog(@"scale = %f", recognizer.scale);
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"begin");
            
            /*
            currentScale += [recognizer scale] - lastScale;
            lastScale = [recognizer scale];
            
            NSLog(@"current scale = %f", currentScale);
    
            
            CGAffineTransform currentTransform = CGAffineTransformIdentity;
            CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, currentScale, currentScale);
            recognizer.view.transform = newTransform;
             */
            
            ///CGAffineTransform transform = CGAffineTransformMakeScale(recognizer.scale, recognizer.scale);
            // you can implement any int/float value in context of what scale you want to zoom in or out
            //recognizer.view.transform = transform;
            
            //NSLog(@"current view: height = %f | width = %f", recognizer.view.frame.size.height, recognizer.view.frame.size.width);
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"end");
            NSLog(@"SCALE = %f", recognizer.scale);
            
            if (recognizer.scale > 1.0) {
                tagView = [recognizer.view tag];
                oldFrame = recognizer.view.frame;
                lastScale = recognizer.scale;
                self.zoomScrollView = [[UIScrollView alloc] initWithFrame:recognizer.view.frame];
                [self.zoomScrollView setBackgroundColor:[UIColor colorWithRed:1/255.0f green:1/255.0f blue:1/255.0f alpha:0.8]];
                [self.view addSubview:zoomScrollView];
                [zoomScrollView release];
                
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.5];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDidStopSelector:@selector(beginZoom)];
                //[UIView setAnimationDelay:1.0];
                
                [self.zoomScrollView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
                
                [UIView commitAnimations];
                
                 //[self.view addSubview:self.zoomScrollView];
                 //[self.zoomScrollView release];
                 
            }
            
            break;
        default:
            break;
    }
}



#pragma mark -
#pragma mark View management

- (void) loadView {
	[super loadView];
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    if (isLandScape) {
        [self.view setFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y - 32, self.view.bounds.size.height + 20, self.view.bounds.size.width)];
        self.flipper = [[[AFKPageFlipper alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height)] autorelease];
        NSLog(@"flipper : x = %f, y = %f", self.flipper.frame.origin.x, self.flipper.frame.origin.y);
    }
    else {
        [self.view setFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y - 22, self.view.bounds.size.width, self.view.bounds.size.height)];
        self.flipper = [[[AFKPageFlipper alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height)] autorelease];
        NSLog(@"flipper : x = %f, y = %f", self.flipper.frame.origin.x, self.flipper.frame.origin.y);
    }
    
	
    self.flipper.pageMode = 0;
	self.flipper.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.flipper.dataSource = self;
	
	[self.view addSubview:self.flipper];
    [_flipper release];
}

- (void)calculateNumberOfPages
{
    //numberOfPages = self.view.bounds.size.width > self.view.bounds.size.height ? ceil((float) (CGPDFDocumentGetNumberOfPages(pdfDocument) - flipper.currentPDFPage - 1) / 2) : CGPDFDocumentGetNumberOfPages(pdfDocument);
    NSInteger num = CGPDFDocumentGetNumberOfPages(pdfDocument);
    NSLog(@"NUM pdt = %i", num);
    if (self.view.bounds.size.width > self.view.bounds.size.height) {
        numberOfPages = num / 2;
        if (num % 2 != 0) {
            numberOfPages++;
        }
    }
    else {
        numberOfPages = num;
    }
}

- (NSInteger)getNumberOfPDFPage
{
   return CGPDFDocumentGetNumberOfPages(pdfDocument);
}

#pragma mark -
#pragma mark Data source implementation

- (NSInteger) numberOfPagesForPageFlipper:(AFKPageFlipper *)pageFlipper {
    [self calculateNumberOfPages];
    //numberOfPages = self.view.bounds.size.width > self.view.bounds.size.height ? ceil((float) CGPDFDocumentGetNumberOfPages(pdfDocument) / 2) : CGPDFDocumentGetNumberOfPages(pdfDocument);
	return numberOfPages;
}

- (UIView *) viewForPage:(NSInteger) page inFlipper:(AFKPageFlipper *) pageFlipper {
    UIView *viewPage = [[UIView alloc] initWithFrame:self.view.frame];
    NSLog(@"pdf = %i", pageFlipper.currentPDFPage);
    /*
	PDFRendererView *result = [[[PDFRendererView alloc] initWithFrame:pageFlipper.bounds] autorelease];
	result.pdfDocument = pdfDocument;
	result.pageNumber = page;
    
    //For BookReader
    result.pagePdfNumber = pageFlipper.currentPDFPage;
	
    [viewPage addSubview:result]; */
    
    // Landscape
    if (self.view.bounds.size.width > self.view.bounds.size.height || isLandScape) {
        NSLog(@"Landscape");
        NSLog(@"flipper page : x = %f | y = %f", pageFlipper.bounds.origin.x, pageFlipper.bounds.origin.y);
        PDFRendererView *result1 = [[PDFRendererView alloc] initWithFrame:CGRectMake(pageFlipper.bounds.origin.x, pageFlipper.bounds.origin.y, pageFlipper.bounds.size.width / 2, pageFlipper.bounds.size.height)];
        result1.pdfDocument = pdfDocument;
        result1.pageNumber = page;
        result1.pagePdfNumber = pageFlipper.currentPDFPage;
        
        //self.contentView = result1;
        
        self.pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinched:)];
        [result1 addGestureRecognizer:self.pinchRecognizer];
        [self.pinchRecognizer release];
        
        //UIScrollView *scrollViewRS1 = [[UIScrollView alloc] initWithFrame:result1.frame];
        //[scrollViewRS1 setMaximumZoomScale:3.0];
        //[scrollViewRS1 setMinimumZoomScale:1];
        //[scrollViewRS1 setContentSize:result1.frame.size];
        //[scrollViewRS1 addSubview:result1];
        //[result1 release];
        //scrollViewRS1.delegate = self;
        //scrollViewRS1.clipsToBounds = YES;
        [result1 setTag:pageFlipper.currentPDFPage];
        [viewPage addSubview:result1];
        
        [result1 release];
        //[scrollViewRS1 release];
        
        if (pageFlipper.currentPage + 1 <= CGPDFDocumentGetNumberOfPages(pdfDocument)) {
            PDFRendererView *result2 = [[PDFRendererView alloc] initWithFrame:CGRectMake(result1.frame.size.width, pageFlipper.bounds.origin.y, pageFlipper.bounds.size.width / 2, pageFlipper.bounds.size.height)];
            [result2 setFrame:CGRectMake(result1.frame.size.width, result1.frame.origin.y, result1.frame.size.width, result1.frame.size.height)];
            //result2.frame.origin.x = result1.frame.size.width;
            result2.pdfDocument = pdfDocument;
            result2.pageNumber = page;
            result2.pagePdfNumber = pageFlipper.currentPDFPage + 1;
            
            self.pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinched:)];
            [result2 addGestureRecognizer:self.pinchRecognizer];
            [self.pinchRecognizer release];
            
            [result2 setTag:pageFlipper.currentPDFPage + 1];
            [viewPage addSubview:result2]; 
            
            [result2 release];
        }
    }
    // Portrait
    else {
        NSLog(@"Portrait");
        PDFRendererView *result = [[PDFRendererView alloc] initWithFrame:CGRectMake(pageFlipper.bounds.origin.x, pageFlipper.bounds.origin.y, pageFlipper.bounds.size.width, pageFlipper.bounds.size.height)];
        result.pdfDocument = pdfDocument;
        result.pageNumber = page;
        result.pagePdfNumber = pageFlipper.currentPDFPage;
        [result setTag:pageFlipper.currentPDFPage];
        self.pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinched:)];
        [result addGestureRecognizer:self.pinchRecognizer];
        [self.pinchRecognizer release];
        
        [viewPage addSubview:result]; 
        [result release];
    }
    
	return viewPage;
}

#pragma mark -
#pragma mark Initialization and memory management
- (void)dealloc {
	CGPDFDocumentRelease(pdfDocument);
    pdfDocument = nil;
    
    [pagesPopover release];
    pagesPopover = nil;
    
    [_flipper release];
    _flipper = nil;
    
    [zoomScrollView release];
    zoomScrollView = nil;
    
    
    [super dealloc];
}

#pragma mark - View lifecycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top_nosd.png"] forBarMetrics:UIBarMetricsDefault];
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *imgBack = [UIImage imageNamed:@"back_btt.png"];
    [btnBack setFrame:CGRectMake(0, 0, imgBack.size.width, imgBack.size.height)];
    [btnBack setImage:imgBack forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(btnBackDetailIsPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *btnItemBack = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    self.navigationItem.leftBarButtonItem = btnItemBack;
    [btnItemBack release];
    
    UIBarButtonItem *btnPagesList = [[UIBarButtonItem alloc] initWithTitle:@"Pages" style:UIBarButtonItemStyleBordered target:self action:@selector(btnPagesListIsPressed:)];
    self.navigationItem.rightBarButtonItem = btnPagesList;
    [btnPagesList release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    /*
    if (self.zoomScrollView != nil) {
        [self.zoomScrollView removeFromSuperview];
        self.zoomScrollView = nil;
    }
    */
     
    if ([pagesPopover isPopoverVisible]) {
        isGoToPage = NO;
        [pagesPopover dismissPopoverAnimated:YES];
    }
    
    [self calculateNumberOfPages];
    NSLog(@"NUM PAGE = %i", numberOfPages);
    // Portrait
    if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)) {
        NSLog(@"Change to Portrait");
        isLandScape = NO;
    }
    // Landscape
    else {
        NSLog(@"Change to Landscape");
        isLandScape = YES;
    }
    
    //NSInteger tmpCurrentPage = flipper.currentPage;
    /*
    if (flipper.currentPage == 3) {
        [flipper setCurrentPage:2];
    }
    else {
        [flipper setCurrentPage:3];
    }
     */
    NSLog(@"flipper.currentpage = %i", self.flipper.currentPDFPage);
    [self.flipper setCurrentPage:flipper.currentPage];
    
    //flipper.currentPage = tmpCurrentPage;
   
}

@end
