//
//  DrinkIngredient.m
//  LiquorCabinet
//
//  Created by Mark Powell on 9/14/11.
//  Copyright (c) 2011 Lavacado Studios, LLC. All rights reserved.
//

#import "DrinkIngredient.h"
#import "DrinkRecipe.h"


@implementation DrinkIngredient
@dynamic name;
@dynamic secondaryName;
@dynamic optionalAssetName;
@dynamic type;
@dynamic scratchedOffShoppingCart;
@dynamic shoppingCart;
@dynamic drinks;
@dynamic cabinets;

+ (DrinkIngredient *)drinkIngredientWithName:(NSString *)name inContext:(NSManagedObjectContext *)context {
    DrinkIngredient *drinkIngredient = [NSEntityDescription insertNewObjectForEntityForName:@"DrinkIngredient" inManagedObjectContext:context];
    drinkIngredient.name = name;
    return drinkIngredient;
}

+ (DrinkIngredient *)ingredientByName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DrinkIngredient" inManagedObjectContext:context];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    [request setPredicate:predicate];
    NSArray *results = [context executeFetchRequest:request error:nil];
    if ([results count] != 0) {
        return [results objectAtIndex:0];
    } 
    
    return nil;
}

+ (NSArray *)ingredientsInContext:(NSManagedObjectContext *)context containingString:(NSString *)searchString ofType:(NSString *)type {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DrinkIngredient" inManagedObjectContext:context];
    [request setEntity:entity];
    if (type) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@ AND type = %@", searchString, type];
        [request setPredicate:predicate];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchString];
        [request setPredicate:predicate];
    }
    return [context executeFetchRequest:request error:nil];
}

+ (NSArray *)allBaseIngredientsInContext:(NSManagedObjectContext *)context forType:(NSString *)type {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DrinkIngredient" inManagedObjectContext:context];
    [request setEntity:entity];
    if (type) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"secondaryName = nil AND type = %@", type];
        [request setPredicate:predicate];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"secondaryName = nil", type];
        [request setPredicate:predicate];
    }
    return [context executeFetchRequest:request error:nil];
}

- (NSComparisonResult)compare:(DrinkIngredient *)otherObject {
    return [self.name compare:otherObject.name];
}

- (NSArray *)listOfDerivedIngredients:(NSManagedObjectContext *)context {
    NSMutableArray *drinks = [[NSMutableArray alloc] init];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DrinkIngredient" inManagedObjectContext:context];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"secondaryName = %@", self.name];
    [request setPredicate:predicate];
    NSArray *results = [context executeFetchRequest:request error:nil];
    for (int i = 0; i < [results count]; i++) {
        DrinkIngredient *ingredient = [results objectAtIndex:i];
        if (![drinks containsObject:ingredient]) {
            [drinks addObject:ingredient];
            [drinks addObjectsFromArray:[ingredient listOfDerivedIngredients:context]];
        }
    }
    
    if ([drinks count] == 0 && self.secondaryName == nil) {
        NSLog(@"%@ - whoops", self.name);
    }
    
    return [NSArray arrayWithArray:drinks];
}

- (BOOL)hasADerivedIngredientInCabinet:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DrinkIngredient" inManagedObjectContext:context];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(secondaryName = %@) AND (cabinets.@count != 0)", self.name];
    [request setPredicate:predicate];
    NSArray *results = [context executeFetchRequest:request error:nil];
    return [results count] != 0;
}

- (BOOL)hasADerivedIngredientInShoppingCart:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DrinkIngredient" inManagedObjectContext:context];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(secondaryName = %@) AND (shoppingCart == %@)", self.name, [NSNumber numberWithBool:YES]];
    [request setPredicate:predicate];
    NSArray *results = [context executeFetchRequest:request error:nil];
    return [results count] != 0;
}

- (NSArray *)drinkAliasesInContext:(NSManagedObjectContext *)context {
    NSMutableArray *aliases = [NSMutableArray array];
    
    [aliases addObject:self.name];
    
    if (self.secondaryName != nil) {
        NSManagedObjectContext *context = [self managedObjectContext];
        
        DrinkIngredient *ingredient = [DrinkIngredient ingredientByName:self.secondaryName inManagedObjectContext:context];

        [aliases addObjectsFromArray:[ingredient drinkAliasesInContext:context]];
    }
    
    return [NSArray arrayWithArray:aliases];
}

- (BOOL)isKindOfIngredient:(DrinkIngredient *)ingredient {
    if ([self.name isEqualToString:ingredient.name]) {
        return YES;
    }
    
    if (self.secondaryName == nil) {
        return NO;
    }
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    DrinkIngredient *subIngredient = [DrinkIngredient ingredientByName:self.secondaryName inManagedObjectContext:context];
    return [subIngredient isKindOfIngredient:ingredient];
}

- (BOOL)hasChildIngredientsInContext:(NSManagedObjectContext *)context {
    if (self.secondaryName != nil) {
        return NO;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DrinkIngredient" inManagedObjectContext:context];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"secondaryName = %@", self.name];
    [request setPredicate:predicate];
    NSArray *results = [context executeFetchRequest:request error:nil];
    if ([results count] == 0) {
        return NO;
    }
    
    return YES;
}

@end
