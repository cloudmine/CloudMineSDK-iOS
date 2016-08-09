//
//  CMPaymentService.h
//  cloudmine-ios
//
//  Created by Ethan Mick on 7/10/13.
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMPaymentResponse.h"

@class CMUser, CMCardPayment;

@interface CMPaymentService : NSObject

@property (nonatomic, nullable) CMUser *user;

/**
 * Initialize the payment service.
 */
- (nonnull instancetype)init;

/**
 * Initialize the payment service with the given user.
 *
 * This is the designated constructor.
 *
 * @param aUser The user to initialize the service with.
 */
- (nonnull instancetype)initWithUser:(nullable CMUser *)aUser;

/**
 * Start a transaction with the given cart and payment info.
 *
 * @param cart This object can be anything you want. It is serialized into JSON.
 *
 */
- (void)initializeTransactionWithCart:(nonnull id)cart paymentInfo:(nonnull CMCardPayment *)paymentInfo descriptors:(nullable NSArray *)descriptors callback:(nonnull CMPaymentServiceCallback)callback;

/**
 * Completes the transaction started after initializeTransaction has been called.
 *
 */
- (void)fulfillTransactionWithID:(nonnull NSString *)transactionID descriptors:(nullable NSArray *)descriptors callback:(nonnull CMPaymentServiceCallback)callback;

/*
 * Charges the card at the index and processes the cart. This checks out and fulfills the order. You will probably want to use this most of the time.
 */
- (void)chargeCardAtIndex:(NSUInteger)index cart:(nonnull id)cart callback:(nonnull CMPaymentServiceCallback)callback;


@end
