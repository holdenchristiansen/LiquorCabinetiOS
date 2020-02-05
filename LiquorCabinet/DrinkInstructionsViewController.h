//
//  DrinkInstructionsViewController.h
//  LiquorCabinet
//
//  Created by Mark Powell on 9/20/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrinkInstructionsViewController : UIViewController

@property (nonatomic, copy) NSString *instructions;
@property (nonatomic, strong) IBOutlet UILabel *instructionsLabel;

@end
