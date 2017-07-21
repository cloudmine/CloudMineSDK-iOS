# Create Access List

Create a new access list by instantiating a CMACL object.

Your CMStore must be initialized with a user to create access lists.

Permissions are controlled by adding permissions to the access list object. This gives you the option to allow create, read, update, or delete permissions. Valid permissions are defined in CMACL.h.

```objc
extern NSString * const CMACLReadPermission;
extern NSString * const CMACLUpdatePermission;
extern NSString * const CMACLDeletePermission;
```

Add users to this access list by adding them to the set of members on the CMACL.

```objc
CMUser *user = [[CMUser alloc] initWithEmail:@"test@example.com" andPassword:@"my-password"];
CMUser *owner = [[CMUser alloc] initWithEmail:@"owner@example.com" andPassword:@"owner-password"];
 
CMACL *accessList = [[CMACL alloc] init];
[accessList setPermissions:[NSSet setWithObjects:CMACLReadPermission, CMACLUpdatePermission, nil]];
accessList.members = [NSSet setWithObjects:user.objectId];
 
[accessList saveWithUser:owner ^(CMObjectUploadResponse *response) {
    NSLog(@"Status: %@", [response.uploadStatuses objectForKey:car.objectId]);
}];
```

Now that we have an access list, we can use it to share data between users.
