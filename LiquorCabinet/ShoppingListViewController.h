//
//  ShoppingListViewController.h
//  LiquorCabinet
//
//  Created by Mark Powell on 9/15/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlphabetizedIndexedTableViewController.h"

@interface ShoppingListViewController : AlphabetizedIndexedTableViewController

@property (nonatomic, strong) IBOutlet UIButton *doneButton;
@property (nonatomic, strong) IBOutlet UIButton *allIngredientsButton;
@property (nonatomic, strong) IBOutlet UIButton *liquorIngredientsButton;
@property (nonatomic, strong) IBOutlet UIButton *mixerIngredientsButton;
@property (nonatomic, strong) IBOutlet UIButton *garnishIngredientsButton;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, copy) NSArray *ingredients;
@property (nonatomic, strong) NSMutableArray *expandedItems;
@property (nonatomic, strong) NSMutableArray *firstSubIngredients;
@property (nonatomic, strong) NSMutableArray *lastSubIngredients;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, unsafe_unretained) id delegate;

- (IBAction)setFilter:(id)sender;
- (IBAction)done:(id)sender;

@end
