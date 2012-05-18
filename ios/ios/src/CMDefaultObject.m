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

- (id)initWithFields:(NSDictionary *)theFields objectId:(NSString *)objId {
    if (self = [super initWithObjectId:objId]) {
        self.fields = theFields;
    }
    
    return self;
}

@end
