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
		[self.data setObject:[attributeDict objectForKey:@"date"] forKey:@"date"];
	}
	
	if ([elementName isEqualToString:@"meteogrammi"]) {
		_currentRoot = kWeather;
		NSMutableArray* tempArray = [[NSMutableArray alloc] init];
		[self.data setObject:tempArray forKey:@"weather"];
	}
	
	if ([elementName isEqualToString:@"meteogramma"]) {
		NSMutableDictionary* tempDict = [[NSMutableDictionary alloc] init];
		NSMutableArray* tempArray = [[NSMutableArray alloc] init];	
		NSNumber* zoneid = [NSNumber numberWithInt:[[attributeDict objectForKey:@"zoneid"] intValue]];
		[tempDict setObject:zoneid forKey:@"zone"];
		[tempDict setObject:[attributeDict objectForKey:@"name"] forKey:@"name"];
		[tempDict setObject:tempArray forKey:@"slots"];
		[[self.data objectForKey:@"weather"] addObject:tempDict];
	}
	
	if ([elementName isEqualToString:@"slot"] && _currentRoot == kWeather) {
		NSMutableArray* tempArray = [[NSMutableArray alloc] init];	
		[[[[self.data objectForKey:@"weather"] lastObject] objectForKey:@"slots"] addObject:tempArray];
	}
	
	if ([elementName isEqualToString:@"single_row"]) {
		NSMutableDictionary* tempDict = [[NSMutableDictionary alloc] init];
		[tempDict setObject:[attributeDict objectForKey:@"title"] forKey:@"title"];
		[tempDict setObject:[attributeDict objectForKey:@"type"] forKey:@"type"];
		[tempDict setObject:[attributeDict objectForKey:@"value"] forKey:@"value"];
		[tempDict setObject:[NSNumber numberWithInt:1] forKey:@"columns"];		
		[[[[[self.data objectForKey:@"weather"] lastObject] objectForKey:@"slots"] lastObject] addObject:tempDict];
	}
	
	if ([elementName isEqualToString:@"double_row"]) {
		NSMutableDictionary* tempDict = [[NSMutableDictionary alloc] init];
		[tempDict setObject:[attributeDict objectForKey:@"title"] forKey:@"title"];
		[tempDict setObject:[attributeDict objectForKey:@"type"] forKey:@"type"];
		[tempDict setObject:[attributeDict objectForKey:@"value1"] forKey:@"value1"];
		[tempDict setObject:[attributeDict objectForKey:@"value2"] forKey:@"value2"];
		[tempDict setObject:[NSNumber numberWithInt:2] forKey:@"columns"];			
		[[[[[self.data objectForKey:@"weather"] lastObject] objectForKey:@"slots"] lastObject] addObject:tempDict];
	}
	
	if ([elementName isEqualToString:@"bollettini"]) {
		_currentRoot = kBulletin;
		NSMutableArray* tempArray = [[NSMutableArray alloc] init];
		[self.data setObject:tempArray forKey:@"bulletin"];
	}
	
	if ([elementName isEqualToString:@"bollettino"]) {
		NSMutableDictionary* tempDict = [[NSMutableDictionary alloc] init];
		[tempDict setObject:[attributeDict objectForKey:@"bollettinoid"] forKey:@"type"];
		[tempDict setObject:[attributeDict objectForKey:@"name"] forKey:@"name"];
		[tempDict setObject:[attributeDict objectForKey:@"title"] forKey:@"title"];
		NSMutableArray* tempArray = [[NSMutableArray alloc] init];	
		[tempDict setObject:tempArray forKey:@"slots"];
		[[self.data objectForKey:@"bulletin"] addObject:tempDict];
	}
	
	if ([elementName isEqualToString:@"slot"] && _currentRoot == kBulletin) {
		NSMutableDictionary* tempDict = [[NSMutableDictionary alloc] init];
		[[[[self.data objectForKey:@"bulletin"] lastObject] objectForKey:@"slots"] addObject:tempDict];
	}
	
	if ([elementName isEqualToString:@"img"] && _currentRoot == kBulletin) {
		NSMutableDictionary* tempDict = [[[[self.data objectForKey:@"bulletin"] lastObject] objectForKey:@"slots"] lastObject];
		if ([tempDict objectForKey:@"img1"] == nil) {
			[tempDict setObject:[attributeDict objectForKey:@"src"] forKey:@"img1"];
			[tempDict setObject:[attributeDict objectForKey:@"caption"] forKey:@"imgCaption1"];	
		} else {
			[tempDict setObject:[attributeDict objectForKey:@"src"] forKey:@"img2"];
			[tempDict setObject:[attributeDict objectForKey:@"caption"] forKey:@"imgCaption2"];	
		}
	}
	

}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
	NSString *cData = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
	if (_currentRoot == kBulletin) {
		NSMutableDictionary* tempDict = [[[[self.data objectForKey:@"bulletin"] lastObject] objectForKey:@"slots"] lastObject];
		[tempDict setObject:cData forKey:@"text"];
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
