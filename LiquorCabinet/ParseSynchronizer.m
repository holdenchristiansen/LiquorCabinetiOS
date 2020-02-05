//
//  ParseSynchronizer.m
//  LiquorCabinet
//
//  Created by Mark Powell on 3/26/13.
//  Copyright (c) 2013 Lavacado Studios, LLC. All rights reserved.
//

#import "ParseSynchronizer.h"

#import <Parse/Parse.h>
#import "Cabinet.h"
#import "DrinkRecipe.h"
#import "DrinkIngredient.h"
#import "LiquorCabinetAppDelegate.h"
#import "ParseCoreDataConverter.h"

#define kSyncDate @"syncDate"

@implementation ParseSynchronizer {
    NSTimer *userTimer;
}

+ (ParseSynchronizer *)sharedInstance
{
    static ParseSynchronizer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ParseSynchronizer alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (void)addFavorite:(DrinkRecipe *)drinkRecipe {
    PFUser *user = [PFUser currentUser];
    
    if (user != nil) {
        [user addObject:drinkRecipe.drinkID forKey:@"favorites"];
        [self startUserSave];
    }
}

- (void)removeFavorite:(DrinkRecipe *)drinkRecipe {
    PFUser *user = [PFUser currentUser];
    
    if (user != nil) {
        [user removeObject:drinkRecipe.drinkID forKey:@"favorites"];
        [self startUserSave];
    }
}

- (void)addIngredient:(DrinkIngredient *)ingredient toCabinet:(Cabinet *)cabinet {
    PFUser *user = [PFUser currentUser];
    
    if (user != nil) {
        PFQuery *query = [PFQuery queryWithClassName:@"Cabinet"];
        [query whereKey:@"user" equalTo:user];
        [query whereKey:@"name" equalTo:cabinet.name];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            PFObject *cabinetPF = [objects lastObject];
            if (cabinetPF == nil) {
                cabinetPF = [PFObject objectWithClassName:@"Cabinet"];
                [cabinetPF setObject:user forKey:@"user"];
                [cabinetPF setObject:cabinet.name forKey:@"name"];
            }
            
            [cabinetPF addObject:ingredient.name forKey:@"ingredients"];
            [cabinetPF saveEventually];
        }];
    }
}

- (void)removeIngredient:(DrinkIngredient *)ingredient fromCabinet:(Cabinet *)cabinet {
    PFUser *user = [PFUser currentUser];
    
    if (user != nil) {
        PFQuery *query = [PFQuery queryWithClassName:@"Cabinet"];
        [query whereKey:@"user" equalTo:user];
        [query whereKey:@"name" equalTo:cabinet.name];
    
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            PFObject *cabinetPF = [objects lastObject];
            [cabinetPF removeObject:ingredient.name forKey:@"ingredients"];
            [cabinetPF saveEventually];
        }];
    }
}

- (void)addDrinkIngredient:(DrinkIngredient *)ingredient {
    PFUser *user = [PFUser currentUser];
    
    if (user != nil) {
        PFObject *customIngredient = [PFObject objectWithClassName:@"CustomIngredient"];
        [customIngredient setObject:ingredient.optionalAssetName forKey:@"ASSET_NAME"];
        [customIngredient setObject:ingredient.name forKey:@"INGREDIENT_NAME"];
        if (ingredient.secondaryName == nil) {
            [customIngredient setObject:@"" forKey:@"SECONDARY"];
        } else {
            [customIngredient setObject:ingredient.secondaryName forKey:@"SECONDARY"];
        }
        [customIngredient setObject:ingredient.type forKey:@"TYPE"];
        [customIngredient setObject:user forKey:@"user"];
        [customIngredient saveEventually];
    }
}

- (void)deleteDrinkIngredient:(DrinkIngredient *)ingredient {
    //find parse version
}

- (void)addDrinkRecipe:(DrinkRecipe *)drinkRecipe {
    PFUser *user = [PFUser currentUser];
    
    if (user != nil) {
        PFObject *drink = [[ParseCoreDataConverter sharedInstance] convertManagedObjectRecipe:drinkRecipe];
        [drink setObject:user forKey:@"user"];
        [drink saveEventually];
    }
}

- (void)customizeDrinkRecipe:(DrinkRecipe *)drinkRecipe {
    
}

- (void)deleteDrinkRecipe:(DrinkRecipe *)drinkRecipe {
    //find parse version
}

- (void)updateShoppingList {
    PFUser *user = [PFUser currentUser];
    
    if (user != nil) {
        LiquorCabinetAppDelegate *appDelegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    
        NSArray *cart = [appDelegate listOfIngredients:[NSPredicate predicateWithFormat:@"shoppingCart == %@", [NSNumber numberWithBool: YES]]];
        
        NSMutableArray *cartIngredientNames = [NSMutableArray array];
        for (DrinkIngredient *ingredient in cart) {
            if ([ingredient.scratchedOffShoppingCart boolValue]) {
                [cartIngredientNames addObject:[NSString stringWithFormat:@"%@#", ingredient.name]];
            } else {
                [cartIngredientNames addObject:ingredient.name];
            }
        }
        
        [user setObject:cartIngredientNames forKey:@"cartItems"];
        [self saveUser];
    }
}

- (void)synchronize {
    PFUser *user = [PFUser currentUser];
    
    if (user != nil) {
        LiquorCabinetAppDelegate *appDelegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
        
        [user refreshInBackgroundWithBlock:^(PFObject *user, NSError *error) {
            //sync favorites
            NSArray *favorites = [user objectForKey:@"favorites"];
            if (favorites != nil) {
                //reset favorites
                NSPredicate *resetPredicate = [NSPredicate predicateWithFormat:@"favorite == %@", [NSNumber numberWithBool: YES]];
                NSArray *resetDrinks = [appDelegate listOfDrinks:resetPredicate];
                for (DrinkRecipe *drink in resetDrinks) {
                    drink.favorite = [NSNumber numberWithBool:NO];
                }
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"drinkID IN %@", favorites];
                NSArray *drinks = [appDelegate listOfDrinks:predicate];
                for (DrinkRecipe *drink in drinks) {
                    drink.favorite = [NSNumber numberWithBool:YES];
                }
            }
            
            NSArray *cart = [user objectForKey:@"cartItems"];
            if (cart != nil) {
                //clear current cart and rebuild
                LiquorCabinetAppDelegate *appDelegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
                
                NSArray *localCart = [appDelegate listOfIngredients:[NSPredicate predicateWithFormat:@"shoppingCart == %@", [NSNumber numberWithBool: YES]]];
                
                for (DrinkIngredient *ingredient in localCart) {
                    ingredient.shoppingCart = [NSNumber numberWithBool:NO];
                    ingredient.scratchedOffShoppingCart = [NSNumber numberWithBool:NO];
                }
                
                NSMutableArray *cartItems = [NSMutableArray array];
                NSMutableArray *scratchedItems = [NSMutableArray array];
                
                for (NSString *ingredient in cart) {
                    if ([ingredient hasSuffix:@"#"]) {
                        NSString *ingredientName = [ingredient substringToIndex:[ingredient length]-1];
                        [cartItems addObject:ingredientName];
                        [scratchedItems addObject:ingredientName];
                    } else {
                        [cartItems addObject:ingredient];
                    }
                }
                
                localCart = [appDelegate listOfIngredients:[NSPredicate predicateWithFormat:@"name IN %@", cartItems]];
                
                for (DrinkIngredient *drinkIngredient in localCart) {
                    drinkIngredient.shoppingCart = [NSNumber numberWithBool:YES];
                    if ([scratchedItems containsObject:drinkIngredient.name]) {
                        drinkIngredient.scratchedOffShoppingCart = [NSNumber numberWithBool:YES];
                    }
                }
            
            }
        }];
        
        NSDate *checkDate = [[NSUserDefaults standardUserDefaults] objectForKey:kSyncDate];
        if (checkDate == nil) {
            
            //first run, set default check time
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [df setDateFormat:@"yyyyMMddHHmmss"];
            checkDate = [df dateFromString:@"20130221024500"];
        }
        
        PFQuery *customIngredientsQuery = [PFQuery queryWithClassName:@"CustomIngredient"];
        [customIngredientsQuery whereKey:@"user" equalTo:user];
        [customIngredientsQuery whereKey:@"updatedAt" greaterThan:checkDate];
        
        [customIngredientsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for (PFObject *customIngredient in objects) {
                NSArray *baseList = [appDelegate listOfIngredients:[NSPredicate predicateWithFormat:@"name == %@", [customIngredient objectForKey:@"SECONDARY"]]];
                
                [appDelegate createIngredient:[customIngredient objectForKey:@"INGREDIENT_NAME"] base:[baseList lastObject]];
            }
            
            PFQuery *cabinetQuery = [PFQuery queryWithClassName:@"Cabinet"];
            [cabinetQuery whereKey:@"user" equalTo:user];
            [cabinetQuery whereKey:@"updatedAt" greaterThan:checkDate];
            
            [cabinetQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                for (PFObject *cabinet in objects) {
                    Cabinet *localCabinet = [[appDelegate listOfCabinets:[NSPredicate predicateWithFormat:@"name == %@", [cabinet objectForKey:@"name"]]] lastObject];
                    [localCabinet setIngredients:[NSMutableSet set]];
                    
                    NSArray *syncIngredients = [cabinet objectForKey:@"ingredients"];
                    NSArray *localIngredients = [appDelegate listOfIngredients:[NSPredicate predicateWithFormat:@"name IN %@", syncIngredients]];
                    [localCabinet addIngredients:[NSSet setWithArray:localIngredients]];
                }
            }];
            
            PFQuery *drinksQuery = [PFQuery queryWithClassName:@"CustomDrinkRecipe"];
            [drinksQuery whereKey:@"user" equalTo:user];
            [drinksQuery whereKey:@"updatedAt" greaterThan:checkDate];
            [drinksQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                for (PFObject *recipe in objects) {
                    [[ParseCoreDataConverter sharedInstance] convertParseRecipe:recipe];
                }
            }];
        }];
        
        
        
        [appDelegate saveContext];
        
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDate *now = [NSDate date];
        NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:0];
        [cal setTimeZone:tz];
        NSDateComponents *dc = [cal components: NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:now];
        NSDate *newDate = [cal dateFromComponents:dc];
        [[NSUserDefaults standardUserDefaults] setObject:newDate forKey:kSyncDate];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

- (void)startUserSave {
    [userTimer invalidate];
    userTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(saveUser) userInfo:nil repeats:NO];
}


- (void)saveUser {
    [[PFUser currentUser] saveEventually];
}

@end
