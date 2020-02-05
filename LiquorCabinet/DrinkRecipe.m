//
//  DrinkRecipe.m
//  LiquorCabinet
//
//  Created by Mark Powell on 9/14/11.
//  Copyright (c) 2011 Lavacado Studios, LLC. All rights reserved.
//

#import "DrinkRecipe.h"
#import "DrinkCategory.h"
#import "DrinkGarnish.h"
#import "DrinkGlass.h"
#import "DrinkIngredient.h"
#import "RecipeStep.h"

@implementation DrinkRecipe
@dynamic drinkID;
@dynamic name;
@dynamic alcoholic;
@dynamic favorite;
@dynamic isSuggested;
@dynamic steps;
@dynamic instructions;
@dynamic notes;
@dynamic information;
@dynamic categories;
@dynamic glass;
@dynamic ingredients;
@dynamic garnishes;
@dynamic similarDrinks;
@dynamic edited;

+ (DrinkRecipe *)drinkRecipeWithID:(NSNumber *)drinkID andName:(NSString *)name inContext:(NSManagedObjectContext *)context {
    DrinkRecipe *drinkRecipe = [NSEntityDescription insertNewObjectForEntityForName:@"DrinkRecipe" inManagedObjectContext:context];
    drinkRecipe.drinkID = drinkID;
    drinkRecipe.name = name;
    return drinkRecipe;
}

+ (DrinkRecipe *)clone:(DrinkRecipe *)recipe drinkID:(NSNumber *)drinkID andName:(NSString *)name inContext:(NSManagedObjectContext *)context {
    DrinkRecipe *newDrink = [DrinkRecipe drinkRecipeWithID:drinkID andName:name inContext:context];
    
    newDrink.alcoholic = recipe.alcoholic;
    newDrink.favorite = recipe.favorite;
    newDrink.isSuggested = recipe.isSuggested;
    newDrink.instructions = recipe.instructions;
    newDrink.notes = recipe.notes;
    newDrink.information = recipe.information;
    newDrink.edited = [NSNumber numberWithBool:YES];
    newDrink.categories = recipe.categories;
    newDrink.glass = recipe.glass;
    newDrink.ingredients = recipe.ingredients;
    newDrink.garnishes = recipe.garnishes;
    newDrink.steps = recipe.steps;
    newDrink.similarDrinks = recipe.similarDrinks;
    newDrink.edited = recipe.edited;
    
    return newDrink;
}

- (NSString *)ingredientsListAsString {
    NSMutableString *ingredientsString = [NSMutableString string];
    BOOL first = YES;
    
    NSMutableArray *liquors = [NSMutableArray array];
    NSMutableArray *mixers = [NSMutableArray array];
    NSMutableArray *garnish = [NSMutableArray array];
    
    for (DrinkIngredient *ingredient in self.ingredients) {
        if ([ingredient.type isEqualToString:@"LIQUOR"]) {
            [liquors addObject:ingredient];
        } else if ([ingredient.type isEqualToString:@"MIXER"]) {
            [mixers addObject:ingredient];
        } else if ([ingredient.type isEqualToString:@"GARNISH"]) {
            [garnish addObject:ingredient];
        }
    }
    
    [liquors sortUsingSelector:@selector(compare:)];
    [mixers sortUsingSelector:@selector(compare:)];
    [garnish sortUsingSelector:@selector(compare:)];
    
    for (DrinkIngredient *ingredient in liquors) {
        if (first) {
            first = NO;
            [ingredientsString appendString:ingredient.name];
        } else {
            [ingredientsString appendString:[NSString stringWithFormat:@", %@", ingredient.name]];
        }
    }
    
    for (DrinkIngredient *ingredient in mixers) {
        if (first) {
            first = NO;
            [ingredientsString appendString:ingredient.name];
        } else {
            [ingredientsString appendString:[NSString stringWithFormat:@", %@", ingredient.name]];
        }
    }
    
    for (DrinkIngredient *ingredient in garnish) {
        if (first) {
            first = NO;
            [ingredientsString appendString:ingredient.name];
        } else {
            [ingredientsString appendString:[NSString stringWithFormat:@", %@", ingredient.name]];
        }
    }
    
    for (DrinkGarnish *garnish in self.garnishes) {
        if (first) {
            first = NO;
            [ingredientsString appendString:garnish.name];
        } else {
            [ingredientsString appendString:[NSString stringWithFormat:@", %@", garnish.name]];
        }
    }
    
    return [NSString stringWithString:ingredientsString];
}

- (NSComparisonResult)compare:(DrinkRecipe *)recipe {
    return [self.name compare:recipe.name];
}

@end
