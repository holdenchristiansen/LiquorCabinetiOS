//
//  RootViewController.h
//  LiquorCabinet
//
//  Created by Mark Powell on 9/14/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlphabetizedIndexedTableViewController.h"
#import "DrinkIngredient.h"

@interface DrinkListViewController : AlphabetizedIndexedTableViewController

@property (nonatomic, copy) NSString *drinksTitle;
@property (nonatomic, strong) IBOutlet UILabel *noDrinksLabel;
@property (nonatomic, copy) NSArray *drinks;
@property (nonatomic, strong) NSMutableArray *ingredientFilters;
@property (nonatomic, strong) NSMutableArray *ingredientButtons;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *noFilterLabel;
@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UIButton *addFilterButton;
@property (nonatomic, assign, getter=willShowFilterList) BOOL showFilterList;
@property (nonatomic, strong) IBOutlet UIImageView *leftTitleLineImageView;
@property (nonatomic, strong) IBOutlet UIImageView *rightTitleLineImageView;
@property (nonatomic, strong) IBOutlet UIImageView *blackBarImageView;

- (IBAction)back:(id)sender;
- (IBAction)addIngredient:(id)sender;
- (void)addIngredientFilter:(DrinkIngredient *)ingredient;
- (void)updateDrinksWithCurrentFilterList;
- (void)updateIngredientButtons;

@end
