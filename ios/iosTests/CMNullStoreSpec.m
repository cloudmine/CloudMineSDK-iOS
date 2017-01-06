//
//  CMNullStore.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 6/13/14.
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//

#import "Kiwi.h"
#import "CMNullStore.h"
#import "CMObject.h"
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
        [[theBlock(^{ [null objectsWithKeys:@[] additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null userObjectsWithKeys:@[] additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null allObjectsOfClass:[CMObject class] additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null allUserObjectsOfClass:[CMObject class] additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null searchObjects:@"" additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null searchUserObjects:@"" additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null fileWithName:@"'" additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null userFileWithName:@"" additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveAll:^(CMObjectUploadResponse * _Nonnull response) { }]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveAllWithOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveAllAppObjects:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveAllAppObjectsWithOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveAllUserObjects:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveAllUserObjectsWithOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveObject:[CMObject new] additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveObject:[CMObject new] callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveUserObject:[CMObject new] callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveUserObject:[CMObject new] additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null deleteObject:[CMObject new] additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveFileAtURL:[NSURL new] additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveFileAtURL:[NSURL new] named:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveUserFileAtURL:[NSURL new] additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveUserFileAtURL:[NSURL new] named:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveFileWithData:[NSData new] additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveFileWithData:[NSData new] named:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveUserFileWithData:[NSData new] additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null saveUserFileWithData:[NSData new] named:nil additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null deleteFileNamed:@"" additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null deleteUserFileNamed:@"" additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null deleteObjects:@[] additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null deleteUserObjects:@[] additionalOptions:nil callback:nil]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null addObject:[CMObject new]]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null addUserObject:[CMObject new]]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null removeObject:[CMObject new]]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null removeUserObject:[CMObject new]]; }) should] raiseWithName:@"CMInvalidStoreException"];
        [[theBlock(^{ [null objectOwnershipLevel:[CMObject new]]; }) should] raiseWithName:@"CMInvalidStoreException"];
    });
    
});

SPEC_END
