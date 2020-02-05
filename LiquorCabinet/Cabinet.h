//
//  Cabinet.h
//  LiquorCabinet
//
//  Created by Mark Powell on 9/17/11.
//  Copyright (c) 2011 Lavacado Studios, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DrinkIngredient;

@interface Cabinet : NSManagedObject {
@private
}
@property (nonatomic, strong) NSNumber * version;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * dirty;
@property (nonatomic, strong) NSSet *ingredients;

@end

@interface Cabinet (CoreDataGeneratedAccessors)

+ (Cabinet *)cabinetWithName:(NSString *)name inContext:(NSManagedObjectContext *)context;

- (void)addIngredientsObject:(DrinkIngredient *)value;
- (void)removeIngredientsObject:(DrinkIngredient *)value;
- (void)addIngredients:(NSSet *)values;
- (void)removeIngredients:(NSSet *)values;

- (BOOL)cabinetContainsIngredient:(DrinkIngredient *)ingredient;

- (NSArray *)ownedIngredientsWithSearchTerm:(NSString *)string;

@end
