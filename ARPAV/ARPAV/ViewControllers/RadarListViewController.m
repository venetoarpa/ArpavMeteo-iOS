//
//  RadarListViewController.m
//  ARPAV
//
//  Created by Andrea Mazzini on 17/05/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import "RadarListViewController.h"
#import "RadarDetailViewController.h"


@interface RadarListViewController ()

- (void)cachePages;

@end

@implementation RadarListViewController

@synthesize scrollView = _scrollView;
@synthesize	pageControl = _pageControl;
@synthesize hud = _hud;
@synthesize viewControllers = _viewControllers;

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self setTitle:@"Radar"];
	
	_notifyNetworkError = NO;
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																						   target:self 
																						   action:@selector(refreshWeather)];
	
	self.scrollView.pagingEnabled = YES;
	self.scrollView.showsHorizontalScrollIndicator = NO;
	self.scrollView.showsVerticalScrollIndicator = NO;
	self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    self.scrollView.alwaysBounceHorizontal = NO;
	self.scrollView.bounces = NO;
	
	self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.hud setMode:MBProgressHUDModeIndeterminate];
	[self.hud setLabelText:@"Aggiornamento..."];
	
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[[SettingsHelper sharedHelper] setUpdateDelegate:self];
	self.viewControllers = nil;
	[self cachePages];
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
	
	numberOfPages = [[[SettingsHelper sharedHelper].weatherData objectForKey:@"radars"] count];
	
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

- (void)refreshWeather
{
	[self.navigationController.view addSubview:self.hud];
	[self.hud setDelegate:self];
	[self.hud show:YES];
	_notifyNetworkError = YES;
	[[SettingsHelper sharedHelper] updateWeatherOnlyOnline:YES];
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
	[hud removeFromSuperview];
}

- (void)updateWeatherDidFail
{
	[self.hud hide:YES];
	if (_notifyNetworkError) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Errore"
														message:@"Impossibile aggiornare i dati, verificare la connessione e riprovare."
													   delegate:nil
											  cancelButtonTitle:@"Ok"
											  otherButtonTitles:nil];
		[alert show];
	}
	
	_notifyNetworkError = NO;
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
			if (index > [[[SettingsHelper sharedHelper].weatherData objectForKey:@"radars"] count]) {
				return;
			}
			NSDictionary* dict = [[[SettingsHelper sharedHelper].weatherData objectForKey:@"radars"] objectAtIndex:index];
			if (dict != nil) {
				[(RadarDetailViewController*)controller refreshDataWithDict:dict];
			}
		}
    }
}

- (void)loadScrollViewWithPage:(int)page
{
	int numberOfPages =  [[[SettingsHelper sharedHelper].weatherData objectForKey:@"radars"] count];
	if (page < 0)
        return;
    if (page >= numberOfPages)
        return;
	
	NSDictionary* dict = [[[SettingsHelper sharedHelper].weatherData objectForKey:@"radars"] objectAtIndex:page];
	
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

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[SettingsHelper sharedHelper] setUpdateDelegate:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
