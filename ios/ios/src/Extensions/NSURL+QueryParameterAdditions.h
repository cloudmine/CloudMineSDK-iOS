//
//  NSURL+QueryParameterAdditions.h
//  cloudmine-ios
//
//  Created by Marc Weil on 11/10/11.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (QueryParameterAdditions)

- (NSURL *)URLByAppendingQueryString:(NSString *)queryString;

@end
