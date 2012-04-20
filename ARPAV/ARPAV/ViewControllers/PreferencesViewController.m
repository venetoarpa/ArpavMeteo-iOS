//
//  PreferencesViewController.m
//  ARPAV
//
//  Created by Andrea Mazzini on 18/04/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import "PreferencesViewController.h"
#import "SettingsHelper.h"
#import "ProvinceViewController.h"

#define kMinRows 6

@interface PreferencesViewController ()

@end

@implementation PreferencesViewController

@synthesize tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.tableView setBackgroundColor:[UIColor clearColor]];
	[self.tableView setEditing:YES];
	[self setTitle:@"Meteo"];
	
	UIBarButtonItem* barButtonAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
																				  target:self 
																				  action:@selector(addPreference)];

	UIBarButtonItem* barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Fatto" 
																	  style:UIBarButtonItemStyleDone 
																	 target:self 
																	 action:@selector(openWeather)];
	
	[self.navigationItem setLeftBarButtonItem:barButtonAdd];	
	[self.navigationItem setRightBarButtonItem:barButtonDone];
	
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.tableView reloadData];
}

- (void)addPreference
{
	ProvinceViewController* viewController = [[ProvinceViewController alloc] initWithNibName:@"ProvinceView" bundle:nil];
	[self.navigationController pushViewController:viewController animated:YES];
	[[SettingsHelper sharedHelper] savePreferences];
}

- (void)openWeather
{
	[self dismissModalViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return MAX([[SettingsHelper sharedHelper].preferences count], kMinRows);
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString* cellid = @"cellIdentifier";
	
	UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellid];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
	}
	
	if (indexPath.row < [[SettingsHelper sharedHelper].preferences count]) {
		NSDictionary* dict = [[SettingsHelper sharedHelper].preferences objectAtIndex:indexPath.row];
		cell.textLabel.text = [dict objectForKey:@"name"];
	} else {
		cell.textLabel.text = @"";
	}
	
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row < [[SettingsHelper sharedHelper].preferences count]) {
		return YES;
	}
	return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		[[SettingsHelper sharedHelper] removeItemFromPreferences:indexPath.row];
		[self.tableView reloadData];
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
