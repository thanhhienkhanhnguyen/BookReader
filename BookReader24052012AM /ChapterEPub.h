//
//  ChapterEPub.h
//  BookReader
//
//  Created by mac on 4/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ChapterEPub;

@protocol ChapterEPubDelegate <NSObject>
@required
- (void)chapterEPubDidFinishLoad:(ChapterEPub *)chapter;
- (void)pageInChapEPubDidFinishLoad:(ChapterEPub *)chapter;
@end

@interface ChapterEPub : NSObject <UIWebViewDelegate>
{
    id <ChapterEPubDelegate> delegate;
    BOOL isLoaded;
    BOOL isLoadPages;
    BOOL isReload;
}

@property (nonatomic, retain) NSString *spinePath;
@property (nonatomic, assign) NSInteger numPages;
@property (nonatomic, assign) NSInteger idChapter;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, retain) UIWebView *chapWebView;
@property (nonatomic, assign) CGRect frameSize;
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) BOOL isLoaded;
@property (nonatomic, assign) BOOL isLoadPages;
@property (nonatomic, assign) BOOL isReload;
@property (nonatomic, assign) NSInteger totalHeight;
@property (nonatomic, retain) NSMutableArray *pages;

- (id)initWithPath:(NSString *)chapterPath IndexChapter:(NSInteger)indexChapter;
- (void)loadChapterWithFrameSize:(CGRect)theWindowSize;
- (void)gotoPageInChapter:(NSInteger)pageIndex;
- (void)loadPageWithFrameSize:(CGRect)theWindowSize;
@end
