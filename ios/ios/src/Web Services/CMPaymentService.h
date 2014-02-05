//
//  CMPaymentService.h
//  cloudmine-ios
//
//  Created by Ethan Mick on 7/10/13.
//  Copyright (c) 2013 CloudMine, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMPaymentResponse.h"

@class CMUser, CMCardPayment;

@interface CMPaymentService : NSObject

@property (nonatomic, strong) CMUser *user;

/**
 * Initialize the payment service.
 */
- (id)init;

/**
 * Initialize the payment service with the given user.
 *
 * This is the designated constructor.
 *
 * @param aUser The user to initialize the service with.
 */
- (id)initWithUser:(CMUser *)aUser;

/**
 * Start a transaction with the given cart and payment info.
 *
 * @param cart This object can be anything you want. It is serialized into JSON.
 *
 */
- (void)initializeTransactionWithCart:(id)cart paymentInfo:(CMCardPayment *)paymentInfo descriptors:(NSArray *)descriptors callback:(CMPaymentServiceCallback)callback;

/**
 * Completes the transaction started after initializeTransaction has been called.
 *
 */
- (void)fulfillTransactionWithID:(NSString *)transactionID descriptors:(NSArray *)descriptors callback:(CMPaymentServiceCallback)callback;

/*
 * Charges the card at the index and processes the cart. This checks out and fulfills the order. You will probably want to use this most of the time.
 */
- (void)chargeCardAtIndex:(NSUInteger)index cart:(id)cart callback:(CMPaymentServiceCallback)callback;


@end
