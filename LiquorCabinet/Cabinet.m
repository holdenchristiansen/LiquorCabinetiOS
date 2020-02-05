//
//  Cabinet.m
//  LiquorCabinet
//
//  Created by Mark Powell on 9/17/11.
//  Copyright (c) 2011 Lavacado Studios, LLC. All rights reserved.
//

#import "Cabinet.h"
#import "DrinkIngredient.h"


@implementation Cabinet
@dynamic version;
@dynamic name;
@dynamic dirty;
@dynamic ingredients;

+ (Cabinet *)cabinetWithName:(NSString *)name inContext:(NSManagedObjectContext *)context {
    Cabinet *cabinet = [NSEntityDescription insertNewObjectForEntityForName:@"Cabinet" inManagedObjectContext:context];
    cabinet.name = name;
    return cabinet;
}

- (BOOL)cabinetContainsIngredient:(DrinkIngredient *)ingredient {
    for (DrinkIngredient *cabinetIngredient in self.ingredients) {
        
        if ([cabinetIngredient isKindOfIngredient:ingredient]) {
            return YES;
        }
    }
    
    return NO;
}

- (NSArray *)ownedIngredientsWithSearchTerm:(NSString *)string {
    NSMutableArray *ownedIngredients = [NSMutableArray array];
    
    for (DrinkIngredient *ingredient in self.ingredients) {
        if ([[ingredient.name lowercaseString] rangeOfString:[string lowercaseString]].location != NSNotFound) {
            [ownedIngredients addObject:ingredient];
        }
    }
    
    return [NSArray arrayWithArray:ownedIngredients];
}

@end
