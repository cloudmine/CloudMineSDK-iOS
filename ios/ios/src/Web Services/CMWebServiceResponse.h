//
//  CMWebServiceResponse.h
//  cloudmine-ios
//
//  Created by Derek Mansen on 5/8/12.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMWebServiceResponse : NSObject

@property (readonly, strong, atomic) NSDictionary *objects;
@property (readonly, strong, atomic) NSDictionary *errors;
@property (readonly, strong, atomic) NSDictionary *metadata;

@end
