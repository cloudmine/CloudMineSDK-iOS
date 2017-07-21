# Sharing User Data

To share data between different users, we need to grant a [CMACL](http://cocoadocs.org/docsets/CloudMine/1.7.0/Classes/CMACL.html) access to a [CMObject](http://cocoadocs.org/docsets/CloudMine/1.7.0/Classes/CMObject.html). This is done using the [addACL](http://cocoadocs.org/docsets/CloudMine/1.7.0/Classes/CMObject.html#//api/name/addACL:callback:) method.

This assumes that we've already created a CMAccessList.

```objc
// create our users
CMUser *user = [[CMUser alloc] initWithEmail:@"test@example.com" andPassword:@"my-password"];
CMUser *owner = [[CMUser alloc] initWithEmail:@"owner@example.com" andPassword:@"owner-password"];
 
// create the ACL
CMACL *accessList = [[CMACL alloc] init];
[accessList setPermissions:[NSSet setWithObjects:CMACLReadPermission, CMACLUpdatePermission, nil]];
accessList.members = [NSSet setWithObjects:user.email];
 
// this is the object we want to grant access to
CMObject *object = [[CMObject alloc] init];
 
// add the ACL to the permissions list
[object addACL:accessList, ^(CMObjectUploadResponse *response) {
    NSLog(@"Status: %@", [response.uploadStatuses objectForKey:object.objectId]);
}];
```

Once the access list has been attached to an object, members of that list will have the permissions enumerated in the access list.
