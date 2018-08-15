/**
 * Ti.Crypto Module
 * Copyright (c) 2010-present by Appcelerator, Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiProxy.h"
#import <CommonCrypto/CommonCryptor.h>

@interface TiCryptoCryptorProxy : TiProxy {

  @private
  CCCryptorRef cryptorRef;
  BOOL resizeBuffer;
}

@end
