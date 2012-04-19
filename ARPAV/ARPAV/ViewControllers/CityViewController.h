//
//  CityViewController.h
//  ARPAV
//
//  Created by Andrea Mazzini on 18/04/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
	UITableView*			_tableView;
	int						_province;
}

@property (nonatomic, retain) IBOutlet	UITableView*			tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andProvince:(int)province;

@end
