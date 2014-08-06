PRETTY="gem list xcpretty -i"
NOTIFICATION_GROUP='xcodebuild'
NOTIFICATION_TITLE='iOS Lib Tests'
NOTIFICATION_MESSAGE='Tests Finished'
NOTIFICATION_ACTIVATE='com.apple.Terminal'
TERMINAL_NOTIFIER_INSTALLED=$(shell terminal-notifier | grep 'Usage')
NOTIFICATION_ERROR_MSG='You do not have terminal-notifier installed! Run `[sudo] gem install terminal-notifier` to get notifications from this script!'

# Default
build:	clean
	xcodebuild -workspace cm-ios.xcworkspace \
	-scheme libcloudmine \
	-destination 'platform=iOS Simulator,name=iPhone Retina (4-inch)' \
	2>&1 \
	build | xcpretty -c


test:	clean build
	(xcodebuild -workspace cm-ios.xcworkspace \
	-scheme libcloudmine \
	-destination 'platform=iOS Simulator,name=iPhone Retina (4-inch)' \
	2>&1 \
	test || exit 1) |  xcpretty -c
ifeq ($(strip $(TERMINAL_NOTIFIER_INSTALLED)),)
	@echo NOTIFICATION_ERROR_MSG
else
	terminal-notifier -group $(NOTIFICATION_GROUP) -title $(NOTIFICATION_TITLE)  -message $(NOTIFICATION_MESSAGE) -activate $(NOTIFICATION_ACTIVATE)
endif

clean:
	xcodebuild -workspace cm-ios.xcworkspace \
	-scheme libcloudmine \
	clean | xcpretty -c

cov:
	./ios/XcodeCoverage/cleancov
	$(MAKE) test
	./ios/XcodeCoverage/getcov

