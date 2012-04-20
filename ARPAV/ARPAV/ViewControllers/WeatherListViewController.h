//
//  WeatherListViewController.h
//  ARPAV
//
//  Created by Andrea Mazzini on 19/04/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsHelper.h"
#import "MBProgressHUD.h"
#import "ARPAVViewController.h"

@interface WeatherListViewController : ARPAVViewController <UIScrollViewDelegate, UpdateDelegate, MBProgressHUDDelegate>
{
	UIScrollView*		_scrollView;
	UIPageControl*		_pageControl;
	UILabel*			_labelDate;
	UILabel*			_labelError;
	
	NSMutableArray*		_viewControllers;
	
	MBProgressHUD*		_hud;
	BOOL				_notifyNetworkError;
	
	BOOL				_pageControlUsed;
	
	BOOL				_isOffline;
}

@property (nonatomic, retain) IBOutlet UIScrollView*		scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl*		pageControl;
@property (nonatomic, retain) IBOutlet UILabel*				labelDate;
@property (nonatomic, retain) IBOutlet UILabel*				labelError;
@property (nonatomic, retain) NSMutableArray*				viewControllers;
@property (nonatomic, retain) MBProgressHUD*				hud;

- (IBAction)openPreferences:(id)sender;
- (IBAction)buttonBulletin:(id)sender;

@end
