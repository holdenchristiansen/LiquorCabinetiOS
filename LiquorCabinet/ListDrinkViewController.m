//
//  ListDrinkViewController.m
//  LiquorCabinet
//
//  Created by Mark Powell on 10/26/12.
//  Copyright (c) 2012 Lavacado Studios, LLC. All rights reserved.
//

#import "ListDrinkViewController.h"

#import "LiquorCabinetAppDelegate.h"
#import "DrinkGlass.h"
#import "DrinkRecipe.h"
#import "DrinkListScrollViewController.h"
#import "ListManager.h"
#import "ImageManager.h"

@interface ListDrinkViewController ()

@end

@implementation ListDrinkViewController

- (id)initWithListName:(NSString *)listName {
    self = [super initWithNibName:@"ListDrinkViewController" bundle:nil];
    
    if (self) {
        _listName = listName;
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self generateSectionHeadersAndContentGroups];
    self.titleLabel.font = [UIFont fontWithName:@"HoneyScript-SemiBold" size:42];
    self.tableView.separatorColor = [UIColor grayColor];
    self.backButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:17];
    self.titleLabel.text = self.listName;
    
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
    self.tableView = nil;
    self.titleLabel = nil;
    self.backButton = nil;
    
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Table view data source

- (int)numberOfContentObjects {
    return [[ListManager sharedListManager] drinkCountForList:self.listName];
}
- (NSString *)nameOfContentObjectAtIndex:(int)index {
    return [[[ListManager sharedListManager] drinkAtIndex:index forList:self.listName] name];
}
- (id)contentObjectAtIndex:(int)index {
    return [[ListManager sharedListManager] drinkAtIndex:index forList:self.listName];
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
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 20, 28)];
        imageView.tag = 9;
        [cell.contentView addSubview:imageView];
        cell.indentationLevel = 3;
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
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *contentKey = [self.sections objectAtIndex:indexPath.section];
    NSArray *content = [self.alphabetizedContent objectForKey:contentKey];
    
    NSArray *sortedDrinks = [[ListManager sharedListManager] allDrinksForList:self.listName];
    DrinkRecipe *drinkRecipe = [content objectAtIndex:indexPath.row];
    DrinkListScrollViewController *drinkController = [[DrinkListScrollViewController alloc] initWithDrinkList:sortedDrinks initialIndex:[sortedDrinks indexOfObject:drinkRecipe]];
    [self.navigationController pushViewController:drinkController animated:YES];
    
}


@end
