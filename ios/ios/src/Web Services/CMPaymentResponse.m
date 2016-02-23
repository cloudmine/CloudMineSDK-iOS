//
//  CMPaymentResponse.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 7/10/13.
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//

#import "CMPaymentResponse.h"

@implementation CMPaymentResponse

- (CMPaymentResult)result;
{
    return [self wasSuccess] ? CMPaymentResultSuccessful : CMPaymentResultFailed;
}

@end
