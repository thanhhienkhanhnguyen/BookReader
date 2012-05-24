//
//  SearchViewController.h
//  BookReader
//
//  Created by mac on 5/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UITableViewController <UISearchBarDelegate>
{
    UISearchDisplayController *searchDisplayController;
    UISearchDisplayController *searchBar;
    NSArray *allItems;
    NSArray *searchResults;
}

@property (nonatomic, retain) IBOutlet UITableView *tbView;
@property (nonatomic, retain) IBOutlet UISearchDisplayController *searchDisplayController;
@property (nonatomic, retain) IBOutlet UISearchDisplayController *searchBar;
@property (nonatomic, retain) NSArray *allItems;
@property (nonatomic, copy) NSArray *searchResults;
@property (nonatomic, retain) NSMutableData *dataResult;
@property (nonatomic, retain) NSMutableArray *books;
@property (nonatomic, retain) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) NSURLConnection *searchConnection;


@end
