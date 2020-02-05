//
//  ParseCoreDataConverter.h
//  LiquorCabinet
//
//  Created by Mark Powell on 4/18/13.
//  Copyright (c) 2013 Lavacado Studios, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Parse/Parse.h>

#import "DrinkRecipe.h"

@interface ParseCoreDataConverter : NSObject

+ (ParseCoreDataConverter *)sharedInstance;

- (NSManagedObject *)convertParseRecipe:(PFObject *)recipe;
- (PFObject *)convertManagedObjectRecipe:(DrinkRecipe *)recipe;

@end
