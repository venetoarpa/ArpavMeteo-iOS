//
//  RadarListViewController.h
//  ARPAV
//
//  Created by Andrea Mazzini on 17/05/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsHelper.h"
#import "ARPAVViewController.h"
#import "MBProgressHUD.h"

@interface RadarListViewController : ARPAVViewController <UpdateDelegate, UIScrollViewDelegate, MBProgressHUDDelegate>
{
	BOOL				_notifyNetworkError;
	BOOL				_pageControlUsed;
	BOOL				_isOffline;
}

@property (nonatomic, assign) IBOutlet UIScrollView*	scrollView;
@property (nonatomic, assign) IBOutlet UIPageControl*	pageControl;
@property (nonatomic, retain) MBProgressHUD*	hud;
@property (nonatomic, retain) NSMutableArray*	viewControllers;

@end
