//
//  FavoritesListViewController.h
//  LiquorCabinet
//
//  Created by Mark Powell on 9/15/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlphabetizedIndexedTableViewController.h"
@interface FavoritesListViewController : AlphabetizedIndexedTableViewController
@property (nonatomic, strong) IBOutlet UIImageView *leftBorderLineImageView;
@property (nonatomic, strong) IBOutlet UILabel *noFavoritesLabel;
@property (nonatomic, copy) NSArray *drinks;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIButton *restockButton;
@property (nonatomic, strong) IBOutlet UIButton *commitButton;
@property (nonatomic, strong) NSMutableArray *changedDrinks;

- (IBAction)restock:(id)sender;
- (IBAction)commitChanges:(id)sender;

@end
