/**
 * Ti.Crypto Module
 * Copyright (c) 2010-present by Appcelerator, Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiCryptoModule.h"
#import "TiCryptoUtils.h"

#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@implementation TiCryptoModule

#pragma mark Internal

// this is generated for your module, please do not change it
- (id)moduleGUID
{
  return @"5041eaca-a895-4229-a44b-de2f582c9133";
}

// this is generated for your module, please do not change it
- (NSString *)moduleId
{
  return @"ti.crypto";
}

#pragma mark Lifecycle

- (void)startup
{
  // this method is called when the module is first loaded
  // you *must* call the superclass
  [super startup];

  NSLog(@"[INFO] %@ loaded", self);
}

- (void)shutdown:(id)sender
{
  // this method is called when the module is being unloaded
  // typically this is during shutdown. make sure you don't do too
  // much processing here or the app will be quit forceably

  // you *must* call the superclass
  [super shutdown:sender];
}

#pragma mark Cleanup

- (void)dealloc
{
  // release any resources that have been retained by the module
  [super dealloc];
}

#pragma mark Internal Memory Management

- (void)didReceiveMemoryWarning:(NSNotification *)notification
{
  // optionally release any resources that can be dynamically
  // reloaded once memory is available - such as caches
  [super didReceiveMemoryWarning:notification];
}

#pragma mark Public Methods

NSString *const kDataTypeBlobName = @"blob";
NSString *const kDataTypeHexStringName = @"hexstring";
NSString *const kDataTypeBase64StringName = @"base64string";

static NSDictionary *dataTypeMap = nil;

+ (cryptoDataType)constantToDataType:(NSString *)type
{
  if (dataTypeMap == nil) {
    dataTypeMap = [[NSDictionary alloc] initWithObjectsAndKeys:
                                            @(kDataTypeBlob), kDataTypeBlobName,
                                        @(kDataTypeHexString), kDataTypeHexStringName,
                                        @(kDataTypeBase64String), kDataTypeBase64StringName,
                                        nil];
  }
  return [[dataTypeMap valueForKey:type] intValue];
}

- (NSString *)decodeData:(id)args
{
  ENSURE_SINGLE_ARG(args, NSDictionary);

  NSString *type;
  TiBuffer *source;
  id result = nil;

  ENSURE_ARG_FOR_KEY(type, args, @"type", NSString);
  ENSURE_ARG_FOR_KEY(source, args, @"source", TiBuffer);

  switch ([TiCryptoModule constantToDataType:type]) {
  case kDataTypeBase64String:
    result = [TiCryptoUtils base64encode:source];
    break;
  case kDataTypeHexString:
    result = [TiCryptoUtils convertToHex:source];
    break;
  default:
    [self throwException:[NSString stringWithFormat:@"Invalid type identifier '%@'", type]
               subreason:nil
                location:CODELOCATION];
    break;
  }

  return result;
}

- (NSNumber *)encodeData:(id)args
{
  ENSURE_SINGLE_ARG(args, NSDictionary);

  NSString *type;
  id source;
  TiBuffer *dest = nil;
  int destPosition;
  BOOL hasDestPosition;
  NSData *data;

  ENSURE_ARG_FOR_KEY(type, args, @"type", NSString);
  ENSURE_ARG_FOR_KEY(source, args, @"source", NSObject);
  ENSURE_ARG_FOR_KEY(dest, args, @"dest", TiBuffer);
  ENSURE_INT_OR_NIL_FOR_KEY(destPosition, args, @"destPosition", hasDestPosition);

  destPosition = (hasDestPosition) ? destPosition : 0;

  switch ([TiCryptoModule constantToDataType:type]) {
  case kDataTypeBlob:
    ENSURE_TYPE(source, TiBlob);
    data = [source data];
    break;
  case kDataTypeHexString:
    ENSURE_TYPE(source, NSString);
    data = [TiCryptoUtils convertFromHex:source];
    break;
  case kDataTypeBase64String:
    ENSURE_TYPE(source, NSString);
    data = [TiCryptoUtils base64decode:source];
    break;
  default:
    [self throwException:[NSString stringWithFormat:@"Invalid type identifier '%@'", type]
               subreason:nil
                location:CODELOCATION];
    break;
  }

  // Verify that the offset is within range
  NSUInteger destLength = [[dest data] length];
  if (destPosition >= destLength) {
    NSLog(@"[ERROR] Destination position of %d is past end of buffer. Buffer size is %d.", destPosition, destLength);
    return @(BAD_DEST_OFFSET);
  }

  // Verify that the destination can hold the result
  NSUInteger srcLength = [data length];
  NSUInteger neededLength = destPosition + srcLength;
  if (neededLength > destLength) {
    NSLog(@"[ERROR] Destination buffer size of %d is too small. Needed %d.", destLength, neededLength);
    return @(TOO_SMALL);
  }

  void *bufferBytes = [[dest data] mutableBytes];
  const void *srcBytes = [data bytes];

  memcpy(bufferBytes + destPosition, srcBytes, srcLength);

  return @(destPosition + srcLength);
}

#pragma mark Constants

MAKE_SYSTEM_PROP(STATUS_SUCCESS, kCCSuccess)
MAKE_SYSTEM_PROP(STATUS_ERROR, kCCError)
MAKE_SYSTEM_PROP(STATUS_PARAMERROR, kCCParamError)
MAKE_SYSTEM_PROP(STATUS_BUFFERTOOSMALL, kCCBufferTooSmall)
MAKE_SYSTEM_PROP(STATUS_MEMORYFAILURE, kCCMemoryFailure)
MAKE_SYSTEM_PROP(STATUS_ALIGNMENTERROR, kCCAlignmentError)
MAKE_SYSTEM_PROP(STATUS_DECODEERROR, kCCDecodeError)
MAKE_SYSTEM_PROP(STATUS_UNIMPLEMENTED, kCCUnimplemented)

MAKE_SYSTEM_PROP(ENCRYPT, kCCEncrypt)
MAKE_SYSTEM_PROP(DECRYPT, kCCDecrypt)

MAKE_SYSTEM_PROP(ALGORITHM_AES128, kCCAlgorithmAES128)
MAKE_SYSTEM_PROP(ALGORITHM_DES, kCCAlgorithmDES)
MAKE_SYSTEM_PROP(ALGORITHM_3DES, kCCAlgorithm3DES)
MAKE_SYSTEM_PROP(ALGORITHM_CAST, kCCAlgorithmCAST)
MAKE_SYSTEM_PROP(ALGORITHM_RC4, kCCAlgorithmRC4)
MAKE_SYSTEM_PROP(ALGORITHM_RC2, kCCAlgorithmRC2)

MAKE_SYSTEM_PROP(OPTION_PKCS7PADDING, kCCOptionPKCS7Padding)
MAKE_SYSTEM_PROP(OPTION_ECBMODE, kCCOptionECBMode)

MAKE_SYSTEM_PROP(KEYSIZE_AES128, kCCKeySizeAES128)
MAKE_SYSTEM_PROP(KEYSIZE_AES192, kCCKeySizeAES192)
MAKE_SYSTEM_PROP(KEYSIZE_AES256, kCCKeySizeAES256)
MAKE_SYSTEM_PROP(KEYSIZE_DES, kCCKeySizeDES)
MAKE_SYSTEM_PROP(KEYSIZE_3DES, kCCKeySize3DES)
MAKE_SYSTEM_PROP(KEYSIZE_MINCAST, kCCKeySizeMinCAST)
MAKE_SYSTEM_PROP(KEYSIZE_MAXCAST, kCCKeySizeMaxCAST)
MAKE_SYSTEM_PROP(KEYSIZE_MINRC4, kCCKeySizeMinRC4)
MAKE_SYSTEM_PROP(KEYSIZE_MAXRC4, kCCKeySizeMaxRC4)
MAKE_SYSTEM_PROP(KEYSIZE_MINRC2, kCCKeySizeMinRC2)
MAKE_SYSTEM_PROP(KEYSIZE_MAXRC2, kCCKeySizeMaxRC2)

MAKE_SYSTEM_PROP(BLOCKSIZE_AES128, kCCBlockSizeAES128)
MAKE_SYSTEM_PROP(BLOCKSIZE_DES, kCCBlockSizeDES)
MAKE_SYSTEM_PROP(BLOCKSIZE_3DES, kCCBlockSize3DES)
MAKE_SYSTEM_PROP(BLOCKSIZE_CAST, kCCBlockSizeCAST)
MAKE_SYSTEM_PROP(BLOCKSIZE_RC2, kCCBlockSizeRC2)

MAKE_SYSTEM_STR(TYPE_BLOB, kDataTypeBlobName)
MAKE_SYSTEM_STR(TYPE_HEXSTRING, kDataTypeHexStringName)
MAKE_SYSTEM_STR(TYPE_BASE64STRING, kDataTypeBase64StringName)

@end
