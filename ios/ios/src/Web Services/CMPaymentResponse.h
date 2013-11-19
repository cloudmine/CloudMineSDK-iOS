//
//  CMPaymentResponse.h
//  cloudmine-ios
//
//  Created by Ethan Mick on 7/10/13.
//  Copyright (c) 2013 CloudMine, LLC. All rights reserved.
//

#import "CMResponse.h"

typedef enum {
    /** The payment request failed. We can add in more details here as we know. Why did it fail. */
    CMPaymentResultFailed = 0,
    
    /** The payment request was a success */
    CMPaymentResultSuccessful = 1,
    
} CMPaymentResult;

/**
 * CMPaymentResponse
 * Encapsualtes the response of creating a payment.
 */
@interface CMPaymentResponse : CMResponse

@property (nonatomic) CMPaymentResult result;

@end

typedef void (^CMPaymentServiceCallback)(CMPaymentResponse *response);


