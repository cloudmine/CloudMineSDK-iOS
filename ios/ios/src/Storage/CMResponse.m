//
//  CMResponse.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 2/26/13.
//  Copyright (c) 2013 CloudMine, LLC. All rights reserved.
//

#import "CMResponse.h"

@implementation CMResponse

@synthesize httpResponseCode, headers, body, errors;

- (id)initWithResponseBody:(id)responseBody httpCode:(NSUInteger)code error:(NSError *)anError {
    return [self initWithResponseBody:responseBody httpCode:code errors:@[anError]];
}

- (id)initWithResponseBody:(id)responseBody httpCode:(NSUInteger)code errors:(NSArray *)theErrors {
    if ( (self = [super init]) ) {
        self.body = responseBody;
        self.httpResponseCode = code;
        self.errors = theErrors;
    }
    return self;
}

- (BOOL)wasSuccess {
    return 200 <= self.httpResponseCode && self.httpResponseCode < 300;
}

@end
