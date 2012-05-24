//
//  ChapterListPdfViewController.h
//  BookReader
//
//  Created by mac on 4/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailBookViewController.h"

@interface ChapterListPdfViewController : UIViewController

@property (nonatomic, retain) DetailBookViewController *pdfViewController;
@property (nonatomic, retain) IBOutlet UITextField *txtPage;
@property (nonatomic, retain) IBOutlet UILabel *txtTotalPages;

- (IBAction)goBtnIsPressed:(id)sender;

@end
