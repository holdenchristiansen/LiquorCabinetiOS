//
//  SubtableExpandButton.h
//  LiquorCabinet
//
//  Created by Mark Powell on 3/8/12.
//  Copyright (c) 2012 Lavacado Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrinkIngredient.h"

@interface SubtableExpandButton : UIButton

@property NSIndexPath *cellPath;
@property DrinkIngredient *drinkIngredient;

@end
