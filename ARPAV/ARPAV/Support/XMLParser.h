//
//  XMLParser.h
//  ARPAV
//
//  Created by Andrea Mazzini on 18/04/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import <Foundation/Foundation.h>

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
