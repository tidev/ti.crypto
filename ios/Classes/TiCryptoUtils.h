/**
 * Ti.Crypto Module
 * Copyright (c) 2010-present by Appcelerator, Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBuffer.h"

@interface TiCryptoUtils : NSObject {
}

+(NSString*)convertToHex:(TiBuffer*)buffer;
+(NSMutableData*)convertFromHex:(NSString*)value;
+(NSString*)base64encode:(TiBuffer*)buffer;
+(NSMutableData*)base64decode:(NSString*)str;

@end
