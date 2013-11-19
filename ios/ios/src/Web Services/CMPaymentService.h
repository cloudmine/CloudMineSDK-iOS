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

- (id)init;
- (id)initWithUser:(CMUser *)aUser;

- (void)initializeTransactionWithCart:(id)cart paymentInfo:(CMCardPayment *)paymentInfo descriptors:(NSArray *)descriptors callback:(CMPaymentServiceCallback)callback;
- (void)fulfillTransactionWithID:(NSString *)transactionID descriptors:(NSArray *)descriptors callback:(CMPaymentServiceCallback)callback;

- (void)chargeCardAtIndex:(NSUInteger)index cart:(id)cart callback:(CMPaymentServiceCallback)callback;


@end
