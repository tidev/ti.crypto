/**
 * Ti.Crypto Module
 * Copyright (c) 2010-present by Appcelerator, Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiCryptoUtils.h"
#import "TiBuffer.h"
#import "TiCryptoBase64Transcoder.h"

@implementation TiCryptoUtils

+(NSString*)convertToHex:(TiBuffer*)buffer
{
	const char *data = [[buffer data] bytes];
	size_t len = [[buffer data] length];
	
	NSMutableString* encoded = [[NSMutableString alloc] initWithCapacity:len*2];
	for (int i=0; i < len; i++) {
		[encoded appendFormat:@"%02x",data[i]];
	}
	NSString* value = [encoded lowercaseString];
	[encoded release];
								
	return value;
}

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
	NSUInteger len = [valueToConvert length] / 2;
	for (i=0; i < len; i++) {
		byte_chars[0] = [valueToConvert characterAtIndex:i*2];
		byte_chars[1] = [valueToConvert characterAtIndex:i*2+1];
		whole_byte = strtol(byte_chars, NULL, 16);
		[data appendBytes:&whole_byte length:1];
	}
	
	return data;
}

+(NSString*)base64encode:(TiBuffer*)buffer
{
	NSString *str = nil;
	const char *data = [[buffer data] bytes];
	size_t len = [[buffer data] length];
	
	size_t outsize = TiCryptoEstimateBas64EncodedDataSize(len);
	char *base64Result = malloc(sizeof(char)*outsize);
    size_t theResultLength = outsize;
	
    bool result = TiCryptoBase64EncodeData(data, len, base64Result, &theResultLength);
	if (result)	{
		str = [[[NSString alloc] initWithBytes:base64Result length:theResultLength encoding:NSUTF8StringEncoding] autorelease];
	}    
	free(base64Result);
	
	return str;
}

+(NSMutableData*)base64decode:(NSString*)str
{
	NSMutableData *theData = nil;
	const char *data = [str UTF8String];
	size_t len = [str length];
	
	size_t outsize = TiCryptoEstimateBas64DecodedDataSize(len);
	char *base64Result = malloc(sizeof(char)*outsize);
    size_t theResultLength = outsize;
	
    bool result = TiCryptoBase64DecodeData(data, len, base64Result, &theResultLength);
	if (result) {
		theData = [NSMutableData dataWithBytes:base64Result length:theResultLength];
	}    
	free(base64Result);
	
	return theData;
}

@end
