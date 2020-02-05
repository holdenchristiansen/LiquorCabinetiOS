//
//  CabinetIngredientViewController.h
//  LiquorCabinet
//
//  Created by Mark Powell on 9/23/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DrinkIngredient;

@interface CabinetIngredientViewController : UIViewController

@property (nonatomic, strong) DrinkIngredient *ingredient;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *bottleImageView;
@property (nonatomic, unsafe_unretained) id delegate;
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;
@property (nonatomic, assign, getter=isSelected) BOOL selected;
@property (nonatomic, assign) float imageHeight;

- (id)initWithDrinkIngredient:(DrinkIngredient *)ingredient;

- (void)setSelected:(BOOL)selected;
- (IBAction)selected:(id)sender;

@end
