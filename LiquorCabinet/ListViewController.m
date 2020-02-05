//
//  ListViewController.m
//  LiquorCabinet
//
//  Created by Mark Powell on 10/26/12.
//  Copyright (c) 2012 Lavacado Studios, LLC. All rights reserved.
//

#import "ListViewController.h"
#import "ListManager.h"
#import "ListDrinkViewController.h"
#import "FavoritesListViewController.h"
//#import "Flurry.h"

@interface ListViewController ()

@end

@implementation ListViewController


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
    
    self.titleLabel.font = [UIFont fontWithName:@"HoneyScript-SemiBold" size:42];
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
    self.tableView = nil;
    self.titleLabel = nil;
    
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

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return [[ListManager sharedListManager] listCount];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separatorline.png"]];
        separator.frame = CGRectMake(19, 55, 259, 1);
        [cell.contentView addSubview:separator];
        cell.textLabel.font = [UIFont fontWithName:@"tabitha" size:20];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 50, 50)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tag = 9;
        [cell.contentView addSubview:imageView];
        cell.indentationLevel = 5;
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"Favorites";
        UIImage *image = [UIImage imageNamed:@"fav2.png"];
        for (id subview in cell.contentView.subviews) {
            if ([subview tag] == 9) {
                UIImageView *imageView = (UIImageView *)subview;
                imageView.image = image;
                
                CGRect oldFrame = imageView.frame;
                CGRect newFrame = CGRectMake(oldFrame.origin.x + 5, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
                imageView.frame = newFrame;
            }
        }
    } else {
        NSString *listName = [[ListManager sharedListManager] listNameForIndex:indexPath.row];
        cell.textLabel.text = listName;
        [[ListManager sharedListManager] iconForListNamed:listName completionBlock:^(UIImage *image, NSError *error){
            for (id subview in cell.contentView.subviews) {
                if ([subview tag] == 9) {
                    UIImageView *imageView = (UIImageView *)subview;
                    imageView.image = image;
                    
                    CGRect oldFrame = imageView.frame;
                    CGRect newFrame = CGRectMake(oldFrame.origin.x + 5, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
                    imageView.frame = newFrame;
                }
            }
        }];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
//        [Flurry logEvent:@"Selected List" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"Favorites", @"name", nil]];
        
        FavoritesListViewController *controller = [[FavoritesListViewController alloc] initWithNibName:@"FavoritesListViewController" bundle:nil];
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        NSString *name = [[ListManager sharedListManager] listNameForIndex:indexPath.row];
//        [Flurry logEvent:@"Selected List" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:name, @"name", nil]];
        
        ListDrinkViewController *controller = [[ListDrinkViewController alloc] initWithListName:name];
        [self.navigationController pushViewController:controller animated:YES];
    }
    
}

@end
