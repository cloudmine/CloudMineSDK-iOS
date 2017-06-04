#import "CMObject.h"

@interface CMFileMetadata : CMObject

@property (nonatomic, nullable, readonly) NSString *originalKey;
@property (nonatomic, nullable, readonly) NSString *contentType;
@property (nonatomic, nullable, readonly) NSString *fileName;

@end
