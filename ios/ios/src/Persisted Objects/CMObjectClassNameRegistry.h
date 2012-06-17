//
//  CMObjectClassNameRegistry.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>

/**
 * The registry that tracks all the custom class names you've registered by overriding +className in
 * your subclasses of <tt>CMObject</tt>. This is a singleton. <b>Do not call <tt>init</tt></b>. Instead use
 * <tt>+sharedInstance</tt> to get the instance of this class.
 *
 * The way this works is by looking up all the subclasses of <tt>CMObject</tt> by using the Objective-C runtime
 * and sends <tt>+className</tt> to each of them. It then records that name as a mapping to the class itself. Remember
 * that <tt>CMObjec</tt> provides a default implementation of <tt>+className</tt> that simply evaluates to
 * <tt>NSStringFromClass([self class])</tt> so you only need to override that method if you are writing a cross-platform
 * app with multiple codebases and need to keep the class names in sync.
 *
 * @see CMObject#className
 */
@interface CMObjectClassNameRegistry : NSObject {
    NSMutableDictionary *classNameMappings;
}

/**
 * @return The singleton instance of the registry.
 */
+ (id)sharedInstance;

/**
 * Given a class name, look up the actual class.
 *
 * <b>Implementation details</b>:
 * This first looks in the mapping of custom class names to ObjC classes. If it finds a class that matches
 * the name you gave, it returns that. If that fails, it tries to just use <tt>NSClassFromString()</tt>. If
 * that fails, it returns <tt>nil</tt>.
 *
 * @return The Class found in the registry, or nil if no match was found.
 */
- (Class)classForName:(NSString *)name;

/**
 * Drops all the entries in the registry and re-runs the detection method.
 */
- (void)refreshRegistry;

@end
