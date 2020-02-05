//
//  UIButton+TitleSetting.h
//  HundredCamerasInOne
//
//  Created by Mark Powell on 10/26/10.
//  Copyright 2010 Lavacado Studios, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIButton (Title)

- (void)forAllStatesSetTitleColor:(UIColor *)color;
- (void)forAllStatesSetTitle:(NSString *)title;
- (void)forAllStatesSetImage:(UIImage *)image;
- (void)forAllStatesSetBackgroundImage:(UIImage *)image;

@end
