//
//  CMSocialAccountChooser.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 8/1/14.
//  Copyright (c) 2014 CloudMine, LLC. All rights reserved.
//

#import "CMSocialAccountChooser.h"

@interface CMSocialAccountChooser ()

@property (nonatomic, copy) void (^callback)(BOOL answer);
@property (nonatomic, copy) void (^pickerCallback)(id account);
@property (nonatomic, copy) NSArray *accounts;

@end

@implementation CMSocialAccountChooser

- (void)wouldLikeToLogInWithAnotherAccountWithCallback:( void (^)(BOOL answer))callback;
{
    self.callback = callback;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"Twitter access not granted, would you like to login with another Twitter account?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    
#if TESTING==0
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
#endif
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (self.callback) {
        self.callback(buttonIndex != 0);
    }
}

- (void)chooseFromAccounts:(NSArray *)accounts showFrom:(UIViewController *)controller callback:( void (^)(id account))callback;
{
    if (!callback) {
        return; //No point in doing anything with the callback
    }
    self.pickerCallback = callback;
    self.accounts = accounts;
    
#warning Overrideable by using Localized strings
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.title = @"Login to Twitter";
    sheet.delegate = self;
    for (ACAccount *account in accounts) {
        [sheet addButtonWithTitle:[NSString stringWithFormat:@"@%@", account.username]];
    }
    [sheet addButtonWithTitle:@"Login to Another"];
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
/// Kiwi breaks if we try to display anything, so we disable for testing.
#if TESTING==0
        if (controller.tabBarController.tabBar) {
            [sheet showFromTabBar:controller.tabBarController.tabBar];
        } else if (controller.navigationController.toolbar) {
            [sheet showFromToolbar:controller.navigationController.toolbar];
        } else if (controller.view) {
            [sheet showInView:controller.view];
        }
#endif
    });
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    
    if (_pickerCallback) {
        if (buttonIndex == (self.accounts.count + 1)) { //Cancel
            _pickerCallback(nil);
        } else if (buttonIndex == self.accounts.count) { // Login to Another
            _pickerCallback(@YES); //NSNumber signifies trying another
        } else {
            _pickerCallback(_accounts[buttonIndex]);
        }
    }
}

@end
