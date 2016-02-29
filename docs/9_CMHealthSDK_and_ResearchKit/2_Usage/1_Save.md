# Save

```Objective-C
#import <CMHealth/CMHealth.h>

// surveyResult is an instance of ORKTaskResult, or any ORKResult subclass
[surveyResult cmh_saveToStudyWithDescriptor:@"MyClinicalStudy" withCompletion:^(NSString *uploadStatus, NSError *error) {
        if (nil == uploadStatus) {
            // handle error
            return;
        }
        if ([uploadStatus isEqualToString:@"created"]) {
            // A new research kit result was saved
        } else if ([uploadStatus isEqualToString:@"updated"]) {
            // An existing research kit result was updated
        }
    }];
```
