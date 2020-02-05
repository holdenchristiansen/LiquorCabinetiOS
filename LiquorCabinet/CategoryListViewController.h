//
//  CategoryListViewController.h
//  LiquorCabinet
//
//  Created by Mark Powell on 9/14/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CategoryListViewController : UIViewController <UISearchBarDelegate>

@property (nonatomic, copy) NSArray *categories;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *startFilteringLabel;
@property (nonatomic, strong) IBOutlet UITextField *searchTextField;
@property (nonatomic, strong) IBOutlet UIButton *searchButton;
@property (nonatomic, strong) IBOutlet UIButton *clearSearchButton;
@property (strong, nonatomic) IBOutlet UIButton *createButton;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (weak, nonatomic) IBOutlet UILabel *searchAllDrinksLabel;

- (void)searchForDrinkWithTerm:(NSString *)term;
- (IBAction)search:(id)sender;
- (IBAction)clearSearchField:(id)sender;
- (IBAction)startFiltering:(id)sender;
- (IBAction)createNewDrink:(id)sender;

@end
