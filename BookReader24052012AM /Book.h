//
//  Book.h
//  BookReader
//
//  Created by mac on 4/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Book : NSObject

@property (nonatomic, assign) NSInteger idBook; 
@property (nonatomic, retain) NSString *bookTitle;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger chapter;
@property (nonatomic, retain) NSString *imageBig;
@property (nonatomic, retain) NSString *filePath;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *comments;
@property (nonatomic, retain) NSString *authors;
@property (nonatomic, retain) NSString *strRating;
@property (nonatomic, retain) NSString *strRatingCount;


@property (nonatomic, retain) NSString *pathBook;
@property (nonatomic, retain) NSString *imgBook;
@property (nonatomic, retain) NSString *imgDetailBook;
@property (nonatomic, retain) NSString *name;

@property (nonatomic, assign) BOOL isDownloaded;
@property (nonatomic, assign) BOOL isFilled;
@property (nonatomic, retain) UIImage *imgSaveBook;
@property (nonatomic, retain) UIImage *imgSaveDetailBook;


- (id)initWithIdBook:(NSInteger)idB NameBook:(NSString *)nameB ImageCoverPath:(NSString *)path FilePath:(NSString *)fPath;

@end
