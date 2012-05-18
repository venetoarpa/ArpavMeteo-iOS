//
//  RadarDetailViewController.m
//  ARPAV
//
//  Created by Andrea Mazzini on 18/05/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import "RadarDetailViewController.h"
#import "UIImageView+WebCache.h"

@interface RadarDetailViewController ()

@end

@implementation RadarDetailViewController
@synthesize imageView = _imageView;
@synthesize labelTitle = _labelTitle;
@synthesize labelError = _labelError;
@synthesize activityIndicator = _activityIndicator;
@synthesize dict = _dict;

- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [super initWithNibName:@"RadarDetailView" bundle:nil];
    if (self) {
		self.dict = dict;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self refreshDataWithDict:self.dict];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)refreshDataWithDict:(NSDictionary*)dict
{
	self.dict = dict;
	NSURL* url = [NSURL URLWithString:[dict objectForKey:@"img"]];
	[self.activityIndicator startAnimating];
	[self.labelError setAlpha:0];
	[self.imageView setImageWithURL:url 
							success:^(UIImage* imageView) { 
								[self.activityIndicator stopAnimating];
							} 
							failure:^(NSError* error){ 
								[self.activityIndicator stopAnimating];								
								[self.labelError setAlpha:1];
							}];
	[self.labelTitle setText:[dict objectForKey:@"title"]];
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setLabelTitle:nil];
	[self setLabelError:nil];
	[self setActivityIndicator:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
