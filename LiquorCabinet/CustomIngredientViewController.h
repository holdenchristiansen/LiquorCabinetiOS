//
//  CustomIngredientViewController.h
//  LiquorCabinet
//
//  Created by Mark Powell on 10/11/12.
//  Copyright (c) 2012 Lavacado Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "AlphabetizedIndexedTableViewController.h"

@class DrinkIngredient;

@interface CustomIngredientViewController : AlphabetizedIndexedTableViewController <MFMailComposeViewControllerDelegate>

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
@property (strong, nonatomic) IBOutlet UILabel *typeOfLabel;
@property (strong, nonatomic) IBOutlet UILabel *ingredientNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *createButton;
@property (nonatomic, assign) int filterMode;
@property (nonatomic, unsafe_unretained) id delegate;
@property (nonatomic, strong) DrinkIngredient *createdIngredient;
@property (weak, nonatomic) IBOutlet UILabel *ingredientNameLabelSearchBar;

- (IBAction)setFilter:(id)sender;
- (IBAction)back:(id)sender;
- (IBAction)createIngredient:(id)sender;
- (IBAction)dismissKeyboard:(id)sender;

@end
