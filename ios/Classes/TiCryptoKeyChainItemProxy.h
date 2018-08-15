/**
 * Ti.Crypto Module
 * Copyright (c) 2010-2013 by Appcelerator, Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiProxy.h"

@interface TiCryptoKeyChainItemProxy : TiProxy {

  @private
  NSMutableDictionary *keychainItemData; // The actual keychain item data backing store.
  NSMutableDictionary *keychainQuery; // A placeholder for the generic keychain item query used to locate the item
}

@end
