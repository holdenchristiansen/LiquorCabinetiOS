//
//  GlassListViewController.m
//  LiquorCabinet
//
//  Created by Mark Powell on 9/14/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import "GlassListViewController.h"
#import "ImageManager.h"
#import "DrinkGlass.h"
#import "DrinkListViewController.h"

@interface GlassListViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation GlassListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.glassTitle.font = [UIFont fontWithName:@"HoneyScript-SemiBold" size:48];
    self.doneButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:24];
    
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
    return [self.glasses count];
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
        UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separatorline.png"]];
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
    self.selectedGlass = [self.glasses objectAtIndex:indexPath.row];
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
    [self setGlassTitle:nil];
    [self setDoneButton:nil];
    [super viewDidUnload];
    
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *managedObject = [self.glasses objectAtIndex:indexPath.row];
    cell.textLabel.text = [[managedObject valueForKey:@"name"] description];
    NSString *glassName = [[cell.textLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
    NSString *drinkImageName = [NSString stringWithFormat:@"%@.png", glassName];
//    UIImage *image = [UIImage imageNamed:drinkImageName];
    UIImage *image = [UIImage imageNamed:[[ImageManager sharedImageManager] loadImage:drinkImageName]];
    for (id subview in cell.contentView.subviews) {
        if ([subview tag] == 9) {
            UIImageView *imageView = (UIImageView *)subview;
            imageView.image = image;
        }
    }
    
    if (managedObject == self.selectedGlass) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
    } else {
        cell.accessoryView = nil;
    }
}

- (IBAction)selectedGlass:(id)sender {
    [self.delegate controller:self didSelectGlass:self.selectedGlass];
}
@end
