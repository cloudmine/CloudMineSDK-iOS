# APPLICATION DATA

CloudMine allows you to persist your application's data without writing any of the persistence code.

This reference assumes you have a basic knowledge of how to create and model objects that will be persisted to CloudMine. For an introduction to this topic, see the [Create a Custom Object](#/ios#tutorial) tutorial.

Here is an example of an object we will be referring to throughout this reference. This object represents a car, with properties for the make, model, and year.

```objc
@interface CMCar : CMObject
 
@property (strong, nonatomic) NSString *make;
@property (strong, nonatomic) NSString *model;
@property (nonatomic) NSInteger year;
 
@end
```

```objc
@implementation CMCar
 
@synthesize make;
@synthesize model;
@synthesize year;
 
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:make forKey:@"make"];
    [aCoder encodeObject:model forKey:@"model"];
    [aCoder encodeInteger:year forKey:@"year"];
}
 
- (id)initWithCoder:(NSCoder *)aCoder {
    if ((self = [super initWithCoder:aCoder])) {
        make = [aCoder decodeObjectForKey:@"make"];
        model = [aCoder decodeObjectForKey:@"model"];
        year = [aCoder decodeIntegerForKey:@"year"];
    }
    return self;
}
 
@end
``` 
