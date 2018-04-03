package com.client;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.Socket;

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
	private Socket mSocket = null;
	private ObjectOutputStream mOOS = null;
	private ObjectInputStream mOIS = null;
	
	/**
	 * Initialize the client
	 */
	public Client(){
//		if (cs == null)
//			cs = new ChunkServer();
		
		try {
			mSocket = new Socket("localhost", 8000);
			mOOS = new ObjectOutputStream(mSocket.getOutputStream());
			mOIS = new ObjectInputStream(mSocket.getInputStream());
//			mOOS.flush();
//			System.out.println("Sending stuff");
//			mOOS.writeInt(5);
//			mOOS.flush();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	/**
	 * Create a chunk at the chunk server from the client side.
	 */
	public String initializeChunk() {
		String chunkHandle = null;
		try {
			mOOS.writeInt(CommunicationInterface.INIT_CHUNK);
			mOOS.flush();
			chunkHandle = (String)mOIS.readObject();
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
			mOOS.writeInt(CommunicationInterface.PUT_CHUNK);
			mOOS.flush();
			
			mOOS.writeObject(ChunkHandle);
			mOOS.writeInt(offset);
			mOOS.writeInt(payload.length);
			mOOS.write(payload);
			mOOS.flush();
			
			return true;
		} catch (IOException ioe) { ioe.printStackTrace(); }
		
//		return cs.putChunk(ChunkHandle, payload, offset);
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
			mOOS.writeInt(CommunicationInterface.GET_CHUNK);
			
			mOOS.writeObject(ChunkHandle);
			mOOS.writeInt(offset);
			mOOS.writeInt(NumberOfBytes);
//			mOOS.write(payload);
			mOOS.flush();
			
			byte [] payload = new byte[NumberOfBytes];
			mOIS.readFully(payload);
			return payload;
		} catch (IOException ioe) { ioe.printStackTrace(); }
		
		return null;
//		return cs.getChunk(ChunkHandle, offset, NumberOfBytes);
	}

	


}
