// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Ingredient.h instead.

#import <CoreData/CoreData.h>





@interface IngredientID : NSManagedObjectID {}
@end

@interface _Ingredient : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (IngredientID*)objectID;




@property (nonatomic, retain) NSString *name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@end

@interface _Ingredient (CoreDataGeneratedAccessors)

@end

@interface _Ingredient (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




@end
