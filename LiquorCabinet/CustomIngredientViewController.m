//
//  CustomIngredientViewController.m
//  LiquorCabinet
//
//  Created by Mark Powell on 10/11/12.
//  Copyright (c) 2012 Lavacado Studios, LLC. All rights reserved.
//

#import "CustomIngredientViewController.h"
#import "Cabinet.h"
#import "DrinkIngredient.h"
#import "LiquorCabinetAppDelegate.h"
#import "UIButton+TitleSetting.h"
//#import "Flurry.h"
#import "ParseSynchronizer.h"
#import "ImageManager.h"

@interface CustomIngredientViewController ()

- (void)emailIngredient;

@end

@implementation CustomIngredientViewController {
    DrinkIngredient *selectedBase_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sections = [NSMutableArray array];
    self.alphabetizedContent = [NSMutableDictionary dictionary];
    self.displayedIngredients = [NSMutableArray arrayWithArray:self.ingredients];
    [self generateSectionHeadersAndContentGroups];
    self.titleLabel.font = [UIFont fontWithName:@"HoneyScript-SemiBold" size:42];
    self.allIngredientsButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.mixerIngredientsButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.liquorIngredientsButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.garnishIngredientsButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.backButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:14];
    self.typeOfLabel.font = [UIFont fontWithName:@"tabitha" size:15];
    self.ingredientNameLabel.font = [UIFont fontWithName:@"tabitha" size:15];
    self.tableView.separatorColor = [UIColor grayColor];
    [self.allIngredientsButton forAllStatesSetTitleColor:[UIColor blackColor]];
    [self.liquorIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
    [self.mixerIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
    [self.garnishIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
    self.createButton.titleLabel.font = [UIFont fontWithName:@"tabitha" size:17];
    /*
     * 16/01/2016 - David Rojas - WAM Digital (CR)
     * These 2 lines set the table view's index color and background
     */
    [[self tableView] setSectionIndexColor:[UIColor grayColor]];
    [[self tableView] setSectionIndexBackgroundColor:[UIColor clearColor]];
    if (self.ingredients == nil) {
        [self setFilter:nil];
    }
    
    [self.searchField addTarget:self
                         action:@selector(editingChanged:)
               forControlEvents:UIControlEventEditingChanged];
}

-(void) editingChanged:(id)sender {
    if(self.searchField.text.length > 0){
        [self.ingredientNameLabelSearchBar setHidden:YES];
    }else{
        [self.ingredientNameLabelSearchBar setHidden:NO];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (IBAction)back:(id)sender {
    if ([self.delegate respondsToSelector:@selector(customIngredientViewControllerFinished:)]) {
        [self.delegate performSelector:@selector(customIngredientViewControllerFinished:) withObject:self];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self emailIngredient];
    } else {
        if ([self.delegate respondsToSelector:@selector(customIngredientViewControllerFinished:)]) {
            [self.delegate performSelector:@selector(customIngredientViewControllerFinished:) withObject:self];
        }
    }
}

- (IBAction)createIngredient:(id)sender {
    NSString *errorString = [self checkForError];
    if (errorString) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Custom Ingredient Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    } else {
//        [Flurry logEvent:@"Created custom Ingredient" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:self.searchField.text,@"name",selectedBase_.name,@"base", nil]];
        
        LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
        DrinkIngredient *ingredient = [delegate createIngredient:self.searchField.text base:selectedBase_];
        [[delegate currentCabinet] addIngredientsObject:ingredient];
        [delegate saveContext];
        self.createdIngredient = ingredient;
        
        [[ParseSynchronizer sharedInstance] addDrinkIngredient:ingredient];
        [[ParseSynchronizer sharedInstance] addIngredient:ingredient toCabinet:[delegate currentCabinet]];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Send an Email?" message:@"Your new Ingredient has be created and added to the Cabinet. Would you like to inform the developers so they can include it in the next version?" delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Yes, Email Them", nil];
        [alertView show];
    }
}

- (void)emailIngredient {
    if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            [controller setToRecipients:[NSArray arrayWithObject:@"liquorcabinet@lavacado.com"]];
            [controller setSubject:@"New Ingredient Suggestion"];
            [controller setMessageBody:[NSString stringWithFormat:@"You are missing an ingredient! Here is what I added: <b>%@</b> a type of <b>%@</b>", self.searchField.text, selectedBase_.name] isHTML:YES];
            [self presentModalViewController:controller animated:YES];
    }
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissModalViewControllerAnimated:YES];
    
    NSString *message;
	NSString *title;
    if (result != MFMailComposeResultCancelled) {
        if (error) {
            title = NSLocalizedString(@"Email failed to send", @"EMAIL_FAILURE_TITLE");
            message = [error description];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Ok", @"OK_BUTTON")
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(customIngredientViewControllerFinished:)]) {
        [self.delegate performSelector:@selector(customIngredientViewControllerFinished:) withObject:self];
    }
}


- (NSString *)checkForError {
    if (self.searchField.text == nil || [self.searchField.text isEqualToString:@""]) {
        return @"Custom Ingredient must have a name set.";
    }
    
    if (selectedBase_ == nil) {
        return @"The Custom Ingredient's type is not set. An ingredient must be a type of a base ingredient. E.g. Bacardi is a type of Rum.";
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name ==[c] %@", self.searchField.text];
      
    LiquorCabinetAppDelegate *delegate = (LiquorCabinetAppDelegate *)[UIApplication sharedApplication].delegate;
    NSArray *ingredients = [delegate listOfIngredients:predicate];
    if ([ingredients count] != 0) {
        return [NSString stringWithFormat:@"There already exists an Ingredient called %@", self.searchField.text];
    }
    
    return nil;
}

- (IBAction)dismissKeyboard:(id)sender {
    [self.searchField resignFirstResponder];
}

#pragma mark - Filter
- (IBAction)setFilter:(id)sender {
    self.filterMode = [sender tag];
    [self updateTableObjects];
}

- (void)updateTableObjects {
    if (self.filterMode == 0) {
        [self.displayedIngredients removeAllObjects];
        
        [self.displayedIngredients addObjectsFromArray:self.ingredients];
        [self generateSectionHeadersAndContentGroups];
        [self.allIngredientsButton forAllStatesSetTitleColor:[UIColor blackColor]];
        [self.mixerIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.liquorIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.garnishIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.tableView reloadData];
    } else if (self.filterMode == 1) {
        [self.displayedIngredients removeAllObjects];
        for (DrinkIngredient *ingredient in self.ingredients) {
            if ([ingredient.type isEqualToString:@"LIQUOR"]) {
                [self.displayedIngredients addObject:ingredient];
            }
        }
        [self generateSectionHeadersAndContentGroups];
        [self.allIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.mixerIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.liquorIngredientsButton forAllStatesSetTitleColor:[UIColor blackColor]];
        [self.garnishIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.tableView reloadData];
    } else if (self.filterMode == 2) {
        [self.displayedIngredients removeAllObjects];
        for (DrinkIngredient *ingredient in self.ingredients) {
            if ([ingredient.type isEqualToString:@"MIXER"]) {
                [self.displayedIngredients addObject:ingredient];
            }
        }
        [self generateSectionHeadersAndContentGroups];
        [self.allIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.mixerIngredientsButton forAllStatesSetTitleColor:[UIColor blackColor]];
        [self.liquorIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.garnishIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.tableView reloadData];
    } else if (self.filterMode == 3) {
        [self.displayedIngredients removeAllObjects];
        for (DrinkIngredient *ingredient in self.ingredients) {
            if ([ingredient.type isEqualToString:@"GARNISH"]) {
                [self.displayedIngredients addObject:ingredient];
            }
        }
        [self generateSectionHeadersAndContentGroups];
        [self.allIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.mixerIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.liquorIngredientsButton forAllStatesSetTitleColor:[UIColor grayColor]];
        [self.garnishIngredientsButton forAllStatesSetTitleColor:[UIColor blackColor]];
        [self.tableView reloadData];
    }
}

// Customize the number of sections in the table view.
- (int)numberOfContentObjects {
    return [self.displayedIngredients count];
}

- (NSString *)nameOfContentObjectAtIndex:(int)index {
    return [[self.displayedIngredients objectAtIndex:index] name];
}

- (id)contentObjectAtIndex:(int)index {
    return [self.displayedIngredients objectAtIndex:index];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont fontWithName:@"tabitha" size:20];
//        UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separatorline.png"]];
        UIImageView *separator = [[UIImageView alloc] initWithImage:[[ImageManager sharedImageManager] loadImage:@"separatorline.png"]];
        separator.frame = CGRectMake(9, cell.contentView.frame.size.height - 1, 263, 1);
        [cell.contentView addSubview:separator];
    }
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *content = [self.sections objectAtIndex:indexPath.section];
    DrinkIngredient *ingredient = [[self.alphabetizedContent objectForKey:content] objectAtIndex:indexPath.row];
    selectedBase_ = ingredient;
    
    self.typeOfLabel.text = [NSString stringWithFormat:@"2. Select Ingredient Type: %@", ingredient.name];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [self setSearchField:nil];
    [self setTypeOfLabel:nil];
    [self setIngredientNameLabel:nil];
    [self setCreateButton:nil];
    [super viewDidUnload];
    
    self.titleLabel = nil;
    self.allIngredientsButton = nil;
    self.liquorIngredientsButton = nil;
    self.mixerIngredientsButton = nil;
    self.garnishIngredientsButton = nil;
    self.backButton = nil;
    self.tableView = nil;
    
    
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSArray *content = [self.sections objectAtIndex:indexPath.section];
    DrinkIngredient *managedObject = [[self.alphabetizedContent objectForKey:content] objectAtIndex:indexPath.row];
    cell.textLabel.text = managedObject.name;
    
    if ([selectedBase_ isEqual:managedObject]) {
//        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[[ImageManager sharedImageManager] loadImage:@"checkmark.png"]];
    } else {
        cell.accessoryView = nil;
    }
}

@end
