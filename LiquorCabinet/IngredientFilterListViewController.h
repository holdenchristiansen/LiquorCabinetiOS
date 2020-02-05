//
//  IngredientsListViewController.h
//  LiquorCabinet
//
//  Created by Mark Powell on 9/14/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlphabetizedIndexedTableViewController.h"

@interface IngredientFilterListViewController : AlphabetizedIndexedTableViewController

@property (strong, nonatomic) IBOutlet UIButton *clearSearchButton;
@property (strong, nonatomic) IBOutlet UITextField *searchField;
@property (nonatomic, copy) NSArray *ingredients;
@property (nonatomic, strong) NSMutableArray *displayedIngredients;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIButton *allIngredientsButton;
@property (nonatomic, strong) IBOutlet UIButton *liquorIngredientsButton;
@property (nonatomic, strong) IBOutlet UIButton *mixerIngredientsButton;
@property (nonatomic, strong) IBOutlet UIButton *garnishIngredientsButton;
@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, assign) int filterMode;
@property (nonatomic, unsafe_unretained) id delegate;
@property (weak, nonatomic) IBOutlet UILabel *searchIngredientsLabel;

- (IBAction)setFilter:(id)sender;
- (IBAction)back:(id)sender;
- (IBAction)searchValueChanged:(id)sender;
- (IBAction)dismissSearch:(id)sender;
- (IBAction)clearSearch:(id)sender;

@end
