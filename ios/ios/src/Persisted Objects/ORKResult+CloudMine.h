//
//  ORKResult+CloudMine.h
//  cloudmine-ios
//
//  Created by Ethan Mick on 1/12/16.
//  Copyright © 2016 CloudMine, LLC. All rights reserved.
//

#import "CMObject.h"
#import "ResearchKit.h"

@interface ORKResult (CloudMine)

- (void)save:(CMStoreObjectUploadCallback)callback;

- (void)saveWithUser:(CMUser *)user callback:(CMStoreObjectUploadCallback)callback;

@end
