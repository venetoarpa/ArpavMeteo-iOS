//
//  XMLParser.m
//  ARPAV
//
//  Created by Andrea Mazzini on 18/04/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import "XMLParser.h"

@implementation XMLParser

@synthesize data = _data;

static XMLParser *sharedParser;

+ (XMLParser *)sharedParser
{
	if (!sharedParser)
		sharedParser = [[XMLParser alloc] init];
	
	return sharedParser;
}

+ (id)alloc
{
	NSAssert(sharedParser == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

- (void)parseFileAtPath:(NSString*)path
{
	NSURL *xmlFile = [NSURL fileURLWithPath:path];
	NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL:xmlFile];
	[parser setDelegate:self];
	[parser parse];
}

- (void)setDelegate:(id<XMLParserDelegate>)delegate
{
	_delegate = delegate;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	self.data = [[NSMutableDictionary alloc] init];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	[_delegate parserDidEndWithResult:self.data];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:@"data_emissione"]) {
		[self.data setObject:[attributeDict objectForKey:@"date"] forKey:kXMLEmissionDate];
	}
	
	if ([elementName isEqualToString:@"meteogrammi"]) {
		_currentRoot = kWeather;
		NSMutableArray* tempArray = [[NSMutableArray alloc] init];
		[self.data setObject:tempArray forKey:kXMLWeather];
	}
	
	if ([elementName isEqualToString:@"meteogramma"]) {
		NSMutableDictionary* tempDict = [[NSMutableDictionary alloc] init];
		NSMutableArray* tempArray = [[NSMutableArray alloc] init];	
		NSNumber* zoneid = [NSNumber numberWithInt:[[attributeDict objectForKey:@"zoneid"] intValue]];
		[tempDict setObject:zoneid forKey:kXMLWeatherZone];
		[tempDict setObject:[attributeDict objectForKey:@"name"] forKey:kXMLWeatherName];
		[tempDict setObject:tempArray forKey:kXMLWeatherSlots];
		[[self.data objectForKey:kXMLWeather] addObject:tempDict];
	}
	
	if ([elementName isEqualToString:@"slot"] && _currentRoot == kWeather) {
		NSMutableArray* tempArray = [[NSMutableArray alloc] init];	
		[[[[self.data objectForKey:kXMLWeather] lastObject] objectForKey:kXMLWeatherSlots] addObject:tempArray];
	}
	
	if ([elementName isEqualToString:@"single_row"]) {
		NSMutableDictionary* tempDict = [[NSMutableDictionary alloc] init];
		[tempDict setObject:[attributeDict objectForKey:@"title"] forKey:kXMLWeatherRowTitle];
		[tempDict setObject:[attributeDict objectForKey:@"type"] forKey:kXMLWeatherRowType];
		[tempDict setObject:[attributeDict objectForKey:@"value"] forKey:kXMLWeatherRowValue1];
		[tempDict setObject:[NSNumber numberWithInt:1] forKey:kXMLWeatherRowColumns];		
		[[[[[self.data objectForKey:kXMLWeather] lastObject] objectForKey:kXMLWeatherSlots] lastObject] addObject:tempDict];
	}
	
	if ([elementName isEqualToString:@"double_row"]) {
		NSMutableDictionary* tempDict = [[NSMutableDictionary alloc] init];
		[tempDict setObject:[attributeDict objectForKey:@"title"] forKey:kXMLWeatherRowTitle];
		[tempDict setObject:[attributeDict objectForKey:@"type"] forKey:kXMLWeatherRowType];
		[tempDict setObject:[attributeDict objectForKey:@"value1"] forKey:kXMLWeatherRowValue1];
		[tempDict setObject:[attributeDict objectForKey:@"value2"] forKey:kXMLWeatherRowValue2];
		[tempDict setObject:[NSNumber numberWithInt:2] forKey:kXMLWeatherRowColumns];			
		[[[[[self.data objectForKey:kXMLWeather] lastObject] objectForKey:kXMLWeatherSlots] lastObject] addObject:tempDict];
	}
	
	if ([elementName isEqualToString:@"bollettini"]) {
		_currentRoot = kBulletin;
		NSMutableArray* tempArray = [[NSMutableArray alloc] init];
		[self.data setObject:tempArray forKey:kXMLBulletin];
	}
	
	if ([elementName isEqualToString:@"bollettino"]) {
		NSMutableDictionary* tempDict = [[NSMutableDictionary alloc] init];
		[tempDict setObject:[attributeDict objectForKey:@"bollettinoid"] forKey:kXMLBulletinType];
		[tempDict setObject:[attributeDict objectForKey:@"name"] forKey:kXMLBulletinName];
		[tempDict setObject:[attributeDict objectForKey:@"title"] forKey:kXMLBulletinTitle];
		NSMutableArray* tempArray = [[NSMutableArray alloc] init];	
		[tempDict setObject:tempArray forKey:kXMLBulletinSlots];
		[[self.data objectForKey:kXMLBulletin] addObject:tempDict];
	}
	
	if ([elementName isEqualToString:@"slot"] && _currentRoot == kBulletin) {
		NSMutableDictionary* tempDict = [[NSMutableDictionary alloc] init];
		[[[[self.data objectForKey:kXMLBulletin] lastObject] objectForKey:kXMLBulletinSlots] addObject:tempDict];
	}
	
	if ([elementName isEqualToString:@"img"] && _currentRoot == kBulletin) {
		NSMutableDictionary* tempDict = [[[[self.data objectForKey:kXMLBulletin] lastObject] objectForKey:kXMLBulletinSlots] lastObject];
		if ([tempDict objectForKey:@"img1"] == nil) {
			[tempDict setObject:[attributeDict objectForKey:@"src"] forKey:kXMLBulletinImg1];
			[tempDict setObject:[attributeDict objectForKey:@"caption"] forKey:kXMLBulletinCaption1];	
		} else {
			[tempDict setObject:[attributeDict objectForKey:@"src"] forKey:kXMLBulletinImg1];
			[tempDict setObject:[attributeDict objectForKey:@"caption"] forKey:kXMLBulletinCaption2];	
		}
	}
	
	if ([elementName isEqualToString:@"radars"]) {
		NSMutableArray* tempArray = [[NSMutableArray alloc] init];
		[self.data setObject:tempArray forKey:kXMLRadar];
	}

	if ([elementName isEqualToString:@"radar"]) {
		if ([attributeDict count] == 0) {
			return;
		}
		NSMutableDictionary* tempDict = [[NSMutableDictionary alloc] init];
		[tempDict setObject:[attributeDict objectForKey:@"title"] forKey:kXMLRadarTitle];
		[tempDict setObject:[attributeDict objectForKey:@"img"] forKey:kXMLRadarImage];
		[[self.data objectForKey:kXMLRadar] addObject:tempDict];
	}

}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
	NSString *cData = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
	if (_currentRoot == kBulletin) {
		NSMutableDictionary* tempDict = [[[[self.data objectForKey:kXMLBulletin] lastObject] objectForKey:kXMLBulletinSlots] lastObject];
		[tempDict setObject:cData forKey:kXMLBulletinText];
	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	[_delegate parserDidFail];
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
	[_delegate parserDidFail];
}

@end
