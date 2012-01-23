//
//  CMStore.h
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>
#import "CMWebService.h"

@interface CMStore : NSObject

@property (nonatomic, strong) CMWebService *webService;

/**
 * Convenience method to return a newly initialized CMStore instance.
 * Note that, like when using <tt>init</tt>, you must have already initialized the
 * <tt>CMAPICredentials</tt> singleton with your app identifier and secret key.
 *
 * @see CMAPICredentials
 */
+ (CMStore *)store;

/**
 * Default constructor. Note that you must have already initialized the
 * <tt>CMAPICredentials</tt> singleton with your app identifier and secret key.
 *
 * @see CMAPICredentials
 */
- (id)init;

- (NSSet *)allObjects;

@end
