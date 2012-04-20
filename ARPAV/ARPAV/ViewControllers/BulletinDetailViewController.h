//
//  BulletinDetailViewController.h
//  ARPAV
//
//  Created by Andrea Mazzini on 20/04/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BulletinDetailViewController : UIViewController <UIWebViewDelegate>
{
	UIWebView*		_webView;
	UIScrollView*	_scrollView;
	UIImageView*	_imageView1;
	UIImageView*	_imageView2;
	UILabel*		_labelCaption1;
	UILabel*		_labelCaption2;
	
	NSDictionary*	_data;
	
	int				_page;
	NSString*		_type;
}

@property (nonatomic, retain) IBOutlet UIWebView*		webView;
@property (nonatomic, retain) IBOutlet UIScrollView*	scrollView;
@property (nonatomic, retain) IBOutlet UIImageView*		imageView1;
@property (nonatomic, retain) IBOutlet UIImageView*		imageView2;
@property (nonatomic, retain) IBOutlet UILabel*			labelCaption1;
@property (nonatomic, retain) IBOutlet UILabel*			labelCaption2;
@property (nonatomic, retain) NSDictionary*				data;

- (id)initWithPageIndex:(int)page andType:(NSString*)type;
- (void)refreshData;

@end
