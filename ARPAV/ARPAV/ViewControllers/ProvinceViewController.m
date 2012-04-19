//
//  ProvinceViewController.m
//  ARPAV
//
//  Created by Andrea Mazzini on 18/04/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import "ProvinceViewController.h"
#import "SettingsHelper.h"
#import "CityViewController.h"

@interface ProvinceViewController ()

@end

@implementation ProvinceViewController

@synthesize tableView = _tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.tableView setBackgroundColor:[UIColor clearColor]];
	[self setTitle:@"Province"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[[SettingsHelper sharedHelper] getProvinces] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString* cellid = @"cellIdentifier";
	
	UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellid];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
	}
	
	NSDictionary* dict = [[[SettingsHelper sharedHelper] getProvinces] objectAtIndex:indexPath.row];
	cell.textLabel.text = [dict objectForKey:@"provincia"];
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	CityViewController* viewController = [[CityViewController alloc] initWithNibName:@"CityView" 
																			  bundle:nil 
																		 andProvince:indexPath.row];
	[self.navigationController pushViewController:viewController animated:YES];
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
