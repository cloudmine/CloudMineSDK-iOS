// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Ingredient.m instead.

#import "_Ingredient.h"

@implementation IngredientID
@end

@implementation _Ingredient

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Ingredient" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Ingredient";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Ingredient" inManagedObjectContext:moc_];
}

- (IngredientID*)objectID {
	return (IngredientID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic name;










@end
