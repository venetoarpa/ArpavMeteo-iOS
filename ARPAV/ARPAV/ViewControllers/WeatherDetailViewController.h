//
//  WeatherDetailViewController.h
//  ARPAV
//
//  Created by Andrea Mazzini on 19/04/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeatherDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	UITableView*		_tableView;
	NSArray*			_dataSource;
	int					_zoneid;
}

@property (nonatomic, retain) IBOutlet	UITableView*		tableView;
@property (nonatomic, retain) NSArray*						dataSource;

- (id)initWithZoneId:(int)zoneid;
- (void)refreshData;

@end
