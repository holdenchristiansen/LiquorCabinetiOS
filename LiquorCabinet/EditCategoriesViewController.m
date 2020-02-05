//
//  GlassListViewController.m
//  LiquorCabinet
//
//  Created by Mark Powell on 9/14/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import "EditCategoriesViewController.h"
#import "DrinkCategory.h"
#import "ImageManager.h"

@interface EditCategoriesViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation EditCategoriesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.categoriesTitle.font = [UIFont fontWithName:@"HoneyScript-SemiBold" size:48];
    self.doneButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:24];
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

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.categories count];
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
        cell.detailTextLabel.textColor = [UIColor grayColor];
//        UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separatorline.png"]];
        UIImageView *separator = [[UIImageView alloc] initWithImage:[[ImageManager sharedImageManager] loadImage:@"separatorline.png"]];
        separator.frame = CGRectMake(9, cell.contentView.frame.size.height - 1, 263, 1);
        [cell.contentView addSubview:separator];
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
    DrinkCategory *category = [self.categories objectAtIndex:indexPath.row];
    if ([self.selectedCategories containsObject:category]) {
        [self.selectedCategories removeObject:category];
    } else {
        [self.selectedCategories addObject:category];
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setCategoriesTitle:nil];
    [self setDoneButton:nil];
    [super viewDidUnload];
    
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *managedObject = [self.categories objectAtIndex:indexPath.row];
    cell.textLabel.text = [[managedObject valueForKey:@"name"] description];
    
    if ([self.selectedCategories containsObject:managedObject]) {
//        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
    } else {
        cell.accessoryView = nil;
    }
}

- (IBAction)selectedCategories:(id)sender {
    [self.delegate controller:self didSelectCategories:self.selectedCategories];
}
@end
