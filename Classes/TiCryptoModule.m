/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "TiCryptoModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@implementation TiCryptoModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"5041eaca-a895-4229-a44b-de2f582c9133";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"ti.crypto";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
	
	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Encryption

MAKE_SYSTEM_PROP(STATUS_SUCCESS,kCCSuccess)
MAKE_SYSTEM_PROP(STATUS_ERROR,kCCError)
MAKE_SYSTEM_PROP(STATUS_PARAMERROR,kCCParamError)
MAKE_SYSTEM_PROP(STATUS_BUFFERTOOSMALL,kCCBufferTooSmall)
MAKE_SYSTEM_PROP(STATUS_MEMORYFAILURE,kCCMemoryFailure)
MAKE_SYSTEM_PROP(STATUS_ALIGNMENTERROR,kCCAlignmentError)
MAKE_SYSTEM_PROP(STATUS_DECODEERROR,kCCDecodeError)
MAKE_SYSTEM_PROP(STATUS_UNIMPLEMENTED,kCCUnimplemented)

MAKE_SYSTEM_PROP(ENCRYPT,kCCEncrypt)
MAKE_SYSTEM_PROP(DECRYPT,kCCDecrypt)

MAKE_SYSTEM_PROP(ALGORITHM_AES128,kCCAlgorithmAES128)
MAKE_SYSTEM_PROP(ALGORITHM_DES,kCCAlgorithmDES)
MAKE_SYSTEM_PROP(ALGORITHM_3DES,kCCAlgorithm3DES)
MAKE_SYSTEM_PROP(ALGORITHM_CAST,kCCAlgorithmCAST)
MAKE_SYSTEM_PROP(ALGORITHM_RC4,kCCAlgorithmRC4)
MAKE_SYSTEM_PROP(ALGORITHM_RC2,kCCAlgorithmRC2)

MAKE_SYSTEM_PROP(OPTION_PKCS7PADDING,kCCOptionPKCS7Padding)
MAKE_SYSTEM_PROP(OPTION_ECBMODE,kCCOptionECBMode)

MAKE_SYSTEM_PROP(KEYSIZE_AES128,kCCKeySizeAES128)
MAKE_SYSTEM_PROP(KEYSIZE_AES192,kCCKeySizeAES192)
MAKE_SYSTEM_PROP(KEYSIZE_AES256,kCCKeySizeAES256)
MAKE_SYSTEM_PROP(KEYSIZE_DES,kCCKeySizeDES)
MAKE_SYSTEM_PROP(KEYSIZE_3DES,kCCKeySize3DES)
MAKE_SYSTEM_PROP(KEYSIZE_MINCAST,kCCKeySizeMinCAST)
MAKE_SYSTEM_PROP(KEYSIZE_MAXCAST,kCCKeySizeMaxCAST)
MAKE_SYSTEM_PROP(KEYSIZE_MINRC4,kCCKeySizeMinRC4)
MAKE_SYSTEM_PROP(KEYSIZE_MAXRC4,kCCKeySizeMaxRC4)
MAKE_SYSTEM_PROP(KEYSIZE_MINRC2,kCCKeySizeMinRC2)
MAKE_SYSTEM_PROP(KEYSIZE_MAXRC2,kCCKeySizeMaxRC2)

MAKE_SYSTEM_PROP(BLOCKSIZE_AES128,kCCBlockSizeAES128)
MAKE_SYSTEM_PROP(BLOCKSIZE_DES,kCCBlockSizeDES)
MAKE_SYSTEM_PROP(BLOCKSIZE_3DES,kCCBlockSize3DES)
MAKE_SYSTEM_PROP(BLOCKSIZE_CAST,kCCBlockSizeCAST)
MAKE_SYSTEM_PROP(BLOCKSIZE_RC2,kCCBlockSizeRC2)

-(TiBuffer*)createBuffer:(id)args
{
	ENSURE_SINGLE_ARG(args,NSDictionary);
	
	NSMutableData* data;
	NSString* value;	
	
	ENSURE_ARG_OR_NIL_FOR_KEY(value,args,@"value",NSString);
	if (value != nil) {
		data = [[NSMutableData alloc] initWithBytes:[value UTF8String] length:[value length]];
	} else {	
		ENSURE_ARG_OR_NIL_FOR_KEY(value,args,@"hexValue",NSString);
		if (value != nil) {
			data = [[NSMutableData alloc] init];
			
			// Format of input string must be hex values separated by a space (e.g. "21 53 02")
			NSScanner *scanner = [[NSScanner alloc] initWithString:value];
			unsigned hexValue;
			while([scanner scanHexInt:&hexValue]) {
				unsigned char val = hexValue & 0xFF;
				[data appendBytes:&val length:1];
			}
		}
	}
	
    TiBuffer* dataBuffer = [[[TiBuffer alloc] _initWithPageContext:[self executionContext]] autorelease];
	[dataBuffer setData:data];
	[data release];
	
	NSLog(@"HEX BUFFER SET: %d bytes %@", [[dataBuffer data] length], [dataBuffer data]);
	
	return dataBuffer;
}

@end
