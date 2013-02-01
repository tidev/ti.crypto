# Cryptor Object

## Description

The Cryptor object provides access to a number of symmetric encryption algorithms. Symmetric encryption
algorithms come in two "flavors" - block ciphers, and stream ciphers. Block ciphers process data (while
both encrypting and decrypting) in discrete chunks of data called blocks; stream ciphers operate on
arbitrary sized data.

The Cryptor object provides access to both block ciphers and stream ciphers with the same API; however some options are available for block ciphers that do not apply to stream ciphers.
The Android version of this module only exposes block ciphers.

The general operation of a Cryptor is: 

1. Initialize it with raw key data and other optional fields with crypto.createCryptor()
2. Process input data via one or more calls to cryptor.update()
3. Obtain possible remaining output data with cryptor.final()
4. The cryptor object is disposed of by setting the cryptor variable to null. The cryptor object can be reused (with the same key data as provided to crypto.createCryptor()) by calling cryptor.reset() or cryptor.release().

Alternatively, cryptor.encrypt() and cryptor.decrypt() methods are provided for a stateless, one-shot encrypt or decrypt operation.

## Methods

### createCryptor

Creates a crypto.cryptor object for use in encrypting or decrypting data.

#### Arguments

Takes one argument, a dictionary with keys:

* operation[int]: The cryptor operation to perform (default: crypto.ENCRYPT)
    * crypto.ENCRYPT
    * crypto.DECRYPT
* algorithm[int]: The cryptor algorithm for the operation (default: crypto.ALGORITHM\_AES128)
	* crypto.ALGORITHM\_AES128
	* crypto.ALGORITHM\_DES
	* crypto.ALGORITHM\_3DES
	* crypto.ALGORITHM\_CAST
	* crypto.ALGORITHM\_RC4
	* crypto.ALGORITHM\_RC2
* options[int]: The cryptor options for the operation (default: 0)
    * crypto.OPTION\_PKCS7PADDING
    * crypto.OPTION\_ECBMODE
* key[buffer]: The Titanium.Buffer object containing the encryption key
* initializationVector[buffer]: The Titanium.Buffer object containing the initialization vector. If no initialization vector is provided, an initialization vector of all zeroes will be used.

#### Properties

* resizeBuffer[boolean]: Indicates if the dataOut buffer should be resized to the size needed to hold the result of the operation. Default is true.

* Each of the arguments listed for the createCryptor method can also be accessed as properties.

#### Example

<pre>
	var cryptor = crypto.createCryptor({
		algorithm: crypto.ALGORITHM_AES128,
		options: crypto.OPTION_PKCS7PADDING,
		key: key,
		initializationVector: initializationVector
	});
</pre>

### encrypt

Stateless, one-shot encryption operation.

#### Arguments

* dataIn[buffer]: The Titanium.Buffer object containing the data to encrypt
* dataInLength[int]: (optional) The number of bytes in the dataIn buffer to encrypt. If this argument is not provided or is < 0, then the length of the dataIn buffer will be used.
* dataOut[buffer]: (optional) The Titanium.Buffer object to receive the encrypted data. If this argument is not provided, then the dataIn buffer will be used. 
    * If the cryptor.resizeBuffer property is set to true, then the dataOut buffer will be resized to the size of the encrypted data
    * If the cryptor.resizeBuffer property is set to false, then ensure that the dataOut buffer is large enough to receive the encrypted data.
* dataOutLength[int]: (optional) The number of bytes available in the dataOut buffer. If this argument is not provided or is < 0, then the length of the dataOut buffer will be used.

#### Return Value

Returns the number of bytes encrypted into the dataOut buffer. If an error occurred, then the return value will be less than zero and will be one of the following values:

* crypto.STATUS\_ERROR
* crypto.STATUS\_PARAMERROR
* crypto.STATUS\_BUFFERTOOSMALL
* crypto.STATUS\_MEMORYFAILURE
* crypto.STATUS\_ALIGNMENTERROR
* crypto.STATUS\_DECODEERROR
* crypto.STATUS\_UNIMPLEMENTED

#### Example

<pre>
	// Encrypt the entire buffer
	var numBytes = cryptor.encrypt(bufferIn, -1, bufferOut, -1);
	-or-
	// Encrypt in-place
	var numBytes = cryptor.encrypt(bufferIn);
</pre>

### decrypt

Stateless, one-shot decryption operation.

#### Arguments

* dataIn[buffer]: The Titanium.Buffer object containing the data to decrypt
* dataInLength[int]: (optional) The number of bytes in the dataIn buffer to decrypt. If this argument is not provided or is < 0, then the length of the dataIn buffer will be used.
* dataOut[buffer]: (optional) The Titanium.Buffer object to receive the decrypted data. If this argument is not provided, then the dataIn buffer will be used. 
    * If the cryptor.resizeBuffer property is set to true, then the dataOut buffer will be resized to the size of the decrypted data
    * If the cryptor.resizeBuffer property is set to false, then ensure that the dataOut buffer is large enough to receive the decrypted data.
* dataOutLength[int]: (optional) The number of bytes available in the dataOut buffer. If this argument is not provided or is < 0, then the length of the dataOut buffer will be used.

#### Return Value

Returns the number of bytes decrypted into the dataOut buffer. If an error occurred, then the return value will be less than zero and will be one of the following values:

* crypto.STATUS\_ERROR
* crypto.STATUS\_PARAMERROR
* crypto.STATUS\_BUFFERTOOSMALL
* crypto.STATUS\_MEMORYFAILURE
* crypto.STATUS\_ALIGNMENTERROR
* crypto.STATUS\_DECODEERROR
* crypto.STATUS\_UNIMPLEMENTED

#### Example

<pre>
	// Decrypt the entire buffer
	var numBytes = cryptor.decrypt(bufferIn, -1, bufferOut, -1);
	-or-
	// Decrypt in-place
	var numBytes = cryptor.decrypt(bufferIn);
</pre>

### getOutputLength

getOutputLength is used to determine the output buffer size required to process a given input size.

#### Arguments

* dataInLength[int]: The number of bytes for the operation
* final[boolean]: Indicates if the calculation is for determining the output buffer size for a call to cryptor.final() or cryptor.update(). Set to true for cryptor.final() and false for cryptor.update().

#### Return Value

Returns the number of bytes required for the output buffer

#### Example

<pre>
	var numBytesNeeded = cryptor.getOutputLength(bufferIn.length, false);
</pre>
	
### update

update is used to encrypt or decrypt data.  This method can be called multiple times. The caller does not need to align input data lengths to block sizes; input is buffered as necessary for block ciphers.

#### Arguments

* dataIn[buffer]: The Titanium.Buffer object containing the input data
* dataInLength[int]: (optional) The number of bytes in the dataIn buffer to process. If this argument is not provided or is < 0, then the length of the dataIn buffer will be used.
* dataOut[buffer]: (optional) The Titanium.Buffer object to receive the output data. If this argument is not provided, then the dataIn buffer will be used. 
    * If the cryptor.resizeBuffer property is set to true, then the dataOut buffer will be resized to the size of the output data
    * If the cryptor.resizeBuffer property is set to false, then ensure that the dataOut buffer is large enough to receive the output data.
* dataOutLength[int]: (optional) The number of bytes available in the dataOut buffer. If this argument is not provided or is < 0, then the length of the dataOut buffer will be used.

#### Return Value

Returns the number of bytes moved into the dataOut buffer. If an error occurred, then the return value will be less than zero and will be one of the following values:

* crypto.STATUS\_ERROR
* crypto.STATUS\_PARAMERROR
* crypto.STATUS\_BUFFERTOOSMALL
* crypto.STATUS\_MEMORYFAILURE
* crypto.STATUS\_ALIGNMENTERROR
* crypto.STATUS\_DECODEERROR
* crypto.STATUS\_UNIMPLEMENTED

#### Example

<pre>
	// Encrypt the entire buffer into a buffer of fixed size
	var numBytes = cryptor.update(buffer, -1, fixedBuffer);
</pre>

### finish

Finishes encryption and decryption operations and obtains the final data output.

#### Arguments

* dataOut[buffer]: The Titanium.Buffer object to receive the output data.
    * If the cryptor.resizeBuffer property is set to true, then the dataOut buffer will be resized to the size of the output data
    * If the cryptor.resizeBuffer property is set to false, then ensure that the dataOut buffer is large enough to receive the output data.
* dataOutLength[int]: (optional) The number of bytes available in the dataOut buffer. If this argument is not provided or is < 0, then the length of the dataOut buffer will be used.

#### Return Value

Returns the number of bytes moved into the dataOut buffer. If an error occurred, then the return value will be less than zero and will be one of the following values:

* crypto.STATUS\_ERROR
* crypto.STATUS\_PARAMERROR
* crypto.STATUS\_BUFFERTOOSMALL
* crypto.STATUS\_MEMORYFAILURE
* crypto.STATUS\_ALIGNMENTERROR
* crypto.STATUS\_DECODEERROR
* crypto.STATUS\_UNIMPLEMENTED

#### Example

<pre>
	var numBytes = cryptor.final(fixedBuffer)
</pre>

### reset

reset reinitializes an existing cryptor object with a (possibly) new initialization vector.

#### Arguments

* initializationVector[buffer]: (optional) The Titanium.Buffer object containing the initialization vector.

#### Return Value

* crypto.STATUS\_SUCCESS
* crypto.STATUS\_ERROR
* crypto.STATUS\_PARAMERROR
* crypto.STATUS\_BUFFERTOOSMALL
* crypto.STATUS\_MEMORYFAILURE
* crypto.STATUS\_ALIGNMENTERROR
* crypto.STATUS\_DECODEERROR
* crypto.STATUS\_UNIMPLEMENTED

#### Example

<pre>
	cryptor.reset(initializationVector);
</pre>

### release

release will dispose of the internal cryptor data

#### Return Value

* crypto.STATUS\_SUCCESS
* crypto.STATUS\_ERROR
* crypto.STATUS\_PARAMERROR
* crypto.STATUS\_BUFFERTOOSMALL
* crypto.STATUS\_MEMORYFAILURE
* crypto.STATUS\_ALIGNMENTERROR
* crypto.STATUS\_DECODEERROR
* crypto.STATUS\_UNIMPLEMENTED

#### Example

<pre>
	cryptor.release();
</pre>

## License
Copyright(c) 2010-2013 by Appcelerator, Inc. All Rights Reserved. Please see the LICENSE file included in the distribution for further details.


