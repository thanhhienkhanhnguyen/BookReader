//
//  ItemDownload.m
//  BookReader
//
//  Created by mac on 4/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ItemDownload.h"

@implementation ItemDownload

@synthesize url = _url;
@synthesize downloaded = _downloaded;
@synthesize connection = _connection;
@synthesize fileData = _fileData;
@synthesize fileSize = _fileSize;
@synthesize isHide = _isHide;
@synthesize idBook = _idBook;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.url = @"";
        self.downloaded = 0;
        self.connection = nil;
        self.fileData = nil;
        self.fileSize = 0;
        self.isHide = YES;
        self.idBook = 0;
    }
    
    return self;
}

- (void)dealloc
{
    [self.url release];
    [self.connection release];
    [self.fileData release];
    [self.fileSize release];
    
    [super dealloc];
}

@end
