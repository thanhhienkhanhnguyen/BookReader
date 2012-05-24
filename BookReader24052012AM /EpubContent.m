

#import "EpubContent.h"

@implementation EpubContent

@synthesize _manifest;
@synthesize _spine;
@synthesize chapters = _chapters;

- (void) dealloc{

	[_manifest release];
	_manifest=nil;
	[_spine release];
	_spine=nil; 
    [chapters release];
    chapters = nil;
	[super dealloc];
}

@end
