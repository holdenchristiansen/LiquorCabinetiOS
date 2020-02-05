//
//  LiquorCabinetAppDelegate.h
//  LiquorCabinet
//
//  Created by Mark Powell on 9/14/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WelcomeViewController.h"


@class Cabinet;
@class DrinkIngredient;

@interface LiquorCabinetAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (void)rollbackContext;
- (NSURL *)applicationDocumentsDirectory;

@property (nonatomic, strong) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, strong) IBOutlet WelcomeViewController *welcomeController;
@property (nonatomic, assign) int databaseVersion;

- (NSArray *)listOfDrinks:(NSPredicate *)predicate;
- (NSArray *)listOfCategories:(NSPredicate *)predicate;
- (NSArray *)listOfGlasses:(NSPredicate *)predicate;
- (NSArray *)listOfIngredients:(NSPredicate *)predicate;
- (NSArray *)listOfCabinets:(NSPredicate *)predicate;
- (Cabinet *)currentCabinet;
- (void)deleteEntity:(NSManagedObject *)entity;
- (void)showCabinet;
- (void)searchForDrinkWithTerm:(NSString *)term;
- (DrinkIngredient *)createIngredient:(NSString *)name base:(DrinkIngredient *)base;
@end
