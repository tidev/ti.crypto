/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2011 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiCryptoModule.h"
#import "TiCryptoCryptorProxy.h"

#import "TiUtils.h"

@implementation TiCryptoCryptorProxy

-(void)_destroy
{
	if (cryptorRef != nil) {
		CCCryptorRelease(cryptorRef);
		cryptorRef = nil;
	}
	[super _destroy];
}

-(CCCryptorRef)cryptor
{
	if (cryptorRef == nil) {
		CCOperation operation = [TiUtils intValue:[self valueForUndefinedKey:@"op"] def:kCCEncrypt];
		CCAlgorithm algorithm = [TiUtils intValue:[self valueForUndefinedKey:@"algorithm"] def:kCCAlgorithmAES128];
		CCOptions options = [TiUtils intValue:[self valueForUndefinedKey:@"options"] def:0];
		
//BUGBUG: This won't work unless it's possible to set hex values in a JS string. Keys are necessarily made up of readable characters.
		
		NSString* key = [TiUtils stringValue:[self valueForUndefinedKey:@"key"]];
		NSString* initializationVector = [TiUtils stringValue:[self valueForUndefinedKey:@"initializationVector"]];

		if (CCCryptorCreate(operation, 
							algorithm,
							options,
							[key UTF8String],
							[key length],
							[initializationVector UTF8String],
							&cryptorRef) != kCCSuccess) {
			return nil;
		}
	}
	return cryptorRef;
}

-(NSNumber*)getOutputLength:(id)args
{
	ENSURE_SINGLE_ARG(args,NSDictionary);

	CCCryptorRef cryptor = [self cryptor];
	if (cryptor) {
		int length = [TiUtils intValue:[args objectForKey:@"length"] def:-1];
		if (length < 0) {
			length = 0;
		}
		size_t dataOutLength = (size_t)length;
		
		BOOL final = [TiUtils boolValue:[args objectForKey:@"final"] def:NO];
		return NUMINT(CCCryptorGetOutputLength(cryptor, dataOutLength, final));
	}
	
	return NUMINT(0);
}

-(NSNumber*)update:(id)args
{
	CCCryptorStatus result = kCCError;
	ENSURE_SINGLE_ARG(args,NSDictionary);
	
	CCCryptorRef cryptor = [self cryptor];
	if (cryptor) {
		TiBuffer* dataInBuffer;
		TiBuffer* dataOutBuffer;
		size_t dataInLength;
		size_t dataOutLength;
		
		// Get the input and output buffers. If no output buffer is specified then use the input buffer for output (in-place)
		ENSURE_ARG_FOR_KEY(dataInBuffer,args,@"dataIn",TiBuffer);
		ENSURE_ARG_OR_NIL_FOR_KEY(dataOutBuffer,args,@"dataOut",TiBuffer);
		if (dataOutBuffer == nil) {
			dataOutBuffer = dataInBuffer;
		}
		
		// Get the input buffer length. If no length is provided then use the length of the buffer.
		int length = [TiUtils intValue:[args objectForKey:@"dataInLength"] def:-1];
		if (length < 0) {
			length = [[dataInBuffer data] length];
		}
		dataInLength = (size_t)length;
		
		// Get the output buffer length. If no length is provided then calculate the length needed for the buffer.
		length = [TiUtils intValue:[args objectForKey:@"dataOutLength"] def:-1];
		if (length < 0) {
			dataOutLength = CCCryptorGetOutputLength(cryptor,dataInLength,NO);
			if (dataOutLength == 0) {
				dataOutLength = dataInLength;
			}
		} else {
			dataOutLength = (size_t)length;
		}
		
		// Call 'setLength' to make sure that the TiBuffer object allocates the memory for the data
		[dataOutBuffer setLength:NUMINT(dataOutLength)];
		
		NSLog(@"Preparing to update");
		NSLog(@"Input length: %d value: %@", dataInLength, [dataInBuffer data]);
		NSLog(@"Output length: %d", dataOutLength);
				
		size_t numBytesMoved = 0;
		result = CCCryptorUpdate(cryptor,
								 [[dataInBuffer data] bytes],
								 dataInLength,
								 [[dataOutBuffer data] mutableBytes],
								 dataOutLength,
								 &numBytesMoved);
		
		if (result == kCCSuccess) {
			NSLog(@"SUCCESS: %d", numBytesMoved);
			[dataOutBuffer setLength:NUMINT(numBytesMoved)];
			NSLog(@"Data: %@",[dataOutBuffer data]);
		} else {
			NSLog(@"Error: %d", result);
		}
		
		return (result == kCCSuccess) ? NUMINT(numBytesMoved) : NUMINT(result);
	}
	
	return NUMINT(kCCError);
}

-(NSNumber*)reset:(id)args
{
	CCCryptorStatus result = kCCError;
	ENSURE_SINGLE_ARG_OR_NIL(args,NSDictionary);
	
	CCCryptorRef cryptor = [self cryptor];
	if (cryptor) {
		TiBuffer* initializationVector;
		
		ENSURE_ARG_OR_NIL_FOR_KEY(initializationVector,args,@"initializationVector",TiBuffer);
		
		result = CCCryptorReset(cryptor,
								[[initializationVector data] bytes]);
	}
	
	return NUMINT(result);
}

-(NSNumber*)final:(id)args
{
	CCCryptorStatus result = kCCError;
	ENSURE_SINGLE_ARG(args,NSDictionary);
	
	CCCryptorRef cryptor = [self cryptor];
	if (cryptor) {
		TiBuffer* dataOutBuffer;
		size_t dataOutLength;
		
		// Get the output buffers. 
		ENSURE_ARG_FOR_KEY(dataOutBuffer,args,@"dataOut",TiBuffer);
		
		// Get the output buffer length. If no length is provided then calculate the length needed for the buffer.
		int length = [TiUtils intValue:[args objectForKey:@"dataOutLength"] def:-1];
		if (length < 0) {
			length = CCCryptorGetOutputLength(cryptor,0,YES);
		}
		dataOutLength = (size_t)length;
		
		// Call 'setLength' to make sure that the TiBuffer object allocates the memory for the data
		[dataOutBuffer setLength:NUMINT(dataOutLength)];
		
		size_t numBytesMoved = 0;
		result = CCCryptorFinal(cryptor,
								 [[dataOutBuffer data] mutableBytes],
								 dataOutLength,
								 &numBytesMoved);
		
		if (result == kCCSuccess) {
			[dataOutBuffer setLength:NUMINT(numBytesMoved)];
		}
		
		return (result == kCCSuccess) ? NUMINT(numBytesMoved) : NUMINT(result);
	}
	
	return NUMINT(kCCError);
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

-(int)crypt:(CCOperation)operation args:(id)args
{
	CCCryptorStatus result = kCCError;
	ENSURE_SINGLE_ARG(args,NSDictionary);

	CCAlgorithm algorithm = [TiUtils intValue:[self valueForUndefinedKey:@"algorithm"] def:kCCAlgorithmAES128];
	CCOptions options = [TiUtils intValue:[self valueForUndefinedKey:@"options"] def:0];
	NSString* key = [TiUtils stringValue:[self valueForUndefinedKey:@"key"]];
	NSString* initializationVector = [TiUtils stringValue:[self valueForUndefinedKey:@"initializationVector"]];
	
	TiBuffer* dataInBuffer;
	TiBuffer* dataOutBuffer;
	size_t dataInLength;
	size_t dataOutLength;
	
	// Get the input and output buffers. If no output buffer is specified then use the input buffer for output (in-place)
	ENSURE_ARG_FOR_KEY(dataInBuffer,args,@"dataIn",TiBuffer);
	ENSURE_ARG_OR_NIL_FOR_KEY(dataOutBuffer,args,@"dataOut",TiBuffer);
	if (dataOutBuffer == nil) {
		dataOutBuffer = dataInBuffer;
	}
	
	// Get the input buffer length. If no length is provided then use the length of the buffer.
	int length = [TiUtils intValue:[args objectForKey:@"dataInLength"] def:-1];
	if (length < 0) {
		length = [[dataInBuffer data] length];
	}
	dataInLength = (size_t)length;
	
	// Get the output buffer length. If no length is provided then calculatre the length needed for the buffer.
	length = [TiUtils intValue:[args objectForKey:@"dataOutLength"] def:-1];
	if (length < 0) {
		switch (algorithm) {
			case kCCAlgorithmAES128:
				dataOutLength = dataInLength + kCCBlockSizeAES128;
				break;
			case kCCAlgorithmDES:
				dataOutLength = dataInLength + kCCBlockSizeDES;
				break;
			case kCCAlgorithm3DES:
				dataOutLength = dataInLength + kCCBlockSize3DES;
				break;
			case kCCAlgorithmCAST:
				dataOutLength = dataInLength + kCCBlockSizeCAST;
				break;
			case kCCAlgorithmRC4:
			case kCCAlgorithmRC2:
				dataOutLength = dataInLength + kCCBlockSizeRC2;
				break;
			default:
				dataOutLength = dataInLength;
				break;
		}
	} else {
		dataOutLength = (size_t)length;
	}
	// Call 'setLength' to make sure that the TiBuffer object allocates the memory for the data
	[dataOutBuffer setLength:NUMINT(dataOutLength)];
	
	NSLog(@"Preparing to crypt");
	NSLog(@"Input length: %d value: %@", dataInLength, [dataInBuffer data]);
	NSLog(@"Output length: %d", dataOutLength);
	
	NSLog(@"Operation: %d",operation);
	NSLog(@"Algorithm: %d",algorithm);
	NSLog(@"Options: %d",options);
	NSLog(@"Key: %@",key);
	NSLog(@"InitializationVector: %@",initializationVector);
	
	size_t numBytesMoved = 0;
	result = CCCrypt(operation,
					 algorithm,
					 options,
					 [key UTF8String],
					 [key length],
					 [initializationVector UTF8String],
					 [[dataInBuffer data] bytes],
					 dataInLength,
					 [[dataOutBuffer data] mutableBytes],
					 dataOutLength,
					 &numBytesMoved);
	
	if (result == kCCSuccess) {
		NSLog(@"SUCCESS: %d", numBytesMoved);
		[dataOutBuffer setLength:NUMINT(numBytesMoved)];
		NSLog(@"Data: %@",[dataOutBuffer data]);
	} else {
		NSLog(@"ERROR: %d", result);
	}
		
	return (result == kCCSuccess) ? numBytesMoved : result;
}

-(NSNumber*)encrypt:(id)args
{
	return NUMINT([self crypt:kCCEncrypt args:args]);
}

-(NSNumber*)decrypt:(id)args
{
	return NUMINT([self crypt:kCCDecrypt args:args]);
}

@end
