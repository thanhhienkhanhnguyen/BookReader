

#import "XMLHandler.h"


@implementation XMLHandler
@synthesize delegate;

- (void)parseXMLFileAt:(NSString*)strPath{

	_parser=[[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:strPath]];
	_parser.delegate=self;
	[_parser parse];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	
	NSLog(@"Error Occured : %@",[parseError description]);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
	
	if ([elementName isEqualToString:@"rootfile"]) {
		
		_rootPath=[attributeDict valueForKey:@"full-path"];
		if ((delegate!=nil)&&([delegate respondsToSelector:@selector(foundRootPath:)])) {
			
			[delegate foundRootPath:_rootPath];
		}
	}
	
	if ([elementName isEqualToString:@"package"]){
	
		_epubContent=[[EpubContent alloc] init];
	}
	
	if ([elementName isEqualToString:@"manifest"]) {
		
		_itemdictionary=[[NSMutableDictionary alloc] init];
	}
	
	if ([elementName isEqualToString:@"item"]) {
		//NSLog(@"manifest = %@", [attributeDict valueForKey:@"href"]);
		[_itemdictionary setValue:[attributeDict valueForKey:@"href"] forKey:[attributeDict valueForKey:@"id"]];
	}
	
	if ([elementName isEqualToString:@"spine"]) {
		countSpine = 0;
		_spinearray=[[NSMutableArray alloc] init];
        chapters = [[NSMutableArray alloc] init];
	}
	
	if ([elementName isEqualToString:@"itemref"]) {
        //ChapterEPub *chapter = [[ChapterEPub alloc] initWithPath:<#(NSString *)#> IndexChapter:<#(NSInteger)#>]
        NSLog(@"item spine = %@", [attributeDict valueForKey:@"idref"]);
        
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        NSString *strOpfFilePath=[NSString stringWithFormat:@"%@/UnzippedEpub/%@", basePath, [attributeDict valueForKey:@"full-path"]];
        NSString *rPath=[strOpfFilePath stringByReplacingOccurrencesOfString:[strOpfFilePath lastPathComponent] withString:@""];
        
        NSString *chapterPath = [NSString stringWithFormat:@"%@OPS/%@", rPath, [_epubContent._manifest valueForKey:[attributeDict valueForKey:@"idref"]]];
        NSLog(@"chapterPath = %@", chapterPath);
        
        ChapterEPub *chapter = [[ChapterEPub alloc] initWithPath:chapterPath IndexChapter:countSpine++];
        
        [chapters addObject:chapter];
        [chapter release];
		[_spinearray addObject:[attributeDict valueForKey:@"idref"]];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     
	
		if ([elementName isEqualToString:@"manifest"]) {
			
			_epubContent._manifest=_itemdictionary;
		}
		if ([elementName isEqualToString:@"spine"]) {
			
			_epubContent._spine=_spinearray;
            _epubContent.chapters = chapters;
            NSLog(@"end Element SPINE, spinearray = %i", [_spinearray count]);
		}
	
		if ([elementName isEqualToString:@"package"]) {
		
			if ((delegate!=nil)&&([delegate respondsToSelector:@selector(finishedParsing:)])) {
				
				[delegate finishedParsing:_epubContent];
			}
		}

}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	

}
@end
