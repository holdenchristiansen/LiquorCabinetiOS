//
//  DrinkCategory.m
//  LiquorCabinet
//
//  Created by Mark Powell on 9/14/11.
//  Copyright (c) 2011 Lavacado Studios, LLC. All rights reserved.
//

#import "DrinkCategory.h"
#import "DrinkRecipe.h"


@implementation DrinkCategory
@dynamic name;
@dynamic drinks;

+ (DrinkCategory *)drinkCategoryWithName:(NSString *)name inContext:(NSManagedObjectContext *)context {
    DrinkCategory *drinkCategory = [NSEntityDescription insertNewObjectForEntityForName:@"DrinkCategory" inManagedObjectContext:context];
    drinkCategory.name = name;
    return drinkCategory;
}

@end
