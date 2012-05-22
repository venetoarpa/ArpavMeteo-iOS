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
	int				_page;
	NSString*		_type;
}

@property (nonatomic, assign) IBOutlet UIWebView*		webView;
@property (nonatomic, assign) IBOutlet UIScrollView*	scrollView;
@property (nonatomic, assign) IBOutlet UIImageView*		imageView1;
@property (nonatomic, assign) IBOutlet UIImageView*		imageView2;
@property (nonatomic, assign) IBOutlet UILabel*			labelCaption1;
@property (nonatomic, assign) IBOutlet UILabel*			labelCaption2;
@property (nonatomic, retain) NSDictionary*				data;

- (id)initWithPageIndex:(int)page andType:(NSString*)type;
- (void)refreshData;

@end
