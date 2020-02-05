//
//  ListViewController.h
//  LiquorCabinet
//
//  Created by Mark Powell on 10/26/12.
//  Copyright (c) 2012 Lavacado Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlphabetizedIndexedTableViewController.h"

@interface ListViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

@end
