//
//  DrinkCategory.h
//  LiquorCabinet
//
//  Created by Mark Powell on 9/14/11.
//  Copyright (c) 2011 Lavacado Studios, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DrinkRecipe;

@interface DrinkCategory : NSManagedObject {
@private
}
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSSet *drinks;
@end

@interface DrinkCategory (CoreDataGeneratedAccessors)

+ (DrinkCategory *)drinkCategoryWithName:(NSString *)name inContext:(NSManagedObjectContext *)context;

- (void)addDrinksObject:(DrinkRecipe *)value;
- (void)removeDrinksObject:(DrinkRecipe *)value;
- (void)addDrinks:(NSSet *)values;
- (void)removeDrinks:(NSSet *)values;

@end
