/**
 * Ti.Crypto Module
 * Copyright (c) 2010-2013 by Appcelerator, Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

package ti.crypto;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.spongycastle.crypto.BlockCipher;
import org.spongycastle.crypto.engines.AESEngine;
import org.spongycastle.crypto.engines.CAST5Engine;
import org.spongycastle.crypto.engines.DESEngine;
import org.spongycastle.crypto.engines.DESedeEngine;
import org.spongycastle.crypto.engines.RC2Engine;
import org.spongycastle.crypto.modes.CBCBlockCipher;
import org.spongycastle.crypto.paddings.PKCS7Padding;
import org.spongycastle.crypto.paddings.PaddedBufferedBlockCipher;
import org.spongycastle.crypto.params.KeyParameter;
import org.spongycastle.crypto.params.ParametersWithIV;
import org.spongycastle.crypto.params.ParametersWithRandom;

import ti.modules.titanium.BufferProxy;
import android.util.Log;

@Kroll.proxy(creatableInModule = CryptoModule.class,
			 propertyAccessors = { "resizeBuffer", "operation", "algorithm", "options", "key", "initializationVector" })
public class CryptorProxy extends KrollProxy
{

	private static final String LCAT = "CryptoModule";
	private PaddedBufferedBlockCipher _encryptCipher;
	private PaddedBufferedBlockCipher _decryptCipher;

	private class CryptOptions
	{
		// Configuration Options
		public boolean resizeBuffer;
		public int operation;
		public int algorithm;
		public int options;
		public byte[] key;
		public byte[] iv;

		// Passed In Arguments
		public BufferProxy dataIn;
		public int dataInLength;
		public BufferProxy dataOut;
		public int dataOutLength;

		public byte[] getBytesIn()
		{
			return dataIn.getBuffer();
		}

		public int getDataInLength()
		{
			return dataInLength > 0 ? dataInLength : dataIn.getLength();
		}

		public int getDataOutLength()
		{
			return dataOutLength > 0 ? dataOutLength : dataOut.getLength();
		}

		public boolean isEncrypt()
		{
			return operation == CryptoModule.ENCRYPT;
		}
	}

	private CryptOptions prepareCryptOptions(BufferProxy dataIn, int dataInLength, BufferProxy dataOut,
											 int dataOutLength)
	{
		CryptOptions o = new CryptOptions();

		KrollDict dict = this.getProperties();
		o.resizeBuffer = dict.optBoolean("resizeBuffer", true);
		o.operation = dict.optInt("operation", CryptoModule.ENCRYPT);
		o.algorithm = dict.optInt("algorithm", CryptoModule.ALGORITHM_AES128);
		o.options = dict.optInt("options", 0);
		o.key = dict.containsKey("key") ? ((BufferProxy) dict.get("key")).getBuffer() : null;
		o.iv = dict.containsKey("initializationVector") ? ((BufferProxy) dict.get("initializationVector")).getBuffer()
														: null;

		o.dataIn = dataIn;
		o.dataInLength = dataInLength > 0 || dataIn == null ? dataInLength : dataIn.getLength();
		o.dataOut = dataOut != null ? dataOut : dataIn;
		o.dataOutLength = dataOutLength > 0 || o.dataOut == null ? dataOutLength : o.dataOut.getLength();

		return o;
	}

	private void logBytes(String id, byte[] arr)
	{
		StringBuffer out = new StringBuffer();
		if (arr == null) {
			out.append("{{ null }}");
		} else if (arr.length == 0) {
			out.append("{{ empty }}");
		} else {
			out.append("[" + arr[0]);
			for (int i = 1; i < arr.length; i++) {
				out.append("," + arr[i]);
			}
			out.append("]");
		}
		Log.i(LCAT, id + ": " + out.toString());
	}

	private PaddedBufferedBlockCipher createCipher(CryptOptions o)
	{
		// Start off by figuring out what engine to use.
		// (This will influence if we can use a block cipher or a stream cipher.)
		BlockCipher bEngine;
		// StreamCipher sEngine;
		switch (o.algorithm) {
			case CryptoModule.ALGORITHM_AES128:
				bEngine = new AESEngine();
				break;
			case CryptoModule.ALGORITHM_CAST:
				bEngine = new CAST5Engine();
				break;
			case CryptoModule.ALGORITHM_DES:
				bEngine = new DESEngine();
				break;
			case CryptoModule.ALGORITHM_3DES:
				bEngine = new DESedeEngine();
				break;
			case CryptoModule.ALGORITHM_RC2:
				bEngine = new RC2Engine();
				break;
			case CryptoModule.ALGORITHM_RC4:
				// TODO: not sure how to implement this at the moment...
				return null;
				// sEngine = new RC4Engine();
				// break;
			default:
				Log.e(LCAT, "Unsupported algorithm passed to CryptorProxy!");
				return null;
		}

		// Prepare to wrap the ciphers when appropriate.
		BlockCipher blockCipher = new CBCBlockCipher(bEngine);

		// Apply padding.
		PaddedBufferedBlockCipher cipher;
		if ((o.options & CryptoModule.OPTION_PKCS7PADDING) != 0) {
			cipher = new PaddedBufferedBlockCipher(blockCipher, new PKCS7Padding());
		} else {
			cipher = new PaddedBufferedBlockCipher(blockCipher);
		}

		// Apply the various modes.
		if ((o.options & CryptoModule.OPTION_ECBMODE) != 0) {
			// TODO: not sure how to implement this at the moment...
			return null;
		}

		// Initialize the cipher, now that we've determined all its parameters.
		KeyParameter key = new KeyParameter(o.key);
		if (o.iv != null) {
			byte[] iv = o.iv;
			// Ensure initializationVector is the same as the block size; 0 fill, if necessary.
			int blockSize = cipher.getBlockSize();
			if (o.iv.length != blockSize) {
				iv = new byte[blockSize];
				System.arraycopy(o.iv, 0, iv, 0, Math.min(o.iv.length, blockSize));
			}
			cipher.init(o.isEncrypt(), new ParametersWithIV(key, iv));
		} else {
			cipher.init(o.isEncrypt(), new ParametersWithRandom(key));
		}

		return cipher;
	}

	private PaddedBufferedBlockCipher getCipher(CryptOptions o)
	{
		if (o.isEncrypt()) {
			if (_encryptCipher == null)
				_encryptCipher = createCipher(o);
			return _encryptCipher;
		} else {
			if (_decryptCipher == null)
				_decryptCipher = createCipher(o);
			return _decryptCipher;
		}
	}

	private int crypt(CryptOptions o) throws Exception
	{
		// Get our cipher.
		PaddedBufferedBlockCipher cipher = getCipher(o);
		if (cipher == null)
			return CryptoModule.STATUS_PARAMERROR;

		// Create a temporary buffer to write into (it'll include padding)
		byte[] encData = o.getBytesIn();
		int dataInLength = o.getDataInLength();
		byte[] buffer = new byte[cipher.getOutputSize(dataInLength)];
		int numBytesWritten = cipher.processBytes(encData, 0, dataInLength, buffer, 0);
		numBytesWritten += cipher.doFinal(buffer, numBytesWritten);

		// Write to the buffer.
		if (o.resizeBuffer)
			o.dataOut.setLength(numBytesWritten);
		o.dataOut.write(0, buffer, 0, numBytesWritten);

		return numBytesWritten;
	}

	@Kroll.method
	public int encrypt(BufferProxy dataIn, @Kroll.argument(optional = true) int dataInLength,
					   @Kroll.argument(optional = true) BufferProxy dataOut,
					   @Kroll.argument(optional = true) int dataOutLength)
	{
		try {
			CryptOptions o = prepareCryptOptions(dataIn, dataInLength, dataOut, dataOutLength);
			o.operation = CryptoModule.ENCRYPT;
			int numBytes = crypt(o);
			_release();
			return numBytes;
		} catch (Exception e) {
			e.printStackTrace();
			return CryptoModule.STATUS_ERROR;
		}
	}

	@Kroll.method
	public int decrypt(BufferProxy dataIn, @Kroll.argument(optional = true) int dataInLength,
					   @Kroll.argument(optional = true) BufferProxy dataOut,
					   @Kroll.argument(optional = true) int dataOutLength)
	{
		try {
			CryptOptions o = prepareCryptOptions(dataIn, dataInLength, dataOut, dataOutLength);
			o.operation = CryptoModule.DECRYPT;
			int numBytes = crypt(o);
			_release();
			return numBytes;
		} catch (Exception e) {
			e.printStackTrace();
			return CryptoModule.STATUS_ERROR;
		}
	}

	@Kroll.method
	public int getOutputLength(int dataInLength, boolean isFinal)
	{
		if (dataInLength < 0) {
			dataInLength = 0;
		}
		// TODO: implement

		return CryptoModule.STATUS_UNIMPLEMENTED;
	}

	@Kroll.method
	public int update(BufferProxy dataIn, @Kroll.argument(optional = true) int dataInLength,
					  @Kroll.argument(optional = true) BufferProxy dataOut,
					  @Kroll.argument(optional = true) int dataOutLength)
	{
		try {
			// Get our cipher.
			CryptOptions o = prepareCryptOptions(dataIn, dataInLength, dataOut, dataOutLength);
			PaddedBufferedBlockCipher cipher = getCipher(o);
			if (cipher == null)
				return CryptoModule.STATUS_PARAMERROR;

			// Create a temporary buffer to write into (it'll include padding)
			byte[] encData = o.getBytesIn();
			byte[] buffer = new byte[cipher.getOutputSize(o.getDataInLength())];
			int numBytesWritten = cipher.processBytes(encData, 0, o.getDataInLength(), buffer, 0);
			// numBytesWritten += cipher.doFinal(buffer, numBytesWritten);

			// Write to the buffer.
			if (o.resizeBuffer)
				o.dataOut.setLength(numBytesWritten);
			o.dataOut.write(0, buffer, 0, numBytesWritten);

			return numBytesWritten;
		} catch (Exception e) {
			e.printStackTrace();
			return CryptoModule.STATUS_ERROR;
		}
	}

	@Kroll.method
	public int finish(BufferProxy dataOut, @Kroll.argument(optional = true) int dataOutLength)
	{
		try {
			// Get our cipher.
			CryptOptions o = prepareCryptOptions(null, 0, dataOut, dataOutLength);
			PaddedBufferedBlockCipher cipher = getCipher(o);
			if (cipher == null)
				return CryptoModule.STATUS_PARAMERROR;

			// Create a temporary buffer to write into (it'll include padding)
			byte[] buffer = new byte[cipher.getOutputSize(0)];
			int numBytesWritten = cipher.processBytes(new byte[0], 0, 0, buffer, 0);
			numBytesWritten += cipher.doFinal(buffer, numBytesWritten);

			// Write to the buffer.
			if (o.resizeBuffer)
				o.dataOut.setLength(numBytesWritten);
			o.dataOut.write(0, buffer, 0, numBytesWritten);

			return numBytesWritten;
		} catch (Exception e) {
			e.printStackTrace();
			return CryptoModule.STATUS_ERROR;
		}
	}

	@Kroll.method
	public int reset(@Kroll.argument(optional = true) BufferProxy initializationBuffer)
	{
		if (initializationBuffer != null) {
			setProperty("initializationVector", initializationBuffer);
		}
		_encryptCipher = null;
		_decryptCipher = null;
		return CryptoModule.STATUS_SUCCESS;
	}

	@Kroll.method(name = "release")
	public int _release()
	{
		_encryptCipher = null;
		_decryptCipher = null;
		return CryptoModule.STATUS_SUCCESS;
	}
}
