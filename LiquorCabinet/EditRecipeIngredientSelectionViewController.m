//
//  EditRecipeIngredientSelectionViewController.m
//  LiquorCabinet
//
//  Created by Mark Powell on 10/23/12.
//  Copyright (c) 2012 Lavacado Studios, LLC. All rights reserved.
//

#import "EditRecipeIngredientSelectionViewController.h"

#import "Cabinet.h"
#import "DrinkIngredient.h"
#import "DrinkListViewController.h"
#import "LiquorCabinetAppDelegate.h"
#import "UIButton+TitleSetting.h"
#import "SubtableExpandButton.h"

@interface EditRecipeIngredientSelectionViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation EditRecipeIngredientSelectionViewController {
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
    self.tableView.separatorColor = [UIColor grayColor];
    
    if (self.ingredients == nil) {
        [self setFilter:nil];
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


- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark_fade.png"]];
        }
        
        //remove subingredients and change button
        [self.expandedItems removeObject:ingredient];
        [sender setImage:[UIImage imageNamed:@"expand.png"] forState:UIControlStateNormal];
        
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
        [sender setImage:[UIImage imageNamed:@"reduce.png"] forState:UIControlStateNormal];
        
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
        
        UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separatorline.png"]];
        separator.frame = CGRectMake(9, cell.contentView.frame.size.height - 1, 263, 1);
        [cell.contentView addSubview:separator];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 309, 44)];
        imageView.tag = 33;
        [cell.contentView addSubview:imageView];
        
        SubtableExpandButton *expandButton = [[SubtableExpandButton alloc] initWithFrame:CGRectMake(4, 0, 28, 38)];
        [expandButton setImage:[UIImage imageNamed:@"expand.png"] forState:UIControlStateNormal];
        [expandButton addTarget:self action:@selector(toggleExpanded:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:expandButton];
    }
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //return to delegate
    if ([self.delegate respondsToSelector:@selector(ingredientSetTo:)]) {
        NSArray *content = [self.sections objectAtIndex:indexPath.section];
        DrinkIngredient *ingredient = [[self.alphabetizedContent objectForKey:content] objectAtIndex:indexPath.row];
        [self.delegate performSelector:@selector(ingredientSetTo:) withObject:ingredient.name];
        [self.navigationController popViewControllerAnimated:YES];
    }
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
                        view.image = [UIImage imageNamed:@"tear_both.png"];
                    }
                }
            } else if (isFirst) {
                for (UIImageView *view in cell.contentView.subviews) {
                    if (view.tag == 33) {
                        view.image = [UIImage imageNamed:@"tear_top.png"];
                    }
                }
            } else if (isLast) {
                for (UIImageView *view in cell.contentView.subviews) {
                    if (view.tag == 33) {
                        view.image = [UIImage imageNamed:@"tear_bottom.png"];
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
                [toggleButton setImage:[UIImage imageNamed:@"reduce.png"] forState:UIControlStateNormal];
            } else {
                [toggleButton setImage:[UIImage imageNamed:@"expand.png"] forState:UIControlStateNormal];
            }
        } else {
            toggleButton.hidden = YES;
        }
        
    }
}
@end
