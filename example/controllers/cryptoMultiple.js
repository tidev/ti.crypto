App.controllers.cryptoMultiple = function () {
	var API = {
		params: null,
		cryptor: null,
		key: null,
		initializationVector: null,
		plainTextField: null,
		cipherTextField: null,
		fixedBuffer: null,
		encryptionBuffer: null,
		
		init: function (params) {
			API.params = params;

			// Keys can be defined using text strings ('value:') or hex values ('hexValue:')
			switch (params.keySize) {
				case 1:
					API.key = App.crypto.createKey({ hexValue: '11' });
					break;
				case 5:
					// Hex values can be separated by spaces for easier reading
					API.key = App.crypto.createKey({ hexValue: '00 11 22 33 44' });
					break;
				case 8:
					// Or, hex values can be specified as one single sequence of numbers
					API.key = App.crypto.createKey({ hexValue: '0011223344556677' });
					break;
				case 16:
					API.key = App.crypto.createKey({ hexValue: '001122334455667788990a0b0c0d0e0f' });
					break;
				case 24:
					API.key = App.crypto.createKey({ value: 'abcdefghijklmnopqrstuvwx' });
					break;
				case 32:
					API.key = App.crypto.createKey({ value: 'abcdefghijklmnopqrstuvwxyz012345' });
					break;
				case 128:
					API.key = App.crypto.createKey({ value: '00000000001111111111222222222233333333334444444444555555555566666666667777777777888888888899999999990000000000111111111122222222' });
					break;
				case 512:
					var string100 = '0000000000111111111122222222223333333333444444444455555555556666666666777777777788888888889999999999';
					API.key = App.crypto.createKey({ value: string100 + string100 + string100 + string100 + string100 + '012345678901' });
					break;
			};
			
			API.initializationVector = App.crypto.createBuffer({
				hexValue: "00 11 22 33 44 55 66 77 88 99 aa bb cc dd ee ff"
			});
			
			API.cryptor = App.crypto.createCryptor({
				algorithm: params.algorithm,
				options: params.options,
				key: API.key,
				initializationVector: API.initializationVector
			});
			
			// Create a large, fixed size buffer to be used for encryption / decryption
			API.fixedBuffer = Ti.createBuffer();
			API.fixedBuffer.length = 1024;
			
			// Create the encryption buffer to hold the result
			API.encryptionBuffer = Ti.createBuffer();			
			
			// NOTE: Set resizeBuffer to false if you do not want the output buffer to be resized to fit the
			// size needed for encryption / decryption. In this example we are creating a large, fixed size buffer to
			// be reused each time that update is called to minimize memory reallocations.
			API.cryptor.resizeBuffer = false;
		},
		
		cleanup: function() {
			API.params = null;
			API.cryptor = null;
			API.key = null;
			API.initializationVector = null;
			API.plainTextField = null;
			API.cipherTextField = null;
			API.fixedBuffer = null;
			API.encryptionBuffer = null;
		},
		
		handleUpdate: function(e) {
			API.cryptor.operation = App.crypto.ENCRYPT;
			
			var buffer = App.crypto.createBuffer({ value: API.plainTextField.value + '\n' });
			
			// For this example, use the same buffer for both input and output (in-place)
			// You can specify separate buffers for both input and output if desired
			var numBytes = API.cryptor.update(buffer, -1, API.fixedBuffer);
			
			// Append the result to our encryption buffer
			API.encryptionBuffer.append(API.fixedBuffer, 0, numBytes);
			
			Ti.API.info('NumBytes: ' + numBytes);
			if (numBytes < 0) {
				alert('Error occurred during encryption: ' + numBytes);
			} else {
				// Set the value of the encrypted text (base64 encoded for readability)
				API.cipherTextField.value = Ti.Utils.base64encode(API.encryptionBuffer.toBlob()).toString();
			}
			
			// Clear the plain text field for the next update
			API.plainTextField.value = '';
			API.plainTextField.blur();
		},
	
		handleFinal: function(e) {
			var numBytes = API.cryptor.final(API.fixedBuffer);
			if (numBytes > 0) {
				API.encryptionBuffer.append(API.fixedBuffer, 0, numBytes);
			}
			
			API.cryptor.release();
			
			API.doDecryption();
			
			// Reset fields in case another encryption begins
			API.encryptionBuffer.clear();
			API.encryptionBuffer.release();
			API.cipherTextField.value = '';
		},
		
		doDecryption: function() {
			API.cryptor.operation = App.crypto.DECRYPT;
			
			API.cryptor.resizeBuffer = true;
			
			var decryptionBuffer = Ti.createBuffer();
			var decryptedText = Ti.createBuffer();
			
			var numBytes = API.cryptor.update(API.encryptionBuffer, -1, decryptionBuffer);
			if (numBytes > 0) {
				decryptedText.append(decryptionBuffer, 0, numBytes);
			}
			
			numBytes = API.cryptor.final(decryptionBuffer);
			if (numBytes > 0) {
				decryptedText.append(decryptionBuffer, 0, numBytes);
			}
			
			API.cryptor.resizeBuffer = false;
			API.cryptor.release();
						
			Ti.UI.createAlertDialog({
				title: 'Decrypted Text',
				message: decryptedText.toString(),
				buttonNames: ['OK']
			}).show();
		},
		
		create: function(win) {
			win.title = API.params.title + ' - Multiple';
			
			win.add(Ti.UI.createLabel({
				text: 'Enter text to encrypt',
				textAlign: 'left',
				top: 10,
				left: 10,
				color: 'black',
				width: 'auto',
				height: 'auto'
			}));
			
			API.plainTextField = Ti.UI.createTextArea({
				value: 'Titanium Crypto Module',
				color: 'black',
				left: 10, right: 10, top: 4, height: 60,
				borderColor: 'gray',
				borderRadius: 8,
				borderWidth: 1,
				font: { fontSize: 14 }
			});
			win.add(API.plainTextField);
			
			var updateBtn = Ti.UI.createButton({
				title: 'Update',
				top: 10,
				width: 200,
				height: 40
			});
			win.add(updateBtn);
			
			win.add(Ti.UI.createLabel({
				text: 'Encrypted text (base64 encoded)',
				textAlign: 'left',
				top: 10,
				left: 10,
				color: 'black',
				width: 'auto',
				height: 'auto'
			}));
			
			API.cipherTextField = Ti.UI.createTextArea({
				backgroundColor: '#F0F0F0',
				editable: false,
				color: 'black',
				left: 10, right: 10, top: 14, height: 140,
				borderColor: 'gray',
				borderRadius: 8,
				borderWidth: 1,
				font: { fontSize: 14 }
			});
			win.add(API.cipherTextField);
			
			var finalBtn = Ti.UI.createButton({
				title: 'Final',
				top: 10,
				width: 200,
				height: 40
			});
			win.add(finalBtn);
			
			updateBtn.addEventListener('click', API.handleUpdate);
			finalBtn.addEventListener('click', API.handleFinal);
		}
	};
	
	return API;
}