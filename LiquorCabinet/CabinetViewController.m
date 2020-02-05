//
//  CabinetViewController.m
//  LiquorCabinet
//
//  Created by Mark Powell on 9/15/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import "CabinetViewController.h"

#import "Cabinet.h"
#import "CabinetIngredientViewController.h"
#import "CabinetIngredientListViewController.h"
#import "DrinkGarnish.h"
#import "DrinkIngredient.h"
#import "DrinkListViewController.h"
#import "DrinkRecipe.h"
#import "LiquorCabinetAppDelegate.h"
#import "SmartDrinkListViewController.h"
#import "UIButton+TitleSetting.h"
#import "ImageManager.h"
//#import "Flurry.h"

#define kTutorialShown @"TutorialShown"

static BOOL AccelerationIsShaking(UIAcceleration* last, UIAcceleration* current, double threshold) {
    double
    deltaX = fabs(last.x - current.x),
    deltaY = fabs(last.y - current.y),
    deltaZ = fabs(last.z - current.z);
    
    return
    (deltaX > threshold && deltaY > threshold) ||
    (deltaX > threshold && deltaZ > threshold) ||
    (deltaY > threshold && deltaZ > threshold);
}

@interface CabinetViewController (Private)
- (void)enableIngredients;
- (void)showAllAvailableRecipes:(NSSet *)selectedIngredients;
- (void)buildCabinetStock;
@end

@implementation CabinetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - accelerometer
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
    if (self.lastAcceleration && self.allowShake) {
        if (!self.shakingOccuring && AccelerationIsShaking(self.lastAcceleration, acceleration, 0.7)) {
            self.shakingOccuring = YES;
//            [Flurry logEvent:@"Shaking phone to mix"];
            [self mixSelectedIngredients:nil];
            
        } else if (self.shakingOccuring && !AccelerationIsShaking(self.lastAcceleration, acceleration, 0.2)) {
            self.shakingOccuring = NO;
        }
    }
    
    self.lastAcceleration = acceleration;
}

#pragma mark - tutorial
- (IBAction)closeTutorial:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kTutorialShown];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [UIView animateWithDuration:0.5 animations:^(void){
        self.tutorialView.alpha = 0;
    }];
}

#pragma mark - drinks
- (void)revealCompleteList:(NSArray *)drinks almostList:(NSArray *)almost almostIngredients:(NSArray *)ingredients ingredients:(NSDictionary *)ingredientsDictionary {
    SmartDrinkListViewController *controller = [[SmartDrinkListViewController alloc] initWithNibName:@"SmartDrinkListViewController" bundle:nil];
    controller.completeDrinks = drinks;
    controller.almostDrinks = almost;
    controller.almostDrinkIngredients = ingredients;
    controller.ingredients = ingredientsDictionary;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showAllAvailableRecipes:(NSSet *)selectedIngredientNames {
//    [Flurry logEvent:@"Seeing what drinks can be made"];
    self.mixingView.hidden = NO;
    [self.queue addOperation:[NSBlockOperation blockOperationWithBlock:^(void){
        @autoreleasepool {
            LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
            
            NSMutableSet *allIngredients = [NSMutableSet set];
            
            for (DrinkIngredient *ingredient in self.liquorIngredients) {
                [allIngredients addObjectsFromArray:[ingredient drinkAliasesInContext:delegate.managedObjectContext]];
            }
            
            for (DrinkIngredient *ingredient in self.mixerIngredients) {
                [allIngredients addObjectsFromArray:[ingredient drinkAliasesInContext:delegate.managedObjectContext]];
            }
            
            NSMutableSet *drinks = [NSMutableSet set];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY ingredients.name IN %@", allIngredients];
            [drinks addObjectsFromArray:[delegate listOfDrinks:predicate]];
            
            NSMutableArray *completeDrinks = [NSMutableArray array];
            NSMutableArray *almostDrinks = [NSMutableArray array];
            NSMutableArray *almostDrinkIngredients = [NSMutableArray array];
            NSMutableSet *compareIngredients = [NSMutableSet set];
            NSMutableDictionary *ingredients = [NSMutableDictionary dictionary];
            for (DrinkRecipe *recipe in drinks) {
                [compareIngredients removeAllObjects];
                for (DrinkIngredient *ingredient in recipe.ingredients) {
                    [compareIngredients addObject:ingredient.name];
                }
                
                if (selectedIngredientNames != nil) {
                    NSMutableSet *testSet = [NSMutableSet setWithSet:selectedIngredientNames];
                    [testSet minusSet:compareIngredients];
                    if ([testSet count] != 0) {
                       continue;
                    }
                }
                
                [compareIngredients minusSet:allIngredients];
                
                if ([compareIngredients count] == 0) {
                    [completeDrinks addObject:recipe];
                }
                
                if ([compareIngredients count] == 1) {
                    NSString *ingredient = [compareIngredients anyObject];
                    NSMutableArray *drinksList = [ingredients objectForKey:ingredient];
                    if (drinksList == nil) {
                        drinksList = [NSMutableArray array];
                        [ingredients setObject:drinksList forKey:ingredient];
                    }
                    
                    [drinksList addObject:recipe];
                }
                
                if ([compareIngredients count] == 2) {
                    [almostDrinks addObject:recipe];
                    [almostDrinkIngredients addObjectsFromArray:[compareIngredients allObjects]];
                }
            }
            
            [[NSOperationQueue mainQueue] addOperation:[NSBlockOperation blockOperationWithBlock:^(void){
                self.mixingView.hidden = YES;
                [self revealCompleteList:completeDrinks almostList:almostDrinks almostIngredients:almostDrinkIngredients ingredients:ingredients];
            }]];
        
        }
    }]];
    
}

- (IBAction)mixSelectedIngredients:(id)sender {
//    [Flurry logEvent:@"Selecting Ingredients to filter drinks list"];
    if ([self.selectedIngredients count] == 0) {
        if ([self.mixerIngredients count] == 0 && [self.liquorIngredients count] == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cabinet is Empty", @"CABINET_EMPTY_TITLE") message:NSLocalizedString(@"Your cabinet is empty. Please, add some Liquors and/or Mixers then try again.", @"CABINET_EMPTY_MESSAGE") delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", @"OK_BUTTON") otherButtonTitles: nil];
            [alert show];
        } else {
            [self showAllAvailableRecipes:nil];
        }
    } else {
        NSMutableSet *selectedSet = [NSMutableSet set];
        for (DrinkIngredient *ingredient in self.selectedIngredients) {
            [selectedSet addObject:ingredient.name];
        }
        [self showAllAvailableRecipes:selectedSet];
    }
}

#pragma mark - Manage cabinet
- (void)rebuildMixerCabinet {
    for (UIViewController *controller in self.mixersControllers) {
        [controller.view removeFromSuperview];
    }
    
    [self.mixersControllers removeAllObjects];
    
    self.mixersScrollView.contentSize = CGSizeMake(63 * ([self.mixerIngredients count]), self.mixersScrollView.frame.size.height);
	
	for (int i = 0; i < [self.mixerIngredients count]; i++) {
        DrinkIngredient *ingredient = [self.mixerIngredients objectAtIndex:i];
        CabinetIngredientViewController *controller = [[CabinetIngredientViewController alloc] initWithDrinkIngredient:ingredient];
        controller.imageHeight = 119;
        [self.mixersControllers addObject:controller];
        controller.delegate = self;
        CGRect frame = controller.view.frame;
        frame.origin.x = frame.size.width * i;
        frame.origin.y = self.mixersScrollView.frame.size.height - controller.view.frame.size.height;
        controller.view.frame = frame;
        [self.mixersScrollView addSubview:controller.view];
	}
}

- (void)rebuildLiquorCabinet {
    for (UIViewController *controller in self.liquorControllers) {
        [controller.view removeFromSuperview];
    }
    
    [self.liquorControllers removeAllObjects];
    
    self.liquorScrollView.contentSize = CGSizeMake(63 * ([self.liquorIngredients count]), self.liquorScrollView.frame.size.height);
    
	for (int i = 0; i < [self.liquorIngredients count]; i++) {
        DrinkIngredient *ingredient = [self.liquorIngredients objectAtIndex:i];
        CabinetIngredientViewController *controller = [[CabinetIngredientViewController alloc] initWithDrinkIngredient:ingredient];
        [self.liquorControllers addObject:controller];
        controller.delegate = self;
        CGRect frame = controller.view.frame;
        frame.origin.x = frame.size.width * i;
        frame.origin.y = self.liquorScrollView.frame.size.height - controller.view.frame.size.height;
        controller.view.frame = frame;
        [self.liquorScrollView addSubview:controller.view];
	}
}

- (void)ingredientSelected:(DrinkIngredient *)ingredient controller:(CabinetIngredientViewController *)controller {
    if (!self.currentlyProcessingSelection) {
        if ([self.selectedIngredients containsObject:ingredient]) {
            [self.selectedIngredients removeObject:ingredient];
            [controller setSelected:NO];
        } else {
            [self.selectedIngredients addObject:ingredient];
            [controller setSelected:YES];
        }
        
        [self enableIngredients];
    }
}

- (void)enableIngredients {
    if ([self.selectedIngredients count] > 0) {
        if (!self.currentlyProcessingSelection) {
            self.mixButton.userInteractionEnabled = NO;
            self.deselectButton.userInteractionEnabled = NO;
            self.editButton.userInteractionEnabled = NO;
            
            self.currentlyProcessingSelection = YES;
            self.deselectButton.enabled = YES;
            self.deselectButton.alpha = 1;
            self.mixButtonLabel.text = NSLocalizedString(@"Mix it!", @"MIX_IT_BUTTON");
            
            [self.queue addOperation:[NSBlockOperation blockOperationWithBlock:^(void){
                @autoreleasepool {
                    NSMutableArray *predicateArray = [NSMutableArray arrayWithCapacity:[self.selectedIngredients count]];
                    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
                                                    
                    for (DrinkIngredient *ingredient in self.selectedIngredients) {
                        NSArray *drinkAliases = [ingredient drinkAliasesInContext:delegate.managedObjectContext];
                        
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY ingredients.name IN %@ OR ANY garnishes.name IN %@", drinkAliases, drinkAliases];
                        
                        [predicateArray addObject:predicate];
                    }
                    
                    
                    NSPredicate *fetchPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
                    NSArray *drinks = [delegate listOfDrinks:fetchPredicate];
                    NSMutableSet *ingredientsList = [NSMutableSet set];
                    
                    for (DrinkRecipe *recipe in drinks) {
                        for (DrinkIngredient *ingredient in recipe.ingredients) {
                            [ingredientsList addObject:ingredient.name];
                            
                        }
                        
                        for (DrinkGarnish *garnish in recipe.garnishes) {
                            [ingredientsList addObject:garnish.name];
                        }
                    }
                    
                    [[NSOperationQueue mainQueue] addOperation:[NSBlockOperation blockOperationWithBlock:^(void){
                        if ([self.liquorControllers count] > 0) {
                            for (DrinkIngredient *ingredient in self.liquorIngredients) {
                                NSArray *ingredientNames = [ingredient drinkAliasesInContext:delegate.managedObjectContext];
                                BOOL enable = NO;
                                CabinetIngredientViewController *controller = [self.liquorControllers objectAtIndex:[self.liquorIngredients indexOfObject:ingredient]];
                                for (NSString *ingredientName in ingredientNames) {
                                    if ([ingredientsList containsObject:ingredientName]) {
                                        //enable
                                        enable = YES;
                                        break;
                                    }
                                }
                                
                                controller.enabled = enable;
                            }
                        }
                        
                        if ([self.mixersControllers count] > 0) {
                            for (DrinkIngredient *ingredient in self.mixerIngredients) {
                                NSArray *ingredientNames = [ingredient drinkAliasesInContext:delegate.managedObjectContext];
                                BOOL enable = NO;
                                CabinetIngredientViewController *controller = [self.mixersControllers objectAtIndex:[self.mixerIngredients indexOfObject:ingredient]];
                                for (NSString *ingredientName in ingredientNames) {
                                    if ([ingredientsList containsObject:ingredientName]) {
                                        //enable
                                        enable = YES;
                                        break;
                                    }
                                }
                                
                                controller.enabled = enable;
                            }
                        }
                        self.mixButton.userInteractionEnabled = YES;
                        self.deselectButton.userInteractionEnabled = YES;
                        self.editButton.userInteractionEnabled = YES;
                        self.currentlyProcessingSelection = NO;
                    }]];
                }
            }]];
        }
    } else {
        self.deselectButton.enabled = NO;
        self.deselectButton.alpha = .25;
        self.mixButtonLabel.text = NSLocalizedString(@"Make now!", @"MAKE_NOW_BUTTON");
        if ([self.liquorControllers count] > 0) {
            for (DrinkIngredient *ingredient in self.liquorIngredients) {
                CabinetIngredientViewController *controller = [self.liquorControllers objectAtIndex:[self.liquorIngredients indexOfObject:ingredient]];
                controller.enabled = YES;
            }
        }
        
        if ([self.mixersControllers count] > 0) {
            for (DrinkIngredient *ingredient in self.mixerIngredients) {
                CabinetIngredientViewController *controller = [self.mixersControllers objectAtIndex:[self.mixerIngredients indexOfObject:ingredient]];
                controller.enabled = YES;
            }
        }
    }

}

- (IBAction)deselect:(id)sender {
    [self.selectedIngredients removeAllObjects];
    
    for (CabinetIngredientViewController *controller in self.liquorControllers) {
        [controller setSelected:NO];
    }
    
    for (CabinetIngredientViewController *controller in self.mixersControllers) {
        [controller setSelected:NO];
    }
    
    [self enableIngredients];
}

- (IBAction)manageCabinet:(id)sender {
    CabinetIngredientListViewController *controller = [[CabinetIngredientListViewController alloc] initWithNibName:@"CabinetIngredientListViewController" bundle:nil];
    controller.delegate = self;
    controller.filterMode = [sender tag];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.navigationBarHidden = YES;
    [self presentModalViewController:navController animated:YES];
}

- (void)addIngredients {
   [self dismissModalViewControllerAnimated:YES];
   [self buildCabinetStock];
}

- (void)buildCabinetStock {
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    self.liquorIngredients = [NSMutableArray array];
    self.mixerIngredients = [NSMutableArray array];
    self.selectedIngredients = [NSMutableArray array];
    for (DrinkIngredient *ingredient in [delegate currentCabinet].ingredients) {
        if ([ingredient.type isEqualToString:@"LIQUOR"]) {
            [self.liquorIngredients addObject:ingredient];
        } else {
            [self.mixerIngredients addObject:ingredient];
        }
    }
    
    [self.liquorIngredients sortUsingSelector:@selector(compare:)];
    [self.mixerIngredients sortUsingSelector:@selector(compare:)];
    
    if ([self.liquorIngredients count] == 0) { 
        self.addLiquorsButton.alpha = 1;
        self.liquorScrollView.alpha = 0;
    } else {
        self.addLiquorsButton.alpha = 0;
        self.liquorScrollView.alpha = 1;
    }
    
    if ([self.mixerIngredients count] == 0) {
        self.addMixersButton.alpha = 1;
        self.mixersScrollView.alpha = 0;
    } else {
        self.addMixersButton.alpha = 0;
        self.mixersScrollView.alpha = 1;
    }
    
    [self rebuildLiquorCabinet];
    [self rebuildMixerCabinet];
    [self enableIngredients];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([UIScreen mainScreen].bounds.size.height == 568) {
//        self.backgroundImageView.image = [UIImage imageNamed:@"cabinet_empty-568h.png"];
        self.backgroundImageView.image = [[ImageManager sharedImageManager] loadImage:@"cabinet_empty-568h.png"];
        self.liquorScrollView.transform = CGAffineTransformMakeTranslation(0, 28);
        self.liquorsBackgroundLabelImage.transform = CGAffineTransformMakeTranslation(0, 28);
        self.addLiquorsButton.transform = CGAffineTransformMakeTranslation(0, 28);
        self.mixersScrollView.transform = CGAffineTransformMakeTranslation(0, 55);
        self.mixersBackgroundLabelImage.transform = CGAffineTransformMakeTranslation(0, 55);
        self.addMixersButton.transform = CGAffineTransformMakeTranslation(0, 55);
        
//        self.shakerImageView.image = [UIImage imageNamed:@"shaker_big-568h.png"];
        self.shakerImageView.image = [[ImageManager sharedImageManager] loadImage:@"shaker_big-568h.png"];
        self.shakerImageView.frame = CGRectMake(self.shakerImageView.frame.origin.x, self.shakerImageView.frame.origin.y, 79, 128);
        self.shakerImageView.transform = CGAffineTransformMakeTranslation(0, -15);
        
        self.mixButton.frame = CGRectMake(self.mixButton.frame.origin.x, self.mixButton.frame.origin.y, 165, 58);
        self.mixButtonLabel.frame = CGRectMake(self.mixButtonLabel.frame.origin.x, self.mixButtonLabel.frame.origin.y, 165, 58);
        self.mixButton.transform = CGAffineTransformMakeTranslation(10, -30);
        self.mixButtonLabel.transform = CGAffineTransformMakeTranslation(-5, -43);
        
        self.deselectButton.transform = CGAffineTransformMakeTranslation(-25, 0);
        self.editButton.transform = CGAffineTransformMakeTranslation(-115, 30);
    }
    
    self.queue = [[NSOperationQueue alloc] init];
    self.mixersControllers = [NSMutableArray array];
    self.liquorControllers = [NSMutableArray array];
    
    self.mixingViewLabel.font = [UIFont fontWithName:@"tabitha" size:24];
    self.editButton.titleLabel.font = [UIFont fontWithName:@"Lush" size:20];
    self.deselectButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:16];
    self.mixButtonLabel.font = [UIFont fontWithName:@"tabitha" size:32];
    [UIAccelerometer sharedAccelerometer].delegate = self;
    
    BOOL hideTutorial = [[NSUserDefaults standardUserDefaults] boolForKey:kTutorialShown];
    if (hideTutorial) {
        self.tutorialView.hidden = YES;
    } else {
        self.tutorialView.hidden = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self buildCabinetStock];
    self.allowShake = YES;
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    if ([[delegate currentCabinet].dirty boolValue]) {
        [self buildCabinetStock];
        [delegate currentCabinet].dirty = [NSNumber numberWithBool:NO];
        [delegate saveContext];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.allowShake = NO;
}

- (void)viewDidUnload
{
    [self setBackgroundImageView:nil];
    [self setLiquorsBackgroundLabelImage:nil];
    [self setMixersBackgroundLabelImage:nil];
    [self setShakerImageView:nil];
    [super viewDidUnload];
    self.addLiquorsButton = nil;
    self.addMixersButton = nil;
    self.deselectButton = nil;
    self.editButton = nil;
    self.mixButton = nil;
    self.mixButtonLabel = nil;
    self.mixersScrollView = nil;
    self.liquorScrollView = nil;
    self.tutorialView = nil;
    self.mixingView = nil;
    self.mixingViewLabel = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
@end
