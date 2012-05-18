//
//  WeatherCellDouble.h
//  ARPAV
//
//  Created by Andrea Mazzini on 19/04/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeatherCellDouble : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel*		title;
@property (nonatomic, retain) IBOutlet UILabel*		value1;
@property (nonatomic, retain) IBOutlet UILabel*		value2;	
@property (nonatomic, retain) IBOutlet UIImageView*	image1;
@property (nonatomic, retain) IBOutlet UIImageView*	image2;
@property (nonatomic, retain) IBOutlet UIImageView*	imageBack;


@end
