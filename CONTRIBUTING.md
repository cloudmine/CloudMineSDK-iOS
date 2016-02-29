# Contributing to cloudmine-ios

Thank you for your desire to make the CloudMine iOS SDK better.  The Engineering Team at CloudMine
is looking forward to working with you!

## Support


## Reporting Bugs in CloudMine iOS SDK

The [public GitHub issue tracker](https://github.com/cloudmine/cloudmine-ios/issues) is
the preferred channel for bug reports, features requests and submitting pull requests.


## Contributing

Please adhere to the following process when contributing to CloudMine iOS SDK

1. [Fork](https://help.github.com/fork-a-repo/) the project, clone your fork,
   and configure the remotes:

   ```bash
   # Clone your fork of the repo into the current directory
   git clone git@github.com:<your github username>/cloudmine-ios.git
   # Navigate to the newly cloned directory
   cd cloudmine-ios
   # Assign the original repo to a remote called "cloudmine"
   git remote add cloudmine https://github.com/cloudmine/cloudmine-ios.git
   ```

2. If you cloned a while ago, get the latest changes from `cloudmine`

   ```bash
   git checkout master
   git fetch cloudmine master
   git merge cloudmine/master
   ```

3. Create a new topic branch (off the main project development branch) to
   contain your feature, change, or fix:

   ```bash
   git checkout -b <topic-branch-name>
   ```

4. Commit your changes in logical chunks.

5. Locally merge (or rebase) the upstream development branch into your topic branch:

   ```bash
   git fetch cloudmine master
   git merge cloudmine/master
   ```

6. Push your topic branch up to your fork:

   ```bash
   git push origin <topic-branch-name>
   ```

7. [Open a Pull Request](https://help.github.com/articles/using-pull-requests/)
    with a clear title and description against the `master` branch.


## Have Fun!

Coding should be fun.  We hope you enjoy both using and contributing to CloudMine iOS SDK.


## License

By contributing your code, you agree to license your contribution under the
current CloudMine iOS SDK license [MIT License](LICENSE).
