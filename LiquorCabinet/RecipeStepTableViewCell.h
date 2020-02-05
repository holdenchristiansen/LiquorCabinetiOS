//
//  RecipeStepTableViewCell.h
//  LiquorCabinet
//
//  Created by Mark Powell on 9/22/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecipeStepTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *checkBoxImageView;
@property (nonatomic, strong) IBOutlet UILabel *typeLabel;
@property (nonatomic, strong) IBOutlet UILabel *amountLabel;
@property (nonatomic, strong) IBOutlet UILabel *noAmountInstructionLabel;
@end
