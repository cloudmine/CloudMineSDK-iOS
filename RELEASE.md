before attempting a release you must set up a gpg key, which you can then use to sign the release.  useful tools for generating and maintaining your key can be found here

* [GPGKeychain for OSX](https://gpgtools.org/)
* [keybase.io](https://keybase.io/)

once you have your key, you can set it as the signing key for future releases:

```shell
git config --global user.signingkey YOURKEYFINGERPRINT
```

now you can continue with the release process.  from `master`

1. tag the release
```shell
make tag-version
```

2. verify the tag
```shell
make verify-tag
```

3. push the tag to github
```shell
make push-tag-to-origin
```

4. lint the pod
```shell
pod spec lint
```

5. once the pod lints cleanly, push the pod to CocoaPods (allowing warnings if things aren't completely tidy.  but let's hope that's not the case...)
```
make cocoapods-push
```

6. bump the patch version for the next release
```shell
make stage-next-release
```

see also the `release` target in the `Makefile`
