//
//  AlphabetizedIndexedTableViewController.h
//  LiquorCabinet
//
//  Created by Mark Powell on 9/20/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlphabetizedIndexedTableViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSMutableDictionary *alphabetizedContent;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

- (void)generateSectionHeadersAndContentGroups;
- (int)numberOfContentObjects;
- (NSString *)nameOfContentObjectAtIndex:(int)index;
- (id)contentObjectAtIndex:(int)index;

@end
