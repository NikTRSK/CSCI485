package com.chunkserver;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.RandomAccessFile;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Arrays;

import com.interfaces.ChunkServerInterface;
import com.interfaces.CommunicationInterface;

/**
 * implementation of interfaces at the chunkserver side
 * @author Shahram Ghandeharizadeh
 *
 */

public class ChunkServer implements ChunkServerInterface {
	final static String filePath = "csci485/";	//or C:\\newfile.txt
	public static long counter;
	
	private final static String metadataFilename = ".metadata";
	private ServerSocket mServerSocket = null;
	private Socket mSocket = null;
	
	// reader
	private ObjectInputStream mOIS = null;
	private ObjectOutputStream mOOS = null;
	
	private boolean isRunning = true;
	public static int portID = 8000;
	/**
	 * Initialize the chunk server
	 */
	public ChunkServer(){
		File dir = new File(filePath);
		File[] fs = dir.listFiles();

		if(fs.length == 0){
			counter = 0;
		}else{
			long[] cntrs = new long[fs.length];
			for (int j=0; j < cntrs.length; j++)
				cntrs[j] = Long.valueOf( fs[j].getName() ); 
			
			Arrays.sort(cntrs);
			counter = cntrs[cntrs.length - 1];
		}
		
		// Open Socket
		try {
			mServerSocket = new ServerSocket(ChunkServer.portID);
			System.out.println("Listening on: " + mServerSocket.getLocalPort());
			updateMetadata(mServerSocket.getLocalPort());
			mSocket = mServerSocket.accept();
			// Initialize the streams
			mOIS = new ObjectInputStream(mSocket.getInputStream());
			mOOS = new ObjectOutputStream(mSocket.getOutputStream());
			
			System.out.println("Client connected");
		while(isRunning) {
			try {
					// Read in and process input
					int requestCode = mOIS.readInt();
					System.out.println("CODE: " + requestCode);
					if (requestCode == CommunicationInterface.INIT_CHUNK) {
						String chunkHandle = initializeChunk();
						mOOS.writeObject(chunkHandle);
						mOOS.flush();
					}
					else if (requestCode == CommunicationInterface.GET_CHUNK) {
						String handle = (String)mOIS.readObject();
						Integer offset = mOIS.readInt();
						Integer length = mOIS.readInt();
						byte [] payload = getChunk(handle, offset, length);
						mOOS.write(payload);
						mOOS.flush();
					}
					else if (requestCode == CommunicationInterface.PUT_CHUNK) {
						String handle = (String)mOIS.readObject();
						Integer offSet = mOIS.readInt();
						Integer length = mOIS.readInt();
						byte [] payload = new byte[length];
						mOIS.readFully(payload);
						putChunk(handle, payload, offSet);
					}
					else if (requestCode == CommunicationInterface.SHUTDOWN) {
						isRunning = false;
					}
				} catch (IOException | ClassNotFoundException ioe) { /* ioe.printStackTrace(); */ 
					continue; }
			}
		} catch (IOException ioe) { ioe.printStackTrace(); }
		finally {
			try {
				if (mOIS != null) mOIS.close();
				if (mSocket != null) mSocket.close();
				if (mServerSocket != null) mServerSocket.close();
			} catch (IOException ioe) { ioe.printStackTrace(); }
		}
	}
	
	/**
	 * Each chunk is corresponding to a file.
	 * Return the chunk handle of the last chunk in the file.
	 */
	public String initializeChunk() {
		counter++;
		return String.valueOf(counter);
	}
	
	/**
	 * Write the byte array to the chunk at the offset
	 * The byte array size should be no greater than 4KB
	 */
	public boolean putChunk(String ChunkHandle, byte[] payload, int offset) {
		try {
			//If the file corresponding to ChunkHandle does not exist then create it before writing into it
			RandomAccessFile raf = new RandomAccessFile(filePath + ChunkHandle, "rw");
			raf.seek(offset);
			raf.write(payload, 0, payload.length);
			raf.close();
			return true;
		} catch (IOException ex) {
			ex.printStackTrace();
			return false;
		}
	}
	
	/**
	 * read the chunk at the specific offset
	 */
	public byte[] getChunk(String ChunkHandle, int offset, int NumberOfBytes) {
		try {
			//If the file for the chunk does not exist the return null
			boolean exists = (new File(filePath + ChunkHandle)).exists();
			if (exists == false) return null;
			
			//File for the chunk exists then go ahead and read it
			byte[] data = new byte[NumberOfBytes];
			RandomAccessFile raf = new RandomAccessFile(filePath + ChunkHandle, "rw");
			raf.seek(offset);
			raf.read(data, 0, NumberOfBytes);
			raf.close();
			return data;
		} catch (IOException ex){
			ex.printStackTrace();
			return null;
		}
	}

	/*
	 * Updates the metadata file
	 */
	private void updateMetadata(Integer portid) {
		FileOutputStream metadata = null;
		try {
			metadata = new FileOutputStream(metadataFilename);
			metadata.write(portid.toString().getBytes());
			metadata.close();
		} catch (IOException e) { e.printStackTrace(); }
	}
	
	public static void main (String [] args) {
		new ChunkServer();
	}
}
