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
