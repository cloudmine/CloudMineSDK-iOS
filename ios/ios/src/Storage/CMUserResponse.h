//
//  CMResponseUser.h
//  cloudmine-ios
//
//  Created by Ethan Mick on 7/28/14.
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//

#import "CMResponse.h"
#import "CMUser.h"

@interface CMUserResponse : CMResponse

@property (nonatomic) CMUserAccountResult result;

/**
 * The created user.
 */
@property (nonatomic, strong, nullable) CMUser *user;

@end
