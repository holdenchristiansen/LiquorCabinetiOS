//
//  ParseCoreDataConverter.m
//  LiquorCabinet
//
//  Created by Mark Powell on 4/18/13.
//  Copyright (c) 2013 Lavacado Studios, LLC. All rights reserved.
//

#import "ParseCoreDataConverter.h"

#import "LiquorCabinetAppDelegate.h"
#import "DrinkRecipe.h"
#import "DrinkIngredient.h"
#import "DrinkCategory.h"
#import "DrinkGlass.h"
#import "RecipeStep.h"
#import "DrinkGarnish.h"

#define NULL_TO_NIL(obj) ({ __typeof__ (obj) __obj = (obj); __obj == [NSNull null] ? nil : obj; })

@implementation ParseCoreDataConverter

+ (ParseCoreDataConverter *)sharedInstance
{
    static ParseCoreDataConverter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ParseCoreDataConverter alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (NSManagedObject *)convertParseRecipe:(PFObject *)drinkData {
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSString *drinkDataName = NULL_TO_NIL([drinkData objectForKey:@"DrinkName"]);
    
    NSLog(@"Updating/Creating %@", drinkDataName);
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DrinkRecipe" inManagedObjectContext:delegate.managedObjectContext];
    [request setEntity:entity];
    NSNumber *drinkID = [NSNumber numberWithInt:[[drinkData objectForKey:@"iD"] intValue]];
    NSPredicate *idPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"drinkID = '%@'", drinkID]];
    [request setPredicate:idPredicate];
    NSArray *results = [delegate.managedObjectContext executeFetchRequest:request error:nil];
    
    DrinkRecipe *drink = nil;
    if ([results count] == 0) {
        NSLog(@"New drink");
        drink = [DrinkRecipe drinkRecipeWithID:drinkID andName:drinkDataName inContext:delegate.managedObjectContext];
    } else {
        NSLog(@"Updated drink");
        drink = [results objectAtIndex:0];
        if (![drink.name isEqualToString:drinkDataName]) {
            NSLog(@"%@ -> %@", drink.name, drinkDataName);
        }
        drink.name = drinkDataName;
    }
    
    //set drink categories
    NSString *categoryListString = NULL_TO_NIL([drinkData objectForKey:@"DrinkType"]);
    NSArray *categoryNames = [categoryListString componentsSeparatedByString:@"|"];
    [drink removeCategories:drink.categories];
    for (NSString *categoryName in categoryNames) {
        NSFetchRequest *categoryRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *categoryEntity = [NSEntityDescription entityForName:@"DrinkCategory" inManagedObjectContext:delegate.managedObjectContext];
        [categoryRequest setEntity:categoryEntity];
        NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"name = \"%@\"", categoryName]];
        [categoryRequest setPredicate:categoryPredicate];
        NSArray *categoryResults = [delegate.managedObjectContext executeFetchRequest:categoryRequest error:nil];
        
        DrinkCategory *category = nil;
        
        if ([categoryResults count] == 0) {
            category = [DrinkCategory drinkCategoryWithName:categoryName inContext:delegate.managedObjectContext];
        } else {
            category = [categoryResults objectAtIndex:0];
        }
        
        [drink addCategoriesObject:category];
        [category addDrinksObject:drink];
    }
    
    //Add the glass type
    NSFetchRequest *glassRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *glassEntity = [NSEntityDescription entityForName:@"DrinkGlass" inManagedObjectContext:delegate.managedObjectContext];
    [glassRequest setEntity:glassEntity];
    NSString *glassName = NULL_TO_NIL([drinkData objectForKey:@"GlassType"]);
    NSPredicate *glassPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"name = '%@'", glassName]];
    [glassRequest setPredicate:glassPredicate];
    NSArray *glassResults = [delegate.managedObjectContext executeFetchRequest:glassRequest error:nil];
    
    DrinkGlass *glass = nil;
    
    if ([glassResults count] == 0) {
        glass = [DrinkGlass drinkGlassWithName:glassName inContext:delegate.managedObjectContext];
    } else {
        glass = [glassResults objectAtIndex:0];
    }
    
    drink.glass = glass;
    [glass addDrinksObject:drink];
    
    //set ingredientDescriptions
    NSString *instructionsString = NULL_TO_NIL([drinkData objectForKey:@"Instructions"]);
    NSArray *steps = [instructionsString componentsSeparatedByString:@"|"];
    int count = 0;
    NSMutableArray *stepArray = [NSMutableArray array];
    for (NSString *step in steps) {
        NSArray *stepData = [step componentsSeparatedByString:@"#"];
        RecipeStep *recipeStep = nil;
        if ([stepData count] == 2) {
            recipeStep = [RecipeStep recipeStepWithIndex:count title:[stepData objectAtIndex:0] andAmount:[stepData objectAtIndex:1] inContext:delegate.managedObjectContext];
        } else {
            recipeStep = [RecipeStep recipeStepWithIndex:count title:[stepData objectAtIndex:0] andAmount:nil inContext:delegate.managedObjectContext];
        }
        count++;
        [stepArray addObject:recipeStep];
        recipeStep.recipe = drink;
    }
    
    [drink setSteps:[NSSet setWithArray:stepArray]];
    
    //set instructions
    //NSString *instructions = [[components objectAtIndex:6] stringByReplacingOccurrencesOfString:@"|" withString:@"\n"];
    //drink.instructions = instructions;
    
    //add ingredients
    NSString *ingredientsString = NULL_TO_NIL([drinkData objectForKey:@"Ingredients"]);
    NSArray *ingredientNames = [ingredientsString componentsSeparatedByString:@"|"];
    
    for (NSString *ingredientName in ingredientNames) {
        NSFetchRequest *ingredientRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *ingredientEntity = [NSEntityDescription entityForName:@"DrinkIngredient" inManagedObjectContext:delegate.managedObjectContext];
        [ingredientRequest setEntity:ingredientEntity];
        NSPredicate *ingredientPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"name = \"%@\"", ingredientName]];
        [ingredientRequest setPredicate:ingredientPredicate];
        NSArray *ingredientResults = [delegate.managedObjectContext executeFetchRequest:ingredientRequest error:nil];
        
        DrinkIngredient *ingredient = nil;
        
        if ([ingredientResults count] == 0) {
            ingredient = [DrinkIngredient drinkIngredientWithName:ingredientName inContext:delegate.managedObjectContext];
        } else {
            ingredient = [ingredientResults objectAtIndex:0];
        }
        
        [drink addIngredientsObject:ingredient];
        [ingredient addDrinksObject:drink];
    }
    
    //add garnishes
    NSString *garnishString = NULL_TO_NIL([drinkData objectForKey:@"Garnishes"]);
    NSArray *garnishNames = [garnishString componentsSeparatedByString:@"|"];
    
    for (NSString *garnishName in garnishNames) {
        if (![garnishName isEqualToString:@""]) {
            NSFetchRequest *garnishRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *garnishEntity = [NSEntityDescription entityForName:@"DrinkGarnish" inManagedObjectContext:delegate.managedObjectContext];
            [garnishRequest setEntity:garnishEntity];
            NSPredicate *garnishPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"name = \"%@\"", garnishName]];
            [garnishRequest setPredicate:garnishPredicate];
            NSArray *garnishResults = [delegate.managedObjectContext executeFetchRequest:garnishRequest error:nil];
            
            DrinkGarnish *garnish = nil;
            
            if ([garnishResults count] == 0) {
                garnish = [DrinkGarnish drinkGarnishWithName:garnishName inContext:delegate.managedObjectContext];
            } else {
                garnish = [garnishResults objectAtIndex:0];
            }
            
            [drink addGarnishesObject:garnish];
            [garnish addDrinksObject:drink];
        }
    }
    
    //add similar drink list
    NSString *similarDrinksString = NULL_TO_NIL([drinkData objectForKey:@"SimilarDrinks"]);
    NSArray *similarDrinks = [similarDrinksString componentsSeparatedByString:@"|"];
    for (NSString *drinkName in similarDrinks) {
        if (![drinkName isEqualToString:@""]) {
            NSFetchRequest *drinkRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *drinkEntity = [NSEntityDescription entityForName:@"DrinkRecipe" inManagedObjectContext:delegate.managedObjectContext];
            [drinkRequest setEntity:drinkEntity];
            NSPredicate *drinkPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"name = \"%@\"", drinkName]];
            [drinkRequest setPredicate:drinkPredicate];
            NSArray *drinkResults = [delegate.managedObjectContext executeFetchRequest:drinkRequest error:nil];
            
            if ([drinkResults count] == 1) {
                DrinkRecipe *similarDrink = [drinkResults objectAtIndex:0];
                if (![similarDrink.similarDrinks containsObject:drink]) {
                    [drink addSimilarDrinksObject:similarDrink];
                }
            }
        }
    }
    
    //add information
    NSString *information = NULL_TO_NIL([drinkData objectForKey:@"Factoids"]);
    drink.information = information;
    
    return drink;
}

- (PFObject *)convertManagedObjectRecipe:(DrinkRecipe *)recipe {
    PFObject *pfDrink = [PFObject objectWithClassName:@"CustomDrinkRecipe"];
    
    if (recipe.name) {
        [pfDrink setObject:recipe.name forKey:@"DrinkName"];
    }
    
    if (recipe.categories) {
        NSMutableString *typeString = [[NSMutableString alloc] init];
        NSSet *typeList = recipe.categories;
        for (DrinkCategory *category in typeList) {
            if ([typeString length] == 0) {
                [typeString appendString:category.name];
            } else {
                [typeString appendFormat:@"|%@", category.name];
            }
        }
        
        [pfDrink setObject:typeString forKey:@"DrinkType"];
    }
    
    if (recipe.information) {
        [pfDrink setObject:recipe.information forKey:@"Factoids"];
    }
    
    DrinkGlass *glass = recipe.glass;
    
    if (glass.name) {
        [pfDrink setObject:glass.name forKey:@"GlassType"];
    }
    
    if (recipe.garnishes) {
        NSMutableString *garnishString = [[NSMutableString alloc] init];
        NSSet *garnishList = recipe.garnishes;
        for (DrinkGarnish *garnish in garnishList) {
            if ([garnishString length] == 0) {
                [garnishString appendString:garnish.name];
            } else {
                [garnishString appendFormat:@"|%@", garnish.name];
            }
        }
        
        [pfDrink setObject:garnishString forKey:@"Garnishes"];
    }
    
    if (recipe.ingredients) {
        NSMutableString *ingredientString = [[NSMutableString alloc] init];
        NSSet *ingredientList = recipe.ingredients;
        for (DrinkIngredient *ingredient in ingredientList) {
            if ([ingredientString length] == 0) {
                [ingredientString appendString:ingredient.name];
            } else {
                [ingredientString appendFormat:@"|%@", ingredient.name];
            }
        }
        
        [pfDrink setObject:ingredientString forKey:@"Ingredients"];
    }
    
    if (recipe.steps) {
        NSMutableString *instructionsString = [[NSMutableString alloc] init];
        NSSet *instructionList = recipe.steps;
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"stepIndex" ascending:YES];
        NSArray *sortedInstructionList = [instructionList sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        for (RecipeStep *step in sortedInstructionList) {
            if ([instructionsString length] != 0) {
                [instructionsString appendString:@"|"];
            }
            
            if (step.stepAmount == nil) {
                [instructionsString appendString:step.stepTitle];
            } else {
                [instructionsString appendFormat:@"%@#%@",step.stepTitle, step.stepAmount];
            }
        }
        
        [pfDrink setObject:instructionsString forKey:@"Instructions"];
    }
    
    if (recipe.similarDrinks) {
        NSMutableString *similarString = [[NSMutableString alloc] init];
        NSSet *similarList = recipe.similarDrinks;
        for (DrinkRecipe *similarDrink in similarList) {
            if ([similarString length] == 0) {
                [similarString appendString:similarDrink.name];
            } else {
                [similarString appendFormat:@"|%@", similarDrink.name];
            }
        }
        
        [pfDrink setObject:similarString forKey:@"SimilarDrinks"];
    }
    
    if (recipe.drinkID) {
        [pfDrink setObject:recipe.drinkID forKey:@"iD"];
    }
    
   
    
    return pfDrink;
}

@end
