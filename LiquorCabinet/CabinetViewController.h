//
//  CabinetViewController.h
//  LiquorCabinet
//
//  Created by Mark Powell on 9/15/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Cabinet;
@interface CabinetViewController : UIViewController <UIAccelerometerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) IBOutlet UIButton *addLiquorsButton;
@property (nonatomic, strong) IBOutlet UIButton *addMixersButton;
@property (nonatomic, strong) IBOutlet UIButton *deselectButton;
@property (nonatomic, strong) IBOutlet UIButton *editButton;
@property (nonatomic, strong) IBOutlet UIButton *mixButton;
@property (nonatomic, strong) IBOutlet UILabel *mixButtonLabel;
@property (nonatomic, strong) IBOutlet UIScrollView *mixersScrollView;
@property (nonatomic, strong) NSMutableArray *mixersControllers;
@property (nonatomic, strong) IBOutlet UIScrollView *liquorScrollView;
@property (nonatomic, strong) NSMutableArray *liquorControllers;
@property (nonatomic, strong) NSMutableArray *liquorIngredients;
@property (nonatomic, strong) NSMutableArray *mixerIngredients;
@property (nonatomic, strong) NSMutableArray *selectedIngredients;
@property (nonatomic, assign, getter=isShakingOccuring) BOOL shakingOccuring;
@property (nonatomic, assign, getter=shouldAllowShake) BOOL allowShake;
@property (nonatomic, strong) UIAcceleration *lastAcceleration;
@property (nonatomic, strong) IBOutlet UIView *tutorialView;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) IBOutlet UIView *mixingView;
@property (nonatomic, strong) IBOutlet UILabel *mixingViewLabel;
@property (nonatomic, assign, getter=isCurrentlyProcessingSelection) BOOL currentlyProcessingSelection;
@property (strong, nonatomic) IBOutlet UIImageView *liquorsBackgroundLabelImage;
@property (strong, nonatomic) IBOutlet UIImageView *mixersBackgroundLabelImage;
@property (strong, nonatomic) IBOutlet UIImageView *shakerImageView;

- (IBAction)mixSelectedIngredients:(id)sender;
- (IBAction)manageCabinet:(id)sender;
- (IBAction)deselect:(id)sender;
- (IBAction)closeTutorial:(id)sender;

@end
