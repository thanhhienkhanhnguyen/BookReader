//
//  InfoBookViewController.h
//  BookReader
//
//  Created by mac on 4/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoBookViewController : UIViewController

@property (nonatomic, retain) NSMutableData *dataBook;
@property (nonatomic, retain) NSMutableData *dataDownloadBook;
@property (nonatomic, retain) NSMutableData *dataSendIdBook;

@property (nonatomic, assign) NSInteger idBook;
@property (nonatomic, retain) NSString *bookTitle;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger chapter;
@property (nonatomic, retain) NSString *imageBig;
@property (nonatomic, retain) NSString *filePath;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *comments;
@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSString *strRating;
@property (nonatomic, retain) NSString *strRatingCount;

@property (nonatomic, retain) NSURLConnection *connectionDetailBook;
@property (nonatomic, retain) NSURLConnection *connectionDownloadBook;
@property (nonatomic, retain) NSURLConnection *connectionSendIdBook;

@property (nonatomic, retain) UIAlertView *alertLoading;

@property (nonatomic, retain) UIActivityIndicatorView *loadIndicator;

@property (nonatomic, assign) BOOL isDownloaded;

@property (nonatomic, assign) BOOL isImgLoaded;

@property (nonatomic, assign) BOOL isLandscape;

@property (nonatomic, assign) BOOL isOwnBook;

@property (nonatomic, assign) UIProgressView *progressView;

@property (nonatomic, retain) NSNumber *fileSize;

@property (nonatomic, retain) NSDictionary *book;

@property (nonatomic, retain) NSTimer *timer;


- (IBAction)btnReadIsPressed:(id)sender;

@end
