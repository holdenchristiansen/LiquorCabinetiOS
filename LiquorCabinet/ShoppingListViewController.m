//
//  ShoppingListViewController.m
//  LiquorCabinet
//
//  Created by Mark Powell on 9/15/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import "ShoppingListViewController.h"

#import "CartListViewController.h"
#import "DrinkIngredient.h"
#import "LiquorCabinetAppDelegate.h"
#import "UIButton+TitleSetting.h"
#import "SubtableExpandButton.h"

@interface ShoppingListViewController (Private)

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation ShoppingListViewController

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    self.expandedItems = [NSMutableArray array];
    self.firstSubIngredients = [NSMutableArray array];
    self.lastSubIngredients = [NSMutableArray array];
    UIBarButtonItem *cartButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cart", @"CART_TITLE") style:UIBarButtonItemStyleBordered target:self action:@selector(showShoppingCart)];
    self.navigationItem.rightBarButtonItem = cartButton;
    
    if (self.ingredients == nil) {
        [self setFilter:nil];
    }
    
    self.titleLabel.font = [UIFont fontWithName:@"HoneyScript-SemiBold" size:42];
    self.allIngredientsButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.allIngredientsButton.titleLabel.textColor = [UIColor blackColor];
    self.mixerIngredientsButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.mixerIngredientsButton.titleLabel.textColor = [UIColor grayColor];
    self.liquorIngredientsButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.liquorIngredientsButton.titleLabel.textColor = [UIColor grayColor];
    self.garnishIngredientsButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.garnishIngredientsButton.titleLabel.textColor = [UIColor grayColor];
    self.tableView.separatorColor = [UIColor grayColor];
    self.doneButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    
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
    [self.tableView reloadData];
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

- (IBAction)done:(id)sender {
    if ([self.delegate respondsToSelector:@selector(ingredientsAdded)]) {
        [self.delegate performSelector:@selector(ingredientsAdded)];
    }
}
#pragma mark - Filter

- (IBAction)setFilter:(id)sender {
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    if ([sender tag] == 0) {
        //keep it nil, no filtering
        [self.allIngredientsButton forAllStatesSetTitleColor:[UIColor blackColor]];
        [self.mixerIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.liquorIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.garnishIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        self.ingredients = [DrinkIngredient allBaseIngredientsInContext:delegate.managedObjectContext forType:nil];
    } else if ([sender tag] == 1) {
        [self.allIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.mixerIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.liquorIngredientsButton forAllStatesSetTitleColor:[UIColor blackColor]];
        [self.garnishIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        self.ingredients = [DrinkIngredient allBaseIngredientsInContext:delegate.managedObjectContext forType:@"LIQUOR"];
    } else if ([sender tag] == 2) {
        [self.allIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.mixerIngredientsButton forAllStatesSetTitleColor:[UIColor blackColor]];
        [self.liquorIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.garnishIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        self.ingredients = [DrinkIngredient allBaseIngredientsInContext:delegate.managedObjectContext forType:@"MIXER"];
    } else if ([sender tag] == 3) {
        [self.allIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.mixerIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.liquorIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.garnishIngredientsButton forAllStatesSetTitleColor:[UIColor blackColor]];
        self.ingredients = [DrinkIngredient allBaseIngredientsInContext:delegate.managedObjectContext forType:@"GARNISH"];
    }
    [self.expandedItems removeAllObjects];
    [self.firstSubIngredients removeAllObjects];
    [self.lastSubIngredients removeAllObjects];
    [self generateSectionHeadersAndContentGroups];
    [self.tableView reloadData];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

// Customize the number of sections in the table view.
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
    DrinkIngredient *ingredient = [content objectAtIndex:sender.cellPath.row];
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    BOOL isOpen = [self.expandedItems containsObject:ingredient];
    
    if (isOpen) {
        if (![ingredient.shoppingCart boolValue] && [ingredient hasADerivedIngredientInShoppingCart:delegate.managedObjectContext]) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sender.cellPath];
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cart_fade.png"]];
        }
        
        //remove subingredients and change button
        [self.expandedItems removeObject:ingredient];
        [sender setImage:[UIImage imageNamed:@"expand.png"] forState:UIControlStateNormal];
        
        NSArray *subingredients = [ingredient listOfDerivedIngredients:delegate.managedObjectContext];
        subingredients = [subingredients sortedArrayUsingSelector:@selector(compare:)];
        NSMutableArray *updatedPaths = [NSMutableArray arrayWithCapacity:[subingredients count]];
        int index = sender.cellPath.row + 1;
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
        int index = sender.cellPath.row + 1;
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
        cell.textLabel.font = [UIFont fontWithName:@"tabitha" size:20];
        
        UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separatorline.png"]];
        separator.frame = CGRectMake(9, cell.contentView.frame.size.height - 1, 263, 1);
        [cell.contentView addSubview:separator];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 309, 44)];
        imageView.tag = 33;
        [cell.contentView addSubview:imageView];
        
        SubtableExpandButton *expandButton = [[SubtableExpandButton alloc] initWithFrame:CGRectMake(0, 0, 28, 38)];
        [expandButton setImage:[UIImage imageNamed:@"expand.png"] forState:UIControlStateNormal];
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
    ingredient.shoppingCart = [NSNumber numberWithBool:![ingredient.shoppingCart boolValue]];
    
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (![ingredient.shoppingCart boolValue]) {
        if ([ingredient hasADerivedIngredientInShoppingCart:delegate.managedObjectContext]) {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cart_fade.png"]];
        } else {
            cell.accessoryView = nil;
        }
    } else {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cart.png"]];
    }
    
    [delegate saveContext];
	
//    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.doneButton = nil;
    self.allIngredientsButton = nil;
    self.liquorIngredientsButton = nil;
    self.mixerIngredientsButton = nil;
    self.garnishIngredientsButton = nil;
    self.titleLabel = nil;
    self.tableView = nil;

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
        
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
    
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    NSArray *content = [self.sections objectAtIndex:indexPath.section];
    DrinkIngredient *ingredient = [[self.alphabetizedContent objectForKey:content] objectAtIndex:indexPath.row];
    cell.textLabel.text = ingredient.name;
    
    if ([ingredient.shoppingCart boolValue]) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cart.png"]];
    } else if ([ingredient hasADerivedIngredientInShoppingCart:delegate.managedObjectContext] && ![self.expandedItems containsObject:ingredient]) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cart_fade.png"]];
    } else {
        cell.accessoryView = nil;
    }
    
    if (ingredient.secondaryName == nil) {
        cell.indentationLevel = 2;
        cell.textLabel.text = ingredient.name;
        cell.textLabel.font = [UIFont fontWithName:@"tabitha" size:20];
    } else {
        cell.indentationLevel = 4;
        cell.textLabel.text = ingredient.name;
        cell.textLabel.font = [UIFont fontWithName:@"tabitha" size:16];
    }
    
    SubtableExpandButton *toggleButton = nil;
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[SubtableExpandButton class]]) {
            toggleButton = (SubtableExpandButton *)view;
            toggleButton.cellPath = indexPath;
            break;
        }
    }
    
    if ([ingredient hasChildIngredientsInContext:delegate.managedObjectContext]) {
        toggleButton.hidden = NO;
        
        if ([self.expandedItems containsObject:ingredient]) {
            [toggleButton setImage:[UIImage imageNamed:@"reduce.png"] forState:UIControlStateNormal];
        } else {
            [toggleButton setImage:[UIImage imageNamed:@"expand.png"] forState:UIControlStateNormal];
        }
    } else {
        toggleButton.hidden = YES;
    }
    
}

@end
