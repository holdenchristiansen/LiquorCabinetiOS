//
//  LiquorCabinetAppDelegate.m
//  LiquorCabinet
//
//  Created by Mark Powell on 9/14/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import "LiquorCabinetAppDelegate.h"
#import "Appirater.h"
#import "TargetConditionals.h"
#import "Cabinet.h"
#import "CategoryListViewController.h"
#import "DrinkRecipe.h"
#import "DrinkCategory.h"
#import "DrinkGlass.h"
#import "DrinkIngredient.h"
#import "ListManager.h"
#import "RecipeStep.h"
//#import "Flurry.h"
#import <Parse/Parse.h>
#import "ParseSynchronizer.h"
#import "ImageManager.h"

@interface LiquorCabinetAppDelegate ()
- (void)resetDataModel;
- (void)reportDatabaseIssues;
@end

@implementation LiquorCabinetAppDelegate {
    NSURL *iCloudURL_;
}

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [Parse setApplicationId:@"Vk0H9wePUeZs6wnZo9joDCk4LeL2eUiB0fzi7i9z"
                  clientKey:@"nhVsxLD5A3PtHbnpyqyuLdtbOWQit0rvXaeZjqXm"];
//    [PFFacebookUtils initializeWithApplicationId:@"369883486458510"];
    
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    // Override point for customization after application launch.
    // Add the navigation controller's view to the window and display.
    
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    dir = [dir stringByAppendingPathComponent:@"LiquorCabinet.sqlite"];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:dir]) {

        NSBundle* bundle = [NSBundle mainBundle];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString* srcPath = [bundle pathForResource:@"LiquorCabinet" ofType:@"sqlite"];
        if ([fileManager fileExistsAtPath:srcPath]) {
            NSError *createError;
            NSString *destPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            [fileManager createDirectoryAtPath:destPath withIntermediateDirectories:YES attributes:nil error:&createError];
            
            destPath = [destPath stringByAppendingPathComponent:@"LiquorCabinet.sqlite"];
            NSError *copyError;
            [fileManager copyItemAtPath:srcPath toPath:destPath error:&copyError];
        }

    }
    
#if (TARGET_IPHONE_SIMULATOR) 
    [self reportDatabaseIssues];
    //[self checkRecipeStepIngredients];
#endif
    
    Cabinet *cabinet = [self currentCabinet];
    self.databaseVersion = [cabinet.version intValue];
    
    self.window.rootViewController = self.tabBarController;
    [self.window addSubview:self.welcomeController.view];
    [self.window makeKeyAndVisible];
    [Appirater appLaunched:YES];
    [[ListManager sharedListManager] update];
//    [Flurry startSession:@"P8ZQBHN6JHHS9DFMDQTD"];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //[[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
    
    
    //Test
    ImageManager *myImageManager = [ImageManager sharedImageManager];
    [myImageManager downloadRemoteImage:@"Botella-Cacique-Guaro-01-2.png"];
    
    return YES;
}

- (void)checkRecipeStepIngredients {
    NSArray *drinks = [self listOfDrinks:nil];
    NSMutableString *outputString = [[NSMutableString alloc] init];
    for (DrinkRecipe *recipe in drinks) {
        [outputString appendFormat:@"%@:\n", recipe.name];
        for (RecipeStep *step in recipe.steps) {
            if (step.stepAmount) {
                NSArray *ingredient = [self listOfIngredients:[NSPredicate predicateWithFormat:@"name == %@", step.stepTitle]];
                if ([ingredient count] == 0) {
                    [outputString appendFormat:@"\t%@\n", step.stepTitle];
                }
            }
        }
    }
    
    NSLog(@"%@", outputString);
}

- (void)reportDatabaseIssues {
    NSMutableArray *badGlass = [NSMutableArray array];
    NSArray *drinks = [self listOfDrinks:nil];
    for (DrinkRecipe *recipe in drinks) {
        NSString *glassName = [[recipe.glass.name stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
        NSString *drinkImageName = [NSString stringWithFormat:@"%@.png", glassName];
//        UIImage *image = [UIImage imageNamed:drinkImageName];
        UIImage *image = [[ImageManager sharedImageManager] loadImage:drinkImageName];
        if (image == nil) {
            if (![badGlass containsObject:recipe.glass.name] && recipe.glass.name != nil) {
                [badGlass addObject:recipe.glass.name];
            }
        }
    }
    
    NSMutableArray *badIngredientImages = [NSMutableArray array];
    NSMutableArray *badSelectedIngredientImages = [NSMutableArray array];
    NSMutableArray *badIngredientHighResImages = [NSMutableArray array];
    NSMutableArray *badIngredientSelectedHighResImages = [NSMutableArray array];
    NSMutableArray *noDrinkIngredients = [NSMutableArray array];
    NSMutableArray *badIngredientData = [NSMutableArray array];
    NSMutableArray *badParentIngredientList = [NSMutableArray array];
    
    NSArray *list = [self listOfIngredients:nil];
    for (DrinkIngredient *ingredient in list) {
        if (ingredient.type == nil) {
            [badIngredientData addObject:ingredient];
        }
        
        NSString *imageName = [ingredient.optionalAssetName stringByAppendingString:@".png"];
//        UIImage *image = [UIImage imageNamed:imageName];
        UIImage *image = [[ImageManager sharedImageManager] loadImage:imageName];
        if (image == nil) {
            [badIngredientImages addObject:ingredient.name];
        }
        
        imageName = [ingredient.optionalAssetName stringByAppendingString:@"_orange.png"];
//        image = [UIImage imageNamed:imageName];
        image = [[ImageManager sharedImageManager] loadImage:imageName];
        if (image == nil) {
            [badSelectedIngredientImages addObject:ingredient.name];
        }
        
        imageName = [ingredient.optionalAssetName stringByAppendingString:@"@2x.png"];
//        image = [UIImage imageNamed:imageName];
        image = [[ImageManager sharedImageManager] loadImage:imageName];
        if (image == nil) {
            [badIngredientHighResImages addObject:ingredient.name];
        }
        
        imageName = [ingredient.optionalAssetName stringByAppendingString:@"_orange@2x.png"];
//        image = [UIImage imageNamed:imageName];
        image = [[ImageManager sharedImageManager] loadImage:imageName];
        if (image == nil) {
            [badIngredientSelectedHighResImages addObject:ingredient.name];
        }
        
        if ([ingredient.drinks count] == 0 && ingredient.secondaryName == nil) {
            NSArray *garnishCheck = [self listOfDrinks:[NSPredicate predicateWithFormat:@"ANY garnishes.name = %@", ingredient.name]];
            if ([garnishCheck count] == 0) {
                [noDrinkIngredients addObject:ingredient.name];
            }
        }
        
        if (ingredient.secondaryName != nil) {
            DrinkIngredient *parent = [[self listOfIngredients:[NSPredicate predicateWithFormat:@"name = %@", ingredient.secondaryName]] lastObject];
            if (parent == nil) {
                [badParentIngredientList addObject:ingredient.secondaryName];
            }
        }
    }
    
    NSMutableArray *badIngredientList = [NSMutableArray array];
    for (DrinkIngredient *ingredient in badIngredientData) {
        NSMutableArray *drinks = [NSMutableArray array];
        for (DrinkRecipe *recipe in ingredient.drinks) {
            [drinks addObject:recipe.name];
        }
        [badIngredientList addObject:[NSString stringWithFormat:@"%@ - %@", ingredient.name, drinks]];
    }

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
//    return [PFFacebookUtils handleOpenURL:url];
//}
//
//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//    return [PFFacebookUtils handleOpenURL:url];
//}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [Appirater appEnteredForeground:YES];
    [self.welcomeController updateFromWeb];
    if ([PFUser currentUser]) {
        [[ParseSynchronizer sharedInstance] synchronize];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    [PFPush storeDeviceToken:newDeviceToken]; // Send parse the device token
    // Subscribe this user to the broadcast channel, ""
    [PFPush subscribeToChannelInBackground:@"" block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Successfully subscribed to the broadcast channel.");
        } else {
            NSLog(@"Failed to subscribe to the broadcast channel.");
        }
    }];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (void)awakeFromNib
{
}

#pragma mark - alert
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [UIView animateWithDuration:0.35 animations:^(void){
            self.welcomeController.view.transform = CGAffineTransformMakeTranslation(0, -480);
        } completion:^(BOOL finished){
            [self.welcomeController.view removeFromSuperview];
        }];
        [self.tabBarController setSelectedIndex:2];
//        [Flurry logEvent:@"User selected to view Lists from Notification"];
    }
}

- (void)didReceiveNewLists:(NSNotification *)note {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Lists" message:@"There are new drink lists waiting to be perused! Would you like to see them?" delegate:self cancelButtonTitle:@"No, Thanks" otherButtonTitles:@"Yes, Let's See!", nil];
    [alert show];
}

#pragma mark - data

- (void)searchForDrinkWithTerm:(NSString *)term {
//    [Flurry logEvent:@"Search" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:term, @"Search Term", nil]];
    [UIView animateWithDuration:0.35 animations:^(void){
        self.welcomeController.view.transform = CGAffineTransformMakeTranslation(0, -480);
    } completion:^(BOOL finished){
        [self.welcomeController.view removeFromSuperview];
    }];
    [self.tabBarController setSelectedIndex:1];
    UINavigationController *navController = (UINavigationController *)self.tabBarController.selectedViewController;
    CategoryListViewController *controller = (CategoryListViewController *)[navController.viewControllers objectAtIndex:0];
    [controller searchForDrinkWithTerm:term];
}

- (void)showCabinet {
    [UIView animateWithDuration:0.35 animations:^(void){
        self.welcomeController.view.transform = CGAffineTransformMakeTranslation(0, -480);
    } completion:^(BOOL finished){
        [self.welcomeController.view removeFromSuperview];
    }];
    
    [self.tabBarController setSelectedIndex:0];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

- (void)rollbackContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges])
        {
            [managedObjectContext rollback];
        }
    }
}

#pragma mark - Core Data stack
- (void)resetDataModel {
    __managedObjectContext = nil;
    __managedObjectModel = nil;
    __persistentStoreCoordinator = nil;
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"LiquorCabinet" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"LiquorCabinet.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - drinks request
- (NSArray *)listOfDrinks:(NSPredicate *)predicate {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DrinkRecipe" inManagedObjectContext:context];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSArray *results = [context executeFetchRequest:request error:nil];
    
    return results;
}

- (NSArray *)listOfCategories:(NSPredicate *)predicate {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DrinkCategory" inManagedObjectContext:context];
    [request setEntity:entity];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    [request setPredicate:predicate];
    NSArray *results = [context executeFetchRequest:request error:nil];
    
    return results;
}

- (NSArray *)listOfGlasses:(NSPredicate *)predicate {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DrinkGlass" inManagedObjectContext:context];
    [request setEntity:entity];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    [request setPredicate:predicate];
    NSArray *results = [context executeFetchRequest:request error:nil];
    
    return results;
}

- (NSArray *)listOfIngredients:(NSPredicate *)predicate {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DrinkIngredient" inManagedObjectContext:context];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSArray *results = [context executeFetchRequest:request error:nil];
    
    return results;
}

- (NSArray *)listOfCabinets:(NSPredicate *)predicate {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Cabinet" inManagedObjectContext:context];
    [request setEntity:entity];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    [request setPredicate:predicate];
    NSArray *results = [context executeFetchRequest:request error:nil];
    
    return results;
}

- (Cabinet *)currentCabinet {
    NSArray *cabinets = [self listOfCabinets:nil];
    if ([cabinets count] == 0) {
        Cabinet *cabinet = [Cabinet cabinetWithName:@"Default" inContext:self.managedObjectContext];
        [self saveContext];
        return cabinet;
    } else {
        return [cabinets objectAtIndex:0];
    }
}

- (void)deleteEntity:(NSManagedObject *)entity {
    NSManagedObjectContext *context = [self managedObjectContext];
    [context deleteObject:entity];
}

- (DrinkIngredient *)createIngredient:(NSString *)name base:(DrinkIngredient *)base {
    DrinkIngredient *ingredient = [DrinkIngredient drinkIngredientWithName:name inContext:self.managedObjectContext];
    ingredient.secondaryName = base.name;
    ingredient.optionalAssetName = base.optionalAssetName;
    ingredient.type = base.type;
    [self saveContext];
    return ingredient;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
@end
