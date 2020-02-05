//
//  DrinkListScrollViewControllerViewController.h
//  LiquorCabinet
//
//  Created by Mark Powell on 3/19/12.
//  Copyright (c) 2012 Lavacado Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DrinkRecipeDetailViewController;

@interface DrinkListScrollViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSArray *drinkList;
@property (strong, nonatomic) DrinkRecipeDetailViewController *pageOneDrinkController;
@property (strong, nonatomic) DrinkRecipeDetailViewController *pageTwoDrinkController;
@property (strong, nonatomic) DrinkRecipeDetailViewController *pageThreeDrinkController;
@property (nonatomic) int prevIndex;
@property (nonatomic) int currIndex;
@property (nonatomic) int nextIndex;

- (id)initWithDrinkList:(NSArray *)drinkList initialIndex:(int)index;

@end
