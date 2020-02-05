//
//  SmartDrinkListViewController.m
//  LiquorCabinet
//
//  Created by Mark Powell on 10/25/11.
//  Copyright (c) 2011 Lavacado Studios, LLC. All rights reserved.
//

#import "SmartDrinkListViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Cabinet.h"
#import "DrinkCategory.h"
#import "DrinkGlass.h"
#import "DrinkIngredient.h"
#import "DrinkRecipe.h"
#import "DrinkRecipeDetailViewController.h"
#import "DrinkListScrollViewController.h"
#import "IngredientFilterListViewController.h"
#import "LiquorCabinetAppDelegate.h"
#import "SmartListSectionButton.h"
#import "UIButton+TitleSetting.h"
#import "UnderlineLabel.h"
//#import "Flurry.h"

@interface SmartDrinkListViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)generateSectionHeadersAndContentGroups;
@end

@implementation SmartDrinkListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    
    self.sections = [NSMutableArray array];
    self.alphabetizedContent = [NSMutableDictionary dictionary];
    
    if ([self.completeDrinks count] == 0 && [self.ingredients count] == 0) {
        self.mode = kSmartDrinkListModeNone;
        self.noDrinksLabel.hidden = NO;
        self.noDrinksLabel.layer.cornerRadius = 5;
        self.noDrinksLabel.font = [UIFont fontWithName:@"tabitha" size:24];
        [self.completeButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.ingredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        self.completeButton.enabled = NO;
        self.ingredientsButton.enabled = NO;
    } else if ([self.completeDrinks count] == 0) {
        self.mode = kSmartDrinkListModeIngredients;
        self.noDrinksLabel.hidden = YES;
        [self.completeButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.ingredientsButton forAllStatesSetTitleColor:[UIColor blackColor]];
    } else {
        self.mode = kSmartDrinkListModeComplete;
        self.noDrinksLabel.hidden = YES;
        [self.completeButton forAllStatesSetTitleColor:[UIColor blackColor]];
        [self.ingredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
    }
    
    [self generateSectionHeadersAndContentGroups];
    
    self.titleLabel.font = [UIFont fontWithName:@"HoneyScript-SemiBold" size:42];
    self.backButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.completeButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.ingredientsButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.tableView.separatorColor = [UIColor grayColor];
    
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
    self.backButton = nil;
    self.tableView = nil;
    self.completeButton = nil;
    self.ingredientsButton = nil;

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

- (IBAction)setModeToComplete:(id)sender {
    self.mode = kSmartDrinkListModeComplete;
    [self generateSectionHeadersAndContentGroups];
    [self.completeButton forAllStatesSetTitleColor:[UIColor blackColor]];
    [self.ingredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
    [self.tableView reloadData];
    if ([self.sections count] > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (IBAction)setModeToIngredients:(id)sender {
    self.mode = kSmartDrinkListModeIngredients;
    [self generateSectionHeadersAndContentGroups];
    [self.completeButton forAllStatesSetTitleColor:[UIColor grayColor]];
    [self.ingredientsButton forAllStatesSetTitleColor:[UIColor blackColor]];
    [self.tableView reloadData];
    if ([self.almostDrinks count] > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SmartCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
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

#pragma mark - sections generation
- (void)generateSectionHeadersAndContentGroups {
    [self.sections removeAllObjects];
    [self.alphabetizedContent removeAllObjects];
    
    if (self.mode == kSmartDrinkListModeComplete) {
        int number = [self.completeDrinks count];
        for (int i = 0; i < number; i++) {
            NSString *name = [[self.completeDrinks objectAtIndex:i] name];
            if ([name length] > 0) {
                NSString *letter = [[name substringToIndex:1] uppercaseString];
                if (![self.sections containsObject:letter]) {
                    [self.sections addObject:letter];
                }
                
                NSMutableArray *content = [self.alphabetizedContent objectForKey:letter];
                if (content == nil) {
                    content = [NSMutableArray array];
                    [self.alphabetizedContent setObject:content forKey:letter];
                }
                
                [content addObject:[self.completeDrinks objectAtIndex:i]];
                [content sortUsingSelector:@selector(compare:)];
            }
        }
        
        [self.sections sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    } else if (self.mode == kSmartDrinkListModeIngredients) {
        for (NSString *ingredientName in [self.ingredients allKeys]) {
            NSMutableArray *recipes = [self.ingredients objectForKey:ingredientName];
            
            NSString *name = [NSString stringWithFormat:@"%@", ingredientName];
            [self.sections addObject:name];
            
            [recipes sortUsingSelector:@selector(compare:)];
            
            [self.alphabetizedContent setObject:recipes forKey:name];
        }
        [self.sections sortUsingComparator:^NSComparisonResult(NSString *string1, NSString *string2) {
            int value1 = [[self.alphabetizedContent objectForKey:string1] count];
            int value2 = [[self.alphabetizedContent objectForKey:string2] count];
            
            if (value1 > value2) {
                return NSOrderedAscending;
            } if (value1 < value2) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }];
        
        if ([self.almostDrinks count] > 0) {
            [self.sections addObject:NSLocalizedString(@"Missing 2 Ingredients", @"MISSING_2_INGREDIENTS_SECTION_TITLE")];
        }
        [self.alphabetizedContent setObject:[self.almostDrinks sortedArrayUsingSelector:@selector(compare:)] forKey:NSLocalizedString(@"Missing 2 Ingredients", @"MISSING_2_INGREDIENTS_SECTION_TITLE")];
    }
}

- (DrinkIngredient *)drinkIngredientBySectionIndex:(int)index {
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    return [DrinkIngredient ingredientByName:[self.sections objectAtIndex:index] inManagedObjectContext:delegate.managedObjectContext];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex != buttonIndex) {
        LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
        DrinkIngredient *ingredient = [self drinkIngredientBySectionIndex:[alertView tag]];
        
        if (buttonIndex == 1) {
            ingredient.shoppingCart = [NSNumber numberWithBool:YES];
        } else if (buttonIndex == 2) {
//            [Flurry logEvent:@"Added Ingredients based on If You Had"];
            [ingredient addCabinetsObject:[delegate currentCabinet]];
            [delegate currentCabinet].dirty = [NSNumber numberWithBool:YES];
        }
        
        [delegate saveContext];
    }
}

- (void)sectionSelected:(id)sender {
    if ([sender tag] < [self.ingredients count]) {
        DrinkIngredient *ingredient = [self drinkIngredientBySectionIndex:[sender tag]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add Ingredient?", @"ADD_INGREDIENT_REQUEST_TITLE") message:[NSString stringWithFormat:NSLocalizedString(@"%@\n\nWould you like to:", @"ADD_INGREDIENT_REQUEST_MESSAGE"), ingredient.name] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"CANCEL_BUTTON") otherButtonTitles:NSLocalizedString(@"Add to Restocking List", @"ADD_RESTOCK_BUTTON"), NSLocalizedString(@"Add to Cabinet", @"ADD_CABINET_BUTTON"), nil];
        alert.tag = [sender tag];
        [alert show];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    if (self.mode == kSmartDrinkListModeIngredients) {
        
        UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 21)];
        sectionView.backgroundColor = [UIColor clearColor];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:sectionView.frame];
        imageView.image = [UIImage imageNamed:@"gradient_ribbon.png"];
        [sectionView addSubview:imageView];
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, -1, 269, 20)];
        title.text = [self.sections objectAtIndex:section];
        title.font = [UIFont boldSystemFontOfSize:14];
        title.textColor = [UIColor blackColor];
        title.backgroundColor = [UIColor clearColor];
        [sectionView addSubview:title];
        
        UIButton *button = [[UIButton alloc] initWithFrame:sectionView.frame];
        button.tag = section;
        [button addTarget:self action:@selector(sectionSelected:) forControlEvents:UIControlEventTouchUpInside];
        [sectionView addSubview:button];
        
        return sectionView;
    } else if (self.mode == kSmartDrinkListModeComplete) {

        UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 21)];
        sectionView.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:sectionView.frame];
        imageView.image = [UIImage imageNamed:@"gradient_wax.png"];
        [sectionView addSubview:imageView];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(7, 1, 15, 20)];
        title.textAlignment = UITextAlignmentCenter;
        title.text = [self.sections objectAtIndex:section];
        title.font = [UIFont boldSystemFontOfSize:14];
        title.textColor = [UIColor blackColor];
        title.backgroundColor = [UIColor clearColor];
        [sectionView addSubview:title];
        return sectionView;
    }
    
    return nil;
}

// Customize the number of sections in the table view.
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (self.mode == kSmartDrinkListModeComplete) {
        return self.sections;
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString
                                                                             *)title atIndex:(NSInteger)index {
    return [self.sections indexOfObject:title];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *content = [self.alphabetizedContent objectForKey:[self.sections objectAtIndex:section]];
    return [content count];
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
    
    NSArray *sortedDrinks = nil;
    if (self.mode == kSmartDrinkListModeComplete) {
        sortedDrinks = [self.completeDrinks sortedArrayUsingSelector:@selector(compare:)];
    } else if (self.mode == kSmartDrinkListModeIngredients) {
        
        NSMutableArray *allDrinks = [NSMutableArray array];
        
        for (id key in self.sections) {
            [allDrinks addObjectsFromArray:[self.alphabetizedContent objectForKey:key]];
        }
        
        sortedDrinks = allDrinks;
    }
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
        
    if (self.mode == kSmartDrinkListModeComplete || indexPath.section < [self.sections count] - 1) {
        cell.detailTextLabel.text = [managedObject ingredientsListAsString];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
        cell.detailTextLabel.textColor = [UIColor grayColor];
    } else {
        NSMutableString *detailLabel = [NSMutableString stringWithString:@"Missing: "];
        for (DrinkIngredient *ingredient in managedObject.ingredients) {
            if ([self.almostDrinkIngredients containsObject:ingredient.name]) {
                [detailLabel appendFormat:@"%@, ", ingredient.name];
            }
        }
        int length = [detailLabel length];
        NSRange range = NSMakeRange(length - 2, 2);
        [detailLabel replaceCharactersInRange:range withString:@""];
        cell.detailTextLabel.text = detailLabel;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
}

@end

