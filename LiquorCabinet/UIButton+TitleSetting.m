//
//  UIButton+TitleSetting.m
//  HundredCamerasInOne
//
//  Created by Mark Powell on 10/26/10.
//  Copyright 2010 Lavacado Studios, LLC. All rights reserved.
//

#import "UIButton+TitleSetting.h"


@implementation UIButton (Title)

- (void)forAllStatesSetTitleColor:(UIColor *)color {
    [self setTitleColor:color forState:UIControlStateNormal];
    [self setTitleColor:color forState:UIControlStateHighlighted];
    [self setTitleColor:color forState:UIControlStateDisabled];
    [self setTitleColor:color forState:UIControlStateSelected];
}

- (void)forAllStatesSetTitle:(NSString *)title {
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateHighlighted];
    [self setTitle:title forState:UIControlStateDisabled];
    [self setTitle:title forState:UIControlStateSelected];
}

- (void)forAllStatesSetImage:(UIImage *)image {
	[self setImage:image forState:UIControlStateNormal];
	[self setImage:image forState:UIControlStateHighlighted];
    [self setImage:image forState:UIControlStateDisabled];
    [self setImage:image forState:UIControlStateSelected];
}

- (void)forAllStatesSetBackgroundImage:(UIImage *)image {
    [self setBackgroundImage:image forState:UIControlStateNormal];
	[self setBackgroundImage:image forState:UIControlStateHighlighted];
    [self setBackgroundImage:image forState:UIControlStateDisabled];
    [self setBackgroundImage:image forState:UIControlStateSelected];
}

@end
