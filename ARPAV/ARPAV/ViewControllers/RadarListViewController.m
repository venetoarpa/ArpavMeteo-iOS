//
//  RadarListViewController.m
//  ARPAV
//
//  Created by Andrea Mazzini on 17/05/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import "RadarListViewController.h"
#import "RadarDetailViewController.h"
#import "SDImageCache.h"


@interface RadarListViewController ()

@end

@implementation RadarListViewController



- (void)viewDidLoad
{
    [super viewDidLoad];

	[self setTitle:@"Radar"];
		
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																						   target:self 
																						   action:@selector(refreshWeather)];
}

- (void)viewWillAppear:(BOOL)animated
{
	self.viewControllers = nil;
	[super viewWillAppear:animated];
}

- (void)cachePages
{
	int numberOfPages = 0;
	[self.scrollView setAlpha:1];
	[self.pageControl setAlpha:1];
	if ([SettingsHelper sharedHelper].weatherData == nil) {
		[self.scrollView setAlpha:0];
		[self.pageControl setAlpha:0];
		_isOffline = YES;
		[self refreshWeather];
		return;
	} 
	
	numberOfPages = [[[SettingsHelper sharedHelper].weatherData objectForKey:kXMLRadar] count];
	
	if (self.viewControllers == nil) {
		NSMutableArray *controllers = [[NSMutableArray alloc] init];
		for (unsigned i = 0; i < numberOfPages; i++) {
			[controllers addObject:[NSNull null]];
		}
		self.viewControllers = controllers;
		controllers = nil;		
	}
	
	[self.scrollView setAlpha:1];
	self.scrollView.frame = CGRectMake(0, 35, 320, 350);
	self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * numberOfPages, self.scrollView.frame.size.height);
	
	[self.pageControl setAlpha:1];
    self.pageControl.numberOfPages = numberOfPages;
    self.pageControl.currentPage = 0;
	
	// pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
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
		if ([controller isKindOfClass:[RadarDetailViewController class]]) {
			int index = [self.viewControllers indexOfObject:controller];
			if (index > [[[SettingsHelper sharedHelper].weatherData objectForKey:kXMLRadar] count]) {
				return;
			}
			NSDictionary* dict = [[[SettingsHelper sharedHelper].weatherData objectForKey:kXMLRadar] objectAtIndex:index];
			if (dict != nil) {
				[(RadarDetailViewController*)controller refreshDataWithDict:dict];
			}
		}
    }
}

- (void)loadScrollViewWithPage:(int)page
{
	int numberOfPages =  [[[SettingsHelper sharedHelper].weatherData objectForKey:kXMLRadar] count];
	if (page < 0)
        return;
    if (page >= numberOfPages)
        return;
	
	NSDictionary* dict = [[[SettingsHelper sharedHelper].weatherData objectForKey:kXMLRadar] objectAtIndex:page];
	
	if (dict == nil)
		return;
	
    // replace the placeholder if necessary
    RadarDetailViewController *controller = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null]) {
        controller = [[RadarDetailViewController alloc] initWithDictionary:dict];
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
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
}

- (void)viewDidUnload
{
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
