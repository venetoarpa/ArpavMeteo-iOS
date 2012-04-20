//
//  BulletinListViewController.h
//  ARPAV
//
//  Created by Andrea Mazzini on 20/04/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARPAVViewController.h"
#import "MBProgressHUD.h"
#import "SettingsHelper.h"

@interface BulletinListViewController : ARPAVViewController <UIScrollViewDelegate, UpdateDelegate, MBProgressHUDDelegate>
{
	UIScrollView*		_scrollView;
	UIPageControl*		_pageControl;
	
	NSMutableDictionary* _viewControllers;
	
	MBProgressHUD*		_hud;
	BOOL				_notifyNetworkError;
	
	BOOL				_pageControlUsed;
	
	NSMutableDictionary* _currentPages;
	
	BOOL				_isOffline;
	NSString*			_type;
	
	UILabel*			_labelTitle;
}

@property (nonatomic, retain) IBOutlet UIScrollView*		scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl*		pageControl;
@property (nonatomic, retain) NSMutableDictionary*			viewControllers;
@property (nonatomic, retain) NSMutableDictionary*			currentPages;
@property (nonatomic, retain) MBProgressHUD*				hud;
@property (nonatomic, retain) UILabel*						labelTitle;

- (IBAction)segmentChanged:(id)sender;


@end
