//
//  CMServerFunction.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMServerFunction.h"
#import "NSDictionary+CMJSON.h"

@implementation CMServerFunction

@synthesize functionName;
@synthesize extraParameters;
@synthesize resultOnly;
@synthesize async;

#pragma mark - Constructors

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

- (id)init {
    [[NSException exceptionWithName:@"NotImplemented" reason:@"This constructor is not implemented. Use initWithFunctionName:extraParameters:responseContainsResultOnly:performAsynchronously: instead, or use one of the available static convenience initializers."  userInfo:nil] raise];
    return nil;
}

#pragma - Alternate representations

- (NSString *)stringRepresentation {
    NSMutableArray *querySegments = [NSMutableArray arrayWithCapacity:4];

    if (self.functionName && [self.functionName length] > 0) {
        [querySegments addObject:[NSString stringWithFormat:@"f=%@", self.functionName]];
    }

    if (self.extraParameters && [self.extraParameters count] > 0) {
        [querySegments addObject:[NSString stringWithFormat:@"params=%@", [self.extraParameters jsonString]]];
    }

    if (self.resultOnly) {
        [querySegments addObject:@"result_only=true"];
    }

    if (self.async) {
        [querySegments addObject:@"async=true"];
    }

    return [querySegments componentsJoinedByString:@"&"];
}

@end
