//
//  BulletinListViewController.h
//  ARPAV
//
//  Created by Andrea Mazzini on 20/04/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARPAVMultiViewController.h"
#import "MBProgressHUD.h"
#import "SettingsHelper.h"

@interface BulletinListViewController : ARPAVMultiViewController
{
	NSString*			_type;
}

@property (nonatomic, retain) UILabel*						labelTitle;
@property (nonatomic, retain) NSMutableDictionary*			currentPages;

- (IBAction)segmentChanged:(id)sender;

@end
