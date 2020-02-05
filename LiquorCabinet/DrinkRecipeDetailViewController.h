//
//  DrinkRecipeDetailViewController.h
//  LiquorCabinet
//
//  Created by Mark Powell on 9/14/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MessageUI/MessageUI.h>
#import "GlassListViewController.h"
#import "EditCategoriesViewController.h"
#import "EditRecipeStepViewController.h"

@class DrinkGlass;
@class DrinkRecipe;
@class TipsView;

@interface DrinkRecipeDetailViewController : UIViewController <MFMailComposeViewControllerDelegate, UITextViewDelegate, GlassListViewDelegate, EditCategoriesViewDelegate, EditRecipeStepViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, unsafe_unretained) id navigationDelegate;
@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UIButton *emailButton;
@property (nonatomic, strong) IBOutlet UIButton *restockButton;
@property (strong, nonatomic) IBOutlet UITextField *drinkNameField;
@property (nonatomic, strong) IBOutlet UIImageView *glassImageView;
@property (nonatomic, strong) IBOutlet UILabel *categoryLabel;
@property (nonatomic, strong) IBOutlet UIButton *favoriteButton;
@property (nonatomic, strong) IBOutlet UIView *notesView;
@property (nonatomic, strong) IBOutlet UITextView *notesTextView;
@property (nonatomic, strong) IBOutlet UIToolbar *notesToolbar;
@property (nonatomic, strong) IBOutlet UIView *glassNameView;
@property (nonatomic, strong) IBOutlet UILabel *glassNameLabel;
@property (nonatomic, strong) DrinkRecipe *drink;
@property (nonatomic, strong) IBOutlet UITableView *stepsScrollView;
@property (strong, nonatomic) IBOutlet TipsView *tipsView;
@property (strong, nonatomic) IBOutlet UITextView *tipsTextView;
@property (strong, nonatomic) IBOutlet UIButton *tipsRibbonView;
@property (strong, nonatomic) IBOutlet UILabel *tipsDrinkNameLabel;
@property (strong, nonatomic) IBOutlet UIView *editButtonPanel;
@property (strong, nonatomic) IBOutlet UIButton *toggleEditButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelEditingButton;
@property (strong, nonatomic) IBOutlet UIButton *saveEditingButton;
@property (assign, nonatomic) BOOL shouldEditOnStart;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarButtonItem;


#pragma mark - data
@property (nonatomic, strong) NSMutableArray *steps;
@property (nonatomic, strong) NSMutableArray *checkedSteps;
@property (nonatomic, strong) NSString *drinkName;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) DrinkGlass *glass;
@property (nonatomic, strong) NSString *information;
@property (nonatomic, strong) NSMutableArray *ingredients;

- (void)updateViewWithDrink:(DrinkRecipe *)drink;
- (IBAction)back:(id)sender;
- (IBAction)toggleFavorite:(id)sender;
- (IBAction)saveNote:(id)sender;
- (IBAction)clearNote:(id)sender;
- (IBAction)cancelNote:(id)sender;
- (IBAction)emailRecipe:(id)sender;
- (IBAction)restockIngredients:(id)sender;
- (IBAction)showInstructions:(id)sender;
- (IBAction)showGlassInformation:(id)sender;
- (IBAction)hideGlassInformation:(id)sender;
- (IBAction)toggleTips:(id)sender;
- (IBAction)enterEditMode:(id)sender;
- (IBAction)cancelEdit:(id)sender;
- (IBAction)saveEdit:(id)sender;
- (IBAction)editGlassInfo:(id)sender;
- (IBAction)editCategories:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *yourNotesView;

@end
