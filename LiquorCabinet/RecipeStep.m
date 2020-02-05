//
//  RecipeStep.m
//  LiquorCabinet
//
//  Created by Mark Powell on 9/22/11.
//  Copyright (c) 2011 Lavacado Studios, LLC. All rights reserved.
//

#import "RecipeStep.h"
#import "DrinkRecipe.h"


@implementation RecipeStep
@dynamic stepIndex;
@dynamic stepTitle;
@dynamic stepAmount;
@dynamic recipe;

+ (RecipeStep *)recipeStepWithIndex:(int)index title:(NSString *)title andAmount:(NSString *)amount inContext:(NSManagedObjectContext *)context {
    RecipeStep *recipeStep = [NSEntityDescription insertNewObjectForEntityForName:@"RecipeStep" inManagedObjectContext:context];
    recipeStep.stepIndex = [NSNumber numberWithInt:index];
    recipeStep.stepTitle = title;
    recipeStep.stepAmount = amount;
    return recipeStep;
}

- (NSComparisonResult)compare:(RecipeStep *)otherObject {
    return [self.stepIndex compare:otherObject.stepIndex];
}

@end
