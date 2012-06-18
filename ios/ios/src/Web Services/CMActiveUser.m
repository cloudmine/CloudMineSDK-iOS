//
//  CMActiveUser.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMActiveUser.h"
#import "NSString+UUID.h"

@implementation CMActiveUser
@synthesize identifier;

#pragma mark - Singleton access

+ (CMActiveUser *)currentActiveUser {
    __strong static CMActiveUser *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CMActiveUser *storedObject = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"cmau"]];
        if (!storedObject) {
            storedObject = [[CMActiveUser alloc] init];
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:storedObject] forKey:@"cmau"];
        }
        _sharedInstance = storedObject;
    });
    return _sharedInstance;
}

#pragma mark - Constructors

- (id)initWithUUID:(NSString *)uuid {
    if (self = [super init]) {
        identifier = uuid;
    }
    return self;
}

- (id)init {
    return [self initWithUUID:[[[NSString stringWithUUID] stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString]];
}

#pragma mark - Serialization

- (id)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithUUID:[aDecoder decodeObjectForKey:@"identifier"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:identifier forKey:@"identifier"];
}

- (BOOL)isEqual:(id)object {
    if (![[object class] isEqual:[self class]]) {
        return NO;
    } else {
        return [[object identifier] isEqualToString:identifier];
    }
}

@end
