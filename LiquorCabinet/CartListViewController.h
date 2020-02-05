//
//  CartListViewController.h
//  LiquorCabinet
//
//  Created by Mark Powell on 9/15/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlphabetizedIndexedTableViewController.h"

@interface CartListViewController : AlphabetizedIndexedTableViewController

@property (nonatomic, strong) IBOutlet UILabel *noItemsLabel;
@property (nonatomic, strong) IBOutlet UIButton *addButton;
@property (nonatomic, strong) IBOutlet UIButton *clearButton;
@property (nonatomic, strong) IBOutlet UIButton *allIngredientsButton;
@property (nonatomic, strong) IBOutlet UIButton *liquorIngredientsButton;
@property (nonatomic, strong) IBOutlet UIButton *mixerIngredientsButton;
@property (nonatomic, strong) IBOutlet UIButton *garnishIngredientsButton;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) NSMutableArray *ingredients;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *currentDeletePath;
@property (nonatomic, strong) IBOutlet UIImageView *leftTitleBarImageView;
@property (nonatomic, copy) NSString *filterType;

- (IBAction)setFilter:(id)sender;
- (IBAction)addIngredient:(id)sender;
- (IBAction)clear:(id)sender;
- (void)removePurchasedItems:(BOOL)addToCabinet;

@end
