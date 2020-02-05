//
//  TipsView.m
//  LiquorCabinet
//
//  Created by Mark Powell on 3/17/12.
//  Copyright (c) 2012 Lavacado Studios, LLC. All rights reserved.
//

#import "TipsView.h"

@implementation TipsView

@synthesize isOpen;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *v in self.subviews){
        if ([v isKindOfClass:[UIButton class]]){
            if (CGRectContainsPoint(v.frame, point)) {
                return v;
            }
        }
    }
    
    if (self.isOpen) {
        return self;
    }
    
    return nil;
}

@end
