//
//  ProvinceViewController.h
//  ARPAV
//
//  Created by Andrea Mazzini on 18/04/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProvinceViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	UITableView*			_tableView;
}

@property (nonatomic, retain) IBOutlet	UITableView*			tableView;


@end
