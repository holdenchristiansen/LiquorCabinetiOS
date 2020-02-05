//
//  CategoryListViewController.m
//  LiquorCabinet
//
//  Created by Mark Powell on 9/14/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import "CategoryListViewController.h"

#import "DrinkCategory.h"
#import "DrinkListViewController.h"
#import "DrinkRecipeDetailViewController.h"
#import "IngredientFilterListViewController.h"
#import "LiquorCabinetAppDelegate.h"
//#import "Flurry.h"

@interface CategoryListViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)setSearchButtonAlpha:(NSString *)string;
@end

@implementation CategoryListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.categories == nil) {
        LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
        self.categories = [delegate listOfCategories:nil];
    }
    
    self.titleLabel.font = [UIFont fontWithName:@"HoneyScript-SemiBold" size:42];
    self.startFilteringLabel.font = [UIFont fontWithName:@"tabitha" size:20];
    self.createButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:17];
    self.tableView.separatorColor = [UIColor grayColor];
    self.queue = [[NSOperationQueue alloc] init];
    
    /*
     * 16/01/2016 - David Rojas - WAM Digital (CR)
     * These 2 lines set the table view's index color and background
     */
    [[self tableView] setSectionIndexColor:[UIColor grayColor]];
    [[self tableView] setSectionIndexBackgroundColor:[UIColor clearColor]];
    
    [self.searchTextField addTarget:self
                             action:@selector(editingChanged:)
                   forControlEvents:UIControlEventEditingChanged];
}

-(void) editingChanged:(id)sender {
    if(self.searchTextField.text.length > 0){
        [self.searchAllDrinksLabel setHidden:YES];
    }else{
        [self.searchAllDrinksLabel setHidden:NO];
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

#pragma mark - searchbar
#pragma mark - search
- (IBAction)search:(id)sender {
    [self searchForDrinkWithTerm:self.searchTextField.text];
    [self.searchTextField resignFirstResponder];
}

- (IBAction)clearSearchField:(id)sender {
    self.searchTextField.text = nil;
    [self setSearchButtonAlpha:self.searchTextField.text];
    [self.searchTextField resignFirstResponder];
    [self.searchAllDrinksLabel setHidden:NO];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self setSearchButtonAlpha:string];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField { 
    [self searchForDrinkWithTerm:textField.text];
    [textField resignFirstResponder];
    return YES;
}

- (void)setSearchButtonAlpha:(NSString *)string {
    if (string != nil && ![string isEqualToString:@""]) {
        [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^(void) {
            self.searchButton.alpha = 1;
            self.clearSearchButton.alpha = 1;
        } completion:^(BOOL finished){}];
            
    } else {
        [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^(void) {
            self.searchButton.alpha = 0;
            self.clearSearchButton.alpha = 0;
        } completion:^(BOOL finished){}];
    }
}
- (void)searchForDrinkWithTerm:(NSString *)term {
//    [Flurry logEvent:@"Search" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:term, @"Search Term", nil]];
    DrinkListViewController *controller = [[DrinkListViewController alloc] initWithNibName:@"DrinkListViewController" bundle:nil];
    controller.showFilterList = YES;
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSMutableArray *predicates = [NSMutableArray array];
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"name CONTAINS[c] %@", term];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"ANY ingredients.name CONTAINS[c] %@", term];
    NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"instructions CONTAINS[c] %@", term];
    NSPredicate *predicate4 = [NSPredicate predicateWithFormat:@"notes CONTAINS[c] %@", term];
    [predicates addObjectsFromArray:[NSArray arrayWithObjects:predicate1, predicate2, predicate3, predicate4, nil]];
    
    
    NSPredicate *fetchPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
    NSArray *drinks = [delegate listOfDrinks:fetchPredicate];
    controller.drinks = drinks;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)addIngredientFilter:(DrinkIngredient *)ingredient {
//    [Flurry logEvent:@"Selecting Ingredients to filter drinks list"];
    if (ingredient != nil) {
        DrinkListViewController *controller = [[DrinkListViewController alloc] initWithNibName:@"DrinkListViewController" bundle:nil];
        controller.showFilterList = YES;
        controller.ingredientFilters = [NSMutableArray arrayWithObject:ingredient];
        
        LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
        NSArray *drinkAliases = [ingredient drinkAliasesInContext:delegate.managedObjectContext];
        NSMutableArray *subPredicateArray = [NSMutableArray array];
        for (NSString *alias in drinkAliases) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY ingredients.name = %@ OR ANY garnishes.name = %@", alias, alias];
            [subPredicateArray addObject:predicate];
        }
        NSPredicate *subPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:subPredicateArray];
        
        NSArray *drinks = [delegate listOfDrinks:subPredicate];
        controller.drinks = drinks;
        
        [self.navigationController pushViewController:controller animated:YES];
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)startFiltering:(id)sender {
    
    IngredientFilterListViewController *controller = [[IngredientFilterListViewController alloc] initWithNibName:@"IngredientFilterListViewController" bundle:nil];
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    NSArray *baseIngredients = [delegate listOfIngredients:[NSPredicate predicateWithFormat:@"secondaryName = nil"]];
    
    controller.ingredients = baseIngredients;
    controller.delegate = self;
    [self presentModalViewController:controller animated:YES];
}

- (IBAction)createNewDrink:(id)sender {
    DrinkRecipeDetailViewController *controller = [[DrinkRecipeDetailViewController alloc] initWithNibName:@"DrinkRecipeDetailViewController" bundle:nil];
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    NSArray *glasses = [delegate listOfGlasses:[NSPredicate predicateWithFormat:@"name = 'Any Glass'"]];
    DrinkGlass *anyGlass = [glasses objectAtIndex:0];
    controller.glass = anyGlass;
    controller.shouldEditOnStart = YES;
    
    [self.navigationController pushViewController:controller animated:YES];
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.categories count] + 1;
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
    }
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIActivityIndicatorView *activityView = 
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView startAnimating];
    [cell setAccessoryView:activityView];
    
    if (indexPath.row == 0) {
        [self.queue addOperation:[NSBlockOperation blockOperationWithBlock:^(void){
            @autoreleasepool {
                LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
                NSArray *drinks = [delegate listOfDrinks:nil];
                
                [[NSOperationQueue mainQueue] addOperation:[NSBlockOperation blockOperationWithBlock:^(void){
                    DrinkListViewController *controller = [[DrinkListViewController alloc] initWithNibName:@"DrinkListViewController" bundle:nil];
                    controller.showFilterList = YES;
                    controller.drinks = drinks;
                    [self.navigationController pushViewController:controller animated:YES];
                    [activityView stopAnimating];
                    cell.accessoryView = nil;
                }]];
            }
        }]];
    } else {
        [self.queue addOperation:[NSBlockOperation blockOperationWithBlock:^(void){
            @autoreleasepool {
                DrinkCategory *category = (DrinkCategory *)[self.categories objectAtIndex:indexPath.row - 1];
                NSArray *drinks = [category.drinks allObjects];
                
                [[NSOperationQueue mainQueue] addOperation:[NSBlockOperation blockOperationWithBlock:^(void){
                    DrinkListViewController *controller = [[DrinkListViewController alloc] initWithNibName:@"DrinkListViewController" bundle:nil];
                    controller.showFilterList = YES;
                    controller.drinks = drinks;
                    controller.drinksTitle = category.name;
                    [self.navigationController pushViewController:controller animated:YES];
                    [activityView stopAnimating];
                    cell.accessoryView = nil;
                }]];
            }
        }]];
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
    [self setCreateButton:nil];
    [super viewDidUnload];
    
    self.tableView = nil;
    self.titleLabel = nil;
    self.startFilteringLabel = nil;
    self.searchTextField = nil;
    self.searchButton = nil;
    self.clearSearchButton = nil;

}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"All", @"ALL_CELL_TITLE");
        cell.imageView.image = nil;
    } else {
        DrinkCategory *managedObject = [self.categories objectAtIndex:indexPath.row - 1];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)", managedObject.name, [managedObject.drinks count]];
        cell.imageView.image = nil;
    }
    
}
@end
