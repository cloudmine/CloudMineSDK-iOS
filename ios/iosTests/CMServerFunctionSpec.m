//
//  CMServerFunctionSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "Kiwi.h"
#import "CMServerFunction.h"

SPEC_BEGIN(CMServerFunctionSpec)

describe(@"CMServerFunction", ^{
    __block CMServerFunction *serverFunction;

    afterEach(^{
        serverFunction = nil;
    });
    
    it(@"should not be created with just init", ^{
        [[theBlock(^{
            Class class = [CMServerFunction class];
            serverFunction = [[class alloc] init];
        }) should] raiseWithName:@"NotImplemented"];
    });

    it(@"should serialize into a proper query string with only a function name", ^{
        NSString *expectedString = @"f=my_function";
        serverFunction = [CMServerFunction serverFunctionWithName:@"my_function"];
        [[[serverFunction stringRepresentation] should] equal:expectedString];
    });

    it(@"should serialize into a proper query string with a function name and additional parameters", ^{
        NSString *expectedString = @"f=my_function&params={\"numbers\":[1,2,3]}";
        NSDictionary *params = [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:2], [NSNumber numberWithInt:3], nil]
                                                           forKey:@"numbers"];
        serverFunction = [CMServerFunction serverFunctionWithName:@"my_function"
                                                  extraParameters:params];
        [[[serverFunction stringRepresentation] should] equal:expectedString];
    });

    it(@"should serialize into a proper query string with a function name, additional parameters, and returning only the result", ^{
        NSString *expectedString = @"f=my_function&params={\"numbers\":[1,2,3]}&result_only=true";
        NSDictionary *params = [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:2], [NSNumber numberWithInt:3], nil]
                                                           forKey:@"numbers"];
        serverFunction = [CMServerFunction serverFunctionWithName:@"my_function"
                                                  extraParameters:params
                                       responseContainsResultOnly:YES];
        [[[serverFunction stringRepresentation] should] equal:expectedString];
    });

    it(@"should serialize into a proper query string with a function name, additional parameters, returning only the result, asynchronously", ^{
        NSString *expectedString = @"f=my_function&params={\"numbers\":[1,2,3]}&result_only=true&async=true";
        NSDictionary *params = [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:2], [NSNumber numberWithInt:3], nil]
                                                           forKey:@"numbers"];
        serverFunction = [CMServerFunction serverFunctionWithName:@"my_function"
                                                  extraParameters:params
                                       responseContainsResultOnly:YES
                                            performAsynchronously:YES];
        [[[serverFunction stringRepresentation] should] equal:expectedString];
    });
    
});

SPEC_END
