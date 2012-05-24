//
//  ListBookViewController.h
//  BookReader
//
//  Created by mac on 3/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoBookViewController.h"

typedef enum {
    DefaultStoreMode = 0,
    MyStoreMode
} StoreMode;

@interface ListBookViewController : UITableViewController

@property (nonatomic, retain) NSMutableArray *books;
@property (nonatomic, assign) NSInteger idCategory;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSMutableData *bookData;

@property (nonatomic, retain) UIActivityIndicatorView *loadingIndicator;

@property (nonatomic, retain) NSURLConnection *getListConnection;
@property (nonatomic, retain) NSURLConnection *downloadConnection;

@property (nonatomic, assign) NSInteger typeTable;

//@property (nonatomic, retain) NSMutableArray *queueDownloadBook;

@property (nonatomic, retain) NSArray *arrOwnEbooks;


@end
