//
//  ChapterListEPubViewController.h
//  BookReader
//
//  Created by mac on 4/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailBookEpubViewController.h"

@interface ChapterListEPubViewController : UITableViewController
{
    DetailBookEpubViewController *ePubViewController;
}

@property (nonatomic, retain) DetailBookEpubViewController *ePubViewController;

@end
