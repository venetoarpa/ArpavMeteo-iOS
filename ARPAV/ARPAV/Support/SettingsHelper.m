//
//  SettingsHelper.m
//  ARPAV
//
//  Created by Andrea Mazzini on 18/04/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import "SettingsHelper.h"
#import "SDImageCache.h"

@interface SettingsHelper()

- (NSString *)applicationDocumentsDirectory;
- (void)updateDefaults;

@end

@implementation SettingsHelper

@synthesize defaults = _defaults;
@synthesize preferences = _preferences;
@synthesize weatherData = _weatherData;

static SettingsHelper *sharedHelper;

+ (SettingsHelper *)sharedHelper
{
	if (!sharedHelper)
		sharedHelper = [[SettingsHelper alloc] init];
	
	return sharedHelper;
}

+ (id)alloc
{
	NSAssert(sharedHelper == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

- (NSString *)applicationDocumentsDirectory 
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)loadDefaults
{
	NSString *prefsPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Preferences.plist"];

	// Load user preferences
	if ([[NSFileManager defaultManager] fileExistsAtPath:prefsPath]) {
		self.preferences = [[NSMutableArray alloc] initWithContentsOfFile:prefsPath];
	} else {
		self.preferences = [[NSMutableArray alloc] init];
	}
	
	// Default data paths
	NSString *plistPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Defaults.plist"];
	NSString *docPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Defaults.plist"];
	
	// Install default data
	if (![[NSFileManager defaultManager] fileExistsAtPath:docPath]) {
		[[NSFileManager defaultManager] copyItemAtPath:plistPath toPath:docPath error:nil];
	}
	
	self.defaults = [[NSDictionary alloc] initWithContentsOfFile:docPath];
	
	NSUserDefaults*	defaults = [NSUserDefaults standardUserDefaults];
	BOOL timePassed = NO;
	
	// Update default data every day
	NSTimeInterval last = [defaults floatForKey:@"lastUpdate"];
	timePassed = (([[NSDate date] timeIntervalSince1970] - last) > 86400);  // 1 day
	
	if(timePassed) {
		[self updateDefaults];	// Update Defaults in a separate thread
		[defaults setFloat:[[NSDate date] timeIntervalSince1970] forKey:@"lastUpdate"];
	}

}

- (void)setUpdateDelegate:(id<UpdateDelegate>)delegate
{
	_delegate = delegate;
}

- (void)savePreferences
{
	// Save user preferences to disk
	if (self.preferences == nil) {
		return;
	}
	NSString *prefsPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Preferences.plist"];
	[self.preferences writeToFile:prefsPath atomically:YES];
}

- (void)updateWeatherOnlyOnline:(BOOL)online
{
	// Downloads an updated weather dispatch. With (online == NO) first loads up the cached version
	
	// First load the previous cached weather info, if available
	[[XMLParser sharedParser] setDelegate:self];
	
	if (!online) {	
		NSString *filePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"bollettino_app.xml"];
		if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
			[[XMLParser sharedParser] parseFileAtPath:filePath];
		}
	}

	// New GCD queue that will handle the blocking update operation
	dispatch_queue_t updateQueue = dispatch_queue_create("Weather queue", nil);
	dispatch_async(updateQueue, ^{
		NSError* error;
		NSString *update = [NSString stringWithContentsOfURL:[NSURL URLWithString:kWeatherURL] 
													encoding:NSUTF8StringEncoding 
													   error:&error];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			NSString *filePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"bollettino_app.xml"];
			if (error == nil) {
				[update writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
				[[XMLParser sharedParser] parseFileAtPath:filePath];
			} else {
				[_delegate updateWeatherDidFail];
			}
		});
	});
	dispatch_release(updateQueue);
}

- (void)parserDidEndWithResult:(NSMutableDictionary*)result
{
	@synchronized(self) {
		self.weatherData = [[NSDictionary alloc] initWithDictionary:result];
	}
	
	// Clears disk cache. Since the radar images always have the same name, a weak cache policy is required
	SDImageCache *imageCache = [SDImageCache sharedImageCache];
	[imageCache clearMemory];
	[imageCache clearDisk];
	[imageCache cleanDisk];
	[_delegate updateWeatherSuccess];
}

- (void)parserDidFail
{
	[_delegate updateWeatherDidFail];
}

- (void)updateDefaults
{
	// GCD queue that handles blocking update operations for the App Defaults
	dispatch_queue_t updateQueue = dispatch_queue_create("Defaults queue", nil);
	dispatch_async(updateQueue, ^{
		NSString *update = [NSString stringWithContentsOfURL:[NSURL URLWithString:kDefaultsURL] 
													encoding:NSUTF8StringEncoding 
													   error:nil];
		
		NSString *filePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Defaults.plist"];
		[update writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
	});
	dispatch_release(updateQueue);
}	

- (NSArray*)getProvinces
{
	if ([[self.defaults objectForKey:@"info_zone"] count] < 2) {
		return nil;
	}
	return [[self.defaults objectForKey:@"info_zone"] objectAtIndex:1];
}

- (NSArray*)getCitiesFromProvince:(int)provId
{
	if (provId > [[[self.defaults objectForKey:@"info_zone"] objectAtIndex:1] count]) {
		return nil;
	}
	return [[[[self.defaults objectForKey:@"info_zone"] objectAtIndex:1] objectAtIndex:provId] objectForKey:@"comuni"];
}

- (void)addItemToPreferences:(NSDictionary*)dict
{
	if ([self.preferences count] >= kMaxPages) {
		return;
	}
	// checks for double entries
	for (NSDictionary* pref in self.preferences) {
		if ([[pref objectForKey:@"id"] intValue] == [[dict objectForKey:@"id"] intValue]) {
			return;
		}
	}
	[self.preferences addObject:dict];
}

- (void)removeItemFromPreferences:(int)index
{
	if (index >= [self.preferences count]) {
		return;
	}
	[self.preferences removeObjectAtIndex:index];
}

- (NSArray*)getSlotsForZone:(int)zoneid
{
	for (NSDictionary* dict in [self.weatherData objectForKey:kXMLWeather]) {
		if ([[dict objectForKey:kXMLWeatherZone] intValue]== zoneid) {
			return [dict objectForKey:kXMLWeatherSlots];
		}
	}
	
	return nil;
}

- (int)getZoneIdForCity:(int)city_id
{
	NSArray* provinces = [[self.defaults objectForKey:@"info_zone"] objectAtIndex:1];
	for (NSDictionary* dict in provinces) {
		NSArray* cities = [dict objectForKey:@"comuni"];
		for (NSDictionary* city in cities) {
			if ([[city objectForKey:@"id"] intValue] == city_id) {
				return [[city objectForKey:@"zoneid"] intValue];
			}
		}
	}
	return -1;
}

- (int)getBullettinPagesCountFor:(NSString*)type
{
	for (NSDictionary* dict in [self.weatherData objectForKey:kXMLBulletin]) {
		if ([[dict objectForKey:kXMLBulletinType] isEqualToString:type]) {
			return [[dict objectForKey:kXMLBulletinSlots] count];
		}
	}
	return 0;
}

- (NSString*)getBullettinNameFor:(NSString*)type
{
	for (NSDictionary* dict in [self.weatherData objectForKey:kXMLBulletin]) {
		if ([[dict objectForKey:kXMLBulletinType] isEqualToString:type]) {
			return [dict objectForKey:kXMLBulletinName];
		}
	}
	return @"Bollettino";
}

- (NSString*)getBullettinTitleFor:(NSString*)type
{
	for (NSDictionary* dict in [self.weatherData objectForKey:kXMLBulletin]) {
		if ([[dict objectForKey:kXMLBulletinType] isEqualToString:type]) {
			return [dict objectForKey:kXMLBulletinTitle];
		}
	}
	return @"Bollettino";
}

- (NSArray*)getBullettinPagesFor:(NSString*)type
{
	for (NSDictionary* dict in [self.weatherData objectForKey:kXMLBulletin]) {
		if ([[dict objectForKey:kXMLBulletinType] isEqualToString:type]) {
			return [dict objectForKey:kXMLBulletinSlots];
		}
	}
	return nil;
}

- (void)movePreferenceAtIndex:(int)source toIndex:(int)destination
{
	[self.preferences exchangeObjectAtIndex:source withObjectAtIndex:destination];
}

@end
