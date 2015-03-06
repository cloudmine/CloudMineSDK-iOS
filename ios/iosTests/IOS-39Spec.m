//
//  IOS-39Spec.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 3/6/15.
//  Copyright (c) 2015 CloudMine, LLC. All rights reserved.
//

#import "Kiwi.h"
#import "CMObject.h"
#import "CMObjectDecoder.h"

@interface IOS39 : CMObject

@property (nonatomic, copy) NSDictionary *lookAlike;

@end

@implementation IOS39

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
{
    if ( self = ([super initWithCoder:aDecoder]) ) {
        self.lookAlike = [aDecoder decodeObjectForKey:@"lookAlike"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.lookAlike forKey:@"lookAlike"];
}

@end

SPEC_BEGIN(IOS39Spec)

// https://cloudminellc.atlassian.net/browse/IOS-39
/*
 * iOS Library should not Decode Dictionaries that look like CMObjects.
 * To be sure, check for the existence of a __type__ key, which CMObjects won't have.
 */

describe(@"CMObject Bug 39", ^{
    
    it(@"should deserialize a dictionary that looks similar to a CMObject, but has the __type__ key", ^{
        NSDictionary *fake =
        @{
        @"randomid": @{
          @"__class__": @"IOS39",
          @"name": @"something",
          @"lookAlike": @{
            @"__class__": @"map",
            @"preferences": @{
              @"__class__": @"map",
              @"reminders": @{
                @"medication": @YES,
                @"custom": @YES
              },
              @"contactBy": @{
                @"phone": @YES,
                @"email": @YES,
                @"text": @NO,
                @"push": @YES
              }
            }
         }
          }};
        
        NSArray *objects = [CMObjectDecoder decodeObjects:fake];
        NSLog(@"objects %@", objects);
        IOS39 *test = objects[0];
        [[test.lookAlike should] beKindOfClass:[NSDictionary class]];
        [[test.lookAlike[@"preferences"][@"reminders"][@"custom"] should] equal:theValue(YES)];
        [[test.lookAlike[@"preferences"][@"contactBy"][@"text"] should] equal:theValue(NO)];
    });
    
    
});

SPEC_END
