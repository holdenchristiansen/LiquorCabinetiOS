//
//  DrinkListScrollViewControllerViewController.m
//  LiquorCabinet
//
//  Created by Mark Powell on 3/19/12.
//  Copyright (c) 2012 Lavacado Studios, LLC. All rights reserved.
//

#import "DrinkListScrollViewController.h"
#import "DrinkRecipeDetailViewController.h"
//#import "Flurry.h"

@interface DrinkListScrollViewController ()

@end

@implementation DrinkListScrollViewController

- (id)initWithDrinkList:(NSArray *)drinkList initialIndex:(int)index {
    self = [super initWithNibName:@"DrinkListScrollViewController" bundle:nil];
    
    if (self) {
        _drinkList = drinkList;
        _currIndex = index;
        if (index == 0) {
            _prevIndex = [_drinkList count] - 1;
        } else {
            _prevIndex = index - 1;
        }
        
        if (index == [_drinkList count] - 1) {
            _nextIndex = 0;
        } else {
            _nextIndex = index + 1;
        }
    }
    
    return self;
}

- (void)dismiss {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self.drinkList count] > 1) {
        // create placeholders for each of our documents
        self.pageOneDrinkController = [[DrinkRecipeDetailViewController alloc] init];
        self.pageOneDrinkController.navigationDelegate = self;
        self.pageTwoDrinkController = [[DrinkRecipeDetailViewController alloc] init];
        self.pageTwoDrinkController.navigationDelegate = self;
        self.pageThreeDrinkController = [[DrinkRecipeDetailViewController alloc] init];
        self.pageThreeDrinkController.navigationDelegate = self;
        
        // load all three pages into our scroll view
        [self loadPageWithId:self.prevIndex onPage:0];
        [self loadPageWithId:self.currIndex onPage:1];
        [self loadPageWithId:self.nextIndex onPage:2];
        
        [self.scrollView addSubview:self.pageOneDrinkController.view];
        [self.scrollView addSubview:self.pageTwoDrinkController.view];
        [self.scrollView addSubview:self.pageThreeDrinkController.view];
        
        self.pageOneDrinkController.view.frame = CGRectMake(0, 0, 320, 411);
        self.pageTwoDrinkController.view.frame = CGRectMake(320, 0, 320, 411);
        self.pageThreeDrinkController.view.frame = CGRectMake(640, 0, 320, 411);
        
        // adjust content size for three pages of data and reposition to center page
        self.scrollView.contentSize = CGSizeMake(960, 411);
        [self.scrollView scrollRectToVisible:CGRectMake(320,0,320,411) animated:NO];
    } else {
        self.pageOneDrinkController = [[DrinkRecipeDetailViewController alloc] init];
        self.pageOneDrinkController.navigationDelegate = self;
        [self loadPageWithId:self.prevIndex onPage:0];
        [self.scrollView addSubview:self.pageOneDrinkController.view];
        self.pageOneDrinkController.view.frame = CGRectMake(0, 0, 320, 411);
        self.scrollView.contentSize = CGSizeMake(320, 411);
    }
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadPageWithId:(int)index onPage:(int)page {
	// load data for page
	switch (page) {
		case 0:
            [self.pageOneDrinkController updateViewWithDrink:[self.drinkList objectAtIndex:index]];
			break;
		case 1:
//            [Flurry logEvent:@"Recipe Viewed" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[[self.drinkList objectAtIndex:index] name], @"Recipe Name", nil]];
			[self.pageTwoDrinkController updateViewWithDrink:[self.drinkList objectAtIndex:index]];
			break;
		case 2:
			[self.pageThreeDrinkController updateViewWithDrink:[self.drinkList objectAtIndex:index]];
			break;
	}	
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender {     
	// All data for the documents are stored in an array (documentTitles).     
	// We keep track of the index that we are scrolling to so that we     
	// know what data to load for each page.     
	if(self.scrollView.contentOffset.x > self.scrollView.frame.size.width) {
		// We are moving forward. Load the current doc data on the first page.         
		[self loadPageWithId:self.currIndex onPage:0];         
		// Add one to the currentIndex or reset to 0 if we have reached the end.         
		self.currIndex = (self.currIndex >= [self.drinkList count]-1) ? 0 : self.currIndex + 1;         
		[self loadPageWithId:self.currIndex onPage:1];         
		// Load content on the last page. This is either from the next item in the array         
		// or the first if we have reached the end.         
		self.nextIndex = (self.currIndex >= [self.drinkList count]-1) ? 0 : self.currIndex + 1;         
		[self loadPageWithId:self.nextIndex onPage:2];     
	}     
	if(self.scrollView.contentOffset.x < self.scrollView.frame.size.width) {
		// We are moving backward. Load the current doc data on the last page.         
		[self loadPageWithId:self.currIndex onPage:2];         
		// Subtract one from the currentIndex or go to the end if we have reached the beginning.         
		self.currIndex = (self.currIndex == 0) ? [self.drinkList count]-1 : self.currIndex - 1;         
		[self loadPageWithId:self.currIndex onPage:1];         
		// Load content on the first page. This is either from the prev item in the array         
		// or the last if we have reached the beginning.         
		self.prevIndex = (self.currIndex == 0) ? [self.drinkList count]-1 : self.currIndex - 1;         
		[self loadPageWithId:self.prevIndex onPage:0];     
	}     
	
	// Reset offset back to middle page     
	[self.scrollView scrollRectToVisible:CGRectMake(320,0,320,411) animated:NO];
}

@end
