//
//  WelcomeViewController.h
//  LiquorCabinet
//
//  Created by Mark Powell on 9/19/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) IBOutlet UILabel *goToCabinetLabel;
@property (nonatomic, strong) IBOutlet UILabel *welcomeLabel;
@property (nonatomic, strong) IBOutlet UITextField *searchTextField;
@property (nonatomic, strong) IBOutlet UIButton *clearSearchButton;
@property (nonatomic, strong) IBOutlet UIButton *searchButton;
@property (nonatomic, strong) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIView *updatingView;
@property (assign, nonatomic) int startingVersion;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *searchAllDrinksLabel;

- (IBAction)gotoCabinet:(id)sender;
- (IBAction)clearSearchField:(id)sender;
- (IBAction)search:(id)sender;

 /* 
  * 16/01/2016 - David Rojas - WAM Digital (CR)
  * I let the logic to login, just in case that in the future the owners will wish to activate it again.
  * I only removed the login button.
  */
- (IBAction)login:(id)sender;
- (void)updateFromWeb;

@end
