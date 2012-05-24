//
//  BookReaderAppDelegate.h
//  BookReader
//
//  Created by mac on 3/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BookReaderViewController;

@interface BookReaderAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BookReaderViewController *viewController;

@property (nonatomic) BOOL isLandscape;

@property (nonatomic) BOOL isForeground;

@property (nonatomic) BOOL isDownloadOwnBooks;

@property (nonatomic, retain) NSMutableArray *arrDownload;

@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;

@property (nonatomic, assign) NSMutableArray *arrOwnBooks;

@property (nonatomic, retain) NSMutableArray *arrBooks;

@property (nonatomic, retain) NSMutableArray *queueDownloadBook;

@end