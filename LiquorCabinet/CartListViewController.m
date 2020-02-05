//
//  CartListViewController.m
//  LiquorCabinet
//
//  Created by Mark Powell on 9/15/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import "CartListViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Cabinet.h"
#import "DrinkIngredient.h"
#import "LiquorCabinetAppDelegate.h"
#import "ShoppingListViewController.h"
#import "UIButton+TitleSetting.h"
//#import "Flurry.h"
#import "ParseSynchronizer.h"
#import "ImageManager.h"

@interface CartListViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)updateRemoveButton;
@end

@implementation CartListViewController

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}


- (void)updateListOfIngredients {
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    NSPredicate *predicate = nil;
    if ([self.filterType isEqualToString:@"ALL"]) {
        //keep it nil, no filtering
        [self.allIngredientsButton forAllStatesSetTitleColor:[UIColor blackColor]];
        [self.mixerIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.liquorIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.garnishIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
    } else if ([self.filterType isEqualToString:@"LIQUOR"]) {
        predicate = [NSPredicate predicateWithFormat:@"type == \"LIQUOR\""];
        [self.allIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.mixerIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.liquorIngredientsButton forAllStatesSetTitleColor:[UIColor blackColor]];
        [self.garnishIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
    } else if ([self.filterType isEqualToString:@"MIXER"]) {
        predicate = [NSPredicate predicateWithFormat:@"type == \"MIXER\""];
        [self.allIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.mixerIngredientsButton forAllStatesSetTitleColor:[UIColor blackColor]];
        [self.liquorIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.garnishIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
    } else if ([self.filterType isEqualToString:@"GARNISH"]) {
        predicate = [NSPredicate predicateWithFormat:@"type == \"GARNISH\""];
        [self.allIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.mixerIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.liquorIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.garnishIngredientsButton forAllStatesSetTitleColor:[UIColor blackColor]];
    }
    
    NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"shoppingCart == %@", [NSNumber numberWithBool: YES]];
    NSArray *predicates = [NSArray arrayWithObjects:fetchPredicate, predicate, nil];
    NSPredicate *shoppingPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates]; 
    
    self.ingredients = [NSMutableArray arrayWithArray:[delegate listOfIngredients:shoppingPredicate]];
    
    [self generateSectionHeadersAndContentGroups];
    [self.tableView reloadData];
    
    if ([self.ingredients count] == 0) {
        self.noItemsLabel.hidden = NO;
        self.noItemsLabel.layer.cornerRadius = 5;
        self.noItemsLabel.font = [UIFont fontWithName:@"tabitha" size:24];
    } else {
        self.noItemsLabel.hidden = YES;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.font = [UIFont fontWithName:@"HoneyScript-SemiBold" size:42];
    self.allIngredientsButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.mixerIngredientsButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.liquorIngredientsButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.garnishIngredientsButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.tableView.separatorColor = [UIColor grayColor];
    self.addButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.clearButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.clearButton.alpha = 0;
    self.clearButton.frame = CGRectMake(-53,43,51,24);
    self.leftTitleBarImageView.frame = CGRectMake(20, 54, 99, 1);
    self.filterType = @"ALL";
    [self updateListOfIngredients];
    [self updateRemoveButton];
    
    /*
     * 16/01/2016 - David Rojas - WAM Digital (CR)
     * These 2 lines set the table view's index color and background
     */
    [[self tableView] setSectionIndexColor:[UIColor grayColor]];
    [[self tableView] setSectionIndexBackgroundColor:[UIColor clearColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateListOfIngredients];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)updateRemoveButton {
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"scratchedOffShoppingCart == %@", [NSNumber numberWithBool: YES]];
    NSArray *array = [delegate listOfIngredients:fetchPredicate];
    
    if ([array count] == 0) {
        //hide remove
        [UIView animateWithDuration:0.25 animations:^(void)
         {
             self.clearButton.alpha = 0;
             self.clearButton.frame = CGRectMake(-53,43,51,24);
             self.leftTitleBarImageView.frame = CGRectMake(20, 54, 99, 1);
         }];
    } else {
        [UIView animateWithDuration:0.25 animations:^(void)
         {
             self.clearButton.alpha = 1;
             self.clearButton.frame = CGRectMake(13, 43, 51, 24);
             self.leftTitleBarImageView.frame = CGRectMake(72, 54, 47, 1);
         }];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 0) {
        [self removePurchasedItems:(buttonIndex != alertView.cancelButtonIndex)];
    } else if (alertView.tag == 1) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            NSArray *content = [self.sections objectAtIndex:self.currentDeletePath.section];
            DrinkIngredient *ingredient = [[self.alphabetizedContent objectForKey:content] objectAtIndex:self.currentDeletePath.row];
            ingredient.scratchedOffShoppingCart = [NSNumber numberWithBool:NO];
            ingredient.shoppingCart = [NSNumber numberWithBool:NO];
            LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
            [delegate saveContext];
            [self updateListOfIngredients];
            [[ParseSynchronizer sharedInstance] updateShoppingList];
        }
    }
}

- (IBAction)clear:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add to Cabinet?", @"ADD_TO_CABINET_REQUEST_TITLE") message:NSLocalizedString(@"Would you like to add the purchased ingredients to your cabinet?", @"ADD_PURCHASED_ITEMS_TO_CABINET_REQUEST_MESSAGE") delegate:self cancelButtonTitle:NSLocalizedString(@"No, Thanks", @"NO_THANKS_BUTTON") otherButtonTitles:NSLocalizedString(@"Yes!", @"YES_BUTTON"), nil];
    [alertView show];
}

- (void)removePurchasedItems:(BOOL)addToCabinet {
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    
    for (DrinkIngredient *ingredient in self.ingredients) {
        if ([ingredient.scratchedOffShoppingCart boolValue]) {
            ingredient.scratchedOffShoppingCart = [NSNumber numberWithBool:NO];
            ingredient.shoppingCart = [NSNumber numberWithBool:NO];
            if (addToCabinet && ![ingredient.cabinets containsObject:[delegate currentCabinet]]) {
                [ingredient addCabinetsObject:[delegate currentCabinet]];
                [delegate currentCabinet].dirty = [NSNumber numberWithBool:YES];
            }
        }
    }
    
    [delegate saveContext];
    
    [self updateListOfIngredients];
    
    [[ParseSynchronizer sharedInstance] updateShoppingList];
}

- (void)ingredientsAdded {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)addIngredient:(id)sender {
    ShoppingListViewController *controller = [[ShoppingListViewController alloc] initWithNibName:@"ShoppingListViewController" bundle:nil];
    controller.delegate = self;
    [self presentModalViewController:controller animated:YES];
}

- (IBAction)setFilter:(id)sender {
    if ([sender tag] == 0) {
        //keep it nil, no filtering
        self.filterType = @"ALL";
    } else if ([sender tag] == 1) {
        self.filterType = @"LIQUOR";
    } else if ([sender tag] == 2) {
        self.filterType = @"MIXER";
    } else if ([sender tag] == 3) {
        self.filterType = @"GARNISH";
    }
    
    [self updateListOfIngredients];
}


- (int)numberOfContentObjects {
    return [self.ingredients count];
}
- (NSString *)nameOfContentObjectAtIndex:(int)index {
    return [[self.ingredients objectAtIndex:index] name];
}
- (id)contentObjectAtIndex:(int)index {
    return [self.ingredients objectAtIndex:index];
}

// Customize the number of sections in the table view.

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont fontWithName:@"tabitha" size:20];
        
//        UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separatorline.png"]];
        UIImageView *separator = [[UIImageView alloc] initWithImage:[[ImageManager sharedImageManager] loadImage:@"separatorline.png"]];
        separator.frame = CGRectMake(9, cell.contentView.frame.size.height - 1, 263, 1);
        [cell.contentView addSubview:separator];
    }
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [Flurry logEvent:@"Shopping List items scratched off"];
    NSArray *content = [self.sections objectAtIndex:indexPath.section];
    DrinkIngredient *ingredient = [[self.alphabetizedContent objectForKey:content] objectAtIndex:indexPath.row];
    if ([ingredient.scratchedOffShoppingCart boolValue]) {
        ingredient.scratchedOffShoppingCart = [NSNumber numberWithBool:NO];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        for (UIView *scratchView in cell.contentView.subviews) {
            if (scratchView.tag == 33) {
                [scratchView removeFromSuperview];
            }
        }
    } else {
        ingredient.scratchedOffShoppingCart = [NSNumber numberWithBool:YES];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        int random = arc4random() % 5 + 1;
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"line%d.png", random]]];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[[ImageManager sharedImageManager] loadImage:[NSString stringWithFormat:@"line%d.png", random]]];
        imageView.tag = 33;
        [cell.contentView addSubview:imageView];
        imageView.frame = CGRectMake(0, 0, 0, 44);
        [UIView animateWithDuration:.05 animations:^(void){
            imageView.frame = CGRectMake(0, 0, 320, 44);

        }];
    }
    [self updateRemoveButton];
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate saveContext];
    
    [[ParseSynchronizer sharedInstance] updateShoppingList];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete?", @"DELETE_CONFIRM_TITLE") message:NSLocalizedString(@"Do you wish to delete this ingredient without purchasing it?", @"DELETE_CONFIRM_MESSAGE") delegate:self cancelButtonTitle:NSLocalizedString(@"No, Nevermind", @"NO_NEVERMIND") otherButtonTitles:NSLocalizedString(@"Yes, Delete it", @"YES_DELETE"), nil];
        alert.tag = 1;
        self.currentDeletePath = indexPath;
        [alert show];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.noItemsLabel = nil;
    self.addButton = nil;
    self.clearButton = nil;
    self.allIngredientsButton = nil;
    self.liquorIngredientsButton = nil;
    self.mixerIngredientsButton = nil;
    self.garnishIngredientsButton = nil;
    self.titleLabel = nil;
    self.tableView = nil;
    self.leftTitleBarImageView = nil;

}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSArray *content = [self.sections objectAtIndex:indexPath.section];
    DrinkIngredient *managedObject = [[self.alphabetizedContent objectForKey:content] objectAtIndex:indexPath.row];
    cell.textLabel.text = managedObject.name;
    
    if (![managedObject.scratchedOffShoppingCart boolValue]) {
        for (UIView *scratchView in cell.contentView.subviews) {
            if (scratchView.tag == 33) {
                [scratchView removeFromSuperview];
            }
        }
    } else {
        for (UIView *scratchView in cell.contentView.subviews) {
            if (scratchView.tag == 33) {
                return;
            }
        }
        
        int random = arc4random() % 5 + 1;
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"line%d.png", random]]];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[[ImageManager sharedImageManager] loadImage:[NSString stringWithFormat:@"line%d.png", random]]];
        imageView.tag = 33;
        [cell.contentView addSubview:imageView];
        
    }
}
@end
