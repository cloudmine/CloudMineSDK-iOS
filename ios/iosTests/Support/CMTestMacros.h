//
//  CMTestMacros.h
//  cloudmine-ios
//
//  Created by Ethan Mick on 1/16/15.
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//

#import "CMConstants.h"

#define APP_ID (((NSString *)[[NSProcessInfo processInfo] environment][@"APP_ID"]).length != 0 ? [[NSProcessInfo processInfo] environment][@"APP_ID"] : @"9977f87e6ae54815b32a663902c3ca65")

#define API_KEY (((NSString *)[[NSProcessInfo processInfo] environment][@"API_KEY"]).length != 0 ? [[NSProcessInfo processInfo] environment][@"API_KEY"] : @"c701d73554594315948c8d3cc0711ac1")

#define BASE_URL (((NSString *)[[NSProcessInfo processInfo] environment][@"BASE_URL"]).length != 0 ? [[NSProcessInfo processInfo] environment][@"BASE_URL"] : CM_BASE_URL)


#define CM_TEST_TIMEOUT 10.0
