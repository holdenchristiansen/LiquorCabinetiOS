//
//  DrinkRecipeDetailViewController.m
//  LiquorCabinet
//
//  Created by Mark Powell on 9/14/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import "DrinkRecipeDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Cabinet.h"
#import "DrinkCategory.h"
#import "DrinkGarnish.h"
#import "DrinkGlass.h"
#import "DrinkIngredient.h"
#import "DrinkInstructionsViewController.h"
#import "DrinkRecipe.h"
#import "LiquorCabinetAppDelegate.h"
#import "RecipeStep.h"
#import "RecipeStepTableViewCell.h"
#import "TipsView.h"
#import "UIButton+TitleSetting.h"
//#import "Flurry.h"
#import "ParseSynchronizer.h"
#import "ImageManager.h"

@interface ModifiableStep : NSObject

@property NSString *text;
@property NSString *amount;

@end

@implementation ModifiableStep

@end

@implementation DrinkRecipeDetailViewController {
    GlassListViewController *glassController_;
    EditCategoriesViewController *categoriesController_;
    EditRecipeStepViewController *stepController_;
    UINavigationController *navController_;
    float keyboard_height;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (float)heightForTextAtIndexPath:(NSIndexPath *)path {
    if (path.row >= [self.steps count]) {
        return 33;
    }
    ModifiableStep *step = [self.steps objectAtIndex:path.row];
    if (step.amount) {
        return 33;
    } else {
        CGSize size = [step.text sizeWithFont:[UIFont fontWithName:@"tabitha" size:16] constrainedToSize:CGSizeMake(233, 4000) lineBreakMode:UILineBreakModeWordWrap];
        return size.height + 12;
    }
}

#pragma mark - email
- (NSString *)stringForRecipeMail {
    
    NSMutableString *tableString = [[NSMutableString alloc] init];
    
    [tableString appendString:@"<table width=\"300\" border=\"0\" cellspacing=\"1\">"];
    [tableString appendString:[NSString stringWithFormat:@"<tr bgcolor=\"#9E8400\"><td colspan=\"2\"><b>%@</b></td></tr>", self.drink.name]];
    NSArray *steps = [[self.drink.steps allObjects] sortedArrayUsingSelector:@selector(compare:)];
    
    for (RecipeStep *step in steps) {
        if (step.stepAmount != nil) {
            [tableString appendString:@"<tr bgcolor=\"#DBBB7E\">"];
            [tableString appendString:[NSString stringWithFormat:@"<td>%@</td>", step.stepTitle]];
            [tableString appendString:[NSString stringWithFormat:@"<td>%@</td>", step.stepAmount]];
            [tableString appendString:@"</tr>"];
        } else {
            [tableString appendString:@"<tr bgcolor=\"#F1D5A1\">"];
            [tableString appendString:[NSString stringWithFormat:@"<td colspan=\"2\">%@</td>", step.stepTitle]];
            [tableString appendString:@"</tr>"];
        }
        
        
    }
    
    [tableString appendString:@"</table>"];

    return tableString;
}

- (IBAction)emailRecipe:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
		controller.mailComposeDelegate = self;
        [controller setSubject:[NSString stringWithFormat:@"Liquor Cabinet: %@", self.drink.name]];
		[controller setMessageBody:[NSString stringWithFormat:@"<p>%@</p>Check out Liquor Cabinet!", [self stringForRecipeMail]] isHTML:YES];
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        [window.rootViewController presentModalViewController:controller animated:YES];
    }
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [window.rootViewController dismissModalViewControllerAnimated:YES];
    
    NSString *message;
	NSString *title;
    if (result != MFMailComposeResultCancelled) {
        if (error) {
            title = NSLocalizedString(@"Email failed to send", @"EMAIL_FAILURE_TITLE");
            message = [error description];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Ok", @"OK_BUTTON")
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    
    if (self.shouldEditOnStart) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - notes
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.notesToolbar.transform = CGAffineTransformMakeTranslation(0, -keyboard_height);
        self.notesView.transform = CGAffineTransformMakeTranslation(120, -300);
        
    }];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.notesToolbar.transform = CGAffineTransformIdentity;
        self.notesView.transform = CGAffineTransformMakeRotation(.15);
        
    }];
}

- (IBAction)saveNote:(id)sender {
    [self.notesTextView resignFirstResponder];
    
    self.drink.notes = self.notesTextView.text;
    
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate saveContext];
}

- (IBAction)clearNote:(id)sender {
    self.notesTextView.text = @"";
}

- (IBAction)cancelNote:(id)sender {
    [self.notesTextView resignFirstResponder];
    self.notesTextView.text = self.drink.notes;
}

#pragma mark - more info
- (IBAction)showInstructions:(id)sender {
    DrinkInstructionsViewController *controller = [[DrinkInstructionsViewController alloc] initWithNibName:@"DrinkInstructionsViewController" bundle:nil];
    controller.instructions = self.drink.instructions;
    [self.navigationController pushViewController:controller animated:YES];
}
#pragma mark - favorite
- (IBAction)toggleFavorite:(id)sender {
    if ([self.drink.favorite boolValue]) {
//        [Flurry logEvent:@"Recipe Unfavorited" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:self.drink.name, @"Recipe Name", nil]];
//        [self.favoriteButton forAllStatesSetImage:[UIImage imageNamed:@"star_empty.png"]];
        [self.favoriteButton forAllStatesSetImage:[[ImageManager sharedImageManager] loadImage:@"star_empty.png"]];
        self.drink.favorite = [NSNumber numberWithBool:NO];
        [[ParseSynchronizer sharedInstance] removeFavorite:self.drink];
    } else {
//        [Flurry logEvent:@"Recipe Favorited" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:self.drink.name, @"Recipe Name", nil]];
//        [self.favoriteButton forAllStatesSetImage:[UIImage imageNamed:@"star_fill.png"]];
        [self.favoriteButton forAllStatesSetImage:[[ImageManager sharedImageManager] loadImage:@"star_fill.png"]];
        self.drink.favorite = [NSNumber numberWithBool:YES];
        [[ParseSynchronizer sharedInstance] addFavorite:self.drink];
    }
    
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate saveContext];
}

- (IBAction)back:(id)sender {
    if (self.navigationDelegate) {
        [self.navigationDelegate performSelector:@selector(dismiss)];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.isEditing) {
        return [self.steps count] + 1;
    } else {
        return [self.steps count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForTextAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RecipeStepTableViewCell";
    RecipeStepTableViewCell *cell = (RecipeStepTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.typeLabel.font = [UIFont fontWithName:@"tabitha" size:16];
        cell.amountLabel.font = [UIFont fontWithName:@"tabitha" size:16];
        cell.noAmountInstructionLabel.font = [UIFont fontWithName:@"tabitha" size:16];
    }
    
    // Configure the cell.
    if (indexPath.row == [self.steps count]) {
        cell.noAmountInstructionLabel.text = @"Add New Step";
        cell.typeLabel.hidden = YES;
        cell.amountLabel.hidden = YES;
        cell.noAmountInstructionLabel.hidden = NO;
        cell.checkBoxImageView.image = nil;
    } else {
        ModifiableStep *step = [self.steps objectAtIndex:indexPath.row];
        if (step.amount == nil) {
            cell.noAmountInstructionLabel.numberOfLines = 0;
            
            cell.noAmountInstructionLabel.text = step.text;
            CGSize size = [step.text sizeWithFont:[UIFont fontWithName:@"tabitha" size:16] constrainedToSize:CGSizeMake(233, 4000) lineBreakMode:UILineBreakModeWordWrap];
            cell.noAmountInstructionLabel.frame = CGRectMake(36, 6, 233, size.height);
            cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, size.height + 12);
            cell.typeLabel.hidden = YES;
            cell.amountLabel.hidden = YES;
            cell.noAmountInstructionLabel.hidden = NO;
        } else {
            cell.typeLabel.text = step.text;
            cell.amountLabel.text = step.amount;
            cell.typeLabel.hidden = NO;
            cell.amountLabel.hidden = NO;
            cell.noAmountInstructionLabel.hidden = YES;
        }
        
        if ([[self.checkedSteps objectAtIndex:indexPath.row] boolValue]) {
//            cell.checkBoxImageView.image = [UIImage imageNamed:@"checkbox.png"];
            cell.checkBoxImageView.image = [[ImageManager sharedImageManager] loadImage:@"checkbox.png"];
        } else {
//            cell.checkBoxImageView.image = [UIImage imageNamed:@"blankbox.png"];
            cell.checkBoxImageView.image = [[ImageManager sharedImageManager] loadImage:@"blankbox.png"];
        }
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [self.steps count]) {
        return;
    }
        
    if (tableView.isEditing) {
        [self.drinkNameField resignFirstResponder];
        self.drinkName = self.drinkNameField.text;
        ModifiableStep *step = [self.steps objectAtIndex:indexPath.row];
        stepController_ = [[EditRecipeStepViewController alloc] initWithNibName:@"EditRecipeStepViewController" bundle:nil];
        stepController_.delegate = self;
        stepController_.stepText = step.text;
        stepController_.stepAmount = step.amount;
        stepController_.stepIndex = indexPath.row;
        navController_ = [[UINavigationController alloc] initWithRootViewController:stepController_];
        navController_.navigationBarHidden = YES;
        navController_.view.alpha = 0;
        navController_.view.transform = CGAffineTransformMakeTranslation(0, -20); //Account for Navbar trying to compensate for status bar
        [self.view addSubview:navController_.view];
        
        [UIView animateWithDuration:0.25 animations:^(void) {
            navController_.view.alpha = 1;
        }];
    } else {
        RecipeStepTableViewCell *cell = (RecipeStepTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        if ([[self.checkedSteps objectAtIndex:indexPath.row] boolValue]) {
            [self.checkedSteps replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
//            cell.checkBoxImageView.image = [UIImage imageNamed:@"blankbox.png"];
            cell.checkBoxImageView.image = [[ImageManager sharedImageManager] loadImage:@"blankbox.png"];
        } else {
            [self.checkedSteps replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
//            cell.checkBoxImageView.image = [UIImage imageNamed:@"checkbox.png"];
            cell.checkBoxImageView.image = [[ImageManager sharedImageManager] loadImage:@"checkbox.png"];
        }
	}
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.stepsScrollView setEditing:editing animated:animated];
    
    NSArray *paths = [NSArray arrayWithObject:
                      [NSIndexPath indexPathForRow:[self.steps count] inSection:0]];
    if (editing) {
        [self.stepsScrollView insertRowsAtIndexPaths:paths
                                withRowAnimation:UITableViewRowAnimationRight];
    } else {
        [self.stepsScrollView deleteRowsAtIndexPaths:paths
                                withRowAnimation:UITableViewRowAnimationRight];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!tableView.isEditing) {
        return UITableViewCellEditingStyleNone;
    } else if (indexPath.row == [self.steps count]) {
        return UITableViewCellEditingStyleInsert;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [self.steps count]) {
        return NO;
    } else {
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    ModifiableStep *step = [self.steps objectAtIndex:fromIndexPath.row];
    [self.steps removeObjectAtIndex:fromIndexPath.row];
    [self.steps insertObject:step atIndex:toIndexPath.row];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ModifiableStep *step = [self.steps objectAtIndex:indexPath.row];
        if (step.amount) {
            BOOL shouldRemove = YES;
            
            for (int i = 0; i < [self.steps count]; i++) {
                if (i != indexPath.row) {
                    ModifiableStep *testStep = [self.steps objectAtIndex:i];
                    if ([testStep.text isEqualToString:step.text]) {
                        shouldRemove = NO;
                        break;
                    }
                }
            }
            
            if (shouldRemove) {
                LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
                NSArray *ingredients = [delegate listOfIngredients:[NSPredicate predicateWithFormat:@"name == %@", step.text]];
                DrinkIngredient *ingredient = [ingredients lastObject];
                if ([self.ingredients containsObject:ingredient]) {
                    [self.ingredients removeObject:ingredient];
                }
            }
        }
        [self.steps removeObjectAtIndex:indexPath.row];
        NSArray *paths = [NSArray arrayWithObject:
                          indexPath];
        [self.stepsScrollView deleteRowsAtIndexPaths:paths
                                    withRowAnimation:UITableViewRowAnimationRight];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self.drinkNameField resignFirstResponder];
        self.drinkName = self.drinkNameField.text;
        stepController_ = [[EditRecipeStepViewController alloc] initWithNibName:@"EditRecipeStepViewController" bundle:nil];
        stepController_.delegate = self;
        
        navController_ = [[UINavigationController alloc] initWithRootViewController:stepController_];
        navController_.navigationBarHidden = YES;
        navController_.view.alpha = 0;
        navController_.view.transform = CGAffineTransformMakeTranslation(0, -20); //Account for Navbar trying to compensate for status bar
        [self.view addSubview:navController_.view];
        
        [UIView animateWithDuration:0.25 animations:^(void) {
            navController_.view.alpha = 1;
        }];
    }
}

#pragma mark - restocking
- (IBAction)restockIngredients:(id)sender {
//    [Flurry logEvent:@"Restocked Ingredients from Recipe Page"];
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    int numberRestocked = 0;
    int numberInCart = 0;
    for (DrinkIngredient *ingredient in self.drink.ingredients) {
        if (![delegate.currentCabinet cabinetContainsIngredient:ingredient]) {
            if (![ingredient.shoppingCart boolValue]) {
                numberRestocked++;
                ingredient.shoppingCart = [NSNumber numberWithBool:YES];
            } else {
                numberInCart++;
            }
        }
    }
    
    NSSet *garnishes = self.drink.garnishes;
    for (DrinkGarnish *garnish in garnishes) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", garnish.name];
        NSArray *ingredients = [delegate listOfIngredients:predicate];
        
        if ([ingredients count] != 1) {
            NSLog(@"ERROR: no match for %@", garnish.name);
        } else {
            DrinkIngredient *ingredient = [ingredients objectAtIndex:0];
            if (![delegate.currentCabinet cabinetContainsIngredient:ingredient]) {
                if (![ingredient.shoppingCart boolValue]) {
                    numberRestocked++;
                    ingredient.shoppingCart = [NSNumber numberWithBool:YES];
                } else {
                    numberInCart++;
                }
            }
        }
    }
    
    
    if (numberRestocked != 0 || numberInCart != 0) {
        [delegate saveContext];
        
        [[ParseSynchronizer sharedInstance] updateShoppingList];
        NSString *message = nil;
        
        if (numberRestocked != 0 && numberInCart == 0) {
            message = [NSString stringWithFormat:NSLocalizedString(@"%d items have been added to your restocking list.", @"ITEMS_ADDED_RESTOCK_MESSAGE"), numberRestocked];
        } else if (numberRestocked != 0 && numberInCart != 0) {
            message = [NSString stringWithFormat:NSLocalizedString(@"%d items have been added to your restocking list, %d items are already there.", @"ITEMS_ADDED_SOME_NOT_RESTOCK_MESSAGE"), numberRestocked, numberInCart];
        } else {
            message = [NSString stringWithFormat:NSLocalizedString(@"%d items are already in your restocking list.", @"ITEMS_NOT_ADDED_RESTOCK_MESSAGE"), numberInCart];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Restocked", @"RESTOCK_TITLE") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", @"OK_BUTTON") otherButtonTitles: nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Nothing to Restock", @"NOTHING_RESTOCK_TITLE") message:NSLocalizedString(@"You already have all the necessary ingredients. There is nothing you need to restock.", @"NOTHING_RESTOCK_MESSAGE") delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", @"OK_BUTTON") otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark - glass information
- (IBAction)showGlassInformation:(id)sender {
    if (!self.stepsScrollView.isEditing) {
        [UIView animateWithDuration:0.2 animations:^(void){
            self.glassNameView.alpha = 1;
        }];
    }
}

- (IBAction)hideGlassInformation:(id)sender {
    [UIView animateWithDuration:0.2 animations:^(void){
        self.glassNameView.alpha = 0;
    }];
}

#pragma mark - tips

- (IBAction)toggleTips:(id)sender {
    
    if (CGAffineTransformIsIdentity(self.tipsView.transform)) {
        [self openTips];
    } else {
        [self closeTips];
    }
}

- (void)openTips {
    [UIView animateWithDuration:0.35 animations:^(void){
        self.tipsView.transform = CGAffineTransformMakeTranslation(0, -self.tipsView.frame.origin.y);
        self.tipsRibbonView.transform = CGAffineTransformMakeTranslation(0, 26);
    } completion:^(BOOL finished){
        self.tipsView.isOpen = YES;
        [UIView animateWithDuration:0.25 animations:^(void){
            self.tipsView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        }];
    }];
}

- (void)closeTips {
    [UIView animateWithDuration:0.25 animations:^(void){
        self.tipsView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        
    } completion:^(BOOL finished){
        self.tipsView.isOpen = NO;
        [UIView animateWithDuration:0.35 animations:^(void){
            self.tipsView.transform = CGAffineTransformIdentity;
            self.tipsRibbonView.transform = CGAffineTransformIdentity;
        }];
    }];
}

- (void)refreshInterface {
    self.drinkNameField.text = self.drinkName;
    if ([self.categories count] != 0) {
        NSMutableString *categoriesString = [NSMutableString string];
        BOOL first = YES;
        for (DrinkCategory *category in self.categories) {
            if (first) {
                first = NO;
                [categoriesString appendString:category.name];
            } else {
                [categoriesString appendFormat:@", %@", category.name];
            }
        }
        self.categoryLabel.text = categoriesString;
    } else {
        self.categoryLabel.text = @"No Categories Set";
    }
    
    
    if ([self.drink.favorite boolValue]) {
//        [self.favoriteButton forAllStatesSetImage:[UIImage imageNamed:@"star_fill.png"]];
        [self.favoriteButton forAllStatesSetImage:[[ImageManager sharedImageManager] loadImage:@"star_fill.png"]];
    } else {
//        [self.favoriteButton forAllStatesSetImage:[UIImage imageNamed:@"star_empty.png"]];
        [self.favoriteButton forAllStatesSetImage:[[ImageManager sharedImageManager] loadImage:@"star_empty.png"]];
    }
    
    self.notesTextView.text = self.drink.notes;
    self.notesTextView.delegate = self;
    
    NSString *glassName = [[self.glass.name stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
    NSString *drinkImageName = [NSString stringWithFormat:@"%@.png", glassName];
//    UIImage *image = [UIImage imageNamed:drinkImageName];
    UIImage *image = [[ImageManager sharedImageManager] loadImage:drinkImageName];
    
    self.glassImageView.image = image;
    self.glassNameLabel.text = self.glass.name;
    
    
    if (![self.information isEqualToString:@""] && self.information != nil) {
        self.tipsView.hidden = NO;
        self.tipsTextView.text = self.information;
        self.tipsDrinkNameLabel.text = [self.drinkName uppercaseString];
    } else {
        self.tipsView.hidden = YES;
    }
    [self.stepsScrollView reloadData];
}

- (void)updateViewWithDrink:(DrinkRecipe *)drink {
    self.drink = drink;
    self.drinkName = self.drink.name;
    
    self.categories = [self.drink.categories allObjects];
    
    NSArray *managedSteps = [[self.drink.steps allObjects] sortedArrayUsingSelector:@selector(compare:)];
    
    self.steps = [[NSMutableArray alloc] initWithCapacity:[managedSteps count]];
    for (RecipeStep *step in managedSteps) {
        ModifiableStep *mStep = [[ModifiableStep alloc] init];
        mStep.text = step.stepTitle;
        mStep.amount = step.stepAmount;
        [self.steps addObject:mStep];
    }
    
    self.checkedSteps = [NSMutableArray arrayWithCapacity:[self.steps count]];
    for (int i = 0; i < [self.steps count]; i++) {
        [self.checkedSteps addObject:[NSNumber numberWithBool:NO]];
    }
    
    self.glass = self.drink.glass;
    self.information = self.drink.information;
    self.ingredients = [NSMutableArray arrayWithArray:[self.drink.ingredients allObjects]];
    
    [self refreshInterface];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([UIScreen mainScreen].bounds.size.height == 568) {
//        self.backgroundImageView.image = [UIImage imageNamed:@"wood-568h.png"];
        self.backgroundImageView.image = [[ImageManager sharedImageManager] loadImage:@"wood-568h.png"];
    }
    
    self.drinkNameField.font = [UIFont fontWithName:@"HoneyScript-SemiBold" size:36];
    self.backButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.emailButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:15];
    self.restockButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:15];
    self.notesTextView.font = [UIFont fontWithName:@"Post Note" size:24];
    self.tipsTextView.font = [UIFont fontWithName:@"Baskerville" size:16];
    self.cancelEditingButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:17];
    self.saveEditingButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:17];
    self.glassNameLabel.font = [UIFont fontWithName:@"tabitha" size:15];
    self.glassNameView.layer.cornerRadius = 3;
    self.notesView.transform = CGAffineTransformMakeRotation(.15);
    
    if (self.shouldEditOnStart) {
        [self enterEditMode:nil];
        [self refreshInterface];
    } else {
        [self updateViewWithDrink:self.drink];
    }
    
    keyboard_height=0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    self.yourNotesView.frame = CGRectMake(-30, (self.view.bounds.size.height/2)+50, 252, 251);
    
    self.restockButton.frame = CGRectMake(178, (self.view.bounds.size.height/2)+94, 127, 36);
    
    //cancelBarButtonItem
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [negativeSpacer setWidth:-5];
    
    //int height = self.view.bounds.size.height - (self.view.bounds.size.height/4)-5;
    
    int height = (self.view.bounds.size.height/4) * 3 - 6;
    
    self.stepsScrollView.frame = CGRectMake(20, 82, 280, height);

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
    [self setTipsView:nil];
    [self setTipsTextView:nil];
    [self setTipsRibbonView:nil];
    [self setTipsDrinkNameLabel:nil];
    [self setEditButtonPanel:nil];
    [self setToggleEditButton:nil];
    [self setCancelEditingButton:nil];
    [self setSaveEditingButton:nil];
    [self setDrinkNameField:nil];
    self.backButton = nil;
    self.emailButton = nil;
    self.restockButton = nil;
    self.glassImageView = nil;
    self.categoryLabel = nil;
    self.favoriteButton = nil;
    self.notesView = nil;
    self.notesTextView = nil;
    self.notesToolbar = nil;
    self.stepsScrollView = nil;
    self.glassNameView = nil;
    self.glassNameLabel = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Editing

- (IBAction)enterEditMode:(id)sender {
    //move buttons and notes out
    [self setEditing:YES animated:!self.shouldEditOnStart];
    
    self.drinkNameField.enabled = YES;
    
    if (self.shouldEditOnStart) {
        self.backButton.transform = CGAffineTransformTranslate(self.backButton.transform, -60, 0);
        self.emailButton.transform = CGAffineTransformTranslate(self.emailButton.transform, 67, 0);
        self.favoriteButton.transform = CGAffineTransformTranslate(self.favoriteButton.transform, 67, 0);
        self.toggleEditButton.transform = CGAffineTransformTranslate(self.toggleEditButton.transform, 67, 0);
        self.notesView.transform = CGAffineTransformTranslate(self.notesView.transform, 0, 100);
        self.restockButton.transform = CGAffineTransformTranslate(self.restockButton.transform, 0, 100);
        self.tipsView.transform = CGAffineTransformTranslate(self.tipsView.transform, 0, 100);
        self.editButtonPanel.transform = CGAffineTransformTranslate(self.editButtonPanel.transform, -320, 0);
    } else {
        [UIView animateWithDuration:0.25 animations:^(void){
            self.backButton.transform = CGAffineTransformTranslate(self.backButton.transform, -60, 0);
            self.emailButton.transform = CGAffineTransformTranslate(self.emailButton.transform, 67, 0);
            self.favoriteButton.transform = CGAffineTransformTranslate(self.favoriteButton.transform, 67, 0);
            self.toggleEditButton.transform = CGAffineTransformTranslate(self.toggleEditButton.transform, 67, 0);
            self.notesView.transform = CGAffineTransformTranslate(self.notesView.transform, 0, 100);
            self.restockButton.transform = CGAffineTransformTranslate(self.restockButton.transform, 0, 100);
            self.tipsView.transform = CGAffineTransformTranslate(self.tipsView.transform, 0, 100);
            
        } completion:^(BOOL completed) {
            [UIView animateWithDuration:0.25 animations:^(){
                self.editButtonPanel.transform = CGAffineTransformTranslate(self.editButtonPanel.transform, -320, 0);
            }];
        }];
    }
}

- (void)exitEditMode {
    [self setEditing:NO animated:YES];
    self.drinkNameField.enabled = NO;
    [UIView animateWithDuration:0.25 animations:^(void){
        self.editButtonPanel.transform = CGAffineTransformTranslate(self.editButtonPanel.transform, 320, 0);
    } completion:^(BOOL completed) {
        [UIView animateWithDuration:0.25 animations:^(){
            self.backButton.transform = CGAffineTransformTranslate(self.backButton.transform, 60, 0);
            self.emailButton.transform = CGAffineTransformTranslate(self.emailButton.transform, -67, 0);
            self.favoriteButton.transform = CGAffineTransformTranslate(self.favoriteButton.transform, -67, 0);
            self.toggleEditButton.transform = CGAffineTransformTranslate(self.toggleEditButton.transform, -67, 0);
            self.notesView.transform = CGAffineTransformTranslate(self.notesView.transform, 0, -100);
            self.restockButton.transform = CGAffineTransformTranslate(self.restockButton.transform, 0, -100);
            self.tipsView.transform = CGAffineTransformTranslate(self.tipsView.transform, 0, -100);
        }];
    }];
}

- (IBAction)cancelEdit:(id)sender {
    if (self.shouldEditOnStart) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self updateViewWithDrink:self.drink];
        [self exitEditMode];
    }
}

- (IBAction)saveEdit:(id)sender {
    if ([self.drinkName isEqualToString:@""] || [self.steps count] == 0 || [self.categories count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Drink" message:@"Sorry, this is not a valid drink. Either the Drink Name is not set, there are no steps assigned or there are no categories given for the drink." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    if ([self.drinkName isEqualToString:self.drink.name]) {
//        [Flurry logEvent:@"Edited an Existing Drink Recipe" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:self.drink.name, @"name", [self stringForRecipeMail], @"recipe", nil]];
        self.drink.categories = [NSSet setWithArray:self.categories];
        self.drink.glass = self.glass;
        self.drink.ingredients = [NSSet setWithArray:self.ingredients];
        
        NSMutableSet *stepsSet = [NSMutableSet set];
        
        for (int i = 0; i < [self.steps count]; i++) {
            ModifiableStep *oldStep = [self.steps objectAtIndex:i];
            RecipeStep *newStep = [RecipeStep recipeStepWithIndex:i title:oldStep.text andAmount:oldStep.amount inContext:delegate.managedObjectContext];
            [stepsSet addObject:newStep];
        }
        
        self.drink.steps = stepsSet;
        self.drink.edited = [NSNumber numberWithBool:YES];
        
    } else {
//        [Flurry logEvent:@"Created a New Drink Recipe" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:self.drink.name, @"name", [self stringForRecipeMail], @"recipe", nil]];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DrinkRecipe"];
        
        fetchRequest.fetchLimit = 1;
        fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"drinkID" ascending:NO]];
        
        NSError *error = nil;
        
        DrinkRecipe *largestDrink = (DrinkRecipe *)[delegate.managedObjectContext executeFetchRequest:fetchRequest error:&error].lastObject;
        
        int drinkID = [largestDrink.drinkID intValue] + 1;
        
        if (drinkID < 10000) {
            drinkID = 10000;
        }
        
        DrinkRecipe *newDrink = [DrinkRecipe drinkRecipeWithID:[NSNumber numberWithInt:drinkID] andName:self.drinkName inContext:delegate.managedObjectContext];
        self.drink = newDrink;
        
        self.drink.categories = [NSSet setWithArray:self.categories];
        self.drink.glass = self.glass;
        self.drink.ingredients = [NSSet setWithArray:self.ingredients];
        
        NSMutableSet *stepsSet = [NSMutableSet set];
        
        for (int i = 0; i < [self.steps count]; i++) {
            ModifiableStep *oldStep = [self.steps objectAtIndex:i];
            RecipeStep *newStep = [RecipeStep recipeStepWithIndex:i title:oldStep.text andAmount:oldStep.amount inContext:delegate.managedObjectContext];
            [stepsSet addObject:newStep];
        }
        
        self.drink.steps = stepsSet;
        self.drink.edited = [NSNumber numberWithBool:YES];
        [[ParseSynchronizer sharedInstance] addDrinkRecipe:self.drink];
    }
    
    [delegate saveContext];
    
    if (!self.shouldEditOnStart) {
        [self updateViewWithDrink:self.drink];
        [self exitEditMode];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notify Developers?" message:@"Would you like to let the developers know of your changes? Maybe your version will be included in the future!" delegate:self cancelButtonTitle:@"No, Thanks" otherButtonTitles:@"Yes, Please", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            [controller setToRecipients:[NSArray arrayWithObjects:@"appdev@thirdrailplatform.com",nil]];
            [controller setSubject:[NSString stringWithFormat:@"Recipe Suggestion: %@", self.drink.name]];
            [controller setMessageBody:[NSString stringWithFormat:@"Here's a recipe I'd like you to review:<p>%@</p>", [self stringForRecipeMail]] isHTML:YES];
            UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
            [window.rootViewController presentModalViewController:controller animated:YES];
        }
    } else {
        if (self.shouldEditOnStart) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.drinkNameField resignFirstResponder];
    self.drinkName = textField.text;
    
    return YES;
}

- (IBAction)editGlassInfo:(id)sender {
    if (self.stepsScrollView.isEditing) {
        [self.drinkNameField resignFirstResponder];
        self.drinkName = self.drinkNameField.text;
        LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
        glassController_ = [[GlassListViewController alloc] initWithNibName:@"GlassListViewController" bundle:nil];
        glassController_.glasses = [delegate listOfGlasses:nil];
        glassController_.selectedGlass = self.glass;
        glassController_.delegate = self;
        
        navController_ = [[UINavigationController alloc] initWithRootViewController:glassController_];
        navController_.navigationBarHidden = YES;
        navController_.view.alpha = 0;
        navController_.view.transform = CGAffineTransformMakeTranslation(0, -20); //Account for Navbar trying to compensate for status bar
        [self.view addSubview:navController_.view];
        
        [UIView animateWithDuration:0.25 animations:^(void) {
            navController_.view.alpha = 1;
        }];
    }
}

- (IBAction)editCategories:(id)sender {
    if (self.stepsScrollView.isEditing) {
        [self.drinkNameField resignFirstResponder];
        self.drinkName = self.drinkNameField.text;
        LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
        categoriesController_ = [[EditCategoriesViewController alloc] initWithNibName:@"EditCategoriesViewController" bundle:nil];
        categoriesController_.categories = [delegate listOfCategories:nil];
        categoriesController_.selectedCategories = [NSMutableArray arrayWithArray:self.categories];
        categoriesController_.delegate = self;
        
        navController_ = [[UINavigationController alloc] initWithRootViewController:categoriesController_];
        navController_.navigationBarHidden = YES;
        navController_.view.alpha = 0;
        navController_.view.transform = CGAffineTransformMakeTranslation(0, -20); //Account for Navbar trying to compensate for status bar
        [self.view addSubview:navController_.view];
        
        [UIView animateWithDuration:0.25 animations:^(void) {
            navController_.view.alpha = 1;
        }];
    }
}

- (void)controller:(GlassListViewController *)controller didSelectGlass:(DrinkGlass *)glass {
    [UIView animateWithDuration:0.25 animations:^(void) {
        navController_.view.alpha = 0;
    } completion:^(BOOL completed){
        [navController_.view removeFromSuperview];
        navController_ = nil;
    }];
    
    self.glass = glass;
    
    NSString *glassName = [[self.glass.name stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
    NSString *drinkImageName = [NSString stringWithFormat:@"%@.png", glassName];
//    UIImage *image = [UIImage imageNamed:drinkImageName];
    UIImage *image = [[ImageManager sharedImageManager] loadImage:drinkImageName];
    self.glassImageView.image = image;
    self.glassNameLabel.text = self.glass.name;
}

- (void)controller:(EditCategoriesViewController *)controller didSelectCategories:(NSArray *)categories {
    [UIView animateWithDuration:0.25 animations:^(void) {
        navController_.view.alpha = 0;
    } completion:^(BOOL completed){
        [navController_.view removeFromSuperview];
        navController_ = nil;
    }];
    
    self.categories = categories;
    
    NSMutableString *categoriesString = [NSMutableString string];
    BOOL first = YES;
    for (DrinkCategory *category in self.categories) {
        if (first) {
            first = NO;
            [categoriesString appendString:category.name];
        } else {
            [categoriesString appendFormat:@", %@", category.name];
        }
    }
    self.categoryLabel.text = categoriesString;
}

- (void)cancelRecipeStepViewController:(EditRecipeStepViewController *)controller {
    [UIView animateWithDuration:0.25 animations:^(void) {
        navController_.view.alpha = 0;
    } completion:^(BOOL completed){
        [navController_.view removeFromSuperview];
        navController_ = nil;
    }];
}

- (void)recipeStepViewController:(EditRecipeStepViewController *)controller didCreateNewStepWithtext:(NSString *)text andAmount:(NSString *)amount {
    ModifiableStep *newStep = [[ModifiableStep alloc] init];
    newStep.amount = amount;
    newStep.text = text;
    
    if (self.steps == nil) {
        self.steps = [NSMutableArray array];
    }
    
    [self.steps addObject:newStep];
    [self.checkedSteps addObject:[NSNumber numberWithBool:NO]];
    
    [self.stepsScrollView reloadData];
    
    if (amount) {
        LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
        NSArray *ingredients = [delegate listOfIngredients:[NSPredicate predicateWithFormat:@"name == %@", text]];
        DrinkIngredient *ingredient = [ingredients lastObject];
        if (![self.ingredients containsObject:ingredient]) {
            if (self.ingredients == nil) {
                self.ingredients = [NSMutableArray array];
            }
            [self.ingredients addObject:ingredient];
        }
    }
    
    [UIView animateWithDuration:0.25 animations:^(void) {
        navController_.view.alpha = 0;
    } completion:^(BOOL completed){
        [navController_.view removeFromSuperview];
        navController_ = nil;
    }];
}

- (void)recipeStepViewController:(EditRecipeStepViewController *)controller didEditStepAtIndex:(int)index withText:(NSString *)text andAmount:(NSString *)amount {
    
    ModifiableStep *step = [self.steps objectAtIndex:index];
    
    if (amount && ![step.text isEqualToString:text]) {
        //Add new if necessary
        LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
        NSArray *ingredients = [delegate listOfIngredients:[NSPredicate predicateWithFormat:@"name == %@", text]];
        DrinkIngredient *ingredient = [ingredients lastObject];
        if (![self.ingredients containsObject:ingredient]) {
            [self.ingredients addObject:ingredient];
        }
        
        //Remove old if necessary
        BOOL shouldRemove = YES;
        
        for (int i = 0; i < [self.steps count]; i++) {
            if (i != index) {
                ModifiableStep *testStep = [self.steps objectAtIndex:i];
                if ([testStep.text isEqualToString:step.text]) {
                    shouldRemove = NO;
                    break;
                }
            }
        }
        
        if (shouldRemove) {
            ingredients = [delegate listOfIngredients:[NSPredicate predicateWithFormat:@"name == %@", step.text]];
            ingredient = [ingredients lastObject];
            if ([self.ingredients containsObject:ingredient]) {
                [self.ingredients removeObject:ingredient];
            }
        }
    }
    
    step.amount = amount;
    step.text = text;
    [self.stepsScrollView reloadData];
    [UIView animateWithDuration:0.25 animations:^(void) {
        navController_.view.alpha = 0;
    } completion:^(BOOL completed){
        [navController_.view removeFromSuperview];
        navController_ = nil;
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification {

    keyboard_height=[notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height+15;

}

@end
