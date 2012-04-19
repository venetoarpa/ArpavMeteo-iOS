//
//  WeatherListViewController.h
//  ARPAV
//
//  Created by Andrea Mazzini on 19/04/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsHelper.h"

@interface WeatherListViewController : UIViewController <UIScrollViewDelegate, UpdateDelegate>
{
	UIScrollView*		_scrollView;
	UIPageControl*		_pageControl;
	UILabel*			_labelDate;
	
	NSMutableArray*		_viewControllers;
	
	BOOL				_pageControlUsed;
}

@property (nonatomic, retain) IBOutlet UIScrollView*		scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl*		pageControl;
@property (nonatomic, retain) IBOutlet UILabel*				labelDate;
@property (nonatomic, retain) NSMutableArray*				viewControllers;

- (IBAction)openPreferences:(id)sender;

@end
