//
//  CMExtensionsSpec.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 6/11/14.
//  Copyright (c) 2014 CloudMine, LLC. All rights reserved.
//

#import "Kiwi.h"
#import "CMTools.h"
#import "NSArray+CMJSON.h"
#import "NSDictionary+CMJSON.h"
#import "NSString+UUID.h"
#import "NSURL+QueryParameterAdditions.h"
#import "CMConstants.h"

SPEC_BEGIN(CMExtensionsSpec)

describe(@"CMExtensions", ^{

    context(@"CMTools", ^{
        
        it(@"should should url encode a string", ^{
            NSString *toEncode = @"{\"some\":\"json\"}";
            NSString *encoded = [CMTools urlEncode:toEncode];
            [[encoded should] equal:@"%7B%22some%22%3A%22json%22%7D"];
        });
        
        it(@"should encode a url but leave the question mark", ^{
            NSString *randomJson = @"{\"some\":\"json\"}";
            NSString *toEncode = [@"http://api.cloudmine.me/path/to/endpoint?=" stringByAppendingString:randomJson];
            NSString *encoded = [CMTools urlEncode:toEncode];
            [[encoded should] equal:@"http%3A%2F%2Fapi.cloudmine.me%2Fpath%2Fto%2Fendpoint%3F%3D%7B%22some%22%3A%22json%22%7D"];
        });
        
    });
    
    context(@"NSArray With JSON", ^{
        
        it(@"should correctly create the json string", ^{
            NSArray *array = @[@"okay", @"something", @"cool"];
            NSString *jsonString = [array jsonString];
            [[jsonString should] equal:@"[\"okay\",\"something\",\"cool\"]"];
        });
    });
    
    context(@"NSDictionary with JSON", ^{
        
        it(@"should correctly create the json string", ^{
            NSDictionary *dictionary = @{@"akey": @"value"};
            NSString *jsonString = [dictionary jsonString];
            [[jsonString should] equal:@"{\"akey\":\"value\"}"];
        });
        
        it(@"should fail to create the object with bad data", ^{
            NSDictionary *dictionary = @{@"akey": [NSObject new]};
            [[theBlock(^{ [dictionary jsonData]; }) should] raiseWithName:NSInvalidArgumentException];
        });
    });
    
    context(@"NSString with UUID", ^{
        
        it(@"should create a uuid", ^{
            NSString *uuid = [NSString stringWithUUID];
            [[uuid shouldNot] beNil];
        });
    });
    
    context(@"NSURL with Query Parameters", ^{
        
        it(@"should return a copy of itself if there is nothing to add", ^{
            NSURL *url = [NSURL URLWithString:CM_BASE_URL];
            [url URLByAppendingAndEncodingQueryParameter:nil andValue:@"something"];
            [[[url absoluteString] should] equal:CM_BASE_URL];
        });
        
        it(@"should add all the values of a dictionary", ^{
            NSDictionary *query = @{@"value1": @"1", @"value2" : @"string"};
            NSURL *url = [NSURL URLWithString:CM_BASE_URL];
            url = [url URLByAppendingAndEncodingQueryParameters:query];
            
            [[url.absoluteString should] containString:@"https://api.cloudmine.me/?"];
            [[url.absoluteString should] containString:@"value1=1"];
            [[url.absoluteString should] containString:@"value2=string"];
        });
        
        it(@"should return a copy of itself if there is no dictionary", ^{
            NSURL *url = [NSURL URLWithString:CM_BASE_URL];
            [url URLByAppendingAndEncodingQueryParameters:nil];
            [[[url absoluteString] should] equal:CM_BASE_URL];
        });
        
    });
    
});

SPEC_END