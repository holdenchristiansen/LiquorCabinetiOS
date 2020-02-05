//
//  DrinkGarnish.m
//  LiquorCabinet
//
//  Created by Mark Powell on 10/26/11.
//  Copyright (c) 2011 Lavacado Studios, LLC. All rights reserved.
//

#import "DrinkGarnish.h"
#import "DrinkRecipe.h"


@implementation DrinkGarnish

@dynamic name;
@dynamic drinks;

+ (DrinkGarnish *)drinkGarnishWithName:(NSString *)name inContext:(NSManagedObjectContext *)context {
    DrinkGarnish *drinkGarnish = [NSEntityDescription insertNewObjectForEntityForName:@"DrinkGarnish" inManagedObjectContext:context];
    drinkGarnish.name = name;
    return drinkGarnish;
}

@end
