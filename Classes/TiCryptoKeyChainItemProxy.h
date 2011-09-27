/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2011 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"

@interface TiCryptoKeyChainItemProxy : TiProxy {

@private
	NSMutableDictionary *keychainItemData;	// The actual keychain item data backing store.
	NSMutableDictionary *keychainQuery;		// A placeholder for the generic keychain item query used to locate the item
}

@end
