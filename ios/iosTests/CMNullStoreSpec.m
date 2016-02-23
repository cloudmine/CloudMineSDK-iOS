//
//  CMNullStore.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 6/13/14.
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//

#import "Kiwi.h"
#import "CMNullStore.h"
#import "MARTNSObject.h"
#import "RTMethod.h"

SPEC_BEGIN(CMNullStoreSpec)

describe(@"CMNullStore", ^{
    
    it(@"should properly be created", ^{
        CMStore *null = [CMNullStore defaultStore];
        [[null shouldNot] beNil];
    });
    
    it(@"should not let you do anything", ^{
        CMStore *null = [CMNullStore defaultStore];
        
        [[theBlock(^{ [CMNullStore store]; }) should] raise];
        [[theBlock(^{ [null allObjectsWithOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null allUserObjectsWithOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null objectsWithKeys:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null userObjectsWithKeys:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null allObjectsOfClass:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null allUserObjectsOfClass:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null searchObjects:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null searchUserObjects:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null fileWithName:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null userFileWithName:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveAll:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveAllWithOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveAllAppObjects:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveAllAppObjectsWithOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveAllUserObjects:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveAllUserObjectsWithOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveObject:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveObject:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveUserObject:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveUserObject:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null deleteObject:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveFileAtURL:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveFileAtURL:nil named:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveUserFileAtURL:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveUserFileAtURL:nil named:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveFileWithData:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveFileWithData:nil named:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveUserFileWithData:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveUserFileWithData:nil named:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null deleteFileNamed:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null deleteUserFileNamed:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null deleteObjects:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null deleteUserObjects:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null addObject:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null addUserObject:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null removeObject:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null removeUserObject:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null objectOwnershipLevel:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
    });
    
});

SPEC_END
