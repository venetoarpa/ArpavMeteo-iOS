//
//  WeatherListViewController.m
//  ARPAV
//
//  Created by Andrea Mazzini on 19/04/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import "WeatherListViewController.h"
#import "PreferencesViewController.h"
#import "WeatherDetailViewController.h"
#import "BulletinListViewController.h"
#import "RadarListViewController.h"

@interface WeatherListViewController ()

- (void)presentPreferencesAnimated:(BOOL)animated;
- (void)loadScrollViewWithPage:(int)page;
- (void)updatePageTitle;

@end

@implementation WeatherListViewController

@synthesize labelDate = _labelDate;
@synthesize labelError = _labelError;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self setTitle:@"Meteo"];
	
	if ([[SettingsHelper sharedHelper].preferences count] == 0) {
		[self presentPreferencesAnimated:NO];
	}
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																						   target:self 
																						   action:@selector(refreshWeather)];

	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Preferiti" 
																			  style:UIBarButtonItemStylePlain 
																			 target:self 
																			 action:@selector(presentPreferencesAnimated:)];
	
}

- (IBAction)radarButton:(id)sender 
{
	RadarListViewController* viewController = [[RadarListViewController alloc] initWithNibName:@"RadarListView" bundle:nil];
	[self setTitle:@"Meteo"];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
	self.viewControllers = nil;
	[super viewWillAppear:animated];
}

- (void)cachePages
{
	int numberOfPages =  [[SettingsHelper sharedHelper].preferences count];
	[self.scrollView setAlpha:1];
	[self.pageControl setAlpha:1];
	if (numberOfPages == 0 || [SettingsHelper sharedHelper].weatherData == nil) {
		[self.scrollView setAlpha:0];
		[self.pageControl setAlpha:0];
		[self setTitle:@"Meteo"];
		[self.labelError setText:@"Aggiungi i tuoi comuni preferiti cliccando sul tasto Modifica"];
		
		if ([SettingsHelper sharedHelper].weatherData == nil) {
			_isOffline = YES;
			[self.labelError setText:@"Impossibile aggiornare i dati, verificare la connessione e riprovare."];
			[self refreshWeather];
		}
		return;
	} 

	if (self.viewControllers == nil) {
		NSMutableArray *controllers = [[NSMutableArray alloc] init];
		for (unsigned i = 0; i < kMaxPages; i++) {
			[controllers addObject:[NSNull null]];
		}
		self.viewControllers = controllers;
		controllers = nil;		
	}
	
	[self.scrollView setAlpha:1];
	self.scrollView.frame = CGRectMake(0, 35, 320, 315);
	self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * numberOfPages, self.scrollView.frame.size.height);
	
	[self.pageControl setAlpha:1];
    self.pageControl.numberOfPages = numberOfPages;
    self.pageControl.currentPage = 0;
	
	self.labelDate.text = [[SettingsHelper sharedHelper].weatherData objectForKey:@"date"];
	
	// pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
	
	[self updatePageTitle];

}

- (IBAction)buttonBulletin:(id)sender
{
	BulletinListViewController* viewController = [[BulletinListViewController alloc] initWithNibName:@"BulletinListView" bundle:nil];
	[self setTitle:@"Meteo"];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)updateWeatherSuccess
{

	if (_isOffline) {
		_isOffline = NO;
		[self cachePages];
	}
	[self.hud hide:YES];
	_notifyNetworkError = NO;
	for (UIViewController* controller in self.viewControllers) {
		if ([controller isKindOfClass:[WeatherDetailViewController class]]) {
			[(WeatherDetailViewController*)controller refreshData];
		}
    }
	self.labelDate.text = [[SettingsHelper sharedHelper].weatherData objectForKey:@"date"];
	
}

- (IBAction)openPreferences:(id)sender
{
	[self presentPreferencesAnimated:YES];
}

- (void)presentPreferencesAnimated:(BOOL)animated
{
	PreferencesViewController* viewController = [[PreferencesViewController alloc] initWithNibName:@"PreferencesView" bundle:nil];
	UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.25f green:0.60f blue:0.95f alpha:1];
//	[navigationController.navigationBar setBarStyle:UIBarStyleBlack];
	[self presentModalViewController:navigationController animated:animated];
}

- (void)loadScrollViewWithPage:(int)page
{
	int numberOfPages =  [[SettingsHelper sharedHelper].preferences count];
	if (page < 0)
        return;
    if (page >= numberOfPages)
        return;
	
	int city_id = [[[[SettingsHelper sharedHelper].preferences objectAtIndex:page] objectForKey:@"id"] intValue];
	int zoneid = [[SettingsHelper sharedHelper] getZoneIdForCity:city_id];
	
	if (zoneid < 0)
		return;
	
    // replace the placeholder if necessary
    WeatherDetailViewController *controller = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null]) {
        controller = [[WeatherDetailViewController alloc] initWithZoneId:zoneid];
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil) {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [self.scrollView addSubview:controller.view];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    if (_pageControlUsed) {
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
	[self updatePageTitle];
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
}

- (void)updatePageTitle
{
	CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;

 	int numberOfPages =  [[SettingsHelper sharedHelper].preferences count];
	if (page < 0)
        return;
    if (page >= numberOfPages)
        return;   
	
	[self setTitle:[[[SettingsHelper sharedHelper].preferences objectAtIndex:page] objectForKey:@"name"]]; 
}

- (void)viewDidUnload
{
	[self setLabelDate:nil];
	[self setLabelError:nil];
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
