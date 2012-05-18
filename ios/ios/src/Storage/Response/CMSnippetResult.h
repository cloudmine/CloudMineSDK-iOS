//
//  CMSnippetResult.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>

/**
 * Container for data returned by a server-side code snippet.
 */
@interface CMSnippetResult : NSObject

@property (strong, nonatomic) id data;

-(id)initWithData:(id)theData;

@end
