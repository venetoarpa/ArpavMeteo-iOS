//
//  CityViewController.h
//  ARPAV
//
//  Created by Andrea Mazzini on 18/04/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARPAVViewController.h"

@interface CityViewController : ARPAVViewController<UITableViewDelegate, UITableViewDataSource>
{
	int						_province;
}

@property (nonatomic, assign) IBOutlet	UITableView*			tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andProvince:(int)province;

@end
