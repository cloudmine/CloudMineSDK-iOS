#import "CMFileMetadata.h"
#import "CMObjectSerialization.h"

static NSString *const CMInternalOriginalKeyKey = @"__original_key__";
static NSString *const CMInternalContentTypeKey = @"content_type";
static NSString *const CMInternalFileNameKey    = @"filename";

static NSString *const CMInternalFileTypeValue  = @"file";

@interface CMFileMetadata ()
@property (nonatomic, nullable, readwrite) NSString *originalKey;
@property (nonatomic, nullable, readwrite) NSString *contentType;
@property (nonatomic, nullable, readwrite) NSString *fileName;
@end

@implementation CMFileMetadata

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (nil == self) { return nil; }
    
    _originalKey = [aDecoder decodeObjectForKey:CMInternalOriginalKeyKey];
    _contentType = [aDecoder decodeObjectForKey:CMInternalContentTypeKey];
    _fileName = [aDecoder decodeObjectForKey:CMInternalFileNameKey];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    if (nil != self.originalKey) {
        [aCoder encodeObject:self.originalKey forKey:CMInternalOriginalKeyKey];
    }
    
    if (nil != self.contentType) {
        [aCoder encodeObject:self.contentType forKey:CMInternalContentTypeKey];
    }
    
    if (nil != self.fileName) {
        [aCoder encodeObject:self.fileName forKey:CMInternalFileNameKey];
    }
    
    [aCoder encodeObject:CMInternalFileTypeValue forKey:CMInternalTypeStorageKey];
}

@end
