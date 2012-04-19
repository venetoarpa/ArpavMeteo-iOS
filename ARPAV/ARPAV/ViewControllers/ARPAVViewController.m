//
//  ARPAVViewController.m
//  ARPAV
//
//  Created by Andrea Mazzini on 19/04/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import "ARPAVViewController.h"
#import "UIImageView+WebCache.h"
#import "SettingsHelper.h"

@interface ARPAVViewController ()

@end

@implementation ARPAVViewController

@synthesize imageBanner = _imageBanner;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
		if([[UIScreen mainScreen] scale] == 2) {
			[self.imageBanner setImageWithURL:[NSURL URLWithString:kBanner2xURL] 
							 placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
		} else {
			[self.imageBanner setImageWithURL:[NSURL URLWithString:kBannerURL] 
							 placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
		}
	} else {
		[self.imageBanner setImageWithURL:[NSURL URLWithString:kBannerURL] 
						 placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
	}
}


@end
