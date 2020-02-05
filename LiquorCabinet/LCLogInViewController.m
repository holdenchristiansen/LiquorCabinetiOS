//
//  LCLogInViewController.m
//  LiquorCabinet
//
//  Created by Mark Powell on 4/1/13.
//  Copyright (c) 2013 Lavacado Studios, LLC. All rights reserved.
//

#import "LCLogInViewController.h"

@implementation LCLogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:
                                 [UIImage imageNamed:@"paper.png"]];
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"Liquor Cabinet";
    label.font = [UIFont fontWithName:@"HoneyScript-SemiBold" size:50];
    [label sizeToFit];
//    self.logInView.logo = label; // logo can be any UIView
}

@end
