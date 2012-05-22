//
//  BulletinDetailViewController.m
//  ARPAV
//
//  Created by Andrea Mazzini on 20/04/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import "BulletinDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "SettingsHelper.h"

@interface BulletinDetailViewController ()

- (NSString*)checkRetina:(NSString*)source;

@end

@implementation BulletinDetailViewController

@synthesize webView = _webView;
@synthesize scrollView = _scrollView;
@synthesize imageView1 = _imageView1;
@synthesize imageView2 = _imageView2;
@synthesize labelCaption1 = _labelCaption1;
@synthesize labelCaption2 = _labelCaption2;
@synthesize data = _data;

- (id)initWithPageIndex:(int)page andType:(NSString*)type
{
    self = [super initWithNibName:@"BulletinDetailView" bundle:nil];
    if (self) {
		_page = page;
		_type = type;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Remove bouncyness
	for (id subview in self.webView.subviews)
		if ([[subview class] isSubclassOfClass: [UIScrollView class]])
			((UIScrollView *)subview).bounces = NO;
	
	[self refreshData];
}

- (void)setType:(NSString*)type
{
	_type = type;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self refreshData];
}

- (NSString*)checkRetina:(NSString*)source
{
	// checks for retina displays, and appens @2x to the file name
	NSMutableString* ret = [NSMutableString stringWithString:source];
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
		if([[UIScreen mainScreen] scale] == 2) {
			[ret replaceOccurrencesOfString:@".png" 
								withString:@"@2x.png" 
									options:NSUTF8StringEncoding 
									  range:NSMakeRange(0, [source length])];
		} 
	}
	return ret;
}

- (void)refreshData
{
	self.data = [[[SettingsHelper sharedHelper] getBullettinPagesFor:_type] objectAtIndex:_page];

	if ([self.data objectForKey:kXMLBulletinImg2] == nil) {
		// Just one picture
		[self.imageView2 setAlpha:0];
		[self.labelCaption2 setAlpha:0];		
		
		[self.imageView1 setFrame:CGRectMake(80, 30, 160, 160)];
		[self.labelCaption1 setFrame:CGRectMake(80, 10, 160, 20)];
		
		[self.imageView1 setImageWithURL:[NSURL URLWithString:[self checkRetina:[self.data objectForKey:@"img1"]]] 
						placeholderImage:[UIImage imageNamed:@"placeholderMap.png"]];
		
		[self.labelCaption1 setText:[self.data objectForKey:kXMLBulletinCaption1]];
		 
	} else {
		[self.imageView2 setAlpha:1];
		[self.labelCaption2 setAlpha:1];		
		
		[self.imageView1 setFrame:CGRectMake(0, 30, 160, 160)];
		[self.labelCaption1 setFrame:CGRectMake(0, 10, 160, 20)];
		
		[self.imageView1 setImageWithURL:[NSURL URLWithString:[self checkRetina:[self.data objectForKey:@"img1"]]]
						placeholderImage:[UIImage imageNamed:@"placeholderMap.png"]];
		[self.imageView2 setImageWithURL:[NSURL URLWithString:[self checkRetina:[self.data objectForKey:@"img2"]]]
						placeholderImage:[UIImage imageNamed:@"placeholderMap.png"]];
		
		[self.labelCaption1 setText:[self.data objectForKey:kXMLBulletinCaption1]];
		[self.labelCaption2 setText:[self.data objectForKey:kXMLBulletinCaption2]];
	}
	

	NSMutableString* html = [[NSMutableString alloc] initWithString:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\" /></head><body>"];
	[html appendString:[self.data objectForKey:kXMLBulletinText]];
	[html appendString:@"</body></html>"];
	[html replaceOccurrencesOfString:@"\n" withString:@"" options:NSUTF8StringEncoding range:NSMakeRange(0, [html length])];

	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSURL *baseURL = [NSURL fileURLWithPath:path];
	[self.webView setDelegate:self];
	[self.webView loadHTMLString:html baseURL:baseURL];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	// gets the webview height, and stretches it to hold the full content, avoiding a scrollview inside a scrollview
	NSString *output = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"];
	CGRect frame = self.webView.frame;
	frame.size.height = [output intValue] + 20;
	[self.webView setFrame:frame];
	
	[self.scrollView setContentSize:CGSizeMake(320, frame.origin.y + frame.size.height + 20)];
}

- (void)viewDidUnload
{
	[self setWebView:nil];
	[self setScrollView:nil];
	[self setImageView1:nil];
	[self setImageView2:nil];
	[self setLabelCaption1:nil];
	[self setLabelCaption2:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
