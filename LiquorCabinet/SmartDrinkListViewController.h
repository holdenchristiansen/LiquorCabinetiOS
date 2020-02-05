//
//  SmartDrinkListViewController.h
//  LiquorCabinet
//
//  Created by Mark Powell on 10/25/11.
//  Copyright (c) 2011 Lavacado Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kSmartDrinkListModeNone,
    kSmartDrinkListModeComplete,
    kSmartDrinkListModeIngredients
} SmartDrinkListMode;

@class DrinkIngredient;

@interface SmartDrinkListViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *noDrinksLabel;
@property (nonatomic, copy) NSArray *completeDrinks;
@property (nonatomic, copy) NSArray *almostDrinks;
@property (nonatomic, copy) NSArray *almostDrinkIngredients;
@property (nonatomic, strong) NSDictionary *ingredients;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *completeButton;
@property (nonatomic, strong) IBOutlet UIButton *ingredientsButton;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, assign) SmartDrinkListMode mode;
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSMutableDictionary *alphabetizedContent;

- (IBAction)back:(id)sender;
- (IBAction)setModeToComplete:(id)sender;
- (IBAction)setModeToIngredients:(id)sender;

@end
