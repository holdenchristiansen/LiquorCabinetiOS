//
//  EditCategoriesViewController.h
//  LiquorCabinet
//
//  Created by Mark Powell on 10/22/12.
//  Copyright (c) 2012 Lavacado Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditCategoriesViewController;

@protocol EditCategoriesViewDelegate <NSObject>

- (void)controller:(EditCategoriesViewController *)controller didSelectCategories:(NSArray *)categories;

@end

@interface EditCategoriesViewController : UIViewController

@property (weak, nonatomic) id <EditCategoriesViewDelegate> delegate;
@property (nonatomic, copy) NSArray *categories;
@property (nonatomic, strong) NSMutableArray *selectedCategories;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *categoriesTitle;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;

- (IBAction)selectedCategories:(id)sender;

@end
