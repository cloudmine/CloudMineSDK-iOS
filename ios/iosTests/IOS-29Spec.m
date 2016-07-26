//
//  IOS-29Spec.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 12/15/14.
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//

#import "Kiwi.h"
#import "CMObject.h"
#import "CMTestMacros.h"

@interface IOS29 : CMObject

@property (nonatomic, copy) NSString *uuid;

@end

@implementation IOS29

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
{
    if ( self = ([super initWithCoder:aDecoder]) ) {
        self.uuid = [aDecoder decodeObjectForKey:@"uuid"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.uuid forKey:@"uuid"];
}


@end

SPEC_BEGIN(iOS29Spec)

/*
 Wow, this was a fun bug! My first round of debugging didn't find the issue, but luckily my second round of digging figured it out. In the iOS Library, every CMFile is given a uuid to identify it. When we save objects, we try and add it to the store automatically, but if it's a CMFile, we do something else with it.
 
 Well, guess how we are checking for CMFile?
 
 if ([theObject respondsToSelector:@selector(uuid)]) ....
 
 Your object also responds to that selector, and so it was giving a false positive. Simply by changing the name of the property to:
 
 @property (nonatomic, strong) NSString *beaconUUID;
 
 It fixed the issue.
 
 I'm going to file a bug for this and try and make it a stricter check as well.
 */

describe(@"CMObject Bug", ^{
    
    it(@"should add the object to the CMStore even if it has a 'uuid' property", ^{
        IOS29 *bug = [IOS29 new];
        bug.uuid = @"932dab26-eef0-41fd-9a1a-ea2d8a5d880f";
        
        __block CMObjectUploadResponse *resp = nil;
        [bug save:^(CMObjectUploadResponse *response) {
            resp = response;
        }];
        
        [[expectFutureValue(resp.uploadStatuses) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveCountOf:1];
    });
    
    
});

SPEC_END
