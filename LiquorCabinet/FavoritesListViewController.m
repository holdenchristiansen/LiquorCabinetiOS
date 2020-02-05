//
//  FavoritesListViewController.m
//  LiquorCabinet
//
//  Created by Mark Powell on 9/15/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import "FavoritesListViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Cabinet.h"
#import "DrinkGarnish.h"
#import "DrinkIngredient.h"
#import "DrinkRecipe.h"
#import "DrinkRecipeDetailViewController.h"
#import "DrinkListScrollViewController.h"
#import "LiquorCabinetAppDelegate.h"
#import "UIButton+TitleSetting.h"
#import "ParseSynchronizer.h"

@implementation FavoritesListViewController

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
#pragma mark - restock
- (IBAction)restock:(id)sender {
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    int numberRestocked = 0;
    int numberInCart = 0;
    for (DrinkRecipe *drink in self.drinks) {
        for (DrinkIngredient *ingredient in drink.ingredients) {
            if (![delegate.currentCabinet cabinetContainsIngredient:ingredient]) {
                if (![ingredient.shoppingCart boolValue]) {
                    numberRestocked++;
                    ingredient.shoppingCart = [NSNumber numberWithBool:YES];
                } else {
                    numberInCart++;
                }
            }
        }
        
        NSSet *garnishes = drink.garnishes;
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
    }
    
    if (numberRestocked != 0 || numberInCart != 0) {
        [delegate saveContext];
        [[ParseSynchronizer sharedInstance] updateShoppingList];
        NSString *message = nil;
        
        if (numberRestocked != 0 && numberInCart == 0) {
            message = [NSString stringWithFormat:NSLocalizedString(@"%d items have been added to your restocking list.", @"ITEMS_ADDED_RESTOCK_MEESSAGE"), numberRestocked];
        } else if (numberRestocked != 0 && numberInCart != 0) {
            message = [NSString stringWithFormat:NSLocalizedString(@"%d items have been added to your restocking list, %d items are already there.", @"ITEMS_ADDED_SOME_NOT_RESTOCK_MESSAGE"), numberRestocked, numberInCart];
        } else {
            message = [NSString stringWithFormat:NSLocalizedString(@"%d items are already in your restocking list.", @"ITEMS_NOT_ADDED_RESTOCK_MESSAGE"), numberInCart];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Restocked", @"RESTOCK_TITLE") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", @"OK_BUTTON") otherButtonTitles: nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Nothing to Restock", @"NOTHING_RESTOCK_TITLE") message:NSLocalizedString(@"You already have all the necessary ingredients. There is nothing you need to restock.", @"NO_RESTOCK_MESSAGE") delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", @"OK_BUTTON") otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark - remove favorites
- (void)toggleFavorite:(id)sender {
    UIView *contentView = [sender superview];
    UITableViewCell *cell = (UITableViewCell *)[contentView superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSArray *contentKey = [self.sections objectAtIndex:indexPath.section];
    NSArray *content = [self.alphabetizedContent objectForKey:contentKey];
    
    DrinkRecipe *managedObject = [content objectAtIndex:indexPath.row];
    
    UIButton *button = (UIButton *)sender;
    if ([self.changedDrinks containsObject:managedObject]) {
        [self.changedDrinks removeObject:managedObject];
        [[ParseSynchronizer sharedInstance] removeFavorite:managedObject];
    } else {
        [self.changedDrinks addObject:managedObject];
        [button forAllStatesSetBackgroundImage:[UIImage imageNamed:@"star_empty.png"]];
    }
    
    if ([self.changedDrinks count] > 0) {
        [self.commitButton setTitle:@"Commit" forState:UIControlStateNormal];
        [self.commitButton setBackgroundImage:[UIImage imageNamed:@"highlightbox.png"] forState:UIControlStateNormal];
    } else {
        [self.commitButton setTitle:@"Lists" forState:UIControlStateNormal];
        [self.commitButton setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.changedDrinks = [NSMutableArray array];
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"favorite == %@", [NSNumber numberWithBool: YES]];
    self.drinks = [delegate listOfDrinks:fetchPredicate];
    [self generateSectionHeadersAndContentGroups];
    self.titleLabel.font = [UIFont fontWithName:@"HoneyScript-SemiBold" size:42];
    self.tableView.separatorColor = [UIColor grayColor];
    self.restockButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.commitButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    [self.commitButton setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    if ([self.drinks count] == 0) {
        self.noFavoritesLabel.hidden = NO;
        self.noFavoritesLabel.layer.cornerRadius = 5;
        self.noFavoritesLabel.font = [UIFont fontWithName:@"tabitha" size:24];
    } else {
        self.noFavoritesLabel.hidden = YES;
    }
    
    /*
     * 16/01/2016 - David Rojas - WAM Digital (CR)
     * These 2 lines set the table view's index color and background
     */
    [[self tableView] setSectionIndexColor:[UIColor grayColor]];
    [[self tableView] setSectionIndexBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.leftBorderLineImageView = nil;
    self.noFavoritesLabel = nil;
    self.tableView = nil;
    self.titleLabel = nil;
    self.restockButton = nil;
    self.commitButton = nil;

}

- (void)viewWillAppear:(BOOL)animated
{
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"favorite == %@", [NSNumber numberWithBool: YES]];
    self.drinks = [delegate listOfDrinks:fetchPredicate];
    [self generateSectionHeadersAndContentGroups];
    [self.tableView reloadData];
    
    if ([self.drinks count] == 0) {
        self.noFavoritesLabel.hidden = NO;
        self.noFavoritesLabel.layer.cornerRadius = 5;
        self.noFavoritesLabel.font = [UIFont fontWithName:@"tabitha" size:24];
    } else {
        self.noFavoritesLabel.hidden = YES;
    }
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)commitChanges:(id)sender {
    if ([self.changedDrinks count] > 0) {
        for (DrinkRecipe *recipe in self.changedDrinks) {
            recipe.favorite = [NSNumber numberWithBool:NO];
            [[ParseSynchronizer sharedInstance] removeFavorite:recipe];
            
        }
        
        [self.changedDrinks removeAllObjects];
        LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate saveContext];
        NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"favorite == %@", [NSNumber numberWithBool: YES]];
        self.drinks = [delegate listOfDrinks:fetchPredicate];
        [self generateSectionHeadersAndContentGroups];
        [self.tableView reloadData];
        
        if ([self.drinks count] == 0) {
            self.noFavoritesLabel.hidden = NO;
            self.noFavoritesLabel.layer.cornerRadius = 5;
            self.noFavoritesLabel.font = [UIFont fontWithName:@"tabitha" size:24];
        } else {
            self.noFavoritesLabel.hidden = YES;
        }
        [self.commitButton setTitle:@"Lists" forState:UIControlStateNormal];
        [self.commitButton setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - Table view data source

- (int)numberOfContentObjects {
    return [self.drinks count];
}
- (NSString *)nameOfContentObjectAtIndex:(int)index {
    return [[self.drinks objectAtIndex:index] name];
}
- (id)contentObjectAtIndex:(int)index {
    return [self.drinks objectAtIndex:index];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separatorline.png"]];
        separator.frame = CGRectMake(9, cell.contentView.frame.size.height - 1, 263, 1);
        [cell.contentView addSubview:separator];
    }
    
    // Configure the cell...
    NSArray *contentKey = [self.sections objectAtIndex:indexPath.section];
    NSArray *content = [self.alphabetizedContent objectForKey:contentKey];
    
    DrinkRecipe *managedObject = [content objectAtIndex:indexPath.row];
    
    cell.textLabel.text = managedObject.name;
    cell.textLabel.font = [UIFont fontWithName:@"tabitha" size:20];
    cell.detailTextLabel.text = [managedObject ingredientsListAsString];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    NSArray *views = [cell.contentView subviews];
    
    for (UIView *view in views) {
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
    
    if ([self.changedDrinks containsObject:managedObject]) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 35, 33)];
        [button forAllStatesSetBackgroundImage:[UIImage imageNamed:@"star_empty.png"]];
        [button addTarget:self action:@selector(toggleFavorite:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button];
    } else {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 35, 33)];
        [button forAllStatesSetBackgroundImage:[UIImage imageNamed:@"star_fill.png"]];
        [button addTarget:self action:@selector(toggleFavorite:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button];
    }
    cell.indentationLevel = 3;
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *contentKey = [self.sections objectAtIndex:indexPath.section];
    NSArray *content = [self.alphabetizedContent objectForKey:contentKey];
    
    NSArray *sortedDrinks = [self.drinks sortedArrayUsingSelector:@selector(compare:)];
    DrinkRecipe *drinkRecipe = [content objectAtIndex:indexPath.row];
    DrinkListScrollViewController *drinkController = [[DrinkListScrollViewController alloc] initWithDrinkList:sortedDrinks initialIndex:[sortedDrinks indexOfObject:drinkRecipe]];
    [self.navigationController pushViewController:drinkController animated:YES];
    
}

@end
