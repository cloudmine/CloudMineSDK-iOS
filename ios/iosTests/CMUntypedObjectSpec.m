//
//  CMUntypedObjectSpec.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 6/12/14.
//  Copyright (c) 2015 CloudMine, Inc. All rights reserved.
//

#import "Kiwi.h"
#import "CMUntypedObject.h"
#import "CMObjectEncoder.h"
#import "CMObjectDecoder.h"

SPEC_BEGIN(CMUntypedObjectSpec)

describe(@"CMUntypedObject", ^{
    
    it(@"should be able to be decoded into a CMUntypedObject", ^{
        NSDictionary *encoded = @{@"arandomid": @{@"firstName": @"name", @"lastName": @"aName"}};
        NSArray *decoded = [CMObjectDecoder decodeObjects:encoded];
        CMUntypedObject *object = [decoded lastObject];
        [[object shouldNot] beNil];
        [[NSStringFromClass([object class]) should] equal:@"CMUntypedObject"];
        [[object.fields should] haveCountOf:3];
        [[object.fields[@"firstName"] should] equal:@"name"];
        [[object.fields[@"lastName"] should] equal:@"aName"];
    });
    
    it(@"should encode back into a dictioanary", ^{
        NSDictionary *encoded = @{@"arandomid": @{@"firstName": @"name", @"lastName": @"aName"}};
        NSArray *decoded = [CMObjectDecoder decodeObjects:encoded];
        CMUntypedObject *object = [decoded lastObject];
        NSDictionary *finished = [CMObjectEncoder encodeObjects:@[object]];
        [[finished should] haveCountOf:1];
        NSDictionary *inner = finished[@"arandomid"];
        [[inner[@"firstName"] should] equal:@"name"];
        [[inner[@"lastName"] should] equal:@"aName"];
    });
    
});

SPEC_END