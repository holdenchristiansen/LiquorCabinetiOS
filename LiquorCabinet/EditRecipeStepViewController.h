//
//  EditRecipeStepViewController.h
//  LiquorCabinet
//
//  Created by Mark Powell on 10/22/12.
//  Copyright (c) 2012 Lavacado Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditRecipeStepViewController;

@protocol EditRecipeStepViewDelegate <NSObject>

- (void)cancelRecipeStepViewController:(EditRecipeStepViewController *)controller;
- (void)recipeStepViewController:(EditRecipeStepViewController *)controller didCreateNewStepWithtext:(NSString *)text andAmount:(NSString *)amount;
- (void)recipeStepViewController:(EditRecipeStepViewController *)controller didEditStepAtIndex:(int) index withText:(NSString *)text andAmount:(NSString *)amount;
@end

@interface EditRecipeStepViewController : UIViewController
@property (weak, nonatomic) id <EditRecipeStepViewDelegate> delegate;
@property (assign, nonatomic) int stepIndex;
@property (strong, nonatomic) NSString *stepText;
@property (strong, nonatomic) NSString *stepAmount;
@property (strong, nonatomic) IBOutlet UILabel *titleBar;
@property (strong, nonatomic) IBOutlet UIView *typeSelectionStageView;
@property (strong, nonatomic) IBOutlet UILabel *selectStageLabel;
@property (strong, nonatomic) IBOutlet UILabel *orLabel;
@property (strong, nonatomic) IBOutlet UIButton *selectIngredientButton;
@property (strong, nonatomic) IBOutlet UIButton *selectDescriptionButton;
@property (strong, nonatomic) IBOutlet UIView *setIngredientAmountStageView;
@property (strong, nonatomic) IBOutlet UILabel *ingredientLabel;
@property (strong, nonatomic) IBOutlet UILabel *amountLabel;
@property (strong, nonatomic) IBOutlet UITextField *amountTextField;
@property (strong, nonatomic) IBOutlet UIButton *ingredientSelectionButton;
@property (strong, nonatomic) IBOutlet UIView *setDescriptionStageView;
@property (strong, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

- (IBAction)selectIngredientType:(id)sender;
- (IBAction)selectDescriptionType:(id)sender;
- (IBAction)selectIngredientForStep:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)createStep:(id)sender;

@end
