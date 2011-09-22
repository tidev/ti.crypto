// This is a test harness for your module
// You should do something interesting in this harness 
// to test out the module and to provide instructions 
// to users on how to use it by example.


// open a single window
var window = Ti.UI.createWindow({
	backgroundColor:'white'
});
var label = Ti.UI.createLabel();
window.add(label);
window.open();

// TODO: write your module tests here
var crypto = require('ti.crypto');
Ti.API.info("module is => " + crypto);

var buffer = Ti.createBuffer({value: "Hello World"});
var key = crypto.createKey({value: "12345678901234567890123456789012"});
var initializationVector = "abcdefghijklmnop";

Ti.API.info("INITIAL");
Ti.API.info("Buffer Length: " + buffer.length);
Ti.API.info("Buffer Value: " + buffer.toString());

var cryptor = crypto.createCryptor({
	op: crypto.ENCRYPT,
	algorithm: crypto.ALGORITHM_AES128,
	options: crypto.OPTION_PKCS7PADDING,
	key: key,
	initializationVector: initializationVector
});


var numBytes = cryptor.encrypt({
	dataIn: buffer
});

Ti.API.info("ENCRYPTED: " + numBytes);
Ti.API.info("Buffer Length: " + buffer.length);
Ti.API.info("Buffer Value: " + Ti.Utils.base64encode(buffer.toBlob()).toString());

numBytes = cryptor.decrypt({
	dataIn: buffer
});

Ti.API.info("DECRYPTED: " + numBytes);
Ti.API.info("Buffer Length: " + buffer.length);
Ti.API.info("Buffer Value: " + buffer.toString());





Ti.API.info("---FIPS TEST---");
var fipsKey = crypto.createKey({hexValue: "00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f"});
var fipsCryptor = crypto.createCryptor({
	op: crypto.ENCRYPT,
	algorithm: crypto.ALGORITHM_AES128,
//	options: crypto.OPTION_PKCS7PADDING,
	key: fipsKey
});

//var fipsBuffer = Ti.createBuffer({value: "0011223344556677"});
//var fipsBuffer = Ti.createBuffer();
//crypto.fillBuffer({buffer: fipsBuffer, hexValue: "00 11 22 33 44 55 66 77 88 99 aa bb cc dd ee ff"});
var fipsBuffer = crypto.createBuffer({hexValue: "00 11 22 33 44 55 66 77 88 99 aa bb cc dd ee ff"});
var testBuffer = crypto.createBuffer({value: "aabbccddee"});
var initializationVector = crypto.createBuffer({hexValue: "00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"});

Ti.API.info("INITIAL");
Ti.API.info("Buffer Length: " + fipsBuffer.length);
Ti.API.info("Buffer Value: " + fipsBuffer.toString());

numBytes = fipsCryptor.encrypt({
	dataIn: fipsBuffer,
	initializationVector: initializationVector
});

Ti.API.info("ENCRYPTED: " + numBytes);
Ti.API.info("Buffer Length: " + fipsBuffer.length);
Ti.API.info("Buffer Value: " + Ti.Utils.base64encode(fipsBuffer.toBlob()).toString());

numBytes = fipsCryptor.decrypt({
	dataIn: fipsBuffer
});

Ti.API.info("DECRYPTED: " + numBytes);
Ti.API.info("Buffer Length: " + fipsBuffer.length);
Ti.API.info("Buffer Value: " + fipsBuffer.toString());

fipsCryptor = null;




Ti.API.info("---STARTING BLOCK ENCRYPTION---");
//
var inBuffer = Ti.createBuffer({value: "Hello World"});//"This is a test of the emergency encryption system"});
var outBuffer = Ti.createBuffer();

Ti.API.info("INITIAL");
Ti.API.info("inBuffer Length: " + inBuffer.length);
Ti.API.info("inBuffer Value: " + inBuffer.toString());

numBytes = cryptor.update({
	dataIn: inBuffer,
	dataOut: outBuffer
});
Ti.API.info("UPDATE: " + numBytes);
Ti.API.info("outBuffer Length: " + outBuffer.length);
Ti.API.info("outBuffer Value: " + Ti.Utils.base64encode(outBuffer.toBlob()).toString());

numBytes = cryptor.final({
	dataOut: outBuffer
});
Ti.API.info("FINAL: " + numBytes);
Ti.API.info("outBuffer Length: " + outBuffer.length);
Ti.API.info("outBuffer Value: " + Ti.Utils.base64encode(outBuffer.toBlob()).toString());

cryptor.reset();
