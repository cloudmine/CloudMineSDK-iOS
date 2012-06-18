//
//  CMServerFunction.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

/**
 * Encapsulates a call to a server-side function. The call is triggered by being attached to
 * a regular HTTP call (GET, POST, or PUT) to the CM web services.
 */
@interface CMServerFunction : NSObject

/**
 * The name of the server-side code snippet to call.
 *
 * This corresponds to the name of the snippet defined in your CloudMine dashboard.
 */
@property (nonatomic, strong) NSString *functionName;

/**
 * Extra parameters to serve as input to the server-side snippet. These key-value pairs will
 * be converted into JSON so be sure that all non-primitive, non-collection types are able
 * to be serialized as such.
 *
 * Default is <tt>nil</tt>.
 */
@property (nonatomic, strong) NSDictionary *extraParameters;

/**
 * If <tt>YES</tt>, this causes only the result of this function call to be sent in the server's response.
 * This means that the original data will be left out. Use this to reduce the data traffic your app
 * consumes if it doesn't need access to the original data.
 *
 * Default is <tt>NO</tt>. Has no effect if <tt>async</tt> is <tt>YES</tt>.
 */
@property (nonatomic, assign) BOOL resultOnly;

/**
 * If <tt>YES</tt>, causes the server-side code snippet to be run asynchronously with respect to the request
 * that triggered it. This means the request will return immediately and thus the server-side snippet cannot
 * add any information to the response.
 *
 * Default is <tt>NO</tt>. Setting this to <tt>YES</tt> causes <tt>resultOnly</tt> to be treated as
 * <tt>NO</tt> regardless of what you set it to.
 */
@property (nonatomic, assign) BOOL async;

/**
 * Convenience method to return a representation of a server-side code snippet given a name and all other
 * options set to defaults.
 *
 * @param theFunctionName
 * @return CMServerFunction The newly initialized object.
 */
+ (id)serverFunctionWithName:(NSString *)theFunctionName;

/**
 * Convenience method to return a representation of a server-side code snippet given a name and a set
 * of extra parameters to send to the snippet. All other options remain set to their defaults.
 *
 * @param theFunctionName
 * @param theExtraParameters
 * @return CMServerFunction The newly initialized object.
 */
+ (id)serverFunctionWithName:(NSString *)theFunctionName extraParameters:(NSDictionary *)theExtraParameters;

/**
 * Convenience method to return a representation of a server-side code snippet given a name, a set
 * of extra parameters to send to the snippet, and whether or not the server should return only the result of the
 * snippet. <tt>async</tt> is set to its default, <tt>NO</tt>, automatically.
 *
 * @see resultOnly
 *
 * @param theFunctionName
 * @param theExtraParameters
 * @param resultOnly
 * @return CMServerFunction The newly initialized object.
 */
+ (id)serverFunctionWithName:(NSString *)theFunctionName extraParameters:(NSDictionary *)theExtraParameters responseContainsResultOnly:(BOOL)resultOnly;

/**
 * Convenience method to return a representation of a server-side code snippet given a name, a set
 * of extra parameters to send to the snippet, whether or not the server should return only the result of the
 * snippet, and whether the snippet should be called asynchronously.
 *
 * @see resultOnly
 * @see async
 *
 * @param theFunctionName
 * @param theExtraParameters
 * @param resultOnly
 * @param async
 * @return CMServerFunction The newly initialized object.
 */
+ (id)serverFunctionWithName:(NSString *)theFunctionName extraParameters:(NSDictionary *)theExtraParameters responseContainsResultOnly:(BOOL)resultOnly performAsynchronously:(BOOL)async;

/**
 * Convenience method to return a representation of a server-side code snippet given a name, a set
 * of extra parameters to send to the snippet, whether or not the server should return only the result of the
 * snippet, and whether the snippet should be called asynchronously.
 *
 * @see resultOnly
 * @see async
 *
 * @param theFunctionName
 * @param theExtraParameters
 * @param resultOnly
 * @param async
 * @return CMServerFunction The newly initialized object.
 */
- (id)initWithFunctionName:(NSString *)theFunctionName extraParameters:(NSDictionary *)theExtraParameters responseContainsResultOnly:(BOOL)resultOnly performAsynchronously:(BOOL)async;

/**
 * <strong>Do not call this method to construct a new instance.</strong>
 * @see initWithFunctionName:extraParameters:responseContainsResultOnly:performAsynchronously:
 * @throws NSException This initializer is not valid for this object.
 */
- (id)init;

/**
 * This is the query string that will be appended to the CloudMine HTTP call's URL to trigger the server-side
 * code snippet and all its related options encapsulated in this object.
 *
 * @returns NSString The valid query string representation of all the options encapsulated in this object.
 */
- (NSString *)stringRepresentation;

@end
