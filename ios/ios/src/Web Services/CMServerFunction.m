//
//  CMServerFunction.m
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMServerFunction.h"

@implementation CMServerFunction

@synthesize functionName;
@synthesize extraParameters;
@synthesize resultOnly;
@synthesize async;

+ (id)serverFunctionWithName:(NSString *)theFunctionName {
    return [[self alloc] initWithFunctionName:theFunctionName 
                              extraParameters:nil
                   responseContainsResultOnly:NO
                        performAsynchronously:NO
            ];
}

+ (id)serverFunctionWithName:(NSString *)theFunctionName extraParameters:(NSDictionary *)theExtraParameters {
    return [[self alloc] initWithFunctionName:theFunctionName
                              extraParameters:theExtraParameters
                   responseContainsResultOnly:NO
                        performAsynchronously:NO
            ];
}

+ (id)serverFunctionWithName:(NSString *)theFunctionName extraParameters:(NSDictionary *)theExtraParameters responseContainsResultOnly:(BOOL)resultOnly {
    return [[self alloc] initWithFunctionName:theFunctionName
                              extraParameters:theExtraParameters 
                   responseContainsResultOnly:resultOnly
                        performAsynchronously:NO
            ];
}

+ (id)serverFunctionWithName:(NSString *)theFunctionName extraParameters:(NSDictionary *)theExtraParameters responseContainsResultOnly:(BOOL)resultOnly performAsynchronously:(BOOL)async {
    return [[self alloc] initWithFunctionName:theFunctionName
                              extraParameters:theExtraParameters 
                   responseContainsResultOnly:resultOnly
                        performAsynchronously:async
            ];
}

- (id)initWithFunctionName:(NSString *)theFunctionName extraParameters:(NSDictionary *)theExtraParameters responseContainsResultOnly:(BOOL)isResultOnly performAsynchronously:(BOOL)isAsync {
    if (self = [super init]) {
        self.functionName = theFunctionName;
        self.extraParameters = theExtraParameters;
        self.resultOnly = isResultOnly;
        self.async = isAsync;
    }
    return self;
}

@end
