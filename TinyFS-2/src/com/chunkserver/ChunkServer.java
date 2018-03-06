package com.chunkserver;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.RandomAccessFile;

import com.interfaces.ChunkServerInterface;

/**
 * implementation of interfaces at the chunkserver side
 * 
 * @author Shahram Ghandeharizadeh
 *
 */

public class ChunkServer implements ChunkServerInterface {
//	final static String filePath = "C:\\Users\\shahram\\Documents\\TinyFS-2\\csci485Disk\\"; // or C:\\newfile.txt
	final static String filePath = "C:\\Users\\Nick\\Documents\\csci485test\\newfile.txt";
	public static long counter;

	/**
	 * Initialize the chunk server
	 */
	public ChunkServer() {
		System.out.println(
				"Constructor of ChunkServer is invoked:  Part 1 of TinyFS must implement the body of this method.");
		System.out.println("It does nothing for now.\n");
	}

	/**
	 * Each chunk corresponds to a file. Return the chunk handle of the last chunk
	 * in the file.
	 */
	public String initializeChunk() {
		++counter;
		return String.valueOf(counter);
	}

	/**
	 * Write the byte array to the chunk at the specified offset The byte array size
	 * should be no greater than 4KB
	 */
	public boolean putChunk(String ChunkHandle, byte[] payload, int offset) {
		FileOutputStream chunkFile = null;
		try {
			// Creates a file if not exists. If it does just opens it
			chunkFile = new FileOutputStream(filePath + ChunkHandle, true);
			// Append to file
			/* ?????? Should we be checking for the array size here or is it guaranteed??? */
			chunkFile.write(payload, offset, payload.length);
			// Close the chunkFile
			chunkFile.close();
		} catch (IOException e) {
			e.printStackTrace();
			return false;
		}
		return true;
	}

	/**
	 * read the chunk at the specific offset
	 */
	public byte[] getChunk(String ChunkHandle, int offset, int NumberOfBytes) {
		FileInputStream chunkFile = null;
		try {
			chunkFile = new FileInputStream(filePath + ChunkHandle);
			byte [] chunkData = new byte[NumberOfBytes];
			chunkFile.read(chunkData, offset, NumberOfBytes);
			chunkFile.close();
			return chunkData;
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		return null;
	}

}
