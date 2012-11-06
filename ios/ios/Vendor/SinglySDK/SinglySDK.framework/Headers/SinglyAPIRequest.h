//
//  SinglyAPIRequest.h
//  SinglySDK
//
//  Copyright (c) 2012 Singly, Inc. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//

#import <Foundation/Foundation.h>

@class SinglyAPIRequest;

@protocol SinglyAPIRequestDelegate <NSObject>
-(void)singlyAPIRequest:(SinglyAPIRequest*)request succeededWithJSON:(id)json;
-(void)singlyAPIRequest:(SinglyAPIRequest *)request failedWithError:(NSError*)error;
@end

@interface SinglyAPIRequest : NSObject

@property (copy) NSString* endpoint;
@property (copy) NSString* method;
@property (copy) NSData* body;

/*!
 Create a new API request
 @param endpoint
    The Singly API endpoint to hit, does not need to include the / at the begninning
 @param parameters
    A NSDictionary of the query string parameters to send on the request.  This may be nil.
*/
+(SinglyAPIRequest*)apiRequestForEndpoint:(NSString*)endpoint withParameters:(NSDictionary*)parameters;
/*!
 Create a new API request
 @param endpoint
 The Singly API endpoint to hit, does not need to include the / at the begninning
*/
+(SinglyAPIRequest*)apiRequestForEndpoint:(NSString *)endpoint;
-(id)initWithEndpoint:(NSString*)endpoint andParameters:(NSDictionary*)parameters;
-(NSString*)completeURLForToken:(NSString*)accessToken;
@end
