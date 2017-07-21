#import "CMObject.h"

/**
 *  Object for interacting directly with the metadata of a file saved in the
 *  CloudMine cloud, such as one uploaded with an instance of
 *  `CMFile`. These objects are created automatically by the backend and
 *  can be fetched after the file is uploaded. They should not be created
 *  directly. This object can be used to apply ACL's to user level files.
 *
 *  @warning Subclasses of this object will not properly re-serialize when
 *  fetched. Subclassing should be avoided.
 *
 */
@interface CMFileMetadata : CMObject

/**
 *  The original name of the file when created.
 */
@property (nonatomic, nullable, readonly) NSString *originalKey;

/**
 *  The type of file, as detected by the system. For example:
 *  image/png or application/octet, etc...
 */
@property (nonatomic, nullable, readonly) NSString *contentType;

/**
 *  The name of the file.
 */
@property (nonatomic, nullable, readonly) NSString *fileName;

@end
