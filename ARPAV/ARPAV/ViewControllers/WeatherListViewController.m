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

#define kMaxPages 10

@interface WeatherListViewController ()

- (void)presentPreferencesAnimated:(BOOL)animated;
- (void)loadScrollViewWithPage:(int)page;
- (void)updatePageTitle;

@end

@implementation WeatherListViewController

@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize viewControllers = _viewControllers;
@synthesize labelDate = _labelDate;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self setTitle:@"Meteo"];
	if ([[SettingsHelper sharedHelper].preferences count] == 0) {
		[self presentPreferencesAnimated:NO];
	}
	
	self.scrollView.pagingEnabled = YES;
	self.scrollView.showsHorizontalScrollIndicator = NO;
	self.scrollView.showsVerticalScrollIndicator = NO;
	self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    self.scrollView.alwaysBounceHorizontal = NO;
	self.scrollView.bounces = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[[SettingsHelper sharedHelper] setUpdateDelegate:self];
	
	int numberOfPages =  [[SettingsHelper sharedHelper].preferences count];
	
	if (numberOfPages == 0) {
		[self.scrollView setAlpha:0];
		[self.pageControl setAlpha:0];
		[self setTitle:@"Meteo"];
		return;
	}
	
	NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < kMaxPages; i++) {
		[controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    controllers = nil;
	
	[self.scrollView setAlpha:1];
	self.scrollView.frame = CGRectMake(0, 0, 320, 350);
	self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * numberOfPages, self.scrollView.frame.size.height);
	
    self.pageControl.numberOfPages = numberOfPages;
    self.pageControl.currentPage = 0;
    
    // pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
	
	[self updatePageTitle];
}

- (void)updateWeatherDidFail
{
	NSLog(@"failed update");
}

- (void)updateWeatherSuccess
{
	for (UIViewController* controller in self.viewControllers) {
		if ([controller isKindOfClass:[WeatherDetailViewController class]]) {
			[(WeatherDetailViewController*)controller refreshData];
		}
    }
	self.labelDate.text = [[SettingsHelper sharedHelper].watherData objectForKey:@"date"];
}

- (IBAction)openPreferences:(id)sender
{
	[self presentPreferencesAnimated:YES];
}

- (void)presentPreferencesAnimated:(BOOL)animated
{
	PreferencesViewController* viewController = [[PreferencesViewController alloc] initWithNibName:@"PreferencesView" bundle:nil];
	UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[navigationController.navigationBar setBarStyle:UIBarStyleBlack];
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _pageControlUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _pageControlUsed = NO;
}

- (IBAction)changePage:(id)sender
{
    int page = self.pageControl.currentPage;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
	// update the scroll view to the appropriate page
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    _pageControlUsed = YES;
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
