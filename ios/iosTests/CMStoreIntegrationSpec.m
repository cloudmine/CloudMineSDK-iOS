//
//  CMStoreIntegrationSpec.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 6/13/14.
//  Copyright (c) 2014 CloudMine, LLC. All rights reserved.
//

#import "Kiwi.h"
#import "CMStore.h"
#import "Venue.h"

SPEC_BEGIN(CMStoreIntegrationSpec)

describe(@"CMStoreIntegration", ^{
    
    __block CMStore *store = nil;
    __block NSArray *venues = nil;
    beforeAll(^{
        [[CMAPICredentials sharedInstance] setAppIdentifier:@"9977f87e6ae54815b32a663902c3ca65"];
        [[CMAPICredentials sharedInstance] setAppSecret:@"c701d73554594315948c8d3cc0711ac1"];
        
        store = [CMStore store];
        
        NSArray *data = [[NSDictionary dictionaryWithContentsOfFile:
                          [[NSBundle bundleForClass:[self class]]
                           pathForResource:@"venues" ofType:@"plist"]]
                         objectForKey:@"items"];
        
        NSMutableArray *loadedVenues = [NSMutableArray array];
        
        [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Venue *venue = [[Venue alloc] initWithDictionary:obj];
            [loadedVenues addObject:venue];
        }];
        
        venues = [NSArray arrayWithArray:loadedVenues];
    });
    
    it(@"should allow the creation of an object", ^{
        __block CMObjectUploadResponse *res = nil;
        [store saveObject:venues[0] callback:^(CMObjectUploadResponse *response) {
            res = response;
        }];
        
        [[expectFutureValue(res) shouldEventually] beNonNil];
        [[expectFutureValue(res.snippetResult.data) shouldEventually] beEmpty];
        [[expectFutureValue(res.uploadStatuses) shouldEventually] haveCountOf:1];
    });
    
    it(@"should allow the creation of another object and running a snippet", ^{
        
        __block CMObjectUploadResponse *res = nil;
        CMServerFunction *serverFunction = [[CMServerFunction alloc] initWithFunctionName:@"store_integration"
                                                                          extraParameters:nil
                                                               responseContainsResultOnly:NO
                                                                    performAsynchronously:NO];
        
        CMStoreOptions *options = [[CMStoreOptions alloc] initWithServerSideFunction:serverFunction];
        
        [store saveObject:venues[1] additionalOptions:options callback:^(CMObjectUploadResponse *response) {
            res = response;
        }];
        
        [[expectFutureValue(res) shouldEventually] beNonNil];
        [[expectFutureValue(res.snippetResult) shouldEventually] beNonNil];
        [[expectFutureValue(res.snippetResult.data[@"store"]) shouldEventually] equal:@"integration"];
        [[expectFutureValue(res.uploadStatuses) shouldEventually] haveCountOf:1];
    });
    
    it(@"should be able to delete the venues", ^{
        __block CMDeleteResponse *res = nil;
        [store deleteObjects:@[venues[0], venues[1]] additionalOptions:nil callback:^(CMDeleteResponse *response) {
            res = response;
        }];
        
        NSString *objectId1 = [venues[0] objectId];
        NSString *objectId2 = [venues[0] objectId];
        
        [[expectFutureValue(res) shouldEventually] beNonNil];
        [[expectFutureValue(res.success) shouldEventually] haveCountOf:2];
        [[expectFutureValue(res.success[objectId1]) shouldEventually] equal:@"deleted"];
        [[expectFutureValue(res.success[objectId2]) shouldEventually] equal:@"deleted"];
        [[expectFutureValue(res.objectErrors) shouldEventually] beEmpty];
    });

    
});

SPEC_END
