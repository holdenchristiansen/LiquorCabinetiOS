//
//  WelcomeViewController.m
//  LiquorCabinet
//
//  Created by Mark Powell on 9/19/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import "WelcomeViewController.h"

#import "LiquorCabinetAppDelegate.h"
#import "Cabinet.h"
#import "DrinkRecipe.h"
#import "DrinkCategory.h"
#import "DrinkGarnish.h"
#import "DrinkGlass.h"
#import "DrinkIngredient.h"
#import "RecipeStep.h"
#import "NSString+CSV.h"
#import "LCLogInViewController.h"
#import <Parse/Parse.h>
#import "ParseSynchronizer.h"
#import "ParseCoreDataConverter.h"

#define kUpdateDate @"UpdateDateStore"

@interface WelcomeViewController (Private)

- (void)performSearch;
- (void)setSearchButtonAlpha:(NSString *)string;
- (void)generateDatabaseFromCSVFileToVersion:(NSNumber *)version;
- (void)setIngredientTypeWithCSVRow:(NSArray *)components;

@end

@implementation WelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - search
- (IBAction)search:(id)sender {
    [self performSearch];
    self.clearSearchButton.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^(void){
        self.searchTextField.transform = CGAffineTransformIdentity;
    }];
    [self.searchTextField resignFirstResponder];
}

- (IBAction)clearSearchField:(id)sender {
    self.searchTextField.text = nil;
    [self setSearchButtonAlpha:self.searchTextField.text];
    self.clearSearchButton.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^(void){
        self.searchTextField.transform = CGAffineTransformIdentity;
    }];
    [self.searchTextField resignFirstResponder];
    [self.searchAllDrinksLabel setHidden:NO];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.3 animations:^(void){
        self.searchTextField.transform = CGAffineTransformMakeTranslation(0, -47);
    } completion:^(BOOL finished) {
        self.clearSearchButton.alpha = 1;
    }];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self setSearchButtonAlpha:string];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField { 
    [self performSearch];
    self.clearSearchButton.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^(void){
        self.searchTextField.transform = CGAffineTransformIdentity;
    }];
    [textField resignFirstResponder];
    return YES;
}

- (void)performSearch {
    if (self.searchTextField.text != nil && ![self.searchTextField.text isEqualToString:@""]) {
        LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate searchForDrinkWithTerm:self.searchTextField.text];
    }
}

- (void)setSearchButtonAlpha:(NSString *)string {
    if (string != nil && ![string isEqualToString:@""]) {
        [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^(void) {
            self.searchButton.alpha = 1;
            
        } completion:^(BOOL finished){}];
    } else {
        [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^(void) {
            self.searchButton.alpha = 0;
            
        } completion:^(BOOL finished){}];
    }
}

#pragma mark - update db
#pragma mark - initialize data
#pragma mark - db
- (void)updateFromWeb {
    /*NSDate *checkDate = [[NSUserDefaults standardUserDefaults] objectForKey:kUpdateDate];
    if (checkDate == nil) {
        
        //first run, set default check time
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [df setDateFormat:@"yyyyMMddHHmmss"];
        checkDate = [df dateFromString:@"20130221024500"];
    }
    
    PFQuery *ingredientQuery = [PFQuery queryWithClassName:@"Ingredients"];
    [ingredientQuery whereKey:@"updatedAt" greaterThan:checkDate];
    [ingredientQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [self updateIngredients:objects];
        
        PFQuery *drinkQuery = [PFQuery queryWithClassName:@"DrinkRecipes"];
        [drinkQuery whereKey:@"updatedAt" greaterThan:checkDate];
        [drinkQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            [self updateDrinks:objects];
            
            NSCalendar *cal = [NSCalendar currentCalendar];
            NSDate *now = [NSDate date];
            NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:0];
            [cal setTimeZone:tz];
            NSDateComponents *dc = [cal components: NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:now];
            NSDate *newDate = [cal dateFromComponents:dc];
            [[NSUserDefaults standardUserDefaults] setObject:newDate forKey:kUpdateDate];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
        
        LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate saveContext];
        
    }];*/
}

- (IBAction)login:(id)sender {
//    LCLogInViewController *logInController = [[LCLogInViewController alloc] init];
//    logInController.fields = PFLogInFieldsUsernameAndPassword
//    | PFLogInFieldsLogInButton
//    | PFLogInFieldsSignUpButton
//    | PFLogInFieldsPasswordForgotten
//    | PFLogInFieldsFacebook
//    | PFLogInFieldsDismissButton;
//    logInController.facebookPermissions = [NSArray arrayWithObjects:@"publish_stream", nil];
//    logInController.delegate = self;
//    [self presentModalViewController:logInController animated:YES];
}

- (void)updateIngredients:(NSArray *)objects {
    NSLog(@"UPDATE INGREDIENTS: %@", objects);
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    for (PFObject *ingredientData in objects) {
        NSFetchRequest *ingredientRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *ingredientEntity = [NSEntityDescription entityForName:@"DrinkIngredient" inManagedObjectContext:delegate.managedObjectContext];
        [ingredientRequest setEntity:ingredientEntity];
        NSPredicate *ingredientPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"name = \"%@\"", [ingredientData objectForKey:@"INGREDIENT_NAME"]]];
        [ingredientRequest setPredicate:ingredientPredicate];
        NSArray *ingredientResults = [delegate.managedObjectContext executeFetchRequest:ingredientRequest error:nil];
        
        DrinkIngredient *ingredient = nil;
        
        if ([ingredientResults count] == 0) {
            ingredient = [DrinkIngredient drinkIngredientWithName:[ingredientData objectForKey:@"INGREDIENT_NAME"] inContext:delegate.managedObjectContext];
        } else {
            ingredient = [ingredientResults objectAtIndex:0];
        }

        ingredient.type = [ingredientData objectForKey:@"TYPE"];
        ingredient.secondaryName = [ingredientData objectForKey:@"SECONDARY"];
        ingredient.optionalAssetName = [ingredientData objectForKey:@"ASSET_NAME"];
    }
}

- (void)updateDrinks:(NSArray *)objects {
    NSLog(@"UPDATE DRINKS: %@", objects);
    for (PFObject *drinkData in objects) {
        [[ParseCoreDataConverter sharedInstance] convertParseRecipe:drinkData];
    }
}

#pragma mark - go to cabinet
- (IBAction)gotoCabinet:(id)sender {
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate showCabinet];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([UIScreen mainScreen].bounds.size.height == 568) {
        self.backgroundImageView.image = [UIImage imageNamed:@"welcome_back-568h.png"];
        
    }
    
    self.goToCabinetLabel.font = [UIFont fontWithName:@"tabitha" size:19];
    self.welcomeLabel.font = [UIFont fontWithName:@"tabitha" size:15];
    
    self.welcomeLabel.text = NSLocalizedString(@"Welcome to your Liquor Cabinet.\nAdd your spirits to your cabinet to see what kind of cocktails you can make.", @"WELCOME_TEXT");
    
    [UIView animateWithDuration:0.5 animations:^(void){
        self.mainView.alpha = 1;
    }];
    
    self.searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.searchTextField.textAlignment = NSTextAlignmentCenter;
    
    [self.searchTextField addTarget:self
                  action:@selector(editingChanged:)
        forControlEvents:UIControlEventEditingChanged];
    
   /* self.loginButton.hidden = ([PFUser currentUser] != nil);
    if ([PFUser currentUser]) {
        [[ParseSynchronizer sharedInstance] synchronize];
    }*/
    
}

-(void) editingChanged:(id)sender {
    if(self.searchTextField.text.length > 0){
        [self.searchAllDrinksLabel setHidden:YES];
    }else{
        [self.searchAllDrinksLabel setHidden:NO];
    }
}

- (void)viewDidUnload
{
    [self setUpdatingView:nil];
    [self setBackgroundImageView:nil];
    [self setLoginButton:nil];
    [super viewDidUnload];
    self.goToCabinetLabel = nil;
    self.welcomeLabel = nil;
    self.searchTextField = nil;
    self.clearSearchButton = nil;
    self.searchButton = nil;
    self.mainView = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
