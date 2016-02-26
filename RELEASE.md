before attempting a release you must set up a gpg key, which you can then use to sign the release.  useful tools for generating and maintaining your key can be found here

* [GPGKeychain for OSX](https://gpgtools.org/)
* [keybase.io](https://keybase.io/)

once you have your key, you can set it as the signing key for future releases:

```
git config --global user.signingkey YOURKEYFINGERPRINT
```

now you can continue with the release process

1. bump version in `CloudMine.podspec`
```
vi CloudMine.podspec
```
2. tag the release
```
git tag -s 1.7.8 -m "version 1.7.8"
```
2. verify the tag
```
git tag --verify 1.7.8
```
3. push the tag to github
```
git push origin 1.7.8
```
4. lint the pod
```
pod spec lint
```
5. push the pod to CocoaPods
```
6. pod --allow-warnings trunk push CloudMine.podspec
```
7. grant the entire team access
```
pod trunk add-owner CloudMine tech@cloudmine.me
```
