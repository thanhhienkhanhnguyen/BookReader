//
//  DetailBookEpubViewController.h
//  BookReader
//
//  Created by mac on 3/30/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZipArchive.h"
#import "XMLHandler.h"
#import "EpubContent.h"
#import "AFKPageFlipper.h"
#import "ChapterEPub.h"


@interface DetailBookEpubViewController : UIViewController <XMLHandlerDelegate, AFKPageFlipperDataSource, ChapterEPubDelegate, UIWebViewDelegate, UIPopoverControllerDelegate>
{
    XMLHandler *xmlHandler;
    EpubContent *ePubContent;
    
    NSString *pagesPath;
    NSString *rtPath;
    NSString *strFileName;
    
    int _pageNumber;
    NSInteger totalPageAllChapters;
    NSInteger numOfPages;
    
    AFKPageFlipper *flipper;
    
    NSTimer *timer;
    
    NSMutableArray *tempArray;
    NSMutableArray *tempArrayPT;
    
    UIPopoverController *chaptersPopover;
    
    BOOL isLoadTwoPages;
}

@property (nonatomic, retain) XMLHandler *xmlHandler;
@property (nonatomic, retain) EpubContent *ePubContent;
@property (nonatomic, retain) NSString *pagesPath;
@property (nonatomic, retain) NSString *rtPath;
@property (nonatomic, retain) NSString *strFileName;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) NSMutableArray *tempArray;
@property (nonatomic, retain) NSMutableArray *tempArrayPT;
@property (nonatomic, assign) BOOL isLoadTwoPages;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil nameDocument:(NSString *)name;
- (NSString*)getRootFilePath;
- (void)unzipAndSaveFile;
- (NSString *)applicationDocumentsDirectory; 
- (void)loadPage;
- (void)loadWebView:(UIWebView *)wView atPage:(NSInteger)page;
- (void)unzipAndParseFile;

@end
