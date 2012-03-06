The following are issues known to us already and are planned to be resolved in the next release:

* Using a server-side code snippet and sending back JSON objects without a `__class__` key currently does not work properly if using `CMStore`.
* The `initWithCoder:` and `encodeWithCoder:` methods are very boilerplatey and can easily be automated with a bit of runtime introspection.
* There is no way to build a search query without learning the syntax yourself. There should be an object-oriented way to build these up.
* Object graphs with complex relationships are not currently handled.
