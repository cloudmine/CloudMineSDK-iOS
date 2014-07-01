//
//  TestUser.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 7/1/14.
//  Copyright (c) 2014 CloudMine, LLC. All rights reserved.
//

#import "TestUser.h"

@implementation TestUser

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
{
    if ( (self = [super initWithCoder:aDecoder]) ) {
        _firstName = [aDecoder decodeObjectForKey:@"firstName"];
        _lastName = [aDecoder decodeObjectForKey:@"lastName"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_firstName forKey:@"firstName"];
    [aCoder encodeObject:_lastName forKey:@"lastName"];
}

@end
