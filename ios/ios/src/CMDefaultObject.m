//
//  CMDefaultObject.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
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
