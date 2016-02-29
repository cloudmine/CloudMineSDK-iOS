# Fetch

```Objective-C
#import <CMHealth/CMHealth.h>

[ORKTaskResult cmh_fetchUserResultsForStudyWithDescriptor:@"MyClinicalStudy" withCompletion:^(NSArray *results, NSError *error) {
        if (nil == results) {
            // handle error
            return;
        }

        for (ORKTaskResult *result in results) {
            // use your result
        }
    }];
```
