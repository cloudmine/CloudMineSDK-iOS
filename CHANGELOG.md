HEAD
=====


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
