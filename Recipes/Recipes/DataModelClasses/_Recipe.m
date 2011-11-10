// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Recipe.m instead.

#import "_Recipe.h"

@implementation RecipeID
@end

@implementation _Recipe

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Recipe" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Recipe";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Recipe" inManagedObjectContext:moc_];
}

- (RecipeID*)objectID {
	return (RecipeID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic name;






@dynamic ingredients;

	
- (NSMutableSet*)ingredientsSet {
	[self willAccessValueForKey:@"ingredients"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"ingredients"];
	[self didAccessValueForKey:@"ingredients"];
	return result;
}
	

@dynamic nutrition;

	
- (NSMutableSet*)nutritionSet {
	[self willAccessValueForKey:@"nutrition"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"nutrition"];
	[self didAccessValueForKey:@"nutrition"];
	return result;
}
	





@end
