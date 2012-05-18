//
//  RadarDetailViewController.h
//  ARPAV
//
//  Created by Andrea Mazzini on 18/05/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RadarDetailViewController : UIViewController

@property (retain, nonatomic) NSDictionary*	dict;
@property (assign, nonatomic) IBOutlet UIImageView *imageView;
@property (assign, nonatomic) IBOutlet UILabel *labelTitle;
@property (assign, nonatomic) IBOutlet UILabel *labelError;
@property (assign, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (id)initWithDictionary:(NSDictionary*)dict;
- (void)refreshDataWithDict:(NSDictionary*)dict;

@end
