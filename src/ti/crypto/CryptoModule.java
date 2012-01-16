/**
 * Ti.Crypto Module
 * Copyright (c) 2010-2011 by Appcelerator, Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */
package ti.crypto;

import java.security.Security;
import java.util.HashMap;

import org.appcelerator.kroll.common.Log;
import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.titanium.TiBlob;

import ti.crypto.utility.Hex;
import ti.modules.titanium.BufferProxy;

import org.apache.commons.codec.binary.Base64;

@Kroll.module(name = "Crypto", id = "ti.crypto")
public class CryptoModule extends KrollModule {
	private static final String LCAT = "CryptoModule";

	static {
		Security.addProvider(new org.spongycastle.jce.provider.BouncyCastleProvider());
	}

	public CryptoModule() {
		super();
	}

	// Public Methods

	@Kroll.method
	public int encodeData(HashMap args) {
		// Validate and grab the arguments we need.
		if (args == null || !args.containsKey("type") || !args.containsKey("source") || !args.containsKey("dest")) {
			Log.e(LCAT, "Not all required parameters and keys provided to encodeData! Please check the documentation and your usage.");
			return STATUS_PARAMERROR;
		}
		KrollDict dict = new KrollDict(args);
		String type = dict.getString("type");
		Object source = dict.get("source");
		BufferProxy dest = (BufferProxy) dict.get("dest");
		int destPosition = dict.optInt("destPosition", 0);

		// Turn the provided data in to a byte array.
		byte[] data;
		if (type.equals(TYPE_BLOB)) {
			data = ((TiBlob) source).getBytes();
		} else if (type.equals(TYPE_HEXSTRING)) {
			data = Hex.convertFromHex(((String) source).replaceAll(" ", ""));
		} else if (type.equals(TYPE_BASE64STRING)) {
			try {
				String raw = (String) source;
				// The astute among you may notice that I am calling "decodeBase64" in the "encodeData" method.
				// This is deliberate. "encodeData" takes formatted strings and turns them in to data.
				data = raw.length() > 0 ? Base64.decodeBase64(raw.getBytes()) : new byte[0];
			} catch (Exception e) {
				e.printStackTrace();
				data = new byte[0];
			}
		} else {
			Log.e(LCAT, "Invalid type identifier '" + type + "' sent to decodeData");
			return STATUS_PARAMERROR;
		}

		// Verify that the offset is within range.
		int destLength = dest.getLength();
		if (destPosition >= destLength) {
			Log.e(LCAT, "Destination position of " + destPosition + " is past end of buffer. Buffer size is " + destLength + ".");
			return STATUS_BUFFERTOOSMALL;
		}

		// Verify that the destination can hold the result.
		int srcLength = data.length;
		int neededLength = destPosition + srcLength;
		if (neededLength > destLength) {
			Log.e(LCAT, "Destination buffer size of " + destLength + " is too small. Needed " + neededLength + ".");
			return STATUS_BUFFERTOOSMALL;
		}

		dest.write(destPosition, data, 0, srcLength);

		return destPosition + srcLength;
	}

	@Kroll.method
	public String decodeData(HashMap args) {
		// Validate and grab the arguments we need.
		if (args == null || !args.containsKey("type") || !args.containsKey("source")) {
			Log.e(LCAT, "Not all required parameters and keys provided to decodeData! Please check the documentation and your usage.");
			return null;
		}
		KrollDict dict = new KrollDict(args);
		String type = dict.getString("type");
		BufferProxy source = (BufferProxy) dict.get("source");
		String result = null;

		try {
			if (source.getLength() > 0) {
				// Turn the provided buffer in to the desired result.
				if (type.equals(TYPE_BASE64STRING)) {
					// The astute among you may notice that I am calling "encodeBase64" in the "decodeData" method.
					// This is deliberate. "decodeData" takes data and turns it in to formatted strings.
					result = new String(Base64.encodeBase64(source.getBuffer()));
				} else if (type.equals(TYPE_HEXSTRING)) {
					result = Hex.convertToHex(source.getBuffer());
				} else {
					Log.e(LCAT, "Invalid type identifier '" + type + "' sent to decodeData");
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return result;
	}

	// Public Constants

	@Kroll.constant
	public static final int STATUS_SUCCESS = 0;
	@Kroll.constant
	public static final int STATUS_ERROR = -1;
	@Kroll.constant
	public static final int STATUS_PARAMERROR = -4300;
	@Kroll.constant
	public static final int STATUS_BUFFERTOOSMALL = -4301;
	@Kroll.constant
	public static final int STATUS_MEMORYFAILURE = -4302;
	@Kroll.constant
	public static final int STATUS_ALIGNMENTERROR = -4303;
	@Kroll.constant
	public static final int STATUS_DECODEERROR = -4304;
	@Kroll.constant
	public static final int STATUS_UNIMPLEMENTED = -4305;

	@Kroll.constant
	public static final int ENCRYPT = 0;
	@Kroll.constant
	public static final int DECRYPT = 1;

	@Kroll.constant
	public static final int ALGORITHM_AES128 = 0;
	@Kroll.constant
	public static final int ALGORITHM_DES = 1;
	@Kroll.constant
	public static final int ALGORITHM_3DES = 2;
	@Kroll.constant
	public static final int ALGORITHM_CAST = 3;
	@Kroll.constant
	public static final int ALGORITHM_RC4 = 4;
	@Kroll.constant
	public static final int ALGORITHM_RC2 = 5;

	// Note: Options must be powers of two (1, 2, 4, 8, etc)
	@Kroll.constant
	public static final int OPTION_PKCS7PADDING = 1;
	@Kroll.constant
	public static final int OPTION_ECBMODE = 2;

	@Kroll.constant
	public static final int KEYSIZE_AES128 = 16;
	@Kroll.constant
	public static final int KEYSIZE_AES192 = 24;
	@Kroll.constant
	public static final int KEYSIZE_AES256 = 32;
	@Kroll.constant
	public static final int KEYSIZE_DES = 8;
	@Kroll.constant
	public static final int KEYSIZE_3DES = 24;
	@Kroll.constant
	public static final int KEYSIZE_MINCAST = 5;
	@Kroll.constant
	public static final int KEYSIZE_MAXCAST = 16;
	@Kroll.constant
	public static final int KEYSIZE_MINRC4 = 1;
	@Kroll.constant
	public static final int KEYSIZE_MAXRC4 = 512;
	@Kroll.constant
	public static final int KEYSIZE_MINRC2 = 1;
	@Kroll.constant
	public static final int KEYSIZE_MAXRC2 = 128;

	@Kroll.constant
	public static final int BLOCKSIZE_AES128 = 16;
	@Kroll.constant
	public static final int BLOCKSIZE_DES = 8;
	@Kroll.constant
	public static final int BLOCKSIZE_3DES = 8;
	@Kroll.constant
	public static final int BLOCKSIZE_CAST = 8;
	@Kroll.constant
	public static final int BLOCKSIZE_RC2 = 8;

	@Kroll.constant
	public static final String TYPE_BLOB = "blob";
	@Kroll.constant
	public static final String TYPE_HEXSTRING = "hexstring";
	@Kroll.constant
	public static final String TYPE_BASE64STRING = "base64string";

}
