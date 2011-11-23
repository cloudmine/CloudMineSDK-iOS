//
//  CMServerFunction.h
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>

@interface CMServerFunction : NSObject

@property (nonatomic, strong) NSString *functionName;
@property (nonatomic, strong) NSDictionary *extraParameters;
@property (nonatomic, assign) BOOL resultOnly;
@property (nonatomic, assign) BOOL async;

+ (id)serverFunctionWithName:(NSString *)theFunctionName;

+ (id)serverFunctionWithName:(NSString *)theFunctionName extraParameters:(NSDictionary *)theExtraParameters;

+ (id)serverFunctionWithName:(NSString *)theFunctionName extraParameters:(NSDictionary *)theExtraParameters responseContainsResultOnly:(BOOL)resultOnly;

+ (id)serverFunctionWithName:(NSString *)theFunctionName extraParameters:(NSDictionary *)theExtraParameters responseContainsResultOnly:(BOOL)resultOnly performAsynchronously:(BOOL)async;

- (id)initWithFunctionName:(NSString *)theFunctionName extraParameters:(NSDictionary *)theExtraParameters responseContainsResultOnly:(BOOL)resultOnly performAsynchronously:(BOOL)async;

@end
