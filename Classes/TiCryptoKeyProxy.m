/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2011 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiCryptoKeyProxy.h"

#import "TiUtils.h"

@implementation TiCryptoKeyProxy

-(void)secureRelease
{
	[data resetBytesInRange:NSMakeRange(0, [data length])];
	RELEASE_TO_NIL(data);
}

-(void)_destroy
{	
	[self secureRelease];
	
	[super _destroy];
}

-(void)setValue:(id)value
{
	ENSURE_TYPE(value,NSString);
	
	[self secureRelease];
	
	data = [[NSData alloc] initWithBytes:[value UTF8String] length:[value length]];

	NSLog(@"STRING KEY SET: %d bytes %@", [data length], data);
}

-(void)setHexValue:(id)value
{
	ENSURE_TYPE(value,NSString);
	
	[self secureRelease];
	
	data = [[NSMutableData alloc] init];
	
	// Format of input string must be hex values separated by a space (e.g. "21 53 02")
	NSScanner *scanner = [[NSScanner alloc] initWithString:value];
	unsigned hexValue;
	while([scanner scanHexInt:&hexValue]) {
		unsigned char val = hexValue & 0xFF;
		[data appendBytes:&val length:1];
	}
	
	NSLog(@"HEX KEY SET: %d bytes %@", [data length], data);
}

-(const void *)key
{
	return [data bytes];
}

-(size_t)length
{
	return [data length];
}

@end
