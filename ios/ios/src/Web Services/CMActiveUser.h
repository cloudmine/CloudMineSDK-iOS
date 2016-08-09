//
//  CMActiveUser.h
//  cloudmine-ios
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

/** @internal */
@interface CMActiveUser : NSObject <NSCoding>

@property (nonatomic, readonly, nullable) NSString *identifier;

+ (nonnull CMActiveUser *)currentActiveUser;

@end
