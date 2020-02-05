//
//  DrinkRecipe.h
//  LiquorCabinet
//
//  Created by Mark Powell on 9/14/11.
//  Copyright (c) 2011 Lavacado Studios, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DrinkCategory, DrinkGarnish, DrinkGlass, DrinkIngredient, RecipeStep;

@interface DrinkRecipe : NSManagedObject {
@private
}
@property (nonatomic, strong) NSNumber * drinkID;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * alcoholic;
@property (nonatomic, strong) NSNumber * favorite;
@property (nonatomic, strong) NSNumber * isSuggested;
@property (nonatomic, strong) NSString * instructions;
@property (nonatomic, strong) NSString * notes;
@property (nonatomic, strong) NSString * information;
@property (nonatomic, strong) DrinkGlass *glass;
@property (nonatomic, strong) NSSet *categories;
@property (nonatomic, strong) NSSet *ingredients;
@property (nonatomic, strong) NSSet *garnishes;
@property (nonatomic, strong) NSSet *steps;
@property (nonatomic, strong) NSSet *similarDrinks;
@property (nonatomic, strong) NSNumber * edited;
@end

@interface DrinkRecipe (CoreDataGeneratedAccessors)

+ (DrinkRecipe *)drinkRecipeWithID:(NSNumber *)drinkID andName:(NSString *)name inContext:(NSManagedObjectContext *)context;
+ (DrinkRecipe *)clone:(DrinkRecipe *)recipe drinkID:(NSNumber *)drinkID andName:(NSString *)name inContext:(NSManagedObjectContext *)context;

- (void)addIngredientsObject:(DrinkIngredient *)value;
- (void)removeIngredientsObject:(DrinkIngredient *)value;
- (void)addIngredients:(NSSet *)values;
- (void)removeIngredients:(NSSet *)values;
- (void)addGarnishesObject:(DrinkGarnish *)value;
- (void)removeGarnishesObject:(DrinkGarnish *)value;
- (void)addGarnishes:(NSSet *)values;
- (void)removeGarnishes:(NSSet *)values;
- (void)addStepsObject:(RecipeStep *)value;
- (void)removeStepsObject:(RecipeStep *)value;
- (void)addSteps:(NSSet *)values;
- (void)removeSteps:(NSSet *)values;
- (void)addCategoriesObject:(DrinkCategory *)value;
- (void)removeCategoriesObject:(DrinkCategory *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;
- (void)addSimilarDrinksObject:(DrinkRecipe *)value;
- (void)addSimilarDrinksObject:(DrinkRecipe *)value;
- (void)addSimilarDrinks:(NSSet *)values;
- (void)removeSimilarDrinks:(NSSet *)values;
- (NSString *)ingredientsListAsString;

@end
