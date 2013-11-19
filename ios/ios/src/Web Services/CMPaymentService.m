//
//  CMPaymentService.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 7/10/13.
//  Copyright (c) 2013 CloudMine, LLC. All rights reserved.
//

#import "CMPaymentService.h"
#import "CMUser.h"
#import "CMWebService.h"
#import "CMCardPayment.h"
#import "CMObjectEncoder.h"
#import "NSDictionary+CMJSON.h"

@interface CMPaymentService ()

@property (nonatomic, strong) CMWebService *service;
@property (nonatomic, strong) void (^successCallback)(id, NSUInteger, NSDictionary*);
@property (nonatomic, strong) void (^failureCallback)(id, NSUInteger, NSDictionary*, NSError*, NSDictionary*);
@property (nonatomic, strong) CMPaymentServiceCallback callback;

@end

@implementation CMPaymentService

- (id)init;
{
    return [self initWithUser:nil];
}

- (id)initWithUser:(CMUser *)aUser;
{
    
    if ( (self = [super init]) ) {
        self.user = aUser;
        self.service = [CMWebService sharedWebService];
        
        CMPaymentService *selff = self;
        
        self.successCallback = ^(id parsedBody, NSUInteger httpCode, NSDictionary *headers){
            CMPaymentResponse *response = [[CMPaymentResponse alloc] initWithResponseBody:parsedBody httpCode:httpCode headers:headers errors:nil];
            if (selff.callback) selff.callback(response);
        };
        
        self.failureCallback = ^(id responseBody, NSUInteger httpCode, NSDictionary *headers, NSError *error, NSDictionary *errorInfo) {
            CMPaymentResponse *response = [[CMPaymentResponse alloc] initWithResponseBody:responseBody httpCode:httpCode headers:headers errors:errorInfo];
            if (selff.callback) selff.callback(response);
        };
    }
    
    return self;
}

- (void)initializeTransactionWithCart:(id)cart paymentInfo:(CMCardPayment *)paymentInfo descriptors:(NSArray *)descriptors callback:(CMPaymentServiceCallback)callback;
{
    self.callback = callback;
    NSMutableURLRequest *request = [self chargeRequestWithEndpoint:@"init" cart:cart paymentInfo:paymentInfo descriptors:descriptors];
    [self.service executeGenericRequest:request successHandler:self.successCallback errorHandler:self.failureCallback];
}

- (void)fulfillTransactionWithID:(NSString *)transactionID descriptors:(NSArray *)descriptors callback:(CMPaymentServiceCallback)callback;
{
    self.callback = callback;
    NSString *urlString = [NSString stringWithFormat:@"payments/transaction/%@/fulfill", transactionID];
    
    NSURL *url = [self.service constructAppURLWithString:urlString andDescriptors:descriptors];
    NSMutableURLRequest *request = [self.service constructHTTPRequestWithVerb:@"GET" URL:url binaryData:NO user:_user];
    
    [self.service executeGenericRequest:request successHandler:self.successCallback errorHandler:self.failureCallback];
}

- (void)chargeCardAtIndex:(NSUInteger)index cart:(id)cart callback:(CMPaymentServiceCallback)callback;
{
    self.callback = callback;
    
    NSURL *url = [self.service constructAppURLWithString:@"payments/transaction/charge" andDescriptors:nil];
    NSMutableURLRequest *request = [self.service constructHTTPRequestWithVerb:@"POST" URL:url binaryData:NO user:_user];
    [request setHTTPBody:[@{@"cart" : cart, @"paymentInfo" : @{@"index": @(index), @"type": @"card"}} jsonData]];
    [self.service executeGenericRequest:request successHandler:self.successCallback errorHandler:self.failureCallback];
}

- (NSMutableURLRequest *)chargeRequestWithEndpoint:(NSString *)endpoint cart:(id)cart paymentInfo:(CMCardPayment *)paymentInfo descriptors:(NSArray *)descriptors;
{
    NSDictionary *paymentSerialized = [CMObjectEncoder encodeObjects:@[paymentInfo]];
    
    __block NSDictionary *actualPayment = nil;
    
    [paymentSerialized enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        actualPayment = @{@"token": obj[@"token"], @"expiration" : obj[@"expirationDate"]};
    }];
    
    NSURL *url = [self.service constructAppURLWithString:[NSString stringWithFormat:@"payments/transaction/%@", endpoint] andDescriptors:descriptors];
    NSMutableURLRequest *request = [self.service constructHTTPRequestWithVerb:@"POST" URL:url binaryData:NO user:_user];
    [request setHTTPBody:[@{@"cart" : cart, @"paymentInfo" : actualPayment} jsonData]];
    return request;
}



@end
