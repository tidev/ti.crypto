/**
 * Ti.Crypto Module
 * Copyright (c) 2010-present by Appcelerator, Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiCryptoModule.h"
#import "TiCryptoCryptorProxy.h"

#import "TiUtils.h"

@implementation TiCryptoCryptorProxy

#pragma mark Proxy Lifecycle

-(id)init
{
	// Default setting is to resize the output buffer to fit the required size
	resizeBuffer = YES;
	
	return [super init];
}

-(void)_destroy
{
	// Clean-up and release the cryptor
	if (cryptorRef != nil) {
		CCCryptorRelease(cryptorRef);
		cryptorRef = nil;
	}
	[super _destroy];
}

#pragma mark resizeBuffer property

// resizeBuffer property setter / getter
-(void)setResizeBuffer:(id)value
{
	resizeBuffer = [TiUtils boolValue:value def:NO];
}

-(id)getResizeBuffer
{
	return NUMBOOL(resizeBuffer);
}

#pragma mark Argument Processing Helpers

// Local structure for encryption options
typedef struct {
	CCOperation operation;
	CCAlgorithm algorithm;
	CCOptions options;
	TiBuffer* key;
	TiBuffer* initializationVector;
} CryptOptions;

// Local structure for encryption data
typedef struct {
	TiBuffer* dataInBuffer;
	TiBuffer* dataOutBuffer;
	int dataInLength;
	int dataOutLength;
} CryptData;

-(void)prepareCryptOptions:(CryptOptions*)cryptOptions
{
	cryptOptions->operation = [TiUtils intValue:[self valueForUndefinedKey:@"operation"] def:kCCEncrypt];
	cryptOptions->algorithm = [TiUtils intValue:[self valueForUndefinedKey:@"algorithm"] def:kCCAlgorithmAES128];
	cryptOptions->options = [TiUtils intValue:[self valueForUndefinedKey:@"options"] def:0];
	
	// Retrieve the key
	cryptOptions->key = [self valueForUndefinedKey:@"key"];
	ENSURE_TYPE(cryptOptions->key,TiBuffer);
	
	// Retrieve the initialization vector -- it must be a buffer object (preferably created
	// from ti.crypto.createBuffer so that it supports binary vector data
	cryptOptions->initializationVector = [self valueForUndefinedKey:@"initializationVector"];
	if (cryptOptions->initializationVector) {
		ENSURE_TYPE(cryptOptions->initializationVector,TiBuffer);
	}
}

-(void)prepareCryptData:(CryptData*)cryptData fromArgs:(id)args
{
	enum {
		kArgDataIn = 0,							// REQUIRED
		kArgCountRequired,
		kArgDataInLength = kArgCountRequired,	// OPTIONAL
		kArgDataOut,							// OPTIONAL
		kArgDataOutLength,						// OPTIONAL
		kArgCount
	};
	
	ENSURE_ARG_COUNT(args,kArgCountRequired);
	
	BOOL hasValue;
	
	// Get the input buffer. 
	ENSURE_ARG_AT_INDEX(cryptData->dataInBuffer,args,kArgDataIn,TiBuffer);
	
	// Get the input buffer length. If no length is provided then use the length of the buffer.
	ENSURE_INT_OR_NIL_AT_INDEX(cryptData->dataInLength,args,kArgDataInLength,hasValue);
	if (!hasValue || (cryptData->dataInLength < 0)) {
		cryptData->dataInLength = [cryptData->dataInBuffer length].intValue;
	}
	
	// Get the output buffer. If no output buffer is specified then use the input buffer for output (in-place)
	ENSURE_ARG_OR_NIL_AT_INDEX(cryptData->dataOutBuffer,args,kArgDataOut,TiBuffer);
	if (cryptData->dataOutBuffer == nil) {
		cryptData->dataOutBuffer = cryptData->dataInBuffer;
	}
	
	// Get the output buffer length. If no length is provided then calculate the length needed for the buffer.
	ENSURE_INT_OR_NIL_AT_INDEX(cryptData->dataOutLength,args,kArgDataOutLength,hasValue);
	if (!hasValue || (cryptData->dataOutLength < 0)) {
		cryptData->dataOutLength = [cryptData->dataOutBuffer length].intValue;
	}
}

-(void)prepareFinalCryptData:(CryptData*)cryptData fromArgs:(id)args
{
	enum {
		kArgDataOut = 0,						// REQUIRED
		kArgCountRequired,					
		kArgDataOutLength = kArgCountRequired,	// OPTIONAL
		kArgCount
	};
	
	ENSURE_ARG_COUNT(args,kArgCountRequired);
	BOOL hasValue;
	
	// Get the output buffer. 
	ENSURE_ARG_AT_INDEX(cryptData->dataOutBuffer,args,kArgDataOut,TiBuffer);
	
	// Get the output buffer length. If no length is provided then use the length of the buffer.
	ENSURE_INT_OR_NIL_AT_INDEX(cryptData->dataOutLength,args,kArgDataOutLength,hasValue);
	if (!hasValue || (cryptData->dataOutLength < 0)) {
		cryptData->dataOutLength = [cryptData->dataOutBuffer length].intValue;
	}
}

#pragma mark Cryptographic Context Methods

-(CCCryptorRef)cryptor
{
	if (cryptorRef == nil) {
		CryptOptions cryptOptions;
		[self prepareCryptOptions:&cryptOptions];
		
		// Create the cryptor object that will be used for stream encryption
		CCCryptorStatus result = CCCryptorCreate(cryptOptions.operation, 
												 cryptOptions.algorithm,
												 cryptOptions.options,
												 [[cryptOptions.key data] bytes],
												 [cryptOptions.key length].intValue,
												 [[cryptOptions.initializationVector data] bytes],
												 &cryptorRef);
		
		if (result != kCCSuccess) {
			NSLog(@"[ERROR] Error creating cryptor - %d", result);
			return nil;
		}
	}
	
	return cryptorRef;
}

-(NSNumber*)getOutputLength:(id)args
{
	enum {
		kArgLength = 0,
		kArgFinal = 1,
		kArgCount
	};
	
	ENSURE_ARG_COUNT(args,kArgCount);

	CCCryptorRef cryptor = [self cryptor];
	if (cryptor) {
		int length = [TiUtils intValue:[args objectAtIndex:kArgLength] def:-1];
		if (length < 0) {
			length = 0;
		}
		
		BOOL final = [TiUtils boolValue:[args objectAtIndex:kArgFinal] def:NO];
		return [NSNumber numberWithUnsignedInteger: CCCryptorGetOutputLength(cryptor, (size_t)length, final)];
	}
	
	return NUMINT(0);
}

-(NSNumber*)update:(id)args
{	
	CCCryptorRef cryptor = [self cryptor];
	if (cryptor) {
		CryptData cryptData;
		[self prepareCryptData:&cryptData fromArgs:args];	
		 
		// If resize output buffer is specified, then set the output buffer size so that it is
		// large enough to hold the result
		if (resizeBuffer) {
			int neededLength = (int)CCCryptorGetOutputLength(cryptor,cryptData.dataInLength,NO);
			if (neededLength == 0) {
				neededLength = cryptData.dataInLength;
			}
			// Call 'setLength' to make sure that the TiBuffer object allocates the memory for the data
			if (neededLength > cryptData.dataOutLength) {
				cryptData.dataOutLength = neededLength;
				[cryptData.dataOutBuffer setLength:NUMINT(neededLength)];
			}
		}
		 
		size_t numBytesMoved = 0;
		CCCryptorStatus result = CCCryptorUpdate(cryptor,
												 [[cryptData.dataInBuffer data] bytes],
												 (size_t)cryptData.dataInLength,
												 [[cryptData.dataOutBuffer data] mutableBytes],
												 (size_t)cryptData.dataOutLength,
												 &numBytesMoved);
		
		if (result == kCCSuccess) {
			if (resizeBuffer) {
				[cryptData.dataOutBuffer setLength:[NSNumber numberWithUnsignedInteger: numBytesMoved]];
			}
		} else {
			NSLog(@"[ERROR] Error during crypt operation - %d", result);
		}
		
		return (result == kCCSuccess) ? [NSNumber numberWithUnsignedInteger: numBytesMoved] : NUMINT(result);
	}
	
	return NUMINT(kCCError);
}

-(NSNumber*)finish:(id)args
{
	CCCryptorRef cryptor = [self cryptor];
	if (cryptor) {
		CryptData cryptData;
		[self prepareFinalCryptData:&cryptData fromArgs:args];	
		
		// If resize output buffer is specified, then set the output buffer size so that it is
		// large enough to hold the result
		if (resizeBuffer) {
			int neededLength = (int)CCCryptorGetOutputLength(cryptor,0,YES);
			// Call 'setLength' to make sure that the TiBuffer object allocates the memory for the data
			if (neededLength > cryptData.dataOutLength) {
				cryptData.dataOutLength = neededLength;
				[cryptData.dataOutBuffer setLength:NUMINT(cryptData.dataOutLength)];
			}
		}
		
		size_t numBytesMoved = 0;
		CCCryptorStatus result = CCCryptorFinal(cryptor,
												[[cryptData.dataOutBuffer data] mutableBytes],
												(size_t)cryptData.dataOutLength,
												&numBytesMoved);
		
		if (result == kCCSuccess) {
			if (resizeBuffer) {
				[cryptData.dataOutBuffer setLength:[NSNumber numberWithUnsignedInteger: numBytesMoved]];
			}
		} else {
			NSLog(@"[ERROR] Error during final operation - %d", result);
		}
		
		return (result == kCCSuccess) ? [NSNumber numberWithUnsignedInteger: numBytesMoved] : NUMINT(result);
	}
	
	return NUMINT(kCCError);
}


-(NSNumber*)reset:(id)args
{
	enum {
		kArgInitializationVector = 0,	// OPTIONAL
		kArgCount
	};
	
	CCCryptorStatus result = kCCError;
	CCCryptorRef cryptor = [self cryptor];
	if (cryptor) {
		TiBuffer* initializationVector;
		ENSURE_ARG_OR_NIL_AT_INDEX(initializationVector,args,kArgInitializationVector,TiBuffer);
		
		result = CCCryptorReset(cryptor,
								[[initializationVector data] bytes]);
	}
	
	return NUMINT(result);
}

-(NSNumber*)release:(id)args
{
	CCCryptorStatus result = kCCSuccess;
	if (cryptorRef != nil) {
		result = CCCryptorRelease (cryptorRef);
		cryptorRef = nil;
	}
	
	return NUMINT(result);
}

#pragma mark Single-shot Encryption Methods

-(NSNumber*)crypt:(CCOperation)operation args:(id)args
{
	CryptOptions cryptOptions;
	[self prepareCryptOptions:&cryptOptions];
	
	CryptData cryptData;
	[self prepareCryptData:&cryptData fromArgs:args];	
	
	// If resize output buffer is specified, then set the output buffer size so that it is
	// large enough to hold the result. We need to calculate it ourselves here since we don't
	// allocate an actual cryptor in this workflow.
	if (resizeBuffer) {
		int neededLength = cryptData.dataInLength;
		switch (cryptOptions.algorithm) {
			case kCCAlgorithmAES128:
				neededLength += kCCBlockSizeAES128;
				break;
			case kCCAlgorithmDES:
				neededLength += kCCBlockSizeDES*2;
				break;
			case kCCAlgorithm3DES:
				neededLength += kCCBlockSize3DES;
				break;
			case kCCAlgorithmCAST:
				neededLength += kCCBlockSizeCAST;
				break;
			case kCCAlgorithmRC4:
			case kCCAlgorithmRC2:
				neededLength += kCCBlockSizeRC2;
				break;
		}
		// Call 'setLength' to make sure that the TiBuffer object allocates the memory for the data
		if (neededLength > cryptData.dataOutLength) {
			cryptData.dataOutLength = neededLength;
			[cryptData.dataOutBuffer setLength:NUMINT(neededLength)];
		}
	}
	
	//NSLog(@"Preparing to crypt");
	//NSLog(@"Input length: %d value: %@", cryptData.dataInLength, [cryptData.dataInBuffer data]);
	//NSLog(@"Output length: %d", cryptData.dataOutLength);
	//NSLog(@"Operation: %d",cryptOptions.operation);
	//NSLog(@"Algorithm: %d",cryptOptions.algorithm);
	//NSLog(@"Options: %d",cryptOptions.options);
	//NSLog(@"Key: %@", [cryptOptions.key data]);
	//NSLog(@"InitializationVector: %@",[cryptOptions.initializationVector data]);
	
	size_t numBytesMoved = 0;
	CCCryptorStatus result = CCCrypt(operation,
									 cryptOptions.algorithm,
									 cryptOptions.options,
									 [[cryptOptions.key data] bytes],
									 [cryptOptions.key length].intValue,
									 [[cryptOptions.initializationVector data] bytes],
									 [[cryptData.dataInBuffer data] bytes],
									 (size_t)cryptData.dataInLength,
									 [[cryptData.dataOutBuffer data] mutableBytes],
									 (size_t)cryptData.dataOutLength,
									 &numBytesMoved);
	
	if (result == kCCSuccess) {
		if (resizeBuffer) {
			[cryptData.dataOutBuffer setLength:[NSNumber numberWithUnsignedInteger: numBytesMoved]];
		}
		//NSLog(@"DataOut: %@", [cryptData.dataOutBuffer data]);
	} else {
		NSLog(@"[ERROR] Error during crypt operation - %d", result);
	}
		
	return (result == kCCSuccess) ? [NSNumber numberWithUnsignedInteger: numBytesMoved] : NUMINT(result);
}

-(NSNumber*)encrypt:(id)args
{
	return [self crypt:kCCEncrypt args:args];
}

-(NSNumber*)decrypt:(id)args
{
	return [self crypt:kCCDecrypt args:args];
}

@end
