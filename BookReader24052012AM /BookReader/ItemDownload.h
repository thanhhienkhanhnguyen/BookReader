//
//  ItemDownload.h
//  BookReader
//
//  Created by mac on 4/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemDownload : NSObject


@property (nonatomic, retain) NSString *url;
@property (nonatomic, assign) float downloaded;
@property (nonatomic, assign) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *fileData;
@property (nonatomic, retain) NSNumber *fileSize;
@property (nonatomic, assign) BOOL isHide;
@property (nonatomic, assign) NSInteger idBook;

@end
