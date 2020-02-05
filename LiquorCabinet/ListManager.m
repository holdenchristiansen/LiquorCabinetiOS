//
//  ListManager.m
//  LiquorCabinet
//
//  Created by Mark Powell on 10/26/12.
//  Copyright (c) 2012 Lavacado Studios, LLC. All rights reserved.
//

#import "ListManager.h"
#import "DrinkRecipe.h"
#import "LiquorCabinetAppDelegate.h"
#import "LiquorCabinetOnlineCache.h"
#import <Parse/Parse.h>

@implementation ListManager {
    NSMutableArray *lists_;
    NSDate *dateChecked_;
    NSDate *lastModifiedDate_;
    LiquorCabinetOnlineCache *cache_;
}

+ (ListManager *)sharedListManager {
    static ListManager *sharedSingleton;
    
    @synchronized(self)
    {
        if (!sharedSingleton) {
            sharedSingleton = [[ListManager alloc] init];
        }
        return sharedSingleton;
    }
}

- (id)init {
    self = [super init];
    
    if (self) {
        cache_ = [[LiquorCabinetOnlineCache alloc] init];
    }
    
    return self;
}

- (void)update {
    PFQuery *query = [PFQuery queryWithClassName:@"Lists"];
    NSMutableArray *listArray = [NSMutableArray array];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *listObject in objects) {
            if ([[listObject objectForKey:@"active"] boolValue]) {
                NSMutableDictionary *list = [NSMutableDictionary dictionary];
                
                [list setObject:[listObject objectForKey:@"ListName"] forKey:@"name"];
                
                NSArray *ids = [[listObject objectForKey:@"RecipeIDs"] componentsSeparatedByString:@","];
                NSMutableArray *drinkIds = [NSMutableArray array];
                for (NSString *component in ids) {
                    [drinkIds addObject:[NSNumber numberWithInt:[component intValue]]];
                }
                [list setObject:drinkIds forKey:@"drink_ids"];
                
                [listArray addObject:list];
            }
        }
    }];
    lists_ = listArray;
}

- (int)listCount {
    return [lists_ count];
}

- (NSString *)listNameForIndex:(int)index {
    NSDictionary *list = [lists_ objectAtIndex:index];
    return [list objectForKey:@"name"];
}

- (void)iconForListNamed:(NSString *)name completionBlock:(void (^)(UIImage *image, NSError *error))block {
    [cache_ listIconImageForListNamed:name completionBlock:^(NSData *fullData, NSError *error) {
        UIImage *icon = [UIImage imageWithData:fullData];
        block(icon, error);
    }];
}

- (void)clearThumbnailCache {
    [cache_ clearCache];
}

- (int)drinkCountForList:(NSString *)list {
    for (NSDictionary *data in lists_) {
        if ([[data objectForKey:@"name"] isEqualToString:list]) {
            return [[data objectForKey:@"drink_ids"] count];
        }
    }
    
    return 0;
}

- (DrinkRecipe *)drinkAtIndex:(int)index forList:(NSString *)list {
    for (NSDictionary *data in lists_) {
        if ([[data objectForKey:@"name"] isEqualToString:list]) {
            LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            int drinkId = [[[data objectForKey:@"drink_ids"] objectAtIndex:index] intValue];
            
            NSArray *drinks = [delegate listOfDrinks:[NSPredicate predicateWithFormat:@"drinkID == %d", drinkId]];
            return [drinks lastObject];
        }
    }
    
    return nil;
}

- (NSArray *)allDrinksForList:(NSString *)list {
    for (NSDictionary *data in lists_) {
        if ([[data objectForKey:@"name"] isEqualToString:list]) {
            
            NSArray *drinkIDs = [data objectForKey:@"drink_ids"];
            NSMutableArray *predicates = [NSMutableArray array];
            
            for (id number in drinkIDs) {
                [predicates addObject:[NSPredicate predicateWithFormat:@"drinkID == %d", [number intValue]]];
            }
            
            NSPredicate *predicate = [[NSCompoundPredicate alloc] initWithType:NSOrPredicateType subpredicates:predicates];
            
            LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            return [delegate listOfDrinks:predicate];
        }
    }
    
    return nil;
}

@end
