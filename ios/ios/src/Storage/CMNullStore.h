//
//  CMNullStore.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMStore.h"

/**
 * <strong><em>This is an internal class that should not be used in your code.</em></strong> It is used to represent an
 * invalid store state after an object has been explicitly removed from its store and before it has been added to a new one.
 * Any method that is called on an instance (other than defaultStore and nullStore, which both return the singleton instance)
 * will throw an exception.
 */
@interface CMNullStore : CMStore

/**
 * @return The singleton instance of the null store.
 */
+ (CMNullStore *)nullStore;

@end
