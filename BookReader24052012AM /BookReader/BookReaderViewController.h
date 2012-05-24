//
//  BookReaderViewController.h
//  BookReader
//
//  Created by mac on 3/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"
#import "FBRequest.h"
#import <QuartzCore/QuartzCore.h>

@interface BookReaderViewController : UIViewController <FBSessionDelegate, FBRequestDelegate, UIAlertViewDelegate>


@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSMutableData *booksData;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) NSURLConnection *sendIDConnection;
@property (nonatomic, retain) NSURLConnection *getOwnBooksConnection;
@property (nonatomic, retain) NSMutableArray *arrOwnBooks;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UIView *loadingView;

- (void)btnCategoryIsPressed:(id)sender;
- (void)getUserInfo;

@end
