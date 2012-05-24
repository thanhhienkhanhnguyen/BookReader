//
//  DetailBookWebViewController.h
//  BookReader
//
//  Created by mac on 3/29/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailBookWebViewController : UIViewController


@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSString *urlView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil nameWeb:(NSString *)url;
@end
