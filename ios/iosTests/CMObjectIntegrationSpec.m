//
//  CMObjectIntegrationSpec.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 5/16/14.
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//

#import "Kiwi.h"
#import "CMAPICredentials.h"
#import "CMObject.h"
#import "CMSortDescriptor.h"
#import "CMACL.h"
#import "CMStoreOptions.h"
#import "CMWebService.h"
#import "Venue.h"
#import "CMTestMacros.h"

@interface CMTestClass : CMObject

@property (nonatomic, strong) NSString *name;

@end

@implementation CMTestClass

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
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
    [[CMAPICredentials sharedInstance] setAppIdentifier:APP_ID];
    [[CMAPICredentials sharedInstance] setAppSecret:API_KEY];
    [[CMAPICredentials sharedInstance] setBaseURL:BASE_URL];
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

#warning Broken until sorting works on iOS
        // See: https://jira.cloudmine.me/browse/CM-168
        //                NSArray *names = @[@"aaa", @"bbb", @"ccc", @"ddd", @"eee", @"fff"]; //sorted
        //                for (NSInteger i = 0; i < objects.count; i++) {
        //                    CMTestClass *obj = objects[i];
        //                    [[obj.name should] equal:names[i]];
        //                }
      }];
      
      [[expectFutureValue(objects) shouldEventually] beNonNil];
      [[expectFutureValue(objects) shouldEventually] haveLengthOf:6];
      
    });
    
    it(@"should replace an object", ^{
      NSString *objectID = @"thisisanid";
      CMTestClass *test1 = [[CMTestClass alloc] initWithObjectId:objectID];
      test1.name = @"bbb";
      [store addObject:test1];
      
      __block CMObjectUploadResponse *response1 = nil;
      [test1.store replaceObject:test1 callback:^(CMObjectUploadResponse *response) {
        response1 = response;
      }];
      [[expectFutureValue(response1) shouldEventually] beNonNil];
      [[expectFutureValue(response1.uploadStatuses) shouldEventuallyBeforeTimingOutAfter(5.0)] haveCountOf:1];
      [[expectFutureValue(response1.uploadStatuses[objectID]) shouldEventuallyBeforeTimingOutAfter(5.0)] equal:@"updated"];
    });
    
    context(@"User Level Objects", ^{
      
      __block CMUser *userObjects = nil;
      __block CMStore *userStore = nil;
      beforeAll(^{
        userStore = [CMStore store];
        __block CMUserAccountResult code = NSNotFound;
        __block NSArray *mes = nil;
        
        userObjects = [[CMUser alloc] initWithEmail:@"test_user_objects@test.com" andPassword:@"testing"];
        [userObjects createAccountAndLoginWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
          code = resultCode;
          mes = messages;
          userStore.user = userObjects;
        }];
        
        [[expectFutureValue(theValue(code)) shouldEventually] equal:theValue(CMUserAccountLoginSucceeded)];
        [[expectFutureValue(mes) shouldEventually] beEmpty];
      });
      
      it(@"should create a user level object", ^{
        CMTestClass *test = [[CMTestClass alloc] init];
        NSString *theID = test.objectId;
        __block CMObjectUploadResponse *res = nil;
        [userStore saveUserObject:test callback:^(CMObjectUploadResponse *response) {
          res = response;
          
        }];
        
        [[expectFutureValue(res.uploadStatuses) shouldEventually] haveCountOf:1];
        [[expectFutureValue(res.uploadStatuses[theID]) shouldEventually] equal:@"created"];
      });
      
      __block NSString *theID;
      it(@"should still create an app level object", ^{
        CMTestClass *test = [[CMTestClass alloc] init];
        theID = test.objectId;
        
        __block CMObjectUploadResponse *res = nil;
        [userStore saveObject:test callback:^(CMObjectUploadResponse *response) {
          res = response;
        }];
        
        [[expectFutureValue(res.uploadStatuses) shouldEventually] haveCountOf:1];
        [[expectFutureValue(res.uploadStatuses[theID]) shouldEventually] equal:@"created"];
        
      });
      
      it(@"should replace the user level object", ^{
        CMTestClass *test = [[CMTestClass alloc] initWithObjectId:theID];
        
        __block CMObjectUploadResponse *res = nil;
        [userStore replaceObject:test callback:^(CMObjectUploadResponse *response) {
          res = response;
        }];
        
        [[expectFutureValue(res.uploadStatuses) shouldEventually] haveCountOf:1];
        [[expectFutureValue(res.uploadStatuses[theID]) shouldEventually] equal:@"updated"];
      });
      
      it(@"should not save an object to both app and user level", ^{
        // I don't think this is working?
        CMTestClass *test = [[CMTestClass alloc] init];
        NSString *theID = test.objectId;
        
        __block CMObjectUploadResponse *res = nil;
        __block CMObjectUploadResponse *res2 = nil;
        [userStore saveObject:test callback:^(CMObjectUploadResponse *response) {
          res = response;
          [userStore saveUserObject:test callback:^(CMObjectUploadResponse *response) {
            res2 = response;
          }];
        }];
        
        [[expectFutureValue(res.uploadStatuses) shouldEventually] haveCountOf:1];
        [[expectFutureValue(res.uploadStatuses[theID]) shouldEventually] equal:@"created"];
        [[expectFutureValue(res2.uploadStatuses) shouldEventually] haveCountOf:1];
        [[expectFutureValue(res2.error) shouldEventually] beNil];
      });
      
    });
    
    context(@"given a CMObject and some ACL's", ^{
      
      __block CMUser *owner = nil;
      __block CMUser *wantr = nil;
      __block CMTestClass *testing = nil;
      __block NSString *testingID = nil;
      beforeAll(^{
        
        testingID = [[NSUUID UUID] UUIDString];
        owner = [[CMUser alloc] initWithEmail:@"the_owner@test.com" andPassword:@"testing"];
        wantr = [[CMUser alloc] initWithEmail:@"the_wantr@test.com" andPassword:@"testing"];
        
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
      
      __block NSString *aclID = nil;
      __block CMACL *theACL = nil;
      it(@"should let you add an ACL", ^{
        CMACL *newACL = [[CMACL alloc] init];
        aclID = newACL.objectId;
        newACL.permissions = [NSSet setWithObjects:CMACLReadPermission, CMACLUpdatePermission, CMACLDeletePermission, nil];
        newACL.members = [NSSet setWithObjects:wantr.objectId, owner.objectId, nil];
        [store addACL:newACL];
        theACL = newACL;
        
        __block CMObjectUploadResponse *resp = nil;
        [newACL save:^(CMObjectUploadResponse *responseACL) {
          [testing addACL:newACL callback:^(CMObjectUploadResponse *response) {
            resp = response;
          }];
        }];
        
        [[expectFutureValue(resp) shouldEventually] beNonNil];
        [[expectFutureValue(resp.error) shouldEventually] beNil];
        [[expectFutureValue(resp.uploadStatuses[testingID]) shouldEventually] equal:@"updated"];
      });
      
      it(@"should now let you get the ACL", ^{
        __block CMACLFetchResponse *resp = nil;
        [testing getACLs:^(CMACLFetchResponse *response) {
          resp = response;
        }];
        
        [[expectFutureValue(resp) shouldEventually] beNonNil];
        [[expectFutureValue(resp.acls) shouldEventually] haveCountOf:1];
        [[expectFutureValue([resp.acls.allObjects[0] objectId]) shouldEventually] equal:aclID];
      });
      
      it(@"should let the other user read the object", ^{
        CMStore *newStore = [CMStore store];
        [newStore setUser:wantr];
        CMStoreOptions *options = [[CMStoreOptions alloc] init];
        options.shared = YES;
        
        __block CMObjectFetchResponse *resp = nil;
        [newStore allUserObjectsWithOptions:options callback:^(CMObjectFetchResponse *response) {
          resp = response;
        }];
        
        [[expectFutureValue(resp) shouldEventually] beNonNil];
        [[expectFutureValue(resp.objects) shouldEventually] haveCountOf:1];
        CMTestClass *testObject = [resp.objects lastObject];
        [[expectFutureValue(testObject.objectId) shouldEventually] equal:testingID];
      });
      
      it(@"should let you create a new object and add the same ACL to it", ^{
        
        CMTestClass *newObject = [[CMTestClass alloc] init];
        [store addUserObject:newObject];
        
        __block CMObjectUploadResponse *resp = nil;
        [newObject addACL:theACL callback:^(CMObjectUploadResponse *response) {
          resp = response;
        }];
        
        [[expectFutureValue(resp) shouldEventually] beNonNil];
        [[expectFutureValue(resp.error) shouldEventually] beNil];
        [[expectFutureValue(resp.uploadStatuses[newObject.objectId]) shouldEventually] equal:@"created"];
      });
      
      it(@"should let the other user read both objects", ^{
        CMStore *newStore = [CMStore store];
        [newStore setUser:wantr];
        CMStoreOptions *options = [[CMStoreOptions alloc] init];
        options.shared = YES;
        
        __block CMObjectFetchResponse *resp = nil;
        [newStore allUserObjectsWithOptions:options callback:^(CMObjectFetchResponse *response) {
          resp = response;
        }];
        
        [[expectFutureValue(resp) shouldEventually] beNonNil];
        [[expectFutureValue(resp.objects) shouldEventually] haveCountOf:2];
      });
      
      it(@"should not let another user add ACL's to the object", ^{
        CMStore *newStore = [CMStore store];
        [newStore setUser:wantr];
        
        __block CMObjectFetchResponse *resp = nil;
        __block CMObjectUploadResponse *aclResponse = nil;
        [newStore userObjectsWithKeys:@[testingID] additionalOptions:nil callback:^(CMObjectFetchResponse *response) {
          resp = response;
          
          [[resp.objects should] haveCountOf:1];
          CMTestClass *object = [resp.objects lastObject];
          
          CMACL *newACL = [[CMACL alloc] init];
          newACL.permissions = [NSSet setWithObjects:CMACLReadPermission, CMACLUpdatePermission, CMACLDeletePermission, nil];
          newACL.members = [NSSet setWithObjects:@"someoneelse", nil];
          
          
          [object addACL:newACL callback:^(CMObjectUploadResponse *response) {
            aclResponse = response;
          }];
          
        }];
        
        [[expectFutureValue(resp) shouldEventually] beNonNil];
        [[expectFutureValue(resp.objects) shouldEventually] haveCountOf:1];
        [[expectFutureValue(aclResponse.error.domain) shouldEventually] equal:CMErrorDomain];
        [[expectFutureValue(theValue(aclResponse.error.code)) shouldEventually] equal:@(CMErrorInvalidRequest)];
      });
      
      it(@"should immediately return the ACL's if you ask a shared object", ^{
        
        CMStore *newStore = [CMStore store];
        [newStore setUser:wantr];
        
        __block CMObjectFetchResponse *resp = nil;
        __block CMACLFetchResponse *aclResponse = nil;
        [newStore userObjectsWithKeys:@[testingID] additionalOptions:nil callback:^(CMObjectFetchResponse *response) {
          resp = response;
          
          [[resp.objects should] haveCountOf:1];
          CMTestClass *object = [resp.objects lastObject];
          
          [object getACLs:^(CMACLFetchResponse *response) {
            aclResponse = response;
          }];
        }];
        
        [[expectFutureValue(resp) shouldEventually] beNonNil];
        [[expectFutureValue(resp.objects) shouldEventually] haveCountOf:1];
        [[expectFutureValue(aclResponse) shouldEventually] beNonNil];
        [[expectFutureValue(aclResponse.acls) shouldEventually] haveCountOf:1];
        [[newStore.webService shouldNot] receive:@selector(getACLsForUser:successHandler:errorHandler:)];
      });
      
      it(@"save ACL's on the object", ^{
        
        CMACL *newACL = [[CMACL alloc] initWithObjectId:aclID];
        newACL.permissions = [NSSet setWithObjects:CMACLReadPermission, CMACLUpdatePermission, nil];
        newACL.members = [NSSet setWithObjects:wantr.objectId, owner.objectId, nil];
        [testing.store addACL:newACL];
        
        __block CMObjectUploadResponse *resp = nil;
        [testing saveACLs:^(CMObjectUploadResponse *response) {
          resp = response;
        }];
        
        [[expectFutureValue(resp) shouldEventually] beNonNil];
        [[expectFutureValue(resp.uploadStatuses) shouldEventually] haveCountOf:1];
      });
      
      it(@"should not let another user save the ACL's on the object", ^{
        
        CMStore *newStore = [CMStore store];
        [newStore setUser:wantr];
        
        __block CMObjectFetchResponse *resp = nil;
        __block CMObjectUploadResponse *aclResponse = nil;
        [newStore userObjectsWithKeys:@[testingID] additionalOptions:nil callback:^(CMObjectFetchResponse *response) {
          resp = response;
          
          [[resp.objects should] haveCountOf:1];
          CMTestClass *object = [resp.objects lastObject];
          
          [object saveACLs:^(CMObjectUploadResponse *response) {
            aclResponse = response;
          }];
        }];
        
        [[expectFutureValue(resp) shouldEventually] beNonNil];
        [[expectFutureValue(resp.objects) shouldEventually] haveCountOf:1];
        [[expectFutureValue(aclResponse) shouldEventually] beNonNil];
        [[expectFutureValue(aclResponse.error.domain) shouldEventually] equal:CMErrorDomain];
        [[expectFutureValue(theValue(aclResponse.error.code)) shouldEventually] equal:@(CMErrorInvalidRequest)];
        [[newStore.webService shouldNot] receive:@selector(updateACL:user:successHandler:errorHandler:)];
      });
      
      it(@"should not let another user remove the ACL", ^{
        
        CMStore *newStore = [CMStore store];
        [newStore setUser:wantr];
        
        __block CMObjectFetchResponse *resp = nil;
        __block CMObjectUploadResponse *aclResponse = nil;
        [newStore userObjectsWithKeys:@[testingID] additionalOptions:nil callback:^(CMObjectFetchResponse *response) {
          resp = response;
          
          [[resp.objects should] haveCountOf:1];
          CMTestClass *object = [resp.objects lastObject];
          
          [object removeACL:theACL callback:^(CMObjectUploadResponse *response) {
            aclResponse = response;
          }];
        }];
        
        [[expectFutureValue(resp) shouldEventually] beNonNil];
        [[expectFutureValue(resp.objects) shouldEventually] haveCountOf:1];
        [[expectFutureValue(aclResponse) shouldEventually] beNonNil];
        [[expectFutureValue(aclResponse.error.domain) shouldEventually] equal:CMErrorDomain];
        [[expectFutureValue(theValue(aclResponse.error.code)) shouldEventually] equal:@(CMErrorInvalidRequest)];
        [[newStore.webService shouldNot] receive:@selector(updateValuesFromDictionary:serverSideFunction:user:extraParameters:successHandler:errorHandler:)];
      });
      
      it(@"should let the original user remove the acl", ^{
        __block CMObjectUploadResponse *resp = nil;
        __block CMACLFetchResponse *fetchResponse = nil;
        
        [testing removeACL:theACL callback:^(CMObjectUploadResponse *response) {
          resp = response;
          
          [testing getACLs:^(CMACLFetchResponse *response) {
            fetchResponse = response;
          }];
        }];
        
        [[expectFutureValue(resp) shouldEventually] beNonNil];
        [[expectFutureValue(resp.uploadStatuses) shouldEventually] haveCountOf:1];
        [[expectFutureValue(fetchResponse.acls) shouldEventually] beEmpty];
      });
      
      __block CMTestClass *newTest = nil;
      it(@"should let you add a public segment", ^{
        CMACL *newACL = [[CMACL alloc] init];
        aclID = newACL.objectId;
        newACL.segments[CMACLSegmentPublic] = @YES;
        newACL.permissions = [NSSet setWithObject:CMACLReadPermission];
        [store addACL:newACL];
        testingID = [[NSUUID UUID] UUIDString];
        newTest = [[CMTestClass alloc] initWithObjectId:testingID];
        newTest.name = @"SHARED PUBLIC";
        [store addUserObject:newTest];
        
        __block CMObjectUploadResponse *resp = nil;
        [newTest saveWithUser:owner callback:^(CMObjectUploadResponse *response) {
          [newACL save:^(CMObjectUploadResponse *responseACL) {
            [newTest addACL:newACL callback:^(CMObjectUploadResponse *response) {
              resp = response;
            }];
          }];
        }];
        
        [[expectFutureValue(resp) shouldEventually] beNonNil];
        [[expectFutureValue(resp.error) shouldEventually] beNil];
        [[expectFutureValue(resp.uploadStatuses[testingID]) shouldEventually] equal:@"updated"];
      });
      
      it(@"should let anyone access a public object", ^{
        CMStore *newStore = [CMStore store];
        [newStore setUser:wantr];
        CMStoreOptions *options = [[CMStoreOptions alloc] init];
        options.shared = YES;
        
        __block NSMutableArray *objects = [NSMutableArray array];
        [newStore allUserObjectsWithOptions:options callback:^(CMObjectFetchResponse *response) {
          [response.objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([[obj name] isEqualToString:@"SHARED PUBLIC"]) {
              [objects addObject:obj];
            }
          }];
        }];
        
        [[expectFutureValue(objects) shouldEventually] haveCountOf:1];
        [[expectFutureValue([objects[0] objectId]) shouldEventually] equal:testingID];
      });
    });
  });
  
  context(@"when working with geocoded objects", ^{
    
    __block NSMutableArray *tenVenues = nil;
    beforeAll(^{
      NSArray *data = [[NSDictionary dictionaryWithContentsOfFile:
                        [[NSBundle bundleForClass:[self class]]
                         pathForResource:@"venues" ofType:@"plist"]]
                       objectForKey:@"items"];
      
      NSMutableArray *loadedVenues = [NSMutableArray array];
      
      [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Venue *venue = [[Venue alloc] initWithDictionary:obj];
        [loadedVenues addObject:venue];
      }];
      
      tenVenues = [NSMutableArray array];
      for (NSInteger i = 0; i < 10; i++) {
        Venue *v = loadedVenues[i + 20];
        [tenVenues addObject:v];
        [store addObject:v];
      }
      
      __block CMObjectUploadResponse *res = nil;
      [store saveAllAppObjects:^(CMObjectUploadResponse *response) {
        res = response;
      }];
      
      [[expectFutureValue(res) shouldEventually] beNonNil];
    });
    
    it(@"should fetch all objects near a point", ^{
      
      __block CMObjectFetchResponse *res = nil;
      [store searchObjects:@"[__class__ = \"venue\", location near (-75.162, 39.959), 1mi]"
         additionalOptions:nil
                  callback:^(CMObjectFetchResponse *response) {
                    res = response;
                    [[theValue(response.objects.count) should] equal:@10];
                  }];
      
      [[expectFutureValue(res) shouldEventually] beNonNil];
    });
    
    it(@"should fetch 0 when asking from a random point", ^{
      __block CMObjectFetchResponse *res = nil;
      [store searchObjects:@"[__class__ = \"venue\", location near (-40.162, 20.959), 1mi]"
         additionalOptions:nil
                  callback:^(CMObjectFetchResponse *response) {
                    res = response;
                    [[theValue(response.objects.count) should] equal:@0];
                  }];
      
      [[expectFutureValue(res) shouldEventually] beNonNil];
    });
    
    it(@"should fetch just a few when moved to a location nearby", ^{
      __block CMObjectFetchResponse *res = nil;
      [store searchObjects:@"[__class__ = \"venue\", location near (-75.150, 39.940), 1mi]"
         additionalOptions:nil
                  callback:^(CMObjectFetchResponse *response) {
                    res = response;
                    [[theValue(response.objects.count) should] equal:@1];
                  }];
      
      [[expectFutureValue(res) shouldEventually] beNonNil];
    });
    
    it(@"should find everything in the default radius", ^{
      __block CMObjectFetchResponse *res = nil;
      [store searchObjects:@"[__class__ = \"venue\", location near (-75.150, 39.940)]"
         additionalOptions:nil
                  callback:^(CMObjectFetchResponse *response) {
                    res = response;
                    [[theValue(response.objects.count) should] equal:@10];
                  }];
      
      [[expectFutureValue(res) shouldEventually] beNonNil];
    });
  });
});

SPEC_END
