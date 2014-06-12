//
//  CMObjectIntegrationSpec.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 5/16/14.
//  Copyright (c) 2014 CloudMine, LLC. All rights reserved.
//

#import "Kiwi.h"
#import "CMAPICredentials.h"
#import "CMObject.h"
#import "CMSortDescriptor.h"

@interface CMTestClass : CMObject

@property (nonatomic, strong) NSString *name;

@end

@implementation CMTestClass

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    if (self = [super initWithCoder:aDecoder]) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_name forKey:@"name"];
}

@end


SPEC_BEGIN(CMObjectIntegrationSpec)

describe(@"CMObject Integration", ^{
    
    static CMStore *store = nil;
    beforeAll(^{
        [[CMAPICredentials sharedInstance] setAppIdentifier:@"9977f87e6ae54815b32a663902c3ca65"];
        [[CMAPICredentials sharedInstance] setAppSecret:@"c701d73554594315948c8d3cc0711ac1"];
        store = [CMStore store];
    });
    
    context(@"given a CMObject", ^{
        
        it(@"it should successfully create the object on the server", ^{
            
            NSString *objectID = @"thisisanid";
            CMTestClass *test1 = [[CMTestClass alloc] initWithObjectId:objectID];
            test1.name = @"aaa";
            [store addObject:test1];
            
            __block CMObjectUploadResponse *response1 = nil;
            [test1 save:^(CMObjectUploadResponse *response) {
                response1 = response;
            }];
            [[expectFutureValue(response1) shouldEventually] beNonNil];
            [[expectFutureValue(response1.uploadStatuses) shouldEventuallyBeforeTimingOutAfter(5.0)] haveCountOf:1];
            [[expectFutureValue(response1.uploadStatuses[objectID]) shouldEventuallyBeforeTimingOutAfter(5.0)] equal:@"created"];
        });
        
        it(@"should create multiple objects", ^{
            
            NSArray *names = @[@"bbb", @"ccc", @"ddd", @"eee", @"fff"];
            NSMutableArray *objects = [NSMutableArray array];
            
            for (NSString *aName in names) {
                CMTestClass *test = [[CMTestClass alloc] init];
                test.name = aName;
                [objects addObject:test];
                [store addObject:test];
            }
            
            __block CMObjectUploadResponse *response1 = nil;
            [store saveAllAppObjects:^(CMObjectUploadResponse *response) {
                response1 = response;
            }];
            
            [[expectFutureValue(response1) shouldEventually] beNonNil];
            [[expectFutureValue(response1.uploadStatuses) shouldEventually] haveLengthOf:6];
            
        });
        
        it(@"should retrieve the objects in sorted order", ^{
            CMSortDescriptor *sortDescription = [[CMSortDescriptor alloc] initWithFieldsAndDirections:@"name", CMSortAscending, nil];
            CMStoreOptions *options = [[CMStoreOptions alloc] initWithSortDescriptor:sortDescription];
            
            __block NSArray *objects = nil;
            [store allObjectsOfClass:[CMTestClass class] additionalOptions:options callback:^(CMObjectFetchResponse *response) {
                objects = response.objects;
                
                NSArray *names = @[@"aaa", @"bbb", @"ccc", @"ddd", @"eee", @"fff"]; //sorted
                for (NSInteger i = 0; i < objects.count; i++) {
                    CMTestClass *obj = objects[i];
                    [[obj.name should] equal:names[i]];
                }
            }];
            
            [[expectFutureValue(objects) shouldEventually] beNonNil];
            [[expectFutureValue(objects) shouldEventually] haveLengthOf:6];
            
        });
        
        context(@"given a CMObject and some ACL's", ^{
            
            __block CMUser *owner = nil;
            __block CMUser *wantr = nil;
            __block CMTestClass *testing = nil;
            __block NSString *testingID = nil;
            beforeAll(^{
                
                testingID = [[NSUUID UUID] UUIDString];
                owner = [[CMUser alloc] initWithUsername:@"the_owner" andPassword:@"testing"];
                wantr = [[CMUser alloc] initWithUsername:@"the_wantr" andPassword:@"testing"];

                __block CMObjectUploadResponse *resp = nil;
                [owner createAccountAndLoginWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                    [store setUser:owner];
                    testing = [[CMTestClass alloc] initWithObjectId:testingID];
                    [store addUserObject:testing];
                    [testing saveWithUser:owner callback:^(CMObjectUploadResponse *response) {
                        resp = response;
                    }];
                }];
                
                [wantr createAccountAndLoginWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                    
                }];
                
                [[expectFutureValue(resp.uploadStatuses[testingID]) shouldEventually] equal:@"created"];
                [[expectFutureValue(theValue(owner.isLoggedIn)) shouldEventually] equal:@YES];
                [[expectFutureValue(theValue(wantr.isLoggedIn)) shouldEventually] equal:@YES];
            });
            
            
            it(@"should have no acl's to begin with", ^{
                
                __block CMACLFetchResponse *resp = nil;
                [testing getACLs:^(CMACLFetchResponse *response) {
                    resp = response;
                }];
                
                [[expectFutureValue(resp) shouldEventually] beNonNil];
                [[expectFutureValue(resp.acls) shouldEventually] beEmpty];
            });
        });
    });
});

SPEC_END