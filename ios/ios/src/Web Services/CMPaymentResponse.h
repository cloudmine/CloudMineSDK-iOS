//
//  CMPaymentResponse.h
//  cloudmine-ios
//
//  Created by Ethan Mick on 7/10/13.
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//

#import "CMResponse.h"

typedef NS_ENUM(NSInteger, CMPaymentResult) {
    /** The payment request failed. We can add in more details here as we know. Why did it fail. */
    CMPaymentResultFailed = 0,
    
    /** The payment request was a success */
    CMPaymentResultSuccessful = 1,
    
};

/**
 * CMPaymentResponse
 * Encapsualtes the response of creating a payment.
 */
@interface CMPaymentResponse : CMResponse

@property (nonatomic) CMPaymentResult result;

@end

typedef void (^CMPaymentServiceCallback)(CMPaymentResponse *_Nonnull response);


