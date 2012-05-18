//
//  WeatherCellSingle.h
//  ARPAV
//
//  Created by Andrea Mazzini on 19/04/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeatherCellSingle : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel*		title;
@property (nonatomic, retain) IBOutlet UILabel*		value;
@property (nonatomic, retain) IBOutlet UIImageView*	image;
@property (nonatomic, retain) IBOutlet UIImageView*	imageBack;

@end
