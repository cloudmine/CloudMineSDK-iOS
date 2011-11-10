// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Recipe.h instead.

#import <CoreData/CoreData.h>


@class Ingredient;
@class NutritionStat;



@interface RecipeID : NSManagedObjectID {}
@end

@interface _Recipe : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (RecipeID*)objectID;




@property (nonatomic, retain) NSString *name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSSet* ingredients;

- (NSMutableSet*)ingredientsSet;




@property (nonatomic, retain) NSSet* nutrition;

- (NSMutableSet*)nutritionSet;




@end

@interface _Recipe (CoreDataGeneratedAccessors)

- (void)addIngredients:(NSSet*)value_;
- (void)removeIngredients:(NSSet*)value_;
- (void)addIngredientsObject:(Ingredient*)value_;
- (void)removeIngredientsObject:(Ingredient*)value_;

- (void)addNutrition:(NSSet*)value_;
- (void)removeNutrition:(NSSet*)value_;
- (void)addNutritionObject:(NutritionStat*)value_;
- (void)removeNutritionObject:(NutritionStat*)value_;

@end

@interface _Recipe (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (NSMutableSet*)primitiveIngredients;
- (void)setPrimitiveIngredients:(NSMutableSet*)value;



- (NSMutableSet*)primitiveNutrition;
- (void)setPrimitiveNutrition:(NSMutableSet*)value;


@end
