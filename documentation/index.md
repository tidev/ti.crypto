# crypto Module

## Description

This module provides access to the CCCrypt symmetric encryption interfaces on iOS.

## Accessing the crypto Module

To access this module from JavaScript, you would do the following:

	var crypto = require("ti.crypto");

The crypto variable is a reference to the Module object.	

## Reference

Use the following link(s) to learn more about using the crypto APIs:

* [iOS Developer Library - Mac OS X Manual Page for CCCrypt(3cc)](http://developer.apple.com/library/ios/#documentation/System/Conceptual/ManPages_iPhoneOS/man3/CCCrypt.3cc.html)

## Methods

### createCryptor

Creates a [crypto.cryptor][] object for encrypting and decrypting data. See [Cryptor][crypto.cryptor] for parameters of this method as well as the methods for performing the actual encryption and decryption operations.

### decodeData

Decodes a source buffer into a string using the specified data type. This is a codec method used for converting data from a source buffer into a displayable string.

#### Arguments

Takes one argument, a dictionary with keys:
	
* source[buffer]: The Titanium.Buffer to decode
* type[string]: The format of the returned string:
    * crypto.TYPE\_BASE64STRING - result is a base64 encoded string
    * crypto.TYPE\_HEXSTRING - result is a hexadecimal formatted string

#### Return Value

Returns the decoded string

#### Example

<pre>
	// Set the value of the encrypted text (base64 encoded for readability)
	cipherTextField.value = crypto.decodeData({
		source: buffer,
		type: App.crypto.TYPE_BASE64STRING
	});
</pre>

### encodeData

Encodes the source into the destination buffer using the specified data type. This is a codec method used for converting data to a destination buffer.

#### Arguments

Takes one argument, a dictionary with keys:

* source[object]: The data to encode (see 'type' for supported object types)
* dest[buffer]: The Titanium.Buffer to receive the encoded data
* destPosition[int]: The position in dest to set the encoded data (optional, default is 0)
* type[string]: The data type of the source object:
    * crypto.TYPE\_BASE64STRING - source is a base64 encoded string
    * crypto.TYPE\_HEXSTRING - source is a hexadecimal formatted string
    * crypto.TYPE\_BLOB - source is a Titanium.Blob object

#### Return Value

Returns the position after the encoded data inside the destination.

#### Example

<pre>
	// Load the buffer with the base64encoded value from the encrypted text field
	var buffer = Ti.createBuffer({ length: cipherTextField.value.length });
	var length = crypto.encodeData({
		source: cipherTextField.value,
		dest: buffer,
		type: App.crypto.TYPE_BASE64STRING
	});		
	if (length < 0) {
		Ti.API.info('ERROR: Buffer too small');
		return;
	}
</pre>

## Constants

### Cryptor Status Codes

#### crypto.STATUS\_SUCCESS
#### crypto.STATUS\_ERROR
#### crypto.STATUS\_PARAMERROR
#### crypto.STATUS\_BUFFERTOOSMALL
#### crypto.STATUS\_MEMORYFAILURE
#### crypto.STATUS\_ALIGNMENTERROR
#### crypto.STATUS\_DECODEERROR
#### crypto.STATUS\_UNIMPLEMENTED

### Cryptor Operations

#### crypto.ENCRYPT
#### crypto.DECRYPT

### Cryptor Algorithms

#### crypto.ALGORITHM\_AES128
#### crypto.ALGORITHM\_DES
#### crypto.ALGORITHM\_3DES
#### crypto.ALGORITHM\_CAST
#### crypto.ALGORITHM\_RC4
#### crypto.ALGORITHM\_RC2

### Cryptor Options

#### crypto.OPTION\_PKCS7PADDING
#### crypto.OPTION\_ECBMODE

### Cryptor Key Sizes

#### crypto.KEYSIZE\_AES128
#### crypto.KEYSIZE\_AES192
#### crypto.KEYSIZE\_AES256
#### crypto.KEYSIZE\_DES
#### crypto.KEYSIZE\_3DES
#### crypto.KEYSIZE\_MINCAST
#### crypto.KEYSIZE\_MAXCAST
#### crypto.KEYSIZE\_MINRC4
#### crypto.KEYSIZE\_MAXRC4
#### crypto.KEYSIZE\_MINRC2
#### crypto.KEYSIZE\_MINRC2

### Cryptor Block Sizes

#### crypto.BLOCKSIZE\_AES128
#### crypto.BLOCKSIZE\_DES
#### crypto.BLOCKSIZE\_3DES
#### crypto.BLOCKSIZE\_CAST
#### crypto.BLOCKSIZE\_RC2

### Data Types

#### crypto.TYPE\_BLOB - A Titanium.Blob object
#### crypto.TYPE\_HEXSTRING - A hexadecimal formatted string. Each byte is represented by 2 hexadecimal numbers.
#### crypto.TYPE\_BASE64STRING - A Base64 encoded string

## Using this module

- Copy the module zip file into the root folder of your Titanium application or in the Titanium system folder (e.g. /Library/Application Support/Titanium). 
- Set the `<module>` element in tiapp.xml, such as this: 
    <modules> 
	    <module version="1.0" platform="android">ti.crypto</module> 
    </modules> 

## Usage
See example.

## Author
Jeff English

## Feedback and Support
Please direct all questions, feedback, and concerns to [info@appcelerator.com](mailto:info@appcelerator.com?subject=Android%20Crypto%20Module).

## License
Copyright(c) 2010-2011 by Appcelerator, Inc. All Rights Reserved. Please see the LICENSE file included in the distribution for further details.

[crypto.cryptor]: cryptor.html

