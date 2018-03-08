package com.chunkserver;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.util.HashMap;
import java.util.stream.Stream;

import com.interfaces.ChunkServerInterface;

/**
 * implementation of interfaces at the chunkserver side
 * 
 * @author Shahram Ghandeharizadeh
 *
 */

public class ChunkServer implements ChunkServerInterface {
//	final static String filePath = "C:\\Users\\shahram\\Documents\\TinyFS-2\\csci485Disk\\"; // or C:\\newfile.txt
	final static String filePath = "C:\\Users\\Nick\\Documents\\csci485test\\";
	public static long counter;
	
	private final static String metadataFilename = ".metadata";
	private final static String ext = ".bin";

	/**
	 * Initialize the chunk server
	 */
	public ChunkServer() {
		// read metadata file here and initialize counter
		File metadataFile = null;
		try {
			metadataFile = new File(filePath + metadataFilename);
			if (metadataFile.exists()) {
				HashMap<String, String> parameters = parseMetadata(metadataFile);
				counter = Integer.parseInt(parameters.get("FILE_COUNT")); // Since 0 indexed. The next file is to be the file count
			} else {
				counter = 0;
			}
		} finally {
			updateMetadata("FILE_COUNT:" + counter);
		}
	}

	/**
	 * Each chunk corresponds to a file. Return the chunk handle of the last chunk
	 * in the file.
	 */
	public String initializeChunk() {
		// create file and return the string handle of the latest chunk
		return (filePath + counter + ext);
	}

	/**
	 * Write the byte array to the chunk at the specified offset The byte array size
	 * should be no greater than 4KB
	 */
	public boolean putChunk(String ChunkHandle, byte[] payload, int offset) {
		FileOutputStream chunkFile = null;
		try {
			// Creates a file if not exists. If it does just opens it
			chunkFile = new FileOutputStream(ChunkHandle, true);
			// Append to file
			// Check if the input is chunkSize. If not exception???
			if (payload.length <= ChunkSize) {
				chunkFile.write(payload, offset, payload.length);
			} else {
				System.out.println("Payload size bigger than alloted chunk size");
			}
			// Close the chunkFile
			chunkFile.close();
			++counter;
			updateMetadata("FILE_COUNT:" + counter);
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
			chunkFile = new FileInputStream(ChunkHandle);
			byte [] chunkData = new byte[NumberOfBytes];
			chunkFile.read(chunkData, offset, NumberOfBytes);
			chunkFile.close();
			return chunkData;
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		return null;
	}

	/**
	 * Reads in a metadata file
	 */
	private HashMap<String, String> parseMetadata(File metadataFile) {
		HashMap<String, String> params = new HashMap<>();
		try (Stream<String> lines = Files.lines(metadataFile.toPath(), Charset.defaultCharset())) {
				lines.forEachOrdered(line -> {
					// Expecting KEY:VALUE for each line
					String [] parameter = line.split(":");
					if (parameter.length == 2) {
						params.put(parameter[0], parameter[1]);
					}
				});
			} catch (IOException e) { e.printStackTrace(); }
		
		return params;
	}
	/*
	 * Updates the metadata file
	 */
	private void updateMetadata(String paramArg) {
		FileOutputStream metadata = null;
		try {
			metadata = new FileOutputStream(filePath + metadataFilename);
			metadata.write(paramArg.getBytes());
			metadata.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}
