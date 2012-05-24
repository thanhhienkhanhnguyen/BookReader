//
//  DetailBookViewController.h
//  BookReader
//
//  Created by mac on 3/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFKPageFlipper.h"

@interface DetailBookViewController : UIViewController <AFKPageFlipperDataSource, UIScrollViewDelegate>
{
    CGPDFDocumentRef pdfDocument;
    AFKPageFlipper *flipper;
    BOOL isLandScape;
    BOOL isGoToPage;
    NSInteger numberOfPages;
    NSInteger currentIdPage;
    
    UIView *contentView;
    UIScrollView *zoomScrollView;
    
    UIPopoverController *pagesPopover;
}

@property (nonatomic, retain) UIPinchGestureRecognizer *pinchRecognizer;
@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, retain) UIScrollView *zoomScrollView;
@property (nonatomic, assign) CGPDFDocumentRef pdfDocument;
@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign) NSInteger currentIdPage;
@property (nonatomic, retain) AFKPageFlipper *flipper;
@property (nonatomic, assign) BOOL isGoToPage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isLandScape:(BOOL)value nameDocument:(NSString *)name;
- (NSInteger)getNumberOfPDFPage;

@end
