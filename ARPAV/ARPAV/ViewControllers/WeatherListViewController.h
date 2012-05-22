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
#import "ARPAVMultiViewController.h"

@interface WeatherListViewController : ARPAVMultiViewController

@property (nonatomic, assign) IBOutlet UILabel*				labelDate;
@property (nonatomic, assign) IBOutlet UILabel*				labelError;

- (IBAction)openPreferences:(id)sender;
- (IBAction)buttonBulletin:(id)sender;

@end
