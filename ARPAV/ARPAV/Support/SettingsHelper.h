//
//  SettingsHelper.h
//  ARPAV
//
//  Created by Andrea Mazzini on 18/04/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLParser.h"

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
- (void)updateWeather;
- (NSArray*)getProvinces;
- (NSArray*)getCitiesFromProvince:(int)provId;
- (void)addItemToPreferences:(NSDictionary*)dict;
- (void)removeItemFromPreferences:(int)index;
- (NSArray*)getSlotsForZone:(int)zoneid;
- (void)setUpdateDelegate:(id<UpdateDelegate>)delegate;
- (int)getZoneIdForCity:(int)city_id;

@end
