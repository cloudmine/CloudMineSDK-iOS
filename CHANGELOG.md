HEAD
=====


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
  * https://cloudmine.me/docs/social
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
