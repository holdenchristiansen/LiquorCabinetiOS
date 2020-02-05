//
//  RootViewController.m
//  LiquorCabinet
//
//  Created by Mark Powell on 9/14/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import "DrinkListViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DrinkCategory.h"
#import "DrinkGarnish.h"
#import "DrinkGlass.h"
#import "DrinkIngredient.h"
#import "DrinkRecipe.h"
#import "DrinkRecipeDetailViewController.h"
#import "DrinkListScrollViewController.h"
#import "IngredientFilterListViewController.h"
#import "LiquorCabinetAppDelegate.h"
#import "UIButton+TitleSetting.h"
#import "ImageManager.h"
//#import "Flurry.h"

@interface DrinkListViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)showIngredientsListAnimated:(BOOL)animated;
@end

@implementation DrinkListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.ingredientFilters = [NSMutableArray array];
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.drinksTitle == nil) {
        self.titleLabel.text = NSLocalizedString(@"Drinks", @"DRINKS_NAV_TITLE");
        self.leftTitleLineImageView.hidden = NO;
        self.rightTitleLineImageView.hidden = NO;
    } else {
        self.titleLabel.text = [NSString stringWithFormat:@"%@", self.drinksTitle];
        self.leftTitleLineImageView.hidden = YES;
        self.rightTitleLineImageView.hidden = YES;
    }
    
    if (self.drinks == nil) {
        LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
        self.drinks = [delegate listOfDrinks:nil];
        
    }
    [self generateSectionHeadersAndContentGroups];
    self.ingredientButtons = [NSMutableArray array];
    if ([self.ingredientFilters count] == 0) {
        self.noFilterLabel.hidden = NO;
    } else {
        self.noFilterLabel.hidden = YES;
    }
    
    
    if (self.showFilterList && ([self.drinks count] != 1 || [self.ingredientFilters count] != 0)) {
        if ([self.drinks count] == 1) {
            self.addFilterButton.hidden = YES;
        } else {
            self.addFilterButton.hidden = NO;
        }
    } else {
        self.noFilterLabel.hidden = YES;
        self.addFilterButton.hidden = YES;
    }
    
    self.titleLabel.font = [UIFont fontWithName:@"HoneyScript-SemiBold" size:42];
    self.backButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.noFilterLabel.font = [UIFont fontWithName:@"tabitha" size:20];
    self.tableView.separatorColor = [UIColor grayColor];
    
    if ([self.drinks count] == 0) {
        self.noDrinksLabel.hidden = NO;
        self.noDrinksLabel.layer.cornerRadius = 5;
        self.noDrinksLabel.font = [UIFont fontWithName:@"tabitha" size:24];
    } else {
        self.noDrinksLabel.hidden = YES;
    }
    
    [self updateIngredientButtons];
    
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
    
    self.noDrinksLabel = nil;
    self.titleLabel = nil;
    self.noFilterLabel = nil;
    self.backButton = nil;
    self.addFilterButton = nil;
    self.tableView = nil;
    self.leftTitleLineImageView = nil;
    self.rightTitleLineImageView = nil;
    self.blackBarImageView = nil;

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
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ingredient Filters
- (void)showIngredientsListAnimated:(BOOL)animated {
    IngredientFilterListViewController *controller = [[IngredientFilterListViewController alloc] initWithNibName:@"IngredientFilterListViewController" bundle:nil];
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    NSArray *baseIngredients = [delegate listOfIngredients:[NSPredicate predicateWithFormat:@"secondaryName = nil"]];
    
    NSArray *ingredientsList = [baseIngredients filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY drinks IN %@", self.drinks]];
    
    NSMutableSet *allIngredientsSet = [NSMutableSet setWithArray:ingredientsList];
    NSSet *filterSet = [NSSet setWithArray:self.ingredientFilters];
    
    [allIngredientsSet minusSet:filterSet];
    
    controller.ingredients = [allIngredientsSet allObjects];
    controller.delegate = self;
    [self presentModalViewController:controller animated:animated];
}

- (IBAction)addIngredient:(id)sender {
    [self showIngredientsListAnimated:YES];
}

- (void)addIngredientFilter:(DrinkIngredient *)ingredient {
//    [Flurry logEvent:@"Selecting Ingredients to filter drinks list"];
    
    if (ingredient != nil) {
        if (self.ingredientFilters == nil) {
            self.ingredientFilters = [NSMutableArray array];
        }
        [self.ingredientFilters addObject:ingredient];
        [self updateDrinksWithCurrentFilterList];
        [self updateIngredientButtons];
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)removeIngredientButtonPressed:(id)sender {
    [self.ingredientFilters removeObjectAtIndex:[sender tag]];
    [self updateDrinksWithCurrentFilterList];
    [self updateIngredientButtons];
}

- (void)updateDrinksWithCurrentFilterList {
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    if ([self.ingredientFilters count] == 0) {
        self.drinks = [delegate listOfDrinks:nil];
        [self generateSectionHeadersAndContentGroups];
        [self.tableView reloadData];
    } else {
        NSMutableArray *predicateArray = [NSMutableArray arrayWithCapacity:[self.ingredientFilters count]];
        for (DrinkIngredient *ingredient in self.ingredientFilters) {
            NSArray *drinkAliases = [ingredient drinkAliasesInContext:delegate.managedObjectContext];
            NSMutableArray *subPredicateArray = [NSMutableArray array];
            for (NSString *alias in drinkAliases) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY ingredients.name = %@ OR ANY garnishes.name = %@", alias, alias];
                [subPredicateArray addObject:predicate];
            }
            NSPredicate *subPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:subPredicateArray];
            [predicateArray addObject:subPredicate];
        }
        
        NSPredicate *fetchPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
        self.drinks = [delegate listOfDrinks:fetchPredicate];
        [self generateSectionHeadersAndContentGroups];
        [self.tableView reloadData];
    }
    
    if ([self.drinks count] == 0) {
        self.noDrinksLabel.hidden = NO;
        self.noDrinksLabel.layer.cornerRadius = 5;
        self.noDrinksLabel.font = [UIFont fontWithName:@"tabitha" size:24];
    } else {
        self.noDrinksLabel.hidden = YES;
    }
    
    if ([self.drinks count] == 1) {
        self.addFilterButton.hidden = YES;
    } else {
        self.addFilterButton.hidden = NO;
    }
    
}

- (void)updateIngredientButtons {
    for (UIView *view in self.ingredientButtons) {
        [view removeFromSuperview];
    }
    
    [self.ingredientButtons removeAllObjects];
    
    for (int i = 0; i < [self.ingredientFilters count]; i++) {
        int column = i % 3;
        int row = i / 3;
        DrinkIngredient *ingredient = [self.ingredientFilters objectAtIndex:i];
        CGFloat x = (column * 80) + (5 * (column + 1) + 10);
        CGFloat y = 63 + (row * 25);
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(x, y, 80, 21);
//        [button forAllStatesSetImage:[UIImage imageNamed:@"xbox.png"]];
        [button forAllStatesSetImage:[[ImageManager sharedImageManager] loadImage:@"xbox.png"]];
        [button forAllStatesSetTitle:ingredient.name];
        [button forAllStatesSetTitleColor:[UIColor blackColor]];
        [button setTag:i];
        button.titleLabel.font = [UIFont fontWithName:@"tabitha" size:12];
        button.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        button.titleLabel.minimumFontSize = 8;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button addTarget:self action:@selector(removeIngredientButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        [self.ingredientButtons addObject:button];
    }
    
    if (self.showFilterList) {
        CGFloat y = 0;
        if ([self.ingredientFilters count] > 0) {
            y = (([self.ingredientFilters count] - 1) / 3 * 25);
        }
        [UIView animateWithDuration:0.25 animations:^(void){
            self.tableView.transform = CGAffineTransformMakeTranslation(0, y);
            self.blackBarImageView.transform = CGAffineTransformMakeTranslation(0, y);
        }];
    }
    
    if ([self.ingredientFilters count] == 0) {
        self.noFilterLabel.hidden = NO;
    } else {
        self.noFilterLabel.hidden = YES;
    }
}

// Customize the number of sections in the table view.
- (int)numberOfContentObjects {
    return [self.drinks count];
}
- (NSString *)nameOfContentObjectAtIndex:(int)index {
    return [[self.drinks objectAtIndex:index] name];
}
- (id)contentObjectAtIndex:(int)index {
    return [self.drinks objectAtIndex:index];
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont fontWithName:@"tabitha" size:20];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
        //gray color
        cell.detailTextLabel.textColor = [UIColor grayColor];
//        UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separatorline.png"]];
        UIImageView *separator = [[UIImageView alloc] initWithImage:[[ImageManager sharedImageManager] loadImage:@"separatorline.png"]];
        separator.frame = CGRectMake(9, cell.contentView.frame.size.height - 1, 263, 1);
        [cell.contentView addSubview:separator];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 20, 28)];
        imageView.tag = 9;
        [cell.contentView addSubview:imageView];
        cell.indentationLevel = 3;
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
    NSArray *contentKey = [self.sections objectAtIndex:indexPath.section];
    NSArray *content = [self.alphabetizedContent objectForKey:contentKey];

    NSArray *sortedDrinks = [self.drinks sortedArrayUsingSelector:@selector(compare:)];
    DrinkRecipe *drinkRecipe = [content objectAtIndex:indexPath.row];
    DrinkListScrollViewController *drinkController = [[DrinkListScrollViewController alloc] initWithDrinkList:sortedDrinks initialIndex:[sortedDrinks indexOfObject:drinkRecipe]];
    [self.navigationController pushViewController:drinkController animated:YES];
	
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
   
    NSArray *contentKey = [self.sections objectAtIndex:indexPath.section];
    NSArray *content = [self.alphabetizedContent objectForKey:contentKey];
    
    DrinkRecipe *managedObject = [content objectAtIndex:indexPath.row];
    cell.textLabel.text = managedObject.name;
        
    cell.detailTextLabel.text = [managedObject ingredientsListAsString];
    NSString *glassName = [[managedObject.glass.name stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
    NSString *drinkImageName = [NSString stringWithFormat:@"%@.png", glassName];
//    UIImage *image = [UIImage imageNamed:drinkImageName];
    UIImage *image = [[ImageManager sharedImageManager] loadImage:drinkImageName];
    for (id subview in cell.contentView.subviews) {
        if ([subview tag] == 9) {
            UIImageView *imageView = (UIImageView *)subview;
            imageView.image = image;
        }
    }
}

@end
