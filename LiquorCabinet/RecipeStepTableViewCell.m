//
//  RecipeStepTableViewCell.m
//  LiquorCabinet
//
//  Created by Mark Powell on 9/22/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import "RecipeStepTableViewCell.h"

@implementation RecipeStepTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (editing) {
        if (animated) {
            [UIView animateWithDuration:0.25 animations:^(void){
                self.amountLabel.frame = CGRectMake(self.amountLabel.frame.origin.x, self.amountLabel.frame.origin.y, 60, self.amountLabel.frame.size.height);
            }];
        } else {
            self.amountLabel.frame = CGRectMake(self.amountLabel.frame.origin.x, self.amountLabel.frame.origin.y, 60, self.amountLabel.frame.size.height);
        }
    } else {
        if (animated) {
            [UIView animateWithDuration:0.25 animations:^(void){
                self.amountLabel.frame = CGRectMake(self.amountLabel.frame.origin.x, self.amountLabel.frame.origin.y, 115, self.amountLabel.frame.size.height);
            }];
        } else {
            self.amountLabel.frame = CGRectMake(self.amountLabel.frame.origin.x, self.amountLabel.frame.origin.y, 115, self.amountLabel.frame.size.height);
        }
    }
}
@end
