//
//  ARPAVMultiViewController.m
//  ARPAV
//
//  Created by Andrea Mazzini on 22/05/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import "ARPAVMultiViewController.h"

@interface ARPAVMultiViewController ()


@end

@implementation ARPAVMultiViewController

@synthesize scrollView = _scrollView;
@synthesize	pageControl = _pageControl;
@synthesize hud = _hud;
@synthesize viewControllers = _viewControllers;


- (void)viewDidLoad
{
    [super viewDidLoad];

	_notifyNetworkError = NO;
	
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

- (void)viewDidUnload
{
	[self setPageControl:nil];
	[self setScrollView:nil];
    [super viewDidUnload];
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
	
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _pageControlUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _pageControlUsed = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[SettingsHelper sharedHelper] setUpdateDelegate:nil];
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

- (void)cachePages
{
	
}

- (void)loadScrollViewWithPage:(int)page
{
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
