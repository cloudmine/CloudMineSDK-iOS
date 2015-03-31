# Push Notifications

CloudMine supports receiving push notifications from the Apple Push Notification service (APNs). Before sending push notifications, you'll need to register your app with Apple, as described [here](#/push_notifications). Once your app is configured, you'll need to add code to your app that registers the device with Apple. This involves changing the base class of your app's AppDelegate class.

```objc
#import <UIKit/UIKit.h>
#import <CloudMine/CloudMine.h>
 
@interface MyAppDelegate : CMAppDelegateBase <UIApplicationDelegate>
 
@property (strong, nonatomic) UIWindow *window;
 
// rest of the AppDelegate header code goes here...
 
@end
```

Instead of manually sending your registration token to Apple, use the `CMAppDelegate` base class from our iOS library. This takes care of receiving the authorization token from Apple and sending it to the CloudMine servers.

### Device registration

To register the device for push notifications, call registerForPushNotifications:callback:

```objc
[[CMStore defaultStore] registerForPushNotifications:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)
                                            callback:^(CMDeviceTokenResult result) {
        if (result == CMDeviceTokenUploadSuccess || result == CMDeviceTokenUpdated) {
          NSLog(@"Registered successfully!");
        } else {
          NSLog(@"Uh oh, something happened: %d", result);
        }
      }];
```

{{note "If you plan on subclassing this method, be sure to call `[super didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];` so you can be certain your device is registered through CloudMine."}}

If the registration was successful, your device is now ready to recieve push notifications.

{{note "When registering, CloudMine will attempt to associate a device with a logged-in user. This means that if a CMUser has been set on the CMStore, the library will attempt to login that user before registering the device. If there is no user, future calls to register this device will attempt to associate the new user when the device is recognized server-side."}}

### Unregistering

If you no longer want this device to receive push notifications, use the `unRegisterForPushNotificationsWithCallback:` method.

```objc
[[CMStore defaultStore] unRegisterForPushNotificationsWithCallback:^(CMDeviceTokenResult result) {
  if (result == CMDeviceTokenDeleted) {
    NSLog(@"Success!");
  }
}];
```

After this, you will no longer recieve push notifications.
