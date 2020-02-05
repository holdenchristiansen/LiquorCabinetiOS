//
//  IngredientsListViewController.h
//  LiquorCabinet
//
//  Created by Mark Powell on 9/14/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AlphabetizedIndexedTableViewController.h"

@interface CabinetIngredientListViewController : AlphabetizedIndexedTableViewController

@property (strong, nonatomic) IBOutlet UITextField *searchField;
@property (strong, nonatomic) IBOutlet UIButton *clearSearchButton;
@property (nonatomic, strong) NSArray *ingredients;
@property (nonatomic, strong) NSMutableArray *expandedItems;
@property (nonatomic, strong) NSMutableArray *firstSubIngredients;
@property (nonatomic, strong) NSMutableArray *lastSubIngredients;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIButton *allIngredientsButton;
@property (nonatomic, strong) IBOutlet UIButton *liquorIngredientsButton;
@property (nonatomic, strong) IBOutlet UIButton *mixerIngredientsButton;
@property (nonatomic, strong) IBOutlet UIButton *garnishIngredientsButton;
@property (nonatomic, strong) IBOutlet UIButton *ownedIngredientsButton;
@property (nonatomic, strong) IBOutlet UIButton *backToCabinetButton;
@property (nonatomic, strong) IBOutlet UIButton *clearItemsButton;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *searchIngredientsLabel;
@property (nonatomic, strong) NSMutableArray *removalArray;
@property (nonatomic, assign) int filterMode;
@property (nonatomic, unsafe_unretained) id delegate;

- (IBAction)setFilter:(id)sender;
- (IBAction)backToCabinet:(id)sender;
- (IBAction)searchValueChanged:(id)sender;
- (IBAction)dismissSearch:(id)sender;
- (IBAction)clearSearch:(id)sender;
- (IBAction)addCustomIngredient:(id)sender;


@end
