# Update User Profiles

When using a custom user class, fields can be added which will be persisted as that user's "profile". The main purpose of this profile is discoverability. Using this profile, users of your app can find other users to share their data with.

It's important to remember that profile information is public. For this reason, by default, we don't save any fields on the user's profile except for their unique identifier.

To add fields to a user's profile, first create a custom user class.

CustomUser.h

```objc 
#import <CloudMine/CloudMine.h>
 
@interface CustomUser : CMUser
 
@property (strong) NSString *name;
@property (strong) CMDate *birthday;
 
- (void)resetState;
 
@end
```

CustomUser.m

```objc
@implementation CustomUser
@synthesize name;
@synthesize birthday;
 
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        name = [aDecoder decodeObjectForKey:@"name"];
        birthday = [aDecoder decodeObjectForKey:@"birthday"];
    }
 
    return self;
}
 
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeObject:birthday forKey:@"birthday"];
}
 
- (void)resetState {
    name = nil;
    birthday = nil;
    self.token = nil;
    self.tokenExpiration = nil;
}
 
@end
```

To save updates to fields on the user object, use the save method on CMUser.

```objc
CustomUser *user = [[CustomUser alloc] initWithEmail:@"test@example.com" andPassword:@"password"];
user.name = @"Derek";
user.birthday = [[CMDate alloc] init];
 
[user save:^(CMUserAccountResult result, NSArray *messages) {
    NSLog(@"Status: %@", response.uploadStatuses);
}];
```

The user will be saved using the `encodeWithCoder:` method defined in the implementation.


