//
//  BulletinListViewController.m
//  ARPAV
//
//  Created by Andrea Mazzini on 20/04/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import "BulletinListViewController.h"
#import "BulletinDetailViewController.h"
#import "XMLParser.h"


@interface BulletinListViewController ()

- (void)loadScrollViewWithPage:(int)page;
- (void)updatePageTitle;

@end

@implementation BulletinListViewController

@synthesize currentPages = _currentPages;
@synthesize labelTitle = _labelTitle;


- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.navigationController.navigationBar.backItem.title = @"Meteo";
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																						   target:self 
																						   action:@selector(refreshWeather)];
	
	
	self.currentPages = [[NSMutableDictionary alloc] init];
	[self.currentPages setObject:[NSNumber numberWithInt:0] forKey:kTypeVeneto];
	[self.currentPages setObject:[NSNumber numberWithInt:0] forKey:kTypePianura];
	[self.currentPages setObject:[NSNumber numberWithInt:0] forKey:kTypeDolomiti];	
	
	_type = kTypeVeneto;
	
	self.labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 220, 30)];
	[self.labelTitle setFont:[UIFont boldSystemFontOfSize:12.0]];
	[self.labelTitle setBackgroundColor:[UIColor clearColor]];
	[self.labelTitle setTextColor:[UIColor whiteColor]];
	[self.labelTitle setTextAlignment:UITextAlignmentCenter];
	[self.labelTitle setNumberOfLines:2];
	[[self navigationItem] setTitleView:self.labelTitle];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)cachePages
{
	int numberOfPages =  [[SettingsHelper sharedHelper] getBullettinPagesCountFor:_type];
	[self.scrollView setAlpha:1];
	[self.pageControl setAlpha:1];	
	if (numberOfPages == 0) {
		[self.scrollView setAlpha:0];
		[self.pageControl setAlpha:0];
		[self setTitle:@"Bollettino Meteo"];
		_isOffline = YES;
		return;
	} 
	
	if (self.viewControllers == nil) {
		self.viewControllers = [[NSMutableDictionary alloc] init];
		
		// VCs stored in arrays, inside a dictionary
		// This should be refactored to unload the currently non used views for a specific type
		[self.viewControllers setObject:[[NSMutableArray alloc] init] forKey:kTypeVeneto];		
		for (unsigned i = 0; i < kMaxPages; i++) {
			[[self.viewControllers objectForKey:kTypeVeneto] addObject:[NSNull null]];
		}

		[self.viewControllers setObject:[[NSMutableArray alloc] init] forKey:kTypePianura];		
		for (unsigned i = 0; i < kMaxPages; i++) {
			[[self.viewControllers objectForKey:kTypePianura] addObject:[NSNull null]];
		}

		[self.viewControllers setObject:[[NSMutableArray alloc] init] forKey:kTypeDolomiti];		
		for (unsigned i = 0; i < kMaxPages; i++) {
			[[self.viewControllers objectForKey:kTypeDolomiti] addObject:[NSNull null]];
		}
	}
	
	[self.scrollView setAlpha:1];
	self.scrollView.frame = CGRectMake(0, 35, 320, 315);
	self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * numberOfPages, self.scrollView.frame.size.height);
	
	[self.pageControl setAlpha:1];
    self.pageControl.numberOfPages = numberOfPages;
	
	int currentPage = [[self.currentPages objectForKey:_type] intValue];
	if (currentPage >= numberOfPages) {
		currentPage = 0;
	}
    self.pageControl.currentPage = currentPage;
	
    
	// pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
	[self loadScrollViewWithPage:currentPage - 1];
    [self loadScrollViewWithPage:currentPage];
    [self loadScrollViewWithPage:currentPage + 1];
	
	CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * currentPage;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:NO];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    _pageControlUsed = YES;
	
	[self updatePageTitle];
}

- (void)updateWeatherSuccess
{
	[self.hud hide:YES];
	_notifyNetworkError = NO;
	
	if (_isOffline) {
		_isOffline = NO;
		[self performSelectorOnMainThread:@selector(cachePages) withObject:self waitUntilDone:YES];
	}
	for (UIViewController* controller in [self.viewControllers objectForKey:kTypeVeneto]) {
		if ([controller isKindOfClass:[BulletinDetailViewController class]]) {
			[(BulletinDetailViewController*)controller refreshData];
		}
    }
	for (UIViewController* controller in [self.viewControllers objectForKey:kTypePianura]) {
		if ([controller isKindOfClass:[BulletinDetailViewController class]]) {
			[(BulletinDetailViewController*)controller refreshData];
		}
    }
	for (UIViewController* controller in [self.viewControllers objectForKey:kTypeDolomiti]) {
		if ([controller isKindOfClass:[BulletinDetailViewController class]]) {
			[(BulletinDetailViewController*)controller refreshData];
		}
    }
}

- (void)loadScrollViewWithPage:(int)page
{
	int numberOfPages =  [[SettingsHelper sharedHelper] getBullettinPagesCountFor:_type];
	if (page < 0)
        return;
    if (page >= numberOfPages)
        return;
	
    // replace the placeholder if necessary
    BulletinDetailViewController *controller = [[self.viewControllers objectForKey:_type] objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null]) {
        controller = [[BulletinDetailViewController alloc] initWithPageIndex:page andType:_type];
        [[self.viewControllers objectForKey:_type] replaceObjectAtIndex:page withObject:controller];
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
	[self.currentPages setObject:[NSNumber numberWithInt:page] forKey:_type];
    
	[self updatePageTitle];
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (IBAction)segmentChanged:(id)sender
{
	UISegmentedControl* segment = (UISegmentedControl*)sender;
	
	for (UIViewController* controller in [self.viewControllers objectForKey:_type]) {
		if ([controller isKindOfClass:[BulletinDetailViewController class]]) {
			UIView* subview = controller.view;
			[subview removeFromSuperview];
		}
    }
	
	switch ([segment selectedSegmentIndex]) {
		case 0:
			_type = kTypeVeneto;
			break;
		case 1:
			_type = kTypeDolomiti;
			break;
		case 2:
			_type = kTypePianura;
			break;			
		default:
			break;
	}
	[self cachePages];
}

- (void)updatePageTitle
{
	[self.labelTitle setText:[NSString stringWithFormat:@"%@\n%@", [[SettingsHelper sharedHelper] getBullettinNameFor:_type],
							  [[SettingsHelper sharedHelper] getBullettinTitleFor:_type]]];
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
