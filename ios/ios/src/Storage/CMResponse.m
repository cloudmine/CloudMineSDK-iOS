//
//  CMResponse.m
//  cloudmine-ios
//
//  Copyright (c) 2013 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMResponse.h"

@implementation CMResponse

@synthesize httpResponseCode, headers, body, errors;

- (id)initWithResponseBody:(id)responseBody httpCode:(NSUInteger)code error:(NSError *)anError {
    return [self initWithResponseBody:responseBody httpCode:code errors:(anError ? @[anError] : @[])];
}

- (id)initWithResponseBody:(id)responseBody httpCode:(NSUInteger)code errors:(NSArray *)theErrors {
    if ( (self = [super init]) ) {
        self.body = responseBody;
        self.httpResponseCode = code;
        self.errors = theErrors;
    }
    return self;
}

- (id)initWithResponseBody:(id)responseBody httpCode:(NSUInteger)code headers:(NSDictionary *)theHeaders errors:(NSDictionary *)theErrors {
    
    if ( (self = [super init]) ) {
        self.body = responseBody;
        self.httpResponseCode = code;
        if (theErrors) {
            self.errors = @[theErrors];
        } else {
            self.errors = @[];
        }

        self.headers = headers;
    }
    return self;
}

- (BOOL)wasSuccess {
    return 200 <= self.httpResponseCode && self.httpResponseCode < 300;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: HTTP Code: %lu\nErrors: %@, Body: %@",
            NSStringFromClass([self class]),
            (unsigned long)self.httpResponseCode,
            self.errors,
            self.body];
}

@end
