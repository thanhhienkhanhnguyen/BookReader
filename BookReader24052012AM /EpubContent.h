

#import <Foundation/Foundation.h>

@interface EpubContent : NSObject {

	NSMutableDictionary *_manifest;
	NSMutableArray *_spine;
    NSMutableArray *chapters;
}

@property (nonatomic, retain) NSMutableDictionary *_manifest;
@property (nonatomic, retain) NSMutableArray *_spine; 
@property (nonatomic, retain) NSMutableArray *chapters;

@end
