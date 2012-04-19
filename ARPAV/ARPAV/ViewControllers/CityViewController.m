//
//  CityViewController.m
//  ARPAV
//
//  Created by Andrea Mazzini on 18/04/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import "CityViewController.h"
#import "SettingsHelper.h"

@interface CityViewController ()

@end

@implementation CityViewController

@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andProvince:(int)province
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		_province = province;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.tableView setBackgroundColor:[UIColor clearColor]];
	[self setTitle:@"Comuni"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[[SettingsHelper sharedHelper] getCitiesFromProvince:_province] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString* cellid = @"cellIdentifier";
	
	UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellid];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
	}
	
	NSDictionary* dict = [[[SettingsHelper sharedHelper] getCitiesFromProvince:_province] objectAtIndex:indexPath.row];
	cell.textLabel.text = [dict objectForKey:@"name"];
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary* dict = [[[SettingsHelper sharedHelper] getCitiesFromProvince:_province] objectAtIndex:indexPath.row];
	[[SettingsHelper sharedHelper] addItemToPreferences:dict];
	[self.navigationController popToRootViewControllerAnimated:YES];
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
