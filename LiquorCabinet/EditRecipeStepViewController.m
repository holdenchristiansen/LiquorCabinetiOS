//
//  EditRecipeStepViewController.m
//  LiquorCabinet
//
//  Created by Mark Powell on 10/22/12.
//  Copyright (c) 2012 Lavacado Studios, LLC. All rights reserved.
//

#import "EditRecipeStepViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "EditRecipeIngredientSelectionViewController.h"
#import "LiquorCabinetAppDelegate.h"

typedef enum {
    StepTypeNone,
    StepTypeIngredient,
    StepTypeDescription
} StepType;

@interface UITextField (Placeholder)
- (void) drawPlaceholderInRect:(CGRect)rect;
@end

@implementation UITextField (Placeholder)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void) drawPlaceholderInRect:(CGRect)rect {
    [[UIColor darkGrayColor] setFill];
    [self.placeholder drawInRect:rect withFont:self.font lineBreakMode:UILineBreakModeTailTruncation alignment:self.textAlignment];
}
#pragma clang diagnostic pop
@end

@interface EditRecipeStepViewController ()

@end

@implementation EditRecipeStepViewController {
    StepType currentStepType_;
    BOOL hasSelectedIngredient_;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleBar.font = [UIFont fontWithName:@"HoneyScript-SemiBold" size:48];
    self.doneButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:17];
    self.selectIngredientButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:17];
    self.selectDescriptionButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:17];
    self.selectIngredientButton.layer.cornerRadius = 5;
    self.selectIngredientButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.selectIngredientButton.layer.borderWidth = 2;
    self.selectDescriptionButton.layer.cornerRadius = 5;
    self.selectDescriptionButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.selectDescriptionButton.layer.borderWidth = 2;
    self.cancelButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:17];
    self.ingredientSelectionButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:17];
    self.selectStageLabel.font = [UIFont fontWithName:@"tabitha" size:17];
    self.orLabel.font = [UIFont fontWithName:@"tabitha" size:17];
    self.ingredientLabel.font = [UIFont fontWithName:@"tabitha" size:17];
    self.amountTextField.font = [UIFont fontWithName:@"tabitha" size:17];
    self.amountLabel.font = [UIFont fontWithName:@"tabitha" size:17];
    self.descriptionTextField.font = [UIFont fontWithName:@"tabitha" size:17];
    self.descriptionLabel.font = [UIFont fontWithName:@"tabitha" size:17];
    
    if (self.stepText) {
        hasSelectedIngredient_ = YES;
        self.titleBar.text = @"Edit Recipe Step";
        [self.doneButton setTitle:@"Edit" forState:UIControlStateNormal];
        if (self.stepAmount) {
            [self.ingredientSelectionButton setTitle:self.stepText forState:UIControlStateNormal];
            self.amountTextField.text = self.stepAmount;
            [self selectIngredientType:nil];
        } else {
            self.descriptionTextField.text = self.stepText;
            [self selectDescriptionType:nil];
        }
        
        self.doneButton.hidden = NO;
        self.cancelButton.transform = CGAffineTransformMakeTranslation(-75, 0);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (currentStepType_ == StepTypeDescription) {
        if (![self.descriptionTextField.text isEqualToString:@""]) {
            self.doneButton.hidden = NO;
            self.cancelButton.transform = CGAffineTransformMakeTranslation(-75, 0);
        } else {
            self.doneButton.hidden = YES;
            self.cancelButton.transform = CGAffineTransformIdentity;
        }
    } else if (currentStepType_ == StepTypeIngredient) {
        if (hasSelectedIngredient_ && ![self.amountTextField.text isEqualToString:@""]) {
            self.doneButton.hidden = NO;
            self.cancelButton.transform = CGAffineTransformMakeTranslation(-75, 0);
        } else {
            self.doneButton.hidden = YES;
            self.cancelButton.transform = CGAffineTransformIdentity;
        }
    }
}

- (IBAction)selectIngredientType:(id)sender {
    currentStepType_ = StepTypeIngredient;
    [UIView animateWithDuration:0.25 animations:^(void){
        self.typeSelectionStageView.transform = CGAffineTransformTranslate(self.typeSelectionStageView.transform, -320, 0);
        self.setIngredientAmountStageView.transform = CGAffineTransformTranslate(self.setIngredientAmountStageView.transform, -320, 0);
    }];
    
}

- (IBAction)selectDescriptionType:(id)sender {
    currentStepType_ = StepTypeDescription;
    [UIView animateWithDuration:0.25 animations:^(void){
        self.typeSelectionStageView.transform = CGAffineTransformTranslate(self.typeSelectionStageView.transform, -320, 0);
        self.setDescriptionStageView.transform = CGAffineTransformTranslate(self.setDescriptionStageView.transform, -320, 0);
    }];
}

- (IBAction)selectIngredientForStep:(id)sender {
    EditRecipeIngredientSelectionViewController *controller = [[EditRecipeIngredientSelectionViewController alloc] init];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)ingredientSetTo:(NSString *)ingredient {
    [self.ingredientSelectionButton setTitle:ingredient forState:UIControlStateNormal];
    hasSelectedIngredient_ = YES;
    if (![self.amountTextField.text isEqualToString:@""]) {
        self.doneButton.hidden = NO;
        self.cancelButton.transform = CGAffineTransformMakeTranslation(-75, 0);
    }
}

- (IBAction)cancel:(id)sender {
    [self.delegate cancelRecipeStepViewController:self];
}

- (IBAction)createStep:(id)sender {
    if (currentStepType_ == StepTypeIngredient) {
        if (self.stepText) {
            [self.delegate recipeStepViewController:self didEditStepAtIndex:self.stepIndex withText:self.ingredientSelectionButton.titleLabel.text andAmount:self.amountTextField.text];
        } else {
            [self.delegate recipeStepViewController:self didCreateNewStepWithtext:self.ingredientSelectionButton.titleLabel.text andAmount:self.amountTextField.text];
        }
        
    } else if (currentStepType_ == StepTypeDescription) {
        if (self.stepText) {
            [self.delegate recipeStepViewController:self didEditStepAtIndex:self.stepIndex withText:self.descriptionTextField.text andAmount:nil];
        } else {
            [self.delegate recipeStepViewController:self didCreateNewStepWithtext:self.descriptionTextField.text andAmount:nil];
        }
    }
}

- (void)viewDidUnload {
    [self setTypeSelectionStageView:nil];
    [self setSetIngredientAmountStageView:nil];
    [self setSetDescriptionStageView:nil];
    [self setDoneButton:nil];
    [self setDescriptionTextField:nil];
    [self setIngredientSelectionButton:nil];
    [self setAmountTextField:nil];
    [self setTitleBar:nil];
    [self setSelectStageLabel:nil];
    [self setOrLabel:nil];
    [self setSelectIngredientButton:nil];
    [self setSelectDescriptionButton:nil];
    [self setCancelButton:nil];
    [self setDescriptionLabel:nil];
    [self setIngredientLabel:nil];
    [self setAmountLabel:nil];
    [super viewDidUnload];
}
@end
