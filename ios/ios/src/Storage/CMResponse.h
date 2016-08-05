//
//  CMResponse.h
//  cloudmine-ios
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>

/**
 * The superclass for all responses. Holds common information such as the response code, headers, http body and errors.
 */
@interface CMResponse : NSObject

/**
 * The HTTP Response Code that returned with the request.
 */
@property (nonatomic) NSUInteger httpResponseCode;

/**
 * The Headers returned with the request.
 */
@property (nonatomic, strong, nullable) NSDictionary *headers;

/**
 * The HTML Body that was returned with the request. Subclasses should typically provide a method which will return the body
 * in a more friendly format, such as an NSArray or NSDictionary, depending on the call made.
 */
@property (nonatomic, strong, nullable) id body;

/**
 * An Array of Errors that occurred during the transaction.
 */
@property (nonatomic, strong, nullable) NSArray *errors;

/**
 * Returns a new CMReponse object
 *
 * @param responseBody The Body of the HTTP response.
 * @param code The HTTP response code.
 * @param anError A single error returned with the response.
 * @return A CMResponse Object
 */
- (nonnull instancetype)initWithResponseBody:(nullable id)responseBody httpCode:(NSUInteger)code error:(nullable NSError *)anError;

/**
 * Returns a new CMReponse object
 *
 * @param responseBody The Body of the HTTP response.
 * @param code The HTTP response code.
 * @param theErrors An Array of NSError objects.
 * @return A CMResponse Object
 */
- (nonnull instancetype)initWithResponseBody:(nullable id)responseBody httpCode:(NSUInteger)code errors:(nullable NSArray *)theErrors;

/**
 * Returns a new CMReponse object
 *
 * @param responseBody The Body of the HTTP response.
 * @param code The HTTP response code.
 * @param theHeaders The headers from the response.
 * @param theErrors An Array of NSError objects.
 * @return A CMResponse Object
 */
- (nonnull instancetype)initWithResponseBody:(nullable id)responseBody httpCode:(NSUInteger)code headers:(nullable NSDictionary *)theHeaders errors:(nullable NSDictionary *)theErrors;

/**
 * Returns if the Response was successful or not, defined by the httpResponseCode being
 * in between 200 and 300.
 * @return A BOOL if it was successful or not.
 */
- (BOOL)wasSuccess;

@end
