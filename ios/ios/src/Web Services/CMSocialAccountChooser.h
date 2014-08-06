//
//  CMSocialAccountChooser.h
//  cloudmine-ios
//
//  Created by Ethan Mick on 8/1/14.
//  Copyright (c) 2014 CloudMine, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

@interface CMSocialAccountChooser : NSObject <UIAlertViewDelegate, UIActionSheetDelegate>

- (void)wouldLikeToLogInWithAnotherAccountWithCallback:( void (^)(BOOL answer))callback;
- (void)chooseFromAccounts:(NSArray *)accounts showFrom:(UIViewController *)controller callback:( void (^)(id account))callback;

@end
