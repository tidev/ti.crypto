// CURRENTLY JUST A SINGLE PASS APP FOR TESTING THE APIS
// NEEDS TO BE REPLACED WITH A WORKING APP

// open a single window
var window = Ti.UI.createWindow({
	backgroundColor:'white'
});
var label = Ti.UI.createLabel();
window.add(label);
window.open();

var crypto = require('ti.crypto');
Ti.API.info("module is => " + crypto);

var buffer = Ti.createBuffer({value: "Hello World"});

var key = crypto.createKey({value: "12345678901234567890123456789012"});
var initializationVector = crypto.createBuffer({value: "abcdefghijklmnop"});

Ti.API.info("INITIAL");
Ti.API.info("Buffer Length: " + buffer.length);
Ti.API.info("Buffer Value: " + buffer.toString());


var cryptor = crypto.createCryptor({
	operation: crypto.ENCRYPT,
	algorithm: crypto.ALGORITHM_AES128,
	options: crypto.OPTION_PKCS7PADDING,
	key: key,
	initializationVector: initializationVector
});


var numBytes = cryptor.encrypt(buffer);


Ti.API.info("ENCRYPTED: " + numBytes);
Ti.API.info("Buffer Length: " + buffer.length);
Ti.API.info("Buffer Value: " + Ti.Utils.base64encode(buffer.toBlob()).toString());

numBytes = cryptor.decrypt(buffer);


Ti.API.info("DECRYPTED: " + numBytes);
Ti.API.info("Buffer Length: " + buffer.length);
Ti.API.info("Buffer Value: " + buffer.toString());





Ti.API.info("---FIPS TEST---");
var fipsKey = crypto.createKey({hexValue: "00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f"});
var initializationVector = crypto.createBuffer({hexValue: "00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"});
var fipsCryptor = crypto.createCryptor({
	operation: crypto.ENCRYPT,
	algorithm: crypto.ALGORITHM_AES128,
//	options: crypto.OPTION_PKCS7PADDING,
	key: fipsKey,
	initializationVector: initializationVector
});

//var fipsBuffer = Ti.createBuffer({value: "0011223344556677"});
//var fipsBuffer = Ti.createBuffer();
//crypto.fillBuffer({buffer: fipsBuffer, hexValue: "00 11 22 33 44 55 66 77 88 99 aa bb cc dd ee ff"});
var fipsBuffer = crypto.createBuffer({hexValue: "00 11 22 33 44 55 66 77 88 99 aa bb cc dd ee ff"});
var testBuffer = crypto.createBuffer({value: "aabbccddee"});

Ti.API.info("INITIAL");
Ti.API.info("Buffer Length: " + fipsBuffer.length);
Ti.API.info("Buffer Value: " + fipsBuffer.toString());

numBytes = fipsCryptor.encrypt(fipsBuffer);

Ti.API.info("ENCRYPTED: " + numBytes);
Ti.API.info("Buffer Length: " + fipsBuffer.length);
Ti.API.info("Buffer Value: " + Ti.Utils.base64encode(fipsBuffer.toBlob()).toString());

numBytes = fipsCryptor.decrypt(fipsBuffer);

Ti.API.info("DECRYPTED: " + numBytes);
Ti.API.info("Buffer Length: " + fipsBuffer.length);
Ti.API.info("Buffer Value: " + fipsBuffer.toString());

fipsCryptor = null;
fipsKey = null;
initializationVector = null;



Ti.API.info("---STARTING BLOCK ENCRYPTION---");
//
var inBuffer = Ti.createBuffer({value: "This is a test of the emergency encryption system."});
var outBuffer = Ti.createBuffer();

Ti.API.info("INITIAL");
Ti.API.info("inBuffer Length: " + inBuffer.length);
Ti.API.info("inBuffer Value: " + inBuffer.toString());

numBytes = cryptor.update(inBuffer,-1,outBuffer,-1);

Ti.API.info("UPDATE: " + numBytes);
Ti.API.info("outBuffer Length: " + outBuffer.length);
Ti.API.info("outBuffer Value: " + Ti.Utils.base64encode(outBuffer.toBlob()).toString());

numBytes = cryptor.final(outBuffer);

Ti.API.info("FINAL: " + numBytes);
Ti.API.info("outBuffer Length: " + outBuffer.length);
Ti.API.info("outBuffer Value: " + Ti.Utils.base64encode(outBuffer.toBlob()).toString());

//THIS IS NECESSARY!!!
cryptor.release();


Ti.API.info("");
Ti.API.info("_____________ ENCRYPT ______________");

var fixedBuffer = Ti.createBuffer();
fixedBuffer.length = 100;
inBuffer.length = 100;
var encryptionBuffer = Ti.createBuffer();

Ti.API.info("INITIAL");
Ti.API.info("outBuffer Length: " + fixedBuffer.length);

cryptor.resizeBuffer = false;

numBytes = Ti.Codec.encodeString({ source: "1. This is line 1\n", dest: inBuffer });
numBytes = cryptor.update(inBuffer,numBytes,fixedBuffer);
encryptionBuffer.append(fixedBuffer,0,numBytes);

Ti.API.info("UPDATE: " + numBytes);
Ti.API.info("inBuffer Length: " + inBuffer.length);
Ti.API.info("inBuffer Value: " + inBuffer.toString());
Ti.API.info("outBuffer Length: " + fixedBuffer.length);
Ti.API.info("outBuffer Value: " + Ti.Utils.base64encode(fixedBuffer.toBlob()).toString());
Ti.API.info("encryptionBuffer Length: " + encryptionBuffer.length);

numBytes = Ti.Codec.encodeString({ source: "2. This is line 2 and it is a little longer than line 1\n", dest: inBuffer });
numBytes = cryptor.update(inBuffer,numBytes,fixedBuffer);
encryptionBuffer.append(fixedBuffer,0,numBytes);

Ti.API.info("UPDATE: " + numBytes);
Ti.API.info("inBuffer Length: " + inBuffer.length);
Ti.API.info("inBuffer Value: " + inBuffer.toString());
Ti.API.info("outBuffer Length: " + fixedBuffer.length);
Ti.API.info("outBuffer Value: " + Ti.Utils.base64encode(fixedBuffer.toBlob()).toString());
Ti.API.info("encryptionBuffer Length: " + encryptionBuffer.length);

numBytes = Ti.Codec.encodeString({ source: "3. This is line 3 and it is a event longer than line 2 1234567890\n", dest: inBuffer });
numBytes = cryptor.update(inBuffer,numBytes,fixedBuffer);
encryptionBuffer.append(fixedBuffer,0,numBytes);

Ti.API.info("UPDATE: " + numBytes);
Ti.API.info("inBuffer Length: " + inBuffer.length);
Ti.API.info("inBuffer Value: " + inBuffer.toString());
Ti.API.info("outBuffer Length: " + fixedBuffer.length);
Ti.API.info("outBuffer Value: " + Ti.Utils.base64encode(fixedBuffer.toBlob()).toString());
Ti.API.info("encryptionBuffer Length: " + encryptionBuffer.length);

numBytes = cryptor.final(fixedBuffer);
if (numBytes > 0) {
	encryptionBuffer.append(fixedBuffer,0,numBytes);
}

Ti.API.info("FINAL: " + numBytes);
Ti.API.info("outBuffer Length: " + fixedBuffer.length);
Ti.API.info("outBuffer Value: " + Ti.Utils.base64encode(fixedBuffer.toBlob()).toString());
Ti.API.info("encryptionBuffer Length: " + encryptionBuffer.length);

cryptor.release();


Ti.API.info("");
Ti.API.info("_____________ DECRYPT ______________");

var decryptionBuffer = Ti.createBuffer();
fixedBuffer.length = encryptionBuffer.length;
cryptor.operation = crypto.DECRYPT;

Ti.API.info("INITIAL");
Ti.API.info("inBuffer Length: " + encryptionBuffer.length);
Ti.API.info("outBuffer Length: " + fixedBuffer.length);

numBytes = cryptor.update(encryptionBuffer,-1,fixedBuffer);
if (numBytes > 0) {
	decryptionBuffer.append(fixedBuffer,0,numBytes);
}

Ti.API.info("UPDATE: " + numBytes);
Ti.API.info("outBuffer Length: " + fixedBuffer.length);
Ti.API.info("outBuffer Value: " + fixedBuffer.toString());

numBytes = cryptor.final(fixedBuffer);
if (numBytes > 0) {
	decryptionBuffer.append(fixedBuffer,0,numBytes);
}

Ti.API.info("DECRYPTED: " + numBytes);
Ti.API.info("Buffer Length: " + decryptionBuffer.length);
Ti.API.info("Buffer Value: " + decryptionBuffer.toString());


cryptor.release();
cryptor = null;

