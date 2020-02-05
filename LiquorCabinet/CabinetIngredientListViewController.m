//
//  IngredientsListViewController.m
//  LiquorCabinet
//
//  Created by Mark Powell on 9/14/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import "CabinetIngredientListViewController.h"
#import "ImageManager.h"
#import "Cabinet.h"
#import "CustomIngredientViewController.h"
#import "DrinkIngredient.h"
#import "DrinkListViewController.h"
#import "LiquorCabinetAppDelegate.h"
#import "UIButton+TitleSetting.h"
#import "SubtableExpandButton.h"
#import "ParseSynchronizer.h"

@interface CabinetIngredientListViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation CabinetIngredientListViewController {
    CustomIngredientViewController *controller_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.expandedItems = [NSMutableArray array];
    self.firstSubIngredients = [NSMutableArray array];
    self.lastSubIngredients = [NSMutableArray array];
    self.sections = [NSMutableArray array];
    self.alphabetizedContent = [NSMutableDictionary dictionary];
    self.removalArray = [NSMutableArray array];
    self.titleLabel.font = [UIFont fontWithName:@"HoneyScript-SemiBold" size:42];
    self.allIngredientsButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.mixerIngredientsButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.liquorIngredientsButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.garnishIngredientsButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.ownedIngredientsButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.backToCabinetButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.clearItemsButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.tableView.separatorColor = [UIColor grayColor];
    
    if (self.ingredients == nil) {
        [self setFilter:nil];
    }
    
    /*
     * 16/01/2016 - David Rojas - WAM Digital (CR)
     * These 2 lines set the table view's index color and background
     */
    [[self tableView] setSectionIndexColor:[UIColor grayColor]];
    [[self tableView] setSectionIndexBackgroundColor:[UIColor clearColor]];
    
    [self.searchField addTarget:self
                         action:@selector(editingChanged:)
               forControlEvents:UIControlEventEditingChanged];
    
}

-(void) editingChanged:(id)sender {
    if(self.searchField.text.length > 0){
        [self.searchIngredientsLabel setHidden:YES];
    }else{
        [self.searchIngredientsLabel setHidden:NO];
    }
}

- (void)viewDidUnload
{
    [self setSearchField:nil];
    [self setClearSearchButton:nil];
    [super viewDidUnload];
    
    self.titleLabel = nil;
    self.allIngredientsButton = nil;
    self.liquorIngredientsButton = nil;
    self.mixerIngredientsButton = nil;
    self.garnishIngredientsButton = nil;
    self.ownedIngredientsButton = nil;
    self.backToCabinetButton = nil;
    self.clearItemsButton = nil;
    self.tableView = nil;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 0) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
            for (DrinkIngredient *ingredient in self.removalArray) {
                ingredient.shoppingCart = [NSNumber numberWithBool:YES];
            }
            [delegate saveContext];
        }
        
        if ([self.delegate respondsToSelector:@selector(addIngredients)]) {
            [self.delegate performSelector:@selector(addIngredients)];
        }
    } else if (alertView.tag == 1) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
            Cabinet *cabinet = delegate.currentCabinet;
            [self.removalArray addObjectsFromArray:[cabinet.ingredients allObjects]];
            [cabinet setIngredients:nil];
            [delegate saveContext];
            [self.tableView reloadData];
        }
    }
}

- (IBAction)backToCabinet:(id)sender {
    if ([self.removalArray count] > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add Ingredients to Restock List?", @"ADD_INGREDIENTS_REQUEST_TITLE") message:[NSString stringWithFormat:NSLocalizedString(@"You have selected to remove %d item(s) from your cabinet. Would you like to add these to your list to restock later?", @"ADD_INGREDIENTS_REQUEST_TEXT"), [self.removalArray count]] delegate:self cancelButtonTitle:NSLocalizedString(@"No, Thanks", @"NO_THANKS_BUTTON") otherButtonTitles:NSLocalizedString(@"Yes, Please", @"YES_PLEASE"), nil];
        [alertView show];
    } else {
        if ([self.delegate respondsToSelector:@selector(addIngredients)]) {
            [self.delegate performSelector:@selector(addIngredients)];
        }
    }
}

- (IBAction)searchValueChanged:(id)sender {
    self.clearSearchButton.alpha = 1;
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *searchString = [sender text];
    
    NSString *type = nil;
    
    if (self.filterMode == 1) {
        type = @"LIQUOR";
    } else if (self.filterMode == 2) {
        type = @"MIXER";
    } else if (self.filterMode == 3) {
        type = @"GARNISH";
    }
    
    if (searchString == nil || [searchString isEqualToString:@""]) {
        if (self.filterMode == 4) {
            self.ingredients = [[delegate currentCabinet].ingredients allObjects];
        } else {
            self.ingredients = [DrinkIngredient allBaseIngredientsInContext:delegate.managedObjectContext forType:type];
        }
    } else if (self.filterMode == 4) {
        self.ingredients = [[delegate currentCabinet] ownedIngredientsWithSearchTerm:searchString];
    } else {
       self.ingredients = [DrinkIngredient ingredientsInContext:delegate.managedObjectContext containingString:searchString ofType:type];
    }
    
    [self.expandedItems removeAllObjects];
    [self.firstSubIngredients removeAllObjects];
    [self.lastSubIngredients removeAllObjects];
    [self generateSectionHeadersAndContentGroups];
    [self.tableView reloadData];
}

- (IBAction)dismissSearch:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)clearSearch:(id)sender {
    self.searchField.text = @"";
    [self searchValueChanged:self.searchField];
    [self.searchField resignFirstResponder];
    self.clearSearchButton.alpha = 0;
    [self.searchIngredientsLabel setHidden:NO];
}

- (IBAction)addCustomIngredient:(id)sender {
    CustomIngredientViewController *controller = [[CustomIngredientViewController alloc] init];
    
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    NSArray *baseIngredients = [delegate listOfIngredients:[NSPredicate predicateWithFormat:@"secondaryName = nil"]];
    
    controller.ingredients = baseIngredients;
    controller.delegate = self;
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)customIngredientViewControllerFinished:(CustomIngredientViewController *)controller {
    
    if (controller.createdIngredient) {
        NSMutableArray *working = [NSMutableArray arrayWithArray:self.ingredients];
        [working addObject:controller.createdIngredient];
        self.ingredients = [NSArray arrayWithArray:working];
        [self setFilter:nil];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Filter

- (IBAction)setFilter:(id)sender {
    [self clearSearch:nil];
    
    if (sender != nil) {
        self.filterMode = [sender tag];
    }
    
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    if (self.filterMode == 0) {
        [self.allIngredientsButton forAllStatesSetTitleColor:[UIColor blackColor]];
        [self.mixerIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.liquorIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.garnishIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.ownedIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        self.ingredients = [DrinkIngredient allBaseIngredientsInContext:delegate.managedObjectContext forType:nil];
        
    } else if (self.filterMode == 1) {
        [self.allIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.mixerIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.liquorIngredientsButton forAllStatesSetTitleColor:[UIColor blackColor]];
        [self.garnishIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.ownedIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        self.ingredients = [DrinkIngredient allBaseIngredientsInContext:delegate.managedObjectContext forType:@"LIQUOR"];
    } else if (self.filterMode == 2) {
        [self.allIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.mixerIngredientsButton forAllStatesSetTitleColor:[UIColor blackColor]];
        [self.liquorIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.garnishIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.ownedIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        self.ingredients = [DrinkIngredient allBaseIngredientsInContext:delegate.managedObjectContext forType:@"MIXER"];
    } else if (self.filterMode == 3) {
        [self.allIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.mixerIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.liquorIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.garnishIngredientsButton forAllStatesSetTitleColor:[UIColor blackColor]];
        [self.ownedIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        self.ingredients = [DrinkIngredient allBaseIngredientsInContext:delegate.managedObjectContext forType:@"GARNISH"];
    } else if (self.filterMode == 4) {
        self.ingredients = [[delegate currentCabinet].ingredients allObjects];
        [self.allIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.mixerIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.liquorIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.garnishIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.ownedIngredientsButton forAllStatesSetTitleColor:[UIColor blackColor]];
    }
    [self.expandedItems removeAllObjects];
    [self.firstSubIngredients removeAllObjects];
    [self.lastSubIngredients removeAllObjects];
    [self generateSectionHeadersAndContentGroups];
    [self.tableView reloadData];
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

- (void)toggleExpanded:(SubtableExpandButton *)sender {
    NSString *sectionKey = [self.sections objectAtIndex:sender.cellPath.section];
    NSMutableArray *content = [self.alphabetizedContent objectForKey:sectionKey];
    
    DrinkIngredient *ingredient = sender.drinkIngredient;
    
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    BOOL isOpen = [self.expandedItems containsObject:ingredient];
    
    if (isOpen) {
        if ([ingredient.cabinets count] == 0 && [ingredient hasADerivedIngredientInCabinet:delegate.managedObjectContext]) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sender.cellPath];
//            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark_fade.png"]];
            cell.accessoryView = [[UIImageView alloc] initWithImage:[[ImageManager sharedImageManager] loadImage:@"checkmark_fade.png"]];
        }
        
        //remove subingredients and change button
        [self.expandedItems removeObject:ingredient];
//        [sender setImage:[UIImage imageNamed:@"expand.png"] forState:UIControlStateNormal];
        [sender setImage:[[ImageManager sharedImageManager] loadImage:@"expand.png"] forState:UIControlStateNormal];
        
        NSArray *subingredients = [ingredient listOfDerivedIngredients:delegate.managedObjectContext];
        subingredients = [subingredients sortedArrayUsingSelector:@selector(compare:)];
        NSMutableArray *updatedPaths = [NSMutableArray arrayWithCapacity:[subingredients count]];
        int index = [content indexOfObject:ingredient] + 1;
        for (id subingredient in subingredients) {
            [self.firstSubIngredients removeObject:subingredient];
            [self.lastSubIngredients removeObject:subingredient];
            NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:sender.cellPath.section];
            [updatedPaths addObject:path];
            
            [content removeObject:subingredient];
            index++;
        }
        
        [self.tableView deleteRowsAtIndexPaths:updatedPaths withRowAnimation:UITableViewRowAnimationFade];
    } else {
        if ([ingredient.cabinets count] == 0) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sender.cellPath];
            cell.accessoryView = nil;
        }
        [self.expandedItems addObject:ingredient];
//        [sender setImage:[UIImage imageNamed:@"reduce.png"] forState:UIControlStateNormal];
        [sender setImage:[[ImageManager sharedImageManager] loadImage:@"reduce.png"] forState:UIControlStateNormal];
        
        NSArray *subingredients = [ingredient listOfDerivedIngredients:delegate.managedObjectContext];
        subingredients = [subingredients sortedArrayUsingSelector:@selector(compare:)];
        NSMutableArray *updatedPaths = [NSMutableArray arrayWithCapacity:[subingredients count]];
        [self.firstSubIngredients addObject:[subingredients objectAtIndex:0]];
        [self.lastSubIngredients addObject:[subingredients lastObject]];
        int index = [content indexOfObject:ingredient] + 1;
        for (id subingredient in subingredients) {
            [content insertObject:subingredient atIndex:index];
            NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:sender.cellPath.section];
            [updatedPaths addObject:path];
            index++;
        }
        
        [self.tableView insertRowsAtIndexPaths:updatedPaths withRowAnimation:UITableViewRowAnimationFade];
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
//        UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separatorline.png"]];
        UIImageView *separator = [[UIImageView alloc] initWithImage:[[ImageManager sharedImageManager] loadImage:@"separatorline.png"]];
        separator.frame = CGRectMake(9, cell.contentView.frame.size.height - 1, 263, 1);
        [cell.contentView addSubview:separator];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 309, 44)];
        imageView.tag = 33;
        [cell.contentView addSubview:imageView];
        
        SubtableExpandButton *expandButton = [[SubtableExpandButton alloc] initWithFrame:CGRectMake(4, 0, 28, 38)];
//        [expandButton setImage:[UIImage imageNamed:@"expand.png"] forState:UIControlStateNormal];
        [expandButton setImage:[[ImageManager sharedImageManager] loadImage:@"expand.png"] forState:UIControlStateNormal];
        [expandButton addTarget:self action:@selector(toggleExpanded:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:expandButton];
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
    
    NSArray *content = [self.sections objectAtIndex:indexPath.section];
    DrinkIngredient *ingredient = [[self.alphabetizedContent objectForKey:content] objectAtIndex:indexPath.row];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    if ([ingredient.cabinets count] != 0) {
        [[delegate currentCabinet] removeIngredientsObject:ingredient];
        [[ParseSynchronizer sharedInstance] removeIngredient:ingredient fromCabinet:[delegate currentCabinet]];
        [self.removalArray addObject:ingredient];
        
        if ([ingredient hasADerivedIngredientInCabinet:delegate.managedObjectContext]) {
//            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark_fade.png"]];
            cell.accessoryView = [[UIImageView alloc] initWithImage:[[ImageManager sharedImageManager] loadImage:@"checkmark_fade.png"]];
        } else {
            cell.accessoryView = nil;
        }
    } else {
        [[delegate currentCabinet] addIngredientsObject:ingredient];
        [[ParseSynchronizer sharedInstance] addIngredient:ingredient toCabinet:[delegate currentCabinet]];
        
//        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[[ImageManager sharedImageManager] loadImage:@"checkmark.png"]];
        if ([self.removalArray containsObject:ingredient]) {
            [self.removalArray removeObject:ingredient];
        }
    }
    
    [delegate saveContext];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.filterMode != 4 && [self.searchField.text isEqualToString:@""]) {
        
        NSArray *content = [self.sections objectAtIndex:indexPath.section];
        DrinkIngredient *managedObject = [[self.alphabetizedContent objectForKey:content] objectAtIndex:indexPath.row];
    
        if (managedObject.secondaryName != nil) {
            BOOL isFirst = [self.firstSubIngredients containsObject:managedObject];
            BOOL isLast = [self.lastSubIngredients containsObject:managedObject];
            if (isFirst && isLast) {
                for (UIImageView *view in cell.contentView.subviews) {
                    if (view.tag == 33) {
//                        view.image = [UIImage imageNamed:@"tear_both.png"];
                        view.image = [[ImageManager sharedImageManager] loadImage:@"tear_both.png"];
                    }
                }
            } else if (isFirst) {
                for (UIImageView *view in cell.contentView.subviews) {
                    if (view.tag == 33) {
//                        view.image = [UIImage imageNamed:@"tear_top.png"];
                        view.image = [[ImageManager sharedImageManager] loadImage:@"tear_top.png"];
                    }
                }
            } else if (isLast) {
                for (UIImageView *view in cell.contentView.subviews) {
                    if (view.tag == 33) {
//                        view.image = [UIImage imageNamed:@"tear_bottom.png"];
                        view.image = [[ImageManager sharedImageManager] loadImage:@"tear_bottom.png"];
                    }
                }
            } else {
                for (UIImageView *view in cell.contentView.subviews) {
                    if (view.tag == 33) {
                        view.image = nil;
                    }
                }
                cell.backgroundColor = [UIColor colorWithRed:0.55 green:0.27 blue:0.07 alpha:0.15];
            }
            cell.textLabel.backgroundColor = [UIColor clearColor];
        } else {
            for (UIImageView *view in cell.contentView.subviews) {
                if (view.tag == 33) {
                    view.image = nil;
                }
            }
            cell.backgroundColor = [UIColor clearColor];
        }
    } else {
        for (UIImageView *view in cell.contentView.subviews) {
            if (view.tag == 33) {
                view.image = nil;
            }
        }
        cell.backgroundColor = [UIColor clearColor];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    NSArray *content = [self.sections objectAtIndex:indexPath.section];
    DrinkIngredient *managedObject = [[self.alphabetizedContent objectForKey:content] objectAtIndex:indexPath.row];
    
    if ([managedObject.cabinets count] != 0) {
//        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[[ImageManager sharedImageManager] loadImage:@"checkmark.png"]];
    } else if ([managedObject hasADerivedIngredientInCabinet:delegate.managedObjectContext] && ![self.expandedItems containsObject:managedObject]) {
//        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark_fade.png"]];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[[ImageManager sharedImageManager] loadImage:@"checkmark_fade.png"]];
    } else {
        cell.accessoryView = nil;
    }
    
    
    if (self.filterMode == 4 || ![self.searchField.text isEqualToString:@""]) {
        cell.indentationLevel = 2;
        cell.textLabel.text = managedObject.name;
        cell.textLabel.font = [UIFont fontWithName:@"tabitha" size:20];
        SubtableExpandButton *toggleButton = nil;
        for (UIView *view in cell.contentView.subviews) {
            if ([view isKindOfClass:[SubtableExpandButton class]]) {
                toggleButton = (SubtableExpandButton *)view;
                toggleButton.cellPath = indexPath;
                break;
            }
        }
        
        toggleButton.hidden = YES;
    } else {
    
        if (managedObject.secondaryName == nil) {
            cell.indentationLevel = 2;
            cell.textLabel.text = managedObject.name;
            cell.textLabel.font = [UIFont fontWithName:@"tabitha" size:20];
        } else {
            cell.indentationLevel = 4;
            cell.textLabel.text = managedObject.name;
            cell.textLabel.font = [UIFont fontWithName:@"tabitha" size:16];
        }
        
        SubtableExpandButton *toggleButton = nil;
        for (UIView *view in cell.contentView.subviews) {
            if ([view isKindOfClass:[SubtableExpandButton class]]) {
                toggleButton = (SubtableExpandButton *)view;
                toggleButton.cellPath = indexPath;
                toggleButton.drinkIngredient = managedObject;
                break;
            }
        }
        
        if ([managedObject hasChildIngredientsInContext:delegate.managedObjectContext]) {
            toggleButton.hidden = NO;
            
            if ([self.expandedItems containsObject:managedObject]) {
//                [toggleButton setImage:[UIImage imageNamed:@"reduce.png"] forState:UIControlStateNormal];
                [toggleButton setImage:[[ImageManager sharedImageManager] loadImage:@"reduce.png"] forState:UIControlStateNormal];
            } else {
//                [toggleButton setImage:[UIImage imageNamed:@"expand.png"] forState:UIControlStateNormal];
                [toggleButton setImage:[[ImageManager sharedImageManager] loadImage:@"expand.png"] forState:UIControlStateNormal];
            }
        } else {
            toggleButton.hidden = YES;
        }
    
    }
}
@end
