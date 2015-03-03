//
//  CMPaymentServiceSpec.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 6/13/14.
//  Copyright (c) 2015 CloudMine, Inc. All rights reserved.
//

#import "Kiwi.h"
#import "CMPaymentService.h"
#import "CMUser.h"
#import "CMCardPayment.h"
#import "CMWebService.h"

SPEC_BEGIN(CMPaymentServiceSpec)

describe(@"CMPaymentService", ^{
    
    context(@"without a user", ^{
        
        __block CMPaymentService *paymentService = nil;
        beforeEach(^{
            paymentService = [[CMPaymentService alloc] init];
        });
        
        it(@"should initialize a transaction", ^{
            
            CMCardPayment *card = [[CMCardPayment alloc] init];
            card.nameOnCard = @"Ethan Smith";
            card.token = @"3243249390328409";
            card.expirationDate = @"0919";
            card.last4Digits = @"1111";
            card.type = CMCardPaymentTypeVisa;
            
            KWCaptureSpy *callbackBlockSpy = [[paymentService valueForKey:@"service"]
                                              captureArgument:@selector(executeGenericRequest:successHandler:errorHandler:) atIndex:1];
            [[[paymentService valueForKey:@"service"] should] receive:@selector(executeGenericRequest:successHandler:errorHandler:) withCount:1];
            
            [paymentService initializeTransactionWithCart:@{@"something": @"okay"}
                                              paymentInfo:card
                                              descriptors:nil
                                                 callback:^(CMPaymentResponse *response) {
                                                     [[theValue([response wasSuccess]) should] beTrue];
                                                     [[theValue(response.result) should] equal:@(CMPaymentResultSuccessful)];
                                                 }];
            
            CMWebServiceGenericRequestCallback callback = callbackBlockSpy.argument;
            callback(@{@"result":@"success"}, 200, @{});
        });
        
        it(@"should return the proper error when the web service fails", ^{
            
            KWCaptureSpy *callbackBlockSpy = [[paymentService valueForKey:@"service"]
                                              captureArgument:@selector(executeGenericRequest:successHandler:errorHandler:) atIndex:2];
            [[[paymentService valueForKey:@"service"] should] receive:@selector(executeGenericRequest:successHandler:errorHandler:) withCount:1];
            
            CMCardPayment *card = [[CMCardPayment alloc] init];
            card.nameOnCard = @"Ethan Smith";
            card.token = @"3243249390328409";
            card.expirationDate = @"0919";
            card.last4Digits = @"1111";
            card.type = CMCardPaymentTypeVisa;
            
            // This first call should trigger the web service call.
            [paymentService initializeTransactionWithCart:@{@"something": @"okay"}
                                              paymentInfo:card
                                              descriptors:nil
                                                 callback:^(CMPaymentResponse *response) {
                                                     [[theValue([response wasSuccess]) should] beFalse];
                                                     [[theValue(response.result) should] equal:@(CMPaymentResultFailed)];
                                                 }];
            
            CMWebServiceErorCallack callback = callbackBlockSpy.argument;
            callback(@{@"Error": @"error message"}, 400, @{}, [NSError new], @{});
        });
        
        it(@"should fulfill a transcaction", ^{
            KWCaptureSpy *callbackBlockSpy = [[paymentService valueForKey:@"service"]
                                              captureArgument:@selector(executeGenericRequest:successHandler:errorHandler:) atIndex:1];
            [[[paymentService valueForKey:@"service"] should] receive:@selector(executeGenericRequest:successHandler:errorHandler:) withCount:1];
            
            [paymentService fulfillTransactionWithID:@"transaction_id"
                                         descriptors:nil
                                            callback:^(CMPaymentResponse *response) {
                                                [[theValue([response wasSuccess]) should] beTrue];
                                                [[theValue(response.result) should] equal:@(CMPaymentResultSuccessful)];
                                            }];
            
            CMWebServiceGenericRequestCallback callback = callbackBlockSpy.argument;
            callback(@{@"fulfilled":@"yes"}, 200, @{});
        });
        
        it(@"charge the card at the index", ^{
            KWCaptureSpy *callbackBlockSpy = [[paymentService valueForKey:@"service"]
                                              captureArgument:@selector(executeGenericRequest:successHandler:errorHandler:) atIndex:1];
            [[[paymentService valueForKey:@"service"] should] receive:@selector(executeGenericRequest:successHandler:errorHandler:) withCount:1];
            
            [paymentService chargeCardAtIndex:0 cart:@{@"something": @"inmycart"} callback:^(CMPaymentResponse *response) {
                [[theValue([response wasSuccess]) should] beTrue];
                [[theValue(response.result) should] equal:@(CMPaymentResultSuccessful)];
            }];
            
            CMWebServiceGenericRequestCallback callback = callbackBlockSpy.argument;
            callback(@{@"done":@"yes"}, 200, @{});
        });
    });
    
    
    context(@"with a user", ^{
        
        __block CMPaymentService *paymentService = nil;
        beforeEach(^{
            CMUser *user = [[CMUser alloc] initWithEmail:@"test_payment_service@cloudmine.me" andPassword:@"testing"];
            paymentService = [[CMPaymentService alloc] initWithUser:user];
        });
    });
    
});

SPEC_END

