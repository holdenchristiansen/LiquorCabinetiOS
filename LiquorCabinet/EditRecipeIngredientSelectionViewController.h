//
//  EditRecipeIngredientSelectionViewController.h
//  LiquorCabinet
//
//  Created by Mark Powell on 10/23/12.
//  Copyright (c) 2012 Lavacado Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlphabetizedIndexedTableViewController.h"

@interface EditRecipeIngredientSelectionViewController : AlphabetizedIndexedTableViewController

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
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *removalArray;
@property (nonatomic, assign) int filterMode;
@property (nonatomic, unsafe_unretained) id delegate;

- (IBAction)setFilter:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)searchValueChanged:(id)sender;
- (IBAction)dismissSearch:(id)sender;
- (IBAction)clearSearch:(id)sender;
@end
