/**
 * Ti.Crypto Module
 * Copyright (c) 2010-2013 by Appcelerator, Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

package ti.crypto.utility;

public class Hex {

  /**
   * Prevent instantiation.
   */
  private Hex() {}

  /**
   * Converts a hex string in to a byte array.
   *
   * @param val
   *            A hex string to convert.
   * @return The byte array.
   */
  public static byte[] convertFromHex(String s) {
    // Source:
    // http://stackoverflow.com/questions/140131/convert-a-string-representation-of-a-hex-dump-to-a-byte-array-using-java
    int len = s.length();
    byte[] data = new byte[len / 2];
    for (int i = 0; i < len; i += 2) {
      data[i / 2] = (byte)((Character.digit(s.charAt(i), 16) << 4) +
                           Character.digit(s.charAt(i + 1), 16));
    }
    return data;
  }

  /**
   * Converts the provided byte array to a hex string.
   *
   * @param data
   *            A byte array to convert.
   * @return The hex string.
   */
  public static String convertToHex(byte[] data) {
    StringBuffer result = new StringBuffer();
    for (int i = 0; i < data.length; i++) {
      result.append(Integer.toHexString(data[i]));
    }
    return result.toString();
  }
}
