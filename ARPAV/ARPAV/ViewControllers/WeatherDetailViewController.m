//
//  WeatherDetailViewController.m
//  ARPAV
//
//  Created by Andrea Mazzini on 19/04/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import "WeatherDetailViewController.h"
#import "SettingsHelper.h"
#import "WeatherCellDouble.h"
#import "WeatherCellSingle.h"

@interface WeatherDetailViewController ()

@end

@implementation WeatherDetailViewController

@synthesize tableView = _tableView;
@synthesize dataSource = _dataSource;

- (id)initWithZoneId:(int)zoneid
{
    self = [super initWithNibName:@"WeatherDetailView" bundle:nil];
    if (self) {
		_zoneid = zoneid;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSArray* data = [[SettingsHelper sharedHelper] getSlotsForZone:_zoneid];
	if (data != nil) {
		self.dataSource = [[NSArray alloc] initWithArray:data];
	} else {
		self.dataSource = nil;
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	NSArray* data = [[SettingsHelper sharedHelper] getSlotsForZone:_zoneid];
	if (data != nil) {
		self.dataSource = [[NSArray alloc] initWithArray:data];
	} else {
		self.dataSource = nil;
	}
	[self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section < [self.dataSource count]) {
		return [[self.dataSource objectAtIndex:section] count];
	}
	return 0;
}

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 0;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary* dict = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	if ([[dict objectForKey:kXMLWeatherRowType] isEqualToString:kXMLWeatherRowTitle]) {
		return 30;
	}
	return 44;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	NSString* singleIdentifier = @"WeatherCellSingle";
	NSString* doubleIdentifier = @"WeatherCellDouble";
	NSString* singleHeaderIdentifier = @"WeatherHeaderSingle";
	NSString* doubleHeaderIdentifier = @"WeatherHeaderDouble";
	
	NSDictionary* dict = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	
	// Building the header
	if ([[dict objectForKey:kXMLWeatherRowType] isEqualToString:@"title"]) {
		if ([[dict objectForKey:kXMLWeatherRowColumns] intValue] == 1) {
			WeatherCellSingle* cell;
			cell = [self.tableView dequeueReusableCellWithIdentifier:singleHeaderIdentifier];
			
			if (cell == nil) {
				NSArray *nib = [[NSBundle mainBundle] loadNibNamed:singleHeaderIdentifier owner:self options:nil];
				cell = (WeatherCellSingle *)[nib objectAtIndex:0];
			}
			
			cell.title.text = @"";
			cell.value.text = [dict objectForKey:kXMLWeatherRowValue1];
			
			return cell;
		}
		
		if ([[dict objectForKey:kXMLWeatherRowColumns] intValue] == 2) {
			WeatherCellDouble* cell;
			cell = [self.tableView dequeueReusableCellWithIdentifier:doubleHeaderIdentifier];
			
			if (cell == nil) {
				NSArray *nib = [[NSBundle mainBundle] loadNibNamed:doubleHeaderIdentifier owner:self options:nil];
				cell = (WeatherCellDouble *)[nib objectAtIndex:0];
			}
			
			cell.title.text = @"";
			cell.value1.text = [dict objectForKey:kXMLWeatherRowValue1];
			cell.value2.text = [dict objectForKey:kXMLWeatherRowValue2];
			
			return cell;
		}
	}
	
	// Building the content
	if ([[dict objectForKey:kXMLWeatherRowColumns] intValue] == 1) {
		WeatherCellSingle* cell;
		cell = [self.tableView dequeueReusableCellWithIdentifier:singleIdentifier];
		
		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:singleIdentifier owner:self options:nil];
			cell = (WeatherCellSingle *)[nib objectAtIndex:0];
		}
		
		cell.title.text = [dict objectForKey:kXMLWeatherRowTitle];
		
		if ([[dict objectForKey:kXMLWeatherRowType] isEqualToString:@"text"]) {
			cell.value.text = [dict objectForKey:kXMLWeatherRowValue1];
			[cell.value setAlpha:1];
			[cell.image setAlpha:0];
		} 
		
		if ([[dict objectForKey:kXMLWeatherRowType] isEqualToString:@"image"]) {
			cell.image.image = [UIImage imageNamed:[dict objectForKey:kXMLWeatherRowValue1]];
			[cell.value setAlpha:0];
			[cell.image setAlpha:1];
		} 
		
		return cell;
	} 
	
	if ([[dict objectForKey:kXMLWeatherRowColumns] intValue] == 2) {
		WeatherCellDouble* cell;
		cell = [self.tableView dequeueReusableCellWithIdentifier:doubleIdentifier];
		
		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:doubleIdentifier owner:self options:nil];
			cell = (WeatherCellDouble *)[nib objectAtIndex:0];
		}
		
		cell.title.text = [dict objectForKey:kXMLWeatherRowTitle];
		
		if ([[dict objectForKey:kXMLWeatherRowType] isEqualToString:@"text"]) {
			cell.value1.text = [dict objectForKey:kXMLWeatherRowValue1];
			cell.value2.text = [dict objectForKey:kXMLWeatherRowValue2];
			[cell.value1 setAlpha:1];
			[cell.value2 setAlpha:1];
			[cell.image1 setAlpha:0];
			[cell.image2 setAlpha:0];
		} 
		
		if ([[dict objectForKey:kXMLWeatherRowType] isEqualToString:@"image"]) {
			cell.image1.image = [UIImage imageNamed:[dict objectForKey:kXMLWeatherRowValue1]];
			cell.image2.image = [UIImage imageNamed:[dict objectForKey:kXMLWeatherRowValue2]];
			[cell.value1 setAlpha:0];
			[cell.value2 setAlpha:0];
			[cell.image1 setAlpha:1];
			[cell.image2 setAlpha:1];
		} 
		
		return cell;
	} 
	
	return nil;
}

- (void)refreshData
{
	NSArray* data = [[SettingsHelper sharedHelper] getSlotsForZone:_zoneid];
	self.dataSource = [[NSArray alloc] initWithArray:data];
	[self.tableView reloadData];
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
