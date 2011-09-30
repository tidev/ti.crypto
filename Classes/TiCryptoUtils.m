/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2011 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiCryptoUtils.h"


@implementation TiCryptoUtils

+(NSMutableData*)convertFromHex:(NSString*)value
{
	// This implementation supports either a straight hexadecimal string or one
	// that is formatted with spaces between each hexadecimal byte
	NSString* valueToConvert = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSMutableData* data = [[[NSMutableData alloc] initWithCapacity:(valueToConvert.length / 2)] autorelease];
	
	unsigned char whole_byte;
	char byte_chars[3];
	byte_chars[2] = '\0';
	int i;
	int len = [valueToConvert length] / 2;
	for (i=0; i < len; i++) {
		byte_chars[0] = [valueToConvert characterAtIndex:i*2];
		byte_chars[1] = [valueToConvert characterAtIndex:i*2+1];
		whole_byte = strtol(byte_chars, NULL, 16);
		[data appendBytes:&whole_byte length:1];
	}
	
	return data;
}

@end
