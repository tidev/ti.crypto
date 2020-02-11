let crypto;

describe('ti.crypto', function () {

	it('can be required', () => {
		crypto = require('ti.crypto');

		expect(crypto).toBeDefined();
	});

	it('.apiName', () => {
		expect(crypto.apiName).toBe('Ti.Crypto');
	});

	describe('#createCryptor()', () => {
		it('is a function', () => {
			expect(crypto.createCryptor).toEqual(jasmine.any(Function));
		});
		// TODO: add tests for Cryptor object API!
	});

	describe('#decodeData()', () => {
		// eslint-disable-next-line jasmine/no-spec-dupes
		it('is a function', () => {
			expect(crypto.decodeData).toEqual(jasmine.any(Function));
		});
	});

	describe('#encodeData()', () => {
		// eslint-disable-next-line jasmine/no-spec-dupes
		it('is a function', () => {
			expect(crypto.encodeData).toEqual(jasmine.any(Function));
		});
	});

	describe('can encode and decode data', () => {
		it('hex string round-trip', () => {
			// hex equivalent of ascii: 'my secret value!'
			const source = '6d79207365637265742076616c756521';
			const dest = Ti.createBuffer({ length: 16 });
			const destPosition = 0; // TODO: test without specifying (should default to 0), test with negatives, other integer values, floats
			const position = crypto.encodeData({
				type: crypto.TYPE_HEXSTRING,
				dest,
				destPosition,
				source
			});
			// TODO: test that we have the right bytes in the buffer!
			expect(dest[0]).toEqual(0x6d);

			const decodedString = crypto.decodeData({
				type: crypto.TYPE_HEXSTRING,
				source: dest
			});

			expect(decodedString).toEqual(source);
		});

		// TODO: base64 round-trip
		// TODO: start with Blob
	});

	describe('constants', () => {
		describe('STATUS_*', () => {
			it('STATUS_SUCCESS', () => {
				expect(crypto.STATUS_SUCCESS).toEqual(jasmine.any(Number));
			});

			it('STATUS_ERROR', () => {
				expect(crypto.STATUS_ERROR).toEqual(jasmine.any(Number));
			});

			it('STATUS_PARAMERROR', () => {
				expect(crypto.STATUS_PARAMERROR).toEqual(jasmine.any(Number));
			});

			it('STATUS_BUFFERTOOSMALL', () => {
				expect(crypto.STATUS_BUFFERTOOSMALL).toEqual(jasmine.any(Number));
			});

			it('STATUS_MEMORYFAILURE', () => {
				expect(crypto.STATUS_MEMORYFAILURE).toEqual(jasmine.any(Number));
			});

			it('STATUS_ALIGNMENTERROR', () => {
				expect(crypto.STATUS_ALIGNMENTERROR).toEqual(jasmine.any(Number));
			});

			it('STATUS_DECODEERROR', () => {
				expect(crypto.STATUS_DECODEERROR).toEqual(jasmine.any(Number));
			});

			it('STATUS_UNIMPLEMENTED', () => {
				expect(crypto.STATUS_UNIMPLEMENTED).toEqual(jasmine.any(Number));
			});
		});

		describe('Operations', () => {
			it('ENCRYPT', () => {
				expect(crypto.ENCRYPT).toEqual(jasmine.any(Number));
			});

			it('DECRYPT', () => {
				expect(crypto.DECRYPT).toEqual(jasmine.any(Number));
			});
		});

		describe('Algorithms', () => {
			it('ALGORITHM_AES128', () => {
				expect(crypto.ALGORITHM_AES128).toEqual(jasmine.any(Number));
			});

			it('ALGORITHM_DES', () => {
				expect(crypto.ALGORITHM_DES).toEqual(jasmine.any(Number));
			});

			it('ALGORITHM_3DES', () => {
				expect(crypto.ALGORITHM_3DES).toEqual(jasmine.any(Number));
			});

			it('ALGORITHM_CAST', () => {
				expect(crypto.ALGORITHM_CAST).toEqual(jasmine.any(Number));
			});

			// FIXME: This is iOS only!
			it('ALGORITHM_RC4', () => {
				expect(crypto.ALGORITHM_RC4).toEqual(jasmine.any(Number));
			});

			it('ALGORITHM_RC2', () => {
				expect(crypto.ALGORITHM_RC2).toEqual(jasmine.any(Number));
			});
		});

		describe('Options', () => {
			it('OPTION_PKCS7PADDING', () => {
				expect(crypto.OPTION_PKCS7PADDING).toEqual(jasmine.any(Number));
			});

			it('OPTION_ECBMODE', () => {
				expect(crypto.OPTION_ECBMODE).toEqual(jasmine.any(Number));
			});
		});

		describe('Key Sizes', () => {
			it('KEYSIZE_AES128', () => {
				expect(crypto.KEYSIZE_AES128).toEqual(jasmine.any(Number));
			});

			it('KEYSIZE_AES192', () => {
				expect(crypto.KEYSIZE_AES192).toEqual(jasmine.any(Number));
			});

			it('KEYSIZE_AES256', () => {
				expect(crypto.KEYSIZE_AES256).toEqual(jasmine.any(Number));
			});

			it('KEYSIZE_DES', () => {
				expect(crypto.KEYSIZE_DES).toEqual(jasmine.any(Number));
			});

			it('KEYSIZE_3DES', () => {
				expect(crypto.KEYSIZE_3DES).toEqual(jasmine.any(Number));
			});

			it('KEYSIZE_MINCAST', () => {
				expect(crypto.KEYSIZE_MINCAST).toEqual(jasmine.any(Number));
			});

			it('KEYSIZE_MAXCAST', () => {
				expect(crypto.KEYSIZE_MAXCAST).toEqual(jasmine.any(Number));
			});

			// FIXME: This is iOS only!
			it('KEYSIZE_MINRC4', () => {
				expect(crypto.KEYSIZE_MINRC4).toEqual(jasmine.any(Number));
			});

			// FIXME: This is iOS only!
			it('KEYSIZE_MAXRC4', () => {
				expect(crypto.KEYSIZE_MAXRC4).toEqual(jasmine.any(Number));
			});

			it('KEYSIZE_MINRC2', () => {
				expect(crypto.KEYSIZE_MINRC2).toEqual(jasmine.any(Number));
			});

			it('KEYSIZE_MAXRC2', () => {
				expect(crypto.KEYSIZE_MAXRC2).toEqual(jasmine.any(Number));
			});
		});

		describe('Block Sizes', () => {
			it('BLOCKSIZE_AES128', () => {
				expect(crypto.BLOCKSIZE_AES128).toEqual(jasmine.any(Number));
			});

			it('BLOCKSIZE_DES', () => {
				expect(crypto.BLOCKSIZE_DES).toEqual(jasmine.any(Number));
			});

			it('BLOCKSIZE_3DES', () => {
				expect(crypto.BLOCKSIZE_3DES).toEqual(jasmine.any(Number));
			});

			it('BLOCKSIZE_CAST', () => {
				expect(crypto.BLOCKSIZE_CAST).toEqual(jasmine.any(Number));
			});

			// TODO: is there an BLOCKSIZE_RC4 on iOS only?

			it('BLOCKSIZE_RC2', () => {
				expect(crypto.BLOCKSIZE_RC2).toEqual(jasmine.any(Number));
			});
		});

		describe('Data Types', () => {
			it('TYPE_BLOB', () => {
				expect(crypto.TYPE_BLOB).toEqual('blob');
			});

			it('TYPE_HEXSTRING', () => {
				expect(crypto.TYPE_HEXSTRING).toEqual('hexstring');
			});

			it('TYPE_BASE64STRING', () => {
				expect(crypto.TYPE_BASE64STRING).toEqual('base64string');
			});
		});
	});
});
