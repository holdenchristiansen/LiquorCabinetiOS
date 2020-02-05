//
//  GlassListViewController.h
//  LiquorCabinet
//
//  Created by Mark Powell on 9/14/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DrinkGlass;
@class GlassListViewController;

@protocol GlassListViewDelegate <NSObject>

- (void)controller:(GlassListViewController *)controller didSelectGlass:(DrinkGlass *)glass;

@end

@interface GlassListViewController : UIViewController

@property (weak, nonatomic) id <GlassListViewDelegate> delegate;
@property (nonatomic, copy) NSArray *glasses;
@property (nonatomic, strong) DrinkGlass *selectedGlass;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *glassTitle;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;

- (IBAction)selectedGlass:(id)sender;

@end
