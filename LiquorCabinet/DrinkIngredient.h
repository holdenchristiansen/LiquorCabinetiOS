//
//  DrinkIngredient.h
//  LiquorCabinet
//
//  Created by Mark Powell on 9/14/11.
//  Copyright (c) 2011 Lavacado Studios, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Cabinet;
@class DrinkRecipe;

@interface DrinkIngredient : NSManagedObject {
@private
}
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * secondaryName;
@property (nonatomic, strong) NSString * optionalAssetName;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSNumber * scratchedOffShoppingCart;
@property (nonatomic, strong) NSNumber * shoppingCart;
@property (nonatomic, strong) NSSet *drinks;
@property (nonatomic, strong) NSSet *cabinets;
@end

@interface DrinkIngredient (CoreDataGeneratedAccessors)

+ (DrinkIngredient *)drinkIngredientWithName:(NSString *)name inContext:(NSManagedObjectContext *)context;
+ (DrinkIngredient *)ingredientByName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)ingredientsInContext:(NSManagedObjectContext *)context containingString:(NSString *)searchString ofType:(NSString *)type;
+ (NSArray *)allBaseIngredientsInContext:(NSManagedObjectContext *)context forType:(NSString *)type;

- (void)addDrinksObject:(DrinkRecipe *)value;
- (void)removeDrinksObject:(DrinkRecipe *)value;
- (void)addDrinks:(NSSet *)values;
- (void)removeDrinks:(NSSet *)values;
- (void)addCabinetsObject:(Cabinet *)value;
- (void)removeCabinetsObject:(Cabinet *)value;
- (void)addCabinets:(NSSet *)values;
- (void)removeCabinets:(NSSet *)values;
- (NSComparisonResult)compare:(DrinkIngredient *)other;
- (NSArray *)listOfDerivedIngredients:(NSManagedObjectContext *)context;
- (BOOL)hasADerivedIngredientInCabinet:(NSManagedObjectContext *)context;
- (BOOL)hasADerivedIngredientInShoppingCart:(NSManagedObjectContext *)context;
- (NSArray *)drinkAliasesInContext:(NSManagedObjectContext *)context;
- (BOOL)isKindOfIngredient:(DrinkIngredient *)ingredient;
- (BOOL)hasChildIngredientsInContext:(NSManagedObjectContext *)context;

@end
