//
//  CMActiveUser.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

/** @internal */
@interface CMActiveUser : NSObject <NSCoding>

@property (nonatomic, readonly) NSString *identifier;

+ (CMActiveUser *)currentActiveUser;

@end
