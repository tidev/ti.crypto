/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2011 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiModule.h"
#import <CommonCrypto/CommonCryptor.h>

enum {
	kCCError = -1
};

typedef enum {
	kDataTypeBlob = 0,
	kDataTypeHexString = 1,
	kDataTypeBase64String = 2
} cryptoDataType;

extern NSString * const kDataTypeBlobName;
extern NSString * const kDataTypeHexStringName;
extern NSString * const kDataTypeBase64StringName;

@interface TiCryptoModule : TiModule 
{
}

@end
