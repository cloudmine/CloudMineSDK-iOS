before attempting a release you must set up a gpg key, which you can then use to sign the release.  useful tools for generating and maintaining your key can be found here

* [GPGKeychain for OSX](https://gpgtools.org/)
* [keybase.io](https://keybase.io/)

once you have your key, you can set it as the signing key for future releases:

```
git config --global user.signingkey YOURKEYFINGERPRINT
```

now you can continue with the release process

1. get the current version
```
VERSION=`make get-version`; echo $VERSION
```
2. tag the release
```
git tag -s $VERSION -m "version $VERSION"   # or make tag-version
```
3. verify the tag
```
git tag --verify $VERSION                   # or make verify-tag
```
4. push the tag to github
```
git push origin $VERSION
```
5. lint the pod
```
pod spec lint
```
6. push the pod to CocoaPods (allowing warnings if things aren't completely tidy.  but let's hope that's not the case...)
```
pod --allow-warnings trunk push CMHealth.podspec
```
7. grant the entire team access
```
pod trunk add-owner CMHealth tech@cloudmine.me
```
8. bump the patch version for the next release
```
make bump-patch
```

or, for the really advantageous:

```
make release
```
