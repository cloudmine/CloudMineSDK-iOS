//
//  CMDefaultObject.m
//  cloudmine-ios
//
//  Created by Derek Mansen on 5/16/12.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//

#import "CMDefaultObject.h"
#import "CMObjectSerialization.h"

@implementation CMDefaultObject

@synthesize fields;

- initWithCoder:(NSCoder *)coder {
    NSDictionary *dict = [[NSDictionary alloc] initWithCoder:coder];
    
    if (self = [super initWithObjectId:[dict objectForKey:CMInternalObjectIdKey]]) {
        self.fields = dict;
    }
    
    return self;
}

@end
