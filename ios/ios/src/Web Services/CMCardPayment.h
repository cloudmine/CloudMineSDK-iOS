//
//  CMPayment.h
//  cloudmine-ios
//
//  Created by Ethan Mick on 7/10/13.
//  Copyright (c) 2013 CloudMine, LLC. All rights reserved.
//

#import "CMObject.h"

FOUNDATION_EXPORT NSString *const CMCardPaymentTypeVisa;
FOUNDATION_EXPORT NSString *const CMCardPaymentTypeMasterCard;
FOUNDATION_EXPORT NSString *const CMCardPaymentTypeAmericanExpress;
FOUNDATION_EXPORT NSString *const CMCardPaymentTypeDinersClub;
FOUNDATION_EXPORT NSString *const CMCardPaymentTypeDiscover;
FOUNDATION_EXPORT NSString *const CMCardPaymentTypeJCB;
FOUNDATION_EXPORT NSString *const CMCardPaymentTypeUnknown;

/**
 * This holds "Whatever information Derek needs to make the payment happen."
 * Now, this will change for the different gateways... so either we can try to get everything in this
 * one object... or make a generic CMPayment object and users can subclass it for their individual
 * gateways. Perhaps we create a few nice default ones for the Gateways we support out of the box.
 *
 */
@interface CMCardPayment : CMObject

@property (nonatomic, copy) NSString *nameOnCard;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *expirationDate; //0914
@property (nonatomic, copy) NSString *last4Digits;
@property (nonatomic, copy) NSString *type;

@end
