//
//  Book.m
//  BookReader
//
//  Created by mac on 4/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Book.h"

@implementation Book

//@synthesize idBook, name, pathBook, description, isDownloaded, imgBook, imgDetailBook;
//@synthesize imgSaveBook, imgSaveDetailBook, page, chapter;

@synthesize pathBook = _pathBook;
@synthesize imgBook = _imgBook;
@synthesize imgDetailBook = _imgDetailBook;
@synthesize name = _name;
@synthesize description = _description;
@synthesize imgSaveBook = _imgSaveBook;
@synthesize imgSaveDetailBook = _imgSaveDetailBook;

@synthesize bookTitle = _bookTitle;
@synthesize imageBig = _imageBig;
@synthesize filePath = _filePath;
@synthesize comments = _comments;
@synthesize authors = _authors;
@synthesize strRating = _strRating;
@synthesize strRatingCount = _strRatingCount;

@synthesize idBook =_idBook;
@synthesize isDownloaded = _isDownloaded;
@synthesize isFilled = _isFilled;
@synthesize page = _page;
@synthesize chapter = _chapter;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithIdBook:(NSInteger)idB NameBook:(NSString *)nameB ImageCoverPath:(NSString *)path FilePath:(NSString *)fPath
{
    self.idBook = idB;
    self.name = nameB;
    self.imgBook = path;
    self.pathBook = fPath;
    
    self.imgDetailBook = @"";
    self.description = @"";
    self.chapter = 0;
    self.page = 0;
    self.isDownloaded = NO;
    self.isFilled = NO;
    
    self.imgSaveBook = nil;
    self.imgSaveDetailBook = nil;
    
    return self;
}

- (void)dealloc
{
    [_pathBook release];
    _pathBook = nil;
    
    [_imgBook release];
    _imgBook = nil;
    
    [_imgDetailBook release];
    _imgDetailBook = nil;
    
    [_name release];
    _name = nil;
    
    [_description release];
    _description = nil;
    
    [_imgSaveBook release];
    _imgSaveBook = nil;
    
    [_imgSaveDetailBook release];
    _imgSaveDetailBook = nil;
    
    [super dealloc];
}

@end
