// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to NutritionStat.m instead.

#import "_NutritionStat.h"

@implementation NutritionStatID
@end

@implementation _NutritionStat

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"NutritionStat" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"NutritionStat";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"NutritionStat" inManagedObjectContext:moc_];
}

- (NutritionStatID*)objectID {
	return (NutritionStatID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"amountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"amount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic amount;



- (short)amountValue {
	NSNumber *result = [self amount];
	return [result shortValue];
}

- (void)setAmountValue:(short)value_ {
	[self setAmount:[NSNumber numberWithShort:value_]];
}

- (short)primitiveAmountValue {
	NSNumber *result = [self primitiveAmount];
	return [result shortValue];
}

- (void)setPrimitiveAmountValue:(short)value_ {
	[self setPrimitiveAmount:[NSNumber numberWithShort:value_]];
}





@dynamic name;






@dynamic unit;










@end
