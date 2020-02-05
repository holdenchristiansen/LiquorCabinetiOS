//
//  CabinetIngredientViewController.m
//  LiquorCabinet
//
//  Created by Mark Powell on 9/23/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import "CabinetIngredientViewController.h"
#import "DrinkIngredient.h"
#import "ImageManager.h"

@implementation CabinetIngredientViewController

- (id)initWithDrinkIngredient:(DrinkIngredient *)ingredient {
    self = [super initWithNibName:@"CabinetIngredientViewController" bundle:nil];
    
    if (self) {
        _ingredient = ingredient;
        _enabled = YES;
        _selected = NO;
    }
    
    return self;
}

#pragma mark - interaction
- (IBAction)setEnabled:(BOOL)enabled {
    if (enabled) {
        _enabled = enabled;
        [UIView animateWithDuration:0.25 animations:^(void){
            if (_selected) {
                self.nameLabel.textColor = [UIColor orangeColor];
            } else {
                self.nameLabel.textColor = [UIColor whiteColor];
            }
            self.bottleImageView.alpha = 1;
        }];
    } else {
        _enabled = enabled;
        [UIView animateWithDuration:0.25 animations:^(void) {
            self.nameLabel.textColor = [UIColor grayColor];
            self.bottleImageView.alpha = 0.5;
        }];
    }
}

- (IBAction)selected:(id)sender {
    if (self.enabled && [self.delegate respondsToSelector:@selector(ingredientSelected:controller:)]) {
        [self.delegate performSelector:@selector(ingredientSelected:controller:) withObject:self.ingredient withObject:self];
    }
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    if (selected) {
        NSString *imageName = [self.ingredient.optionalAssetName stringByAppendingString:@"_orange.png"];
        UIImage *image = [UIImage imageNamed:imageName];
        if (image == nil) {
//            image = [UIImage imageNamed:@"bottle_none_orange.png"];
            image = [[ImageManager sharedImageManager] loadImage:@"bottle_none_orange.png"];
        }
        self.bottleImageView.image = image;
        self.nameLabel.textColor = [UIColor orangeColor];
    } else {
        NSString *imageName = [self.ingredient.optionalAssetName stringByAppendingString:@".png"];
//        UIImage *image = [UIImage imageNamed:imageName];
        UIImage *image = [[ImageManager sharedImageManager] loadImage:imageName];
        if (image == nil) {
//            image = [UIImage imageNamed:@"bottle_none.png"];
            image = [[ImageManager sharedImageManager] loadImage:@"bottle_none.png"];
        }
        self.bottleImageView.image = image;
        self.nameLabel.textColor = [UIColor whiteColor];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.nameLabel.text = self.ingredient.name;
    NSString *imageName = [self.ingredient.optionalAssetName stringByAppendingString:@".png"];
    /*UIImage *image = [UIImage imageNamed:imageName];
    if (image == nil) {
        image = [UIImage imageNamed:@"bottle_none.png"];
    }
    self.bottleImageView.image = image;*/
    
    self.bottleImageView.image = [[ImageManager sharedImageManager] loadImage:imageName];
    
    if (self.imageHeight != 0) {
        self.bottleImageView.frame = CGRectMake(self.bottleImageView.frame.origin.x, self.bottleImageView.frame.origin.y, 63, self.imageHeight);
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.nameLabel = nil;
    self.bottleImageView = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
