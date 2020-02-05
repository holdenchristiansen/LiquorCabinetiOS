//
//  RecipeStep.h
//  LiquorCabinet
//
//  Created by Mark Powell on 9/22/11.
//  Copyright (c) 2011 Lavacado Studios, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DrinkRecipe;

@interface RecipeStep : NSManagedObject {
@private
}
@property (nonatomic, strong) NSNumber * stepIndex;
@property (nonatomic, strong) NSString * stepTitle;
@property (nonatomic, strong) NSString * stepAmount;
@property (nonatomic, strong) DrinkRecipe *recipe;

+ (RecipeStep *)recipeStepWithIndex:(int)index title:(NSString *)title andAmount:(NSString *)amount inContext:(NSManagedObjectContext *)context;

- (NSComparisonResult)compare:(id)other;

@end
