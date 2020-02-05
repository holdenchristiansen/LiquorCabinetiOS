//
//  ParseSynchronizer.h
//  LiquorCabinet
//
//  Created by Mark Powell on 3/26/13.
//  Copyright (c) 2013 Lavacado Studios, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Cabinet;
@class DrinkIngredient;
@class DrinkRecipe;

@interface ParseSynchronizer : NSObject

+ (ParseSynchronizer *)sharedInstance;

- (void)addFavorite:(DrinkRecipe *)drinkRecipe;
- (void)removeFavorite:(DrinkRecipe *)drinkRecipe;
- (void)addIngredient:(DrinkIngredient *)ingredient toCabinet:(Cabinet *)cabinet;
- (void)removeIngredient:(DrinkIngredient *)ingredient fromCabinet:(Cabinet *)cabinet;
- (void)addDrinkIngredient:(DrinkIngredient *)ingredient;
- (void)deleteDrinkIngredient:(DrinkIngredient *)ingredient;
- (void)addDrinkRecipe:(DrinkRecipe *)drinkRecipe;
- (void)customizeDrinkRecipe:(DrinkRecipe *)drinkRecipe;
- (void)deleteDrinkRecipe:(DrinkRecipe *)drinkRecipe;
- (void)updateShoppingList;
- (void)synchronize;

@end
