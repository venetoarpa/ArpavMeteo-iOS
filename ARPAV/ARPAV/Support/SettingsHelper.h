//
//  SettingsHelper.h
//  ARPAV
//
//  Created by Andrea Mazzini on 18/04/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLParser.h"

#define kMaxPages 10

#define kDefaultsURL	@"http://www.arpa.veneto.it/apparpav/comuni_app.xml"
#define kWeatherURL		@"http://www.arpa.veneto.it/apparpav/bollettino_app.xml"

#define kBannerURL		@"http://www.arpa.veneto.it/apparpav/images/banner_app.png"
#define kBanner2xURL	@"http://www.arpa.veneto.it/apparpav/images/banner_app@2x.png"

@protocol UpdateDelegate <NSObject>

- (void)updateWeatherDidFail;
- (void)updateWeatherSuccess;

@end

@interface SettingsHelper : NSObject <XMLParserDelegate>
{
	NSDictionary*			_defaults;
	NSMutableArray*			_preferences;
	NSDictionary*			_watherData;
	id<UpdateDelegate>		_delegate;
}

@property (nonatomic, retain)	NSDictionary*			defaults;
@property (nonatomic, retain) 	NSMutableArray*			preferences;
@property (nonatomic, retain) 	NSDictionary*			watherData;

+ (SettingsHelper *)sharedHelper;
- (void)loadDefaults;
- (void)savePreferences;
- (void)updateWeatherOnlyOnline:(BOOL)online;
- (NSArray*)getProvinces;
- (NSArray*)getCitiesFromProvince:(int)provId;
- (void)addItemToPreferences:(NSDictionary*)dict;
- (void)removeItemFromPreferences:(int)index;
- (NSArray*)getSlotsForZone:(int)zoneid;
- (void)setUpdateDelegate:(id<UpdateDelegate>)delegate;
- (int)getZoneIdForCity:(int)city_id;

@end
