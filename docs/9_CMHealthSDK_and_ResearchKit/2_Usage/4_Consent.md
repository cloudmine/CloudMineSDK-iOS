# Consent

The SDK provides specific methods for archiving and fetching participant consent.
In ResearchKit, user consent is collected in any `ORKTask` with special consent and signature
steps included. CMHealth allows you to archive the resulting `ORKTaskResult` object
containing the user's consent. The SDK ensures that a consent step is present in the result hierarchy and that a signature has been collected. It handles uploading the signature image seamlessly.

```Objective-C
#import <CMHealth/CMHealth.h>

// `consentResults` is an instance of `ORKTaskResult`
[[CMHUser currentUser] uploadUserConsent:consentResults forStudyWithDescriptor:@"MyClinicalStudy" andCompletion:^(NSError * consentError) {
    if (nil != error) {
        // handle error
        return;
    }

    // consent uploaded successfully
}];
```

To ensure your participants have a valid consent on file before allowing them to participate in study activities, you can fetch any user's consent object.

```Objective-C
#import <CMHealth/CMHealth.h>

[[CMHUser currentUser] fetchUserConsentForStudyWithDescriptor:@"MyClinicalStudy" andCompletion:^(CMHConsent *consent, NSError *error) {
    if (nil != error) {
        // Something went wrong
        return;
    }

    if (nil == consent) {
        // No consent on file
        return;
    }

    // User has valid consent on file
}];

```
