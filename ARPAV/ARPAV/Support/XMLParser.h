//
//  XMLParser.h
//  ARPAV
//
//  Created by Andrea Mazzini on 18/04/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kXMLEmissionDate		@"date"

#define kXMLWeather				@"weather"
#define kXMLWeatherZone			@"zone"
#define kXMLWeatherName			@"name"
#define kXMLWeatherSlots		@"slots"

#define kXMLWeatherRowTitle		@"title"
#define kXMLWeatherRowType		@"type"
#define kXMLWeatherRowValue1	@"value1"
#define kXMLWeatherRowValue2	@"value2"
#define kXMLWeatherRowColumns	@"columns"

#define kXMLBulletin			@"bulletin"
#define kXMLBulletinType		@"type"
#define kXMLBulletinText		@"text"
#define kXMLBulletinName		@"name"
#define kXMLBulletinTitle		@"title"
#define kXMLBulletinSlots		@"slots"
#define kXMLBulletinImg1		@"img1"
#define kXMLBulletinCaption1	@"imgCaption1"
#define kXMLBulletinImg2		@"img2"
#define kXMLBulletinCaption2	@"imgCaption2"

#define kXMLRadar				@"radars"
#define kXMLRadarTitle			@"title"
#define kXMLRadarImage			@"img"

typedef enum {
	kWeather = 0,
	kBulletin
} RootElements;

@protocol XMLParserDelegate <NSObject>

- (void)parserDidEndWithResult:(NSMutableDictionary*)result;
- (void)parserDidFail;

@end

@interface XMLParser : NSObject <NSXMLParserDelegate>
{
	NSMutableDictionary*		_data;
	NSString*					_currentElement;
	RootElements				_currentRoot;
	id <XMLParserDelegate>		_delegate;
}

@property (nonatomic, retain) 	NSMutableDictionary*	data;

+ (XMLParser *)sharedParser;
- (void)parseFileAtPath:(NSString*)path;
- (void)setDelegate:(id<XMLParserDelegate>)delegate;

@end
