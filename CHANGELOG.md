v1.2
=======
* Rename `appSecret` to `apiKey` in `CMAPICredentials` so it's consistent with the dashboard phrasing.
* Add PNG to mime types registered in `CMMimeType`.
* Make `CMMimeType` case-insensitive.
* Stop using deprecated `CMFile` constructor in `CMStore`.
* Add convenience method to `CMAPICredentials` to set the App ID and API Key at the same time.

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
