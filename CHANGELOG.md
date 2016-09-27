1.8.0 (September 27, 2016)
==========================
The entire SDK has been audited and annotated for nullability. For apps written in
Objective-C, this means you may see compiler warnings if you are not following the
SDK's conventions for nil parameters. When using the SDK in Swift, the changes are more
significant and may require code updates to properly compile. While this may result in
a small upgrade process for your app, the resulting code is both safer and
more natively "Swifty."

Nullability annotations allow the SDK to be used more naturally in Swift by enforcing
the same rules for optionals used in Swift code. In some cases, you may be unwrapping, force
unwrapping, or implicitly unwrapping an optional in your code that is now annotated as
nonnull. The Swift compiler will require the now unnecessary step of unwrapping be
removed. The result of this migration is code that is simpler and safer.

Though we have taken care to audit the SDK thoroughly, we welcome any reports of annotations
which seem incorrect or edge cases that may have slipped through the cracks. Please report
these on GitHub and/or to CloudMine support. As always, it is recommended that you test your
app thoroughly after applying an update to this and other dependencies in your codebase.

Other minor changes are included in this release:

 * The `-saveWithUser:callback:` method on `CMObject` has been deprecated in favor of
   the new `saveAtUserLevel:` method.
 * `appSecret` has been deprecated in favor of `apiKey` on `CMAPICredentials`
 * The designated initializers on `CMObject` have been properly annotated, resulting
   in less boilerplate and less confustion when subclassing in Swift
 * Minor bugfixes and improvements
 
1.7.14 (October 3, 2016)
========================
Resolves a bug that, in rare circumstances, could result in the file cache filling
up. This would only happen if enough files were downloaded to fill the cache
while the app was still open, before the operating system had a chance to purge the
cache directory.

Because the previous caching strategy was ineffective, the existing
caching methods on the CMFile object have been deprecated. If your app uses any
direct access to the CloudMine cache directories, you should remove this behavior.
In future versions of the SDK, all caching will be handled internally.

1.7.13 (September 26, 2016)
===========================
Bugfixes:
  * Resolve a compiler warning caused by stricter Objective-C casting rules in Xcode 8
  * Fix a bug in the CMObject -description method that could, in rare circumstances, cause a crash

1.7.12 (August 9, 2016)
======================
Bugfixes:
 * CMDate now serializes and deserializes properly with NSKeyedArchiver/NSKeydUnarchiver
 * CMStore no longer crashes if you attempt to save a nil object or ACL; prints log warning instead

1.7.11 (April 6, 2016)
======================
* Resolved Swift interop issues:
  * The SDK can now be imported into Swift projects without an Objective-C bridging header
  * Subclassing `CMObject` in Swift is now less confusing thanks to resolved initializer designation
* The SDK no longer throws and catches exceptions internally, making breakpoint debugging more feasible
* The `-registerForPushNotifications:` family of methods on `CMStore` have been deprecated and replaced with versions that work cleanly with changes to Cocoa
* Various compiler warnings and deprecations have been resolved

1.7.10 (February 29, 2016)
======================
* Updated deployment targets to iOS 8.0
* Minor documentation updates
* Integrated MAObjCRuntime library

v1.7.8 (July 28, 2015)
======================
* Added methods on CMStore that replace entire Objects.

v1.7.5 (June 12, 2015)
======================
* Added a method on CMObject that allows direct adding of ACL ID's to the __access__ property.

v1.7.5 (March 6, 2015)
======================
* Changed all returned values to be `instancetype`
* Fixed a bug in which a dictionary that looked like a CMObject, but shouldn't be, was deserialized to be a CMUntypedObject. Inserting `__class__: 'map'` as a Key/Value pair in your dictionaries will stop this from occurring.

v1.7.4 (March 5, 2015)
======================
* Added in Segments API for ACL's
* Updated License and year to 2015

v1.7.3 (October 8, 2014)
========================
* Bug Fixes

v1.7.2 (October 7, 2014)
========================
* Fixed many ARM64 Bugs in the Tests
* Changed all `typedef enums` to use `NS_ENUM` instead to define the type.
* Added a new method on searching CMUser's that uses CMStoreOptions to page and return count.

v1.7.1 (August 26, 2014)
========================
* Added "google" CMSocialIdentifier
* Added "currentUser" method to get the current user. This also persists and saves the user between app launches.
* Added callbacks to Social Login with the user cancels from a native login.

v1.7.0 (August 6, 2014)
=======================
* Added new methods on CMUser that allow a user to be created directly with a access_token or oauthtoken/secret
* Updated loginWithSocialNetwork: to use Twitter.
* Updated loginWithSocialNetwork: to use Facebook (if the sdk is installed by the user, and the user is logged in).
* Added method to retrieve a user's profile without re-logging in. See "getProfile:"
* Added the ability to serialize any object that adheres to NSCoding. This allows you to create nested objects that are not CMObjects, and can make searching much easier.
* Added nested CMObjects.
* Updated push notifications to have a nice error message when attempting to register without a logged in user.
* Removed check in code to ensure a user is logged in, which could cause a crash.

v1.5.7 (March 12, 2013)
=======================
* Added Ability to subscribe/unsubscribe to push channels.
* Added ability to list push channels a device is in.
* Changed all Network Requests to persist in the background if the app is closed during the operation.

v1.5.6 (February 20, 2013)
==========================
* Added Singly as a network that can be used in Social Graph Queries
* Fixed a bug where international locales would fail to parse session expiration

v1.5.5 (January 31, 2013)
=====
* Fixed a bug in which URL's in social graphs querying would sometimes be encoded twice.
* Fixed a bug in which Snippet URL's were not encoded properly.

v1.5.4 (January 14, 2013)
=====
* Renamed Social Proxy methods too:
  * runSocialGraphGETQueryOnNetwork:baseQuery:parameters:headers:withUser:successHandler:errorHandler:
  * runSocialGraphQueryOnNetwork:withVerb:baseQuery:parameters:headers:messageData:withUser:successHandler:errorHandler:
* Added platform support for Social Proxy

v1.5.3 (January 10, 2013)
=====
* Fixed an issue where internal dictionaries to objects were not parsed into dictionaries if they did not have the __class__ attribute.

v1.5.2 (January 10, 2013)
=====
* Fixed an issue where NSNull would not be properly encoded as NSNull in Dictionaries, Arrays, or nested objects.
* Fixed an issue where NSNull would be decoded to nil and set in a dictionary, causing it to crash.l

v1.5.1 (January 9, 2013)
=====
* Deprecated CMUser userId.
  * Use CMUser email from now on. All methods have been renamed to suppor this - old methods are deprecated. Online documentation has been updated.
  * This change makes the iOS Library more consistent with other platforms.

v1.5.0 (January 9, 2013)
=====
* Added Username field to CMUser
* CMUser can be created with either an email or a username.
* Can now change a user's email, username, and password.

v1.4.6 (January 8, 2013)
=====
* Fixed a bug in which the *userId* field of CMUser was being sent up to CloudMine. This was an oversight, and should not be happening - if you relied on this field (which is generally the user's email), you can still access it, but it will no longer be updated automatically. Rather, you should use a custom field instead of userId.

v1.4.5 (December 21, 2012)
======
* Added Push Notification Support!
  * Added call to register device push notification token with CloudMine.
  * Added call to unregister device from push notifications with CloudMine.
  * Added CMAppDelegateBase which can be used to handle push notification registration for you.

v1.4 (December 18, 2012)
======
* Added runSocialGraphQueryOnNetwork: method to CMWebService for running queries on the services. The user needs to be logged in to the service first.
* Added RunQueryGETRequestOnNetwork: as a convenience method for running GET requests.


v1.3 (December 11, 2012)
=====
* Added Social Login. Login via social networks that are supported through CloudMine and Singly.
  * https://cloudmine.io/docs/social
* Allow developers to specify scope for the social login.
* Linking of accounts! Logging in a user through a social network while a user is previously logged in will link the two accounts.
* Creation of accounts through social login! Logging in through a social network will automatically create the user account if no user is logged in.
* Fix bug that caused CMUser's userId field to not be serialized when cached to the filesystem.
* Fixed NSNull being set in CMUser profile as NSNULL, and not being set as nil. Changed to set as nil.

v1.2.2 (November 29, 2012)
=====
* Fix bug that caused CMFile's on-device caching to never work.
* Add method to `CMWebService` to run Java or JavaScript snippets directly without running a store operation and wrapping it.
* Fixed a bug when a custom CMUser has properties named differently than how they are stored on the server.


v1.2.1 (October 8, 2012)
======
* Recompile YAJL.framework to support iPhone 5 (armv7s).


v1.2 (October 4, 2012)
=======
* Rename `appSecret` to `apiKey` in `CMAPICredentials` so it's consistent with the dashboard phrasing.
* Add PNG to mime types registered in `CMMimeType`.
* Make `CMMimeType` case-insensitive.
* Stop using deprecated `CMFile` constructor in `CMStore`.
* Add convenience method to `CMAPICredentials` to set the App ID and API Key at the same time.
* Rebuild to support iPhone 5's armv7s architecture.

v1.1 (September 14, 2012)
======
* Track modifications made to objects and only send dirty objects back to server.

v0.2
======
* Remove erroneous user-related constructors from CMObject. All user-related things are on CMStore.
* Fix bug that would fail to remove private `__type__` fields from serialized NSDictonary objects.

v0.1 (March 5, 2012)
======
* Initial release
