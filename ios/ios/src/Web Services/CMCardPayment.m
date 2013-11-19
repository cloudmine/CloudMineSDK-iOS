//
//  CMPayment.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 7/10/13.
//  Copyright (c) 2013 CloudMine, LLC. All rights reserved.
//

#import "CMCardPayment.h"

NSString *const CMCardPaymentTypeVisa = @"visa";
NSString *const CMCardPaymentTypeMasterCard = @"mc";
NSString *const CMCardPaymentTypeAmericanExpress = @"amex";
NSString *const CMCardPaymentTypeDinersClub = @"othr";
NSString *const CMCardPaymentTypeDiscover = @"disc";
NSString *const CMCardPaymentTypeJCB = @"jcb";
NSString *const CMCardPaymentTypeUnknown = @"othr";

@implementation CMCardPayment

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if ( (self = [super initWithCoder:aDecoder]) ) {
        self.nameOnCard = [aDecoder decodeObjectForKey:@"nameOnCard"];
        self.token = [aDecoder decodeObjectForKey:@"token"];
        self.expirationDate = [aDecoder decodeObjectForKey:@"expirationDate"];
        self.last4Digits = [aDecoder decodeObjectForKey:@"last4Digits"];
        self.type = [aDecoder decodeObjectForKey:@"type"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.nameOnCard forKey:@"nameOnCard"];
    [aCoder encodeObject:self.token forKey:@"token"];
    [aCoder encodeObject:self.expirationDate forKey:@"expirationDate"];
    [aCoder encodeObject:self.last4Digits forKey:@"last4Digits"];
    [aCoder encodeObject:self.type forKey:@"type"];
}


@end
