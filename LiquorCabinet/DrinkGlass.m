//
//  DrinkGlass.m
//  LiquorCabinet
//
//  Created by Mark Powell on 9/14/11.
//  Copyright (c) 2011 Lavacado Studios, LLC. All rights reserved.
//

#import "DrinkGlass.h"
#import "DrinkRecipe.h"


@implementation DrinkGlass
@dynamic name;
@dynamic drinks;

+ (DrinkGlass *)drinkGlassWithName:(NSString *)name inContext:(NSManagedObjectContext *)context {
    DrinkGlass *drinkGlass = [NSEntityDescription insertNewObjectForEntityForName:@"DrinkGlass" inManagedObjectContext:context];
    drinkGlass.name = name;
    return drinkGlass;
}

@end
