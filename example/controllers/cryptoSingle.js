App.controllers.cryptoSingle = function () {
	var API = {
		params: null,
		cryptor: null,
		key: null,
		initializationVector: null,
		plainTextField: null,
		cipherTextField: null,
		
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
		},
		
		cleanup: function() {
			API.params = null;
			API.cryptor = null;
			API.key = null;
			API.initializationVector = null;
			API.plainTextField = null;
			API.cipherTextField = null;
		},
		
		handleEncrypt: function(e) {
			var buffer = App.crypto.createBuffer({ value: API.plainTextField.value });
			
			// For this example, use the same buffer for both input and output (in-place)
			// You can specify separate buffers for both input and output if desired
			var numBytes = API.cryptor.encrypt(buffer);
			
			Ti.API.info('NumBytes: ' + numBytes);
			if (numBytes < 0) {
				alert('Error occurred during encryption: ' + numBytes);
			} else {
				// Set the value of the encrypted text (base64 encoded for readability)
				API.cipherTextField.value = Ti.Utils.base64encode(buffer.toBlob()).toString();
			}
			
			API.plainTextField.blur();
		},
	
		handleDecrypt: function(e) {
			// NOTE: You can use the crypto module's createBuffer method to create a buffer with the blob
			// returned from Ti.Utils.base64decode
			var buffer = App.crypto.createBuffer({ value: Ti.Utils.base64decode(API.cipherTextField.value) });
			
			// For this example, use the same buffer for both input and output (in-place)
			// You can specify separate buffers for both input and output if desired
			var numBytes = API.cryptor.decrypt(buffer);
			
			if (numBytes < 0) {
				alert('Error occurred during encryption: ' + numBytes);
			} else {
				Ti.UI.createAlertDialog({
					title: 'Decrypted Text',
					message: buffer.toString(),
					buttonNames: ['OK']
				}).show();
			}
		},
		
		create: function(win) {
			win.title = API.params.title + ' - Single';
			
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
				left: 10, right: 10, top: 4, height: 100,
				borderColor: 'gray',
				borderRadius: 8,
				borderWidth: 1,
				font: { fontSize: 14 }
			});
			win.add(API.plainTextField);
			
			var encryptBtn = Ti.UI.createButton({
				title: 'Encrypt',
				top: 10,
				width: 200,
				height: 40
			});
			win.add(encryptBtn);
			
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
				left: 10, right: 10, top: 14, height: 100,
				borderColor: 'gray',
				borderRadius: 8,
				borderWidth: 1,
				font: { fontSize: 14 }
			});
			win.add(API.cipherTextField);
			
			var decryptBtn = Ti.UI.createButton({
				title: 'Decrypt',
				top: 10,
				width: 200,
				height: 40
			});
			win.add(decryptBtn);
			
			encryptBtn.addEventListener('click', API.handleEncrypt);
			decryptBtn.addEventListener('click', API.handleDecrypt);
		}
	};
	
	return API;
}