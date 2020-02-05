//
//  IngredientsListViewController.m
//  LiquorCabinet
//
//  Created by Mark Powell on 9/14/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import "IngredientFilterListViewController.h"
#import "DrinkIngredient.h"
#import "UIButton+TitleSetting.h"

#import "LiquorCabinetAppDelegate.h"

@interface IngredientFilterListViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation IngredientFilterListViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sections = [NSMutableArray array];
    self.alphabetizedContent = [NSMutableDictionary dictionary];
    self.displayedIngredients = [NSMutableArray arrayWithArray:self.ingredients];
    [self generateSectionHeadersAndContentGroups];
    self.titleLabel.font = [UIFont fontWithName:@"HoneyScript-SemiBold" size:42];
    self.allIngredientsButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.mixerIngredientsButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.liquorIngredientsButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.garnishIngredientsButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.backButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.tableView.separatorColor = [UIColor grayColor];
    [self.allIngredientsButton forAllStatesSetTitleColor:[UIColor blackColor]];
    [self.liquorIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
    [self.mixerIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
    [self.garnishIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
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

- (IBAction)back:(id)sender {
    if ([self.delegate respondsToSelector:@selector(addIngredientFilter:)]) {
        [self.delegate performSelector:@selector(addIngredientFilter:) withObject:nil];
    }
}

#pragma mark - Filter

- (IBAction)searchValueChanged:(id)sender {
    self.clearSearchButton.alpha = 1;
    [self updateTableObjects];
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

- (IBAction)setFilter:(id)sender {
    self.filterMode = [sender tag];
    [self updateTableObjects];
}

- (void)updateTableObjects {
    NSString *searchString = self.searchField.text;
    
    NSMutableArray *searchedIngredients = [NSMutableArray array];
    if (searchString != nil && ![searchString isEqualToString:@""]) {
        for (DrinkIngredient *ingredient in self.ingredients) {
            if ([[ingredient.name lowercaseString] rangeOfString:[searchString lowercaseString]].location != NSNotFound) {
                [searchedIngredients addObject:ingredient];
            }
        }
    } else {
        [searchedIngredients addObjectsFromArray:self.ingredients];
    }
    
    if (self.filterMode == 0) {
        [self.displayedIngredients removeAllObjects];
        
        [self.displayedIngredients addObjectsFromArray:searchedIngredients];
        [self generateSectionHeadersAndContentGroups];
        [self.allIngredientsButton forAllStatesSetTitleColor:[UIColor blackColor]];
        [self.mixerIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.liquorIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.garnishIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.tableView reloadData];
    } else if (self.filterMode == 1) {
        [self.displayedIngredients removeAllObjects];
        for (DrinkIngredient *ingredient in searchedIngredients) {
            if ([ingredient.type isEqualToString:@"LIQUOR"]) {
                [self.displayedIngredients addObject:ingredient];
            }
        }
        [self generateSectionHeadersAndContentGroups];
        [self.allIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.mixerIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.liquorIngredientsButton forAllStatesSetTitleColor:[UIColor blackColor]];
        [self.garnishIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.tableView reloadData];
    } else if (self.filterMode == 2) {
        [self.displayedIngredients removeAllObjects];
        for (DrinkIngredient *ingredient in searchedIngredients) {
            if ([ingredient.type isEqualToString:@"MIXER"]) {
                [self.displayedIngredients addObject:ingredient];
            }
        }
        [self generateSectionHeadersAndContentGroups];
        [self.allIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.mixerIngredientsButton forAllStatesSetTitleColor:[UIColor blackColor]];
        [self.liquorIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.garnishIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.tableView reloadData];
    } else if (self.filterMode == 3) {
        [self.displayedIngredients removeAllObjects];
        for (DrinkIngredient *ingredient in searchedIngredients) {
            if ([ingredient.type isEqualToString:@"GARNISH"]) {
                [self.displayedIngredients addObject:ingredient];
            }
        }
        [self generateSectionHeadersAndContentGroups];
        [self.allIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.mixerIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.liquorIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.garnishIngredientsButton forAllStatesSetTitleColor:[UIColor blackColor]];
        [self.tableView reloadData];
    }
}

// Customize the number of sections in the table view.
- (int)numberOfContentObjects {
    return [self.displayedIngredients count];
}

- (NSString *)nameOfContentObjectAtIndex:(int)index {
    return [[self.displayedIngredients objectAtIndex:index] name];
}

- (id)contentObjectAtIndex:(int)index {
    return [self.displayedIngredients objectAtIndex:index];
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
    if ([self.delegate respondsToSelector:@selector(addIngredientFilter:)]) {
        NSArray *content = [self.sections objectAtIndex:indexPath.section];
        DrinkIngredient *managedObject = [[self.alphabetizedContent objectForKey:content] objectAtIndex:indexPath.row];
        [self.delegate performSelector:@selector(addIngredientFilter:) withObject:managedObject];
    }
	
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
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
    self.backButton = nil;
    self.tableView = nil;


}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSArray *content = [self.sections objectAtIndex:indexPath.section];
    DrinkIngredient *managedObject = [[self.alphabetizedContent objectForKey:content] objectAtIndex:indexPath.row];
    cell.textLabel.text = managedObject.name;
}
@end
