//
//  ListManager.h
//  LiquorCabinet
//
//  Created by Mark Powell on 10/26/12.
//  Copyright (c) 2012 Lavacado Studios, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DrinkRecipe;

@interface ListManager : NSObject

+ (ListManager *)sharedListManager;

- (void)update;

- (int)listCount;
- (NSString *)listNameForIndex:(int)index;
- (void)iconForListNamed:(NSString *)name completionBlock:(void (^)(UIImage *image, NSError *error))block;
- (int)drinkCountForList:(NSString *)list;
- (DrinkRecipe *)drinkAtIndex:(int)index forList:(NSString *)list;
- (NSArray *)allDrinksForList:(NSString *)list;
@end
