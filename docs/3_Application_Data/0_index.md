# Application Data

CloudMine allows you to persist your application's data without writing any of the persistence code.

You can see the full documentation and class references on [CocoaPods](http://cocoadocs.org/docsets/CloudMine/)
or [GitHub](https://github.com/cloudmine/CloudMineSDK-iOS/tree/master/docs).

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

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.make forKey:@"make"];
    [aCoder encodeObject:self.model forKey:@"model"];
    [aCoder encodeInteger:self.year forKey:@"year"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
    if ((self = [super initWithCoder:aCoder])) {
        _make = [aCoder decodeObjectForKey:@"make"];
        _model = [aCoder decodeObjectForKey:@"model"];
        _year = [aCoder decodeIntegerForKey:@"year"];
    }
    return self;
}

@end
```

## Working in Swift

Subclassing `CMObject` in Swift is also straightforward but the static type system means things change slightly from Objective-C. As demonstrated below, you'll want to mark your properties as `dynamic` and provide default values. Any numeric properties should use Foundation's `NSNumber` class. Be sure to encode and decode them as primitive types, such as integer or float. When decoding object properties, such as `String`, you'll have to coerce them into their correct type using `as?` (or, less safely, `as!`).

```swift
import CloudMine

class CMCar: CMObject {
    dynamic var make: String? = nil
    dynamic var model: String? = nil
    dynamic var year: NSNumber = 0

    override init() {
        super.init()
    }

    override init(objectId theObjectId: String) {
        super.init(objectId: theObjectId)
    }

    required init!(coder: NSCoder) {
        super.init(coder: coder)
        make  = coder.decodeObjectForKey("make") as? String
        model = coder.decodeObjectForKey("model") as? String
        year = coder.decodeIntegerForKey("year")
    }

    override func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encodeObject(make, forKey: "make")
        aCoder.encodeObject(model, forKey: "model")
        aCoder.encodeInteger(year.integerValue, forKey: "year")
    }
}
```

After implementing your model objects in the manner described above, the SDK should work as expected in a Swift project.
