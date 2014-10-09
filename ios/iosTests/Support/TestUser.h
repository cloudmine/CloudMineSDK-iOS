//
//  TestUser.h
//  cloudmine-ios
//
//  Created by Ethan Mick on 7/1/14.
//  Copyright (c) 2014 CloudMine, LLC. All rights reserved.
//

#import "CMUser.h"

@class Venue;

@interface TestUser : CMUser

@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, strong) Venue *aVenue;

@end
