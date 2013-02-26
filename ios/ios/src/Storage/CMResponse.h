//
//  CMResponse.h
//  cloudmine-ios
//
//  Created by Ethan Mick on 2/26/13.
//  Copyright (c) 2013 CloudMine, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMResponse : NSObject

@property (nonatomic) NSUInteger httpResponseCode;
@property (nonatomic, strong) NSDictionary *headers;
@property (nonatomic, strong) id body;
@property (nonatomic, strong) NSArray *errors;

- (id)initWithResponseBody:(id)responseBody httpCode:(NSUInteger)code error:(NSError *)anError;

- (id)initWithResponseBody:(id)responseBody httpCode:(NSUInteger)code errors:(NSArray *)theErrors;

- (BOOL)wasSuccess;

@end
