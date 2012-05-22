//
//  ARPAVMultiViewController.h
//  ARPAV
//
//  Created by Andrea Mazzini on 22/05/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import "ARPAVViewController.h"
#import "MBProgressHUD.h"
#import "SettingsHelper.h"

@interface ARPAVMultiViewController : ARPAVViewController <UpdateDelegate, MBProgressHUDDelegate, UIScrollViewDelegate>
{
	BOOL _notifyNetworkError;
	BOOL _pageControlUsed;
	BOOL _isOffline;
}

@property (nonatomic, assign) IBOutlet UIScrollView*	scrollView;
@property (nonatomic, assign) IBOutlet UIPageControl*	pageControl;
@property (nonatomic, retain) MBProgressHUD*			hud;
@property (nonatomic, retain) id						viewControllers;

- (void)refreshWeather;
- (void)cachePages;
- (void)loadScrollViewWithPage:(int)page;

@end