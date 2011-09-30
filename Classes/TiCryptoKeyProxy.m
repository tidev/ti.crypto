/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2011 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiCryptoKeyProxy.h"
#import "TiCryptoUtils.h"

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
	
	data = [[NSMutableData alloc] initWithBytes:[value UTF8String] length:[value length]];
}

-(void)setHexValue:(id)value
{
	ENSURE_TYPE(value,NSString);
	
	[self secureRelease];	
	
	data = [[TiCryptoUtils convertFromHex:value] retain];
}

-(const void *)key
{
	return [data bytes];
}

-(size_t)length
{
	return [data length];
}

-(NSMutableData*)data
{
	return data;
}

@end
