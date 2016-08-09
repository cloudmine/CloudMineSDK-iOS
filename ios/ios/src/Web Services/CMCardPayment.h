//
//  CMPayment.h
//  cloudmine-ios
//
//  Created by Ethan Mick on 7/10/13.
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//

#import "CMObject.h"

FOUNDATION_EXPORT NSString *_Nonnull const CMCardPaymentTypeVisa;
FOUNDATION_EXPORT NSString *_Nonnull const CMCardPaymentTypeMasterCard;
FOUNDATION_EXPORT NSString *_Nonnull const CMCardPaymentTypeAmericanExpress;
FOUNDATION_EXPORT NSString *_Nonnull const CMCardPaymentTypeDinersClub;
FOUNDATION_EXPORT NSString *_Nonnull const CMCardPaymentTypeDiscover;
FOUNDATION_EXPORT NSString *_Nonnull const CMCardPaymentTypeJCB;
FOUNDATION_EXPORT NSString *_Nonnull const CMCardPaymentTypeUnknown;

/**
 * This holds "Whatever information Derek needs to make the payment happen."
 * Now, this will change for the different gateways... so either we can try to get everything in this
 * one object... or make a generic CMPayment object and users can subclass it for their individual
 * gateways. Perhaps we create a few nice default ones for the Gateways we support out of the box.
 *
 */
@interface CMCardPayment : CMObject

@property (nonatomic, copy, nullable) NSString *nameOnCard;
@property (nonatomic, copy, nullable) NSString *token;
@property (nonatomic, copy, nullable) NSString *expirationDate; //0914
@property (nonatomic, copy, nullable) NSString *last4Digits;
@property (nonatomic, copy, nullable) NSString *type;

@end
