package com.client;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.Socket;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.util.stream.Stream;

import com.chunkserver.ChunkServer;
import com.interfaces.ClientInterface;
import com.interfaces.CommunicationInterface;

/**
 * implementation of interfaces at the client side
 * @author Shahram Ghandeharizadeh
 *
 */
public class Client implements ClientInterface {
//	public static ChunkServer cs = new ChunkServer();

    // Used to comm with the server
	private static Socket mSocket;
	private static ObjectOutputStream mOOS = null;
	private static ObjectInputStream mOIS = null;
	
	/**
	 * Initialize the client
	 */
	public Client(){
		if (mSocket != null) { return; }
		try {
			Integer portID = parseMetadata();
			Client.mSocket = new Socket("localhost", portID);
			Client.mOOS = new ObjectOutputStream(mSocket.getOutputStream());
			Client.mOIS = new ObjectInputStream(mSocket.getInputStream());
		} catch (IOException e) { e.printStackTrace(); }
	}
	
	/**
	 * Create a chunk at the chunk server from the client side.
	 */
	public String initializeChunk() {
		String chunkHandle = null;
		try {
			Client.mOOS.writeInt(CommunicationInterface.INIT_CHUNK);
			Client.mOOS.flush();
			chunkHandle = (String)Client.mOIS.readObject();
			
			int success = mOIS.readInt();
			if (success == CommunicationInterface.FAILURE) return null;
		} catch (IOException | ClassNotFoundException e) { e.printStackTrace(); }
		
		return chunkHandle;
	}
	
	/**
	 * Write a chunk at the chunk server from the client side.
	 */
	public boolean putChunk(String ChunkHandle, byte[] payload, int offset) {
		if(offset + payload.length > ChunkServer.ChunkSize){
			System.out.println("The chunk write should be within the range of the file, invalide chunk write!");
			return false;
		}
		
		try {
			Client.mOOS.writeInt(CommunicationInterface.PUT_CHUNK);
			Client.mOOS.flush();
			
			Client.mOOS.writeObject(ChunkHandle);
			Client.mOOS.writeInt(offset);
			Client.mOOS.writeInt(payload.length);
			Client.mOOS.write(payload);
			Client.mOOS.flush();
			
			int success = mOIS.readInt();
			if (success == CommunicationInterface.SUCCESS) return true;
		} catch (IOException ioe) { ioe.printStackTrace(); }
		
		return false;
	}
	
	/**
	 * Read a chunk at the chunk server from the client side.
	 */
	public byte[] getChunk(String ChunkHandle, int offset, int NumberOfBytes) {
		if(NumberOfBytes + offset > ChunkServer.ChunkSize){
			System.out.println("The chunk read should be within the range of the file, invalide chunk read!");
			return null;
		}
		
		try {
			Client.mOOS.writeInt(CommunicationInterface.GET_CHUNK);
			Client.mOOS.flush();
			
			Client.mOOS.writeObject(ChunkHandle);
			Client.mOOS.writeInt(offset);
			Client.mOOS.writeInt(NumberOfBytes);
			Client.mOOS.flush();
			
			byte [] payload = new byte[NumberOfBytes];
			Client.mOIS.readFully(payload);
			
			int success = mOIS.readInt();
			if (success == CommunicationInterface.FAILURE) return null;
			
			return payload;
		} catch (IOException ioe) { ioe.printStackTrace(); }
		
		return null;
	}

	public void disconnect() {
		try {
			if (mOIS != null) {
				mOIS.close();
				mOIS = null;
			}

			if (mOOS != null) {
				mOOS.close();
				mOOS = null;
			}
			if (mSocket != null) {
				mSocket.close();
				mSocket = null;
			}
		} catch (IOException e) { e.printStackTrace(); }
	}

	/**
	 * Reads in a metadata file
	 */
	private Integer parseMetadata() {
		Integer portID = null;
		FileInputStream metadata = null;
        BufferedReader reader = null;
		try {
			metadata = new FileInputStream(ChunkServer.metadataFilename);
			reader = new BufferedReader(new InputStreamReader(metadata));
			portID = Integer.parseInt(reader.readLine());
			metadata.close();
		} catch (IOException e) { e.printStackTrace(); }
		return portID;
	}
}
