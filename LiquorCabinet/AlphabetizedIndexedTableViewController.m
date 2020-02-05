//
//  AlphabetizedIndexedTableViewController.m
//  LiquorCabinet
//
//  Created by Mark Powell on 9/20/11.
//  Copyright 2011 Lavacado Studios, LLC. All rights reserved.
//

#import "AlphabetizedIndexedTableViewController.h"
#import "ImageManager.h"

@implementation AlphabetizedIndexedTableViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sections = [NSMutableArray array];
    self.alphabetizedContent = [NSMutableDictionary dictionary];
    
    self.numberFormatter = [[NSNumberFormatter alloc] init];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.sections = nil;
    self.alphabetizedContent = nil;
    self.numberFormatter = nil;
}

- (bool)isNumeric:(NSString *)checkText{
    
    NSNumber* number = [self.numberFormatter numberFromString:checkText];
    return number != nil;
}

- (void)generateSectionHeadersAndContentGroups {
    [self.sections removeAllObjects];
    [self.alphabetizedContent removeAllObjects];
    
    int number = [self numberOfContentObjects];
    for (int i = 0; i < number; i++) {
        NSString *name = [self nameOfContentObjectAtIndex:i];
        if ([name length] > 0) {
            NSString *letter = [[name substringToIndex:1] uppercaseString];
            if ([self isNumeric:letter]) {
                letter = @"#";
            }
            
            if (![self.sections containsObject:letter]) {
                [self.sections addObject:letter];
            }
            
            NSMutableArray *content = [self.alphabetizedContent objectForKey:letter];
            if (content == nil) {
                content = [NSMutableArray array];
                [self.alphabetizedContent setObject:content forKey:letter];
            }
            
            [content addObject:[self contentObjectAtIndex:i]];
            [content sortUsingSelector:@selector(compare:)];
        }
    }
    
    [self.sections sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 21)];
    sectionView.backgroundColor = [UIColor clearColor];
    CGRect sectionFrame = CGRectMake(0, sectionView.frame.origin.y, sectionView.frame.size.width, sectionView.frame.size.height);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:sectionFrame];
//    imageView.image = [UIImage imageNamed:@"gradient_wax.png"];
    imageView.image = [[ImageManager sharedImageManager] loadImage:@"gradient_wax.png"];
    [sectionView addSubview:imageView];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(7, 1, 15, 20)];
    title.textAlignment = UITextAlignmentCenter;
    title.text = [self.sections objectAtIndex:section];
    title.font = [UIFont boldSystemFontOfSize:14];
    title.textColor = [UIColor blackColor];
    title.backgroundColor = [UIColor clearColor];
    [sectionView addSubview:title];
    return sectionView;
}

// Customize the number of sections in the table view.
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.sections;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString
                                                                             *)title atIndex:(NSInteger)index {
    return [self.sections indexOfObject:title];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *content = [self.alphabetizedContent objectForKey:[self.sections objectAtIndex:section]];
    return [content count];
}

//subclasses implement

- (int)numberOfContentObjects {return 0;}
- (NSString *)nameOfContentObjectAtIndex:(int)index {return nil;}
- (id)contentObjectAtIndex:(int)index {return 0;}

@end
