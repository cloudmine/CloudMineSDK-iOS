// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to NutritionStat.h instead.

#import <CoreData/CoreData.h>







@interface NutritionStatID : NSManagedObjectID {}
@end

@interface _NutritionStat : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (NutritionStatID*)objectID;




@property (nonatomic, retain) NSNumber *amount;


@property short amountValue;
- (short)amountValue;
- (void)setAmountValue:(short)value_;

//- (BOOL)validateAmount:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *unit;


//- (BOOL)validateUnit:(id*)value_ error:(NSError**)error_;





@end

@interface _NutritionStat (CoreDataGeneratedAccessors)

@end

@interface _NutritionStat (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveAmount;
- (void)setPrimitiveAmount:(NSNumber*)value;

- (short)primitiveAmountValue;
- (void)setPrimitiveAmountValue:(short)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveUnit;
- (void)setPrimitiveUnit:(NSString*)value;




@end
