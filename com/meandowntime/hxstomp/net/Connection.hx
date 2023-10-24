/*
Copyright (c) 2008, Richard J Smith

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package com.meandowntime.hxstomp.net;


import com.meandowntime.hxstomp.exception.ReceiptErrorException;
import com.meandowntime.hxstomp.exception.ReceiptTimeoutException;
import com.meandowntime.hxstomp.exception.SocketCreationException;
import com.meandowntime.hxstomp.exception.SocketReadException;
import com.meandowntime.hxstomp.exception.SocketWriteException;
import com.meandowntime.hxstomp.exception.IncorrectReceiptException;
import Sys;
import com.meandowntime.hxstomp.frame.FrameReader;
import com.meandowntime.hxstomp.STOMPClient;
import com.meandowntime.hxstomp.headers.Headers;

/**
 * Provides comms layer for STOMP protocol
 */
class Connection 
{

	public var sync:Bool;
	
	private var socket : ISocket;
	private var timeout:Float;
	private static var NEWLINE : String = "\n";
	private static var BODY_START : String = "\n\n";
	private static var NULL_BYTE : Int = 0x00;

	private static var MAXRECEIPTLOOPCOUNT:Int = 10;
	
	private var pendingMessageQueue:Array < MessageFrameType > ;
	
	private var frameReader:FrameReader;

	/**
		Creates a new client connected to specified STOMP Broker.
	**/
	public function new( socket:ISocket,?host:String, ?port:Int ){
		this.socket = socket;
		pendingMessageQueue = new Array();
		
		if (host != null)
			connect(host, port);

		
	}

	/**
		Physical connection to STOMP server.
	**/
	public function connect( host:String, port:Int )
	{
		//trace("\nConnecting to host " + host + ":" + port);
		try {
			socket.connect(host, port);
		} catch (e:Dynamic) {
			throw new SocketCreationException(host,port);
		}
	}

	/**
	 * Transmits a STOMP message frame to the connected STOMP broker
	 * @param	command
	 * @param	headers
	 * @param	?body
	 */
	public function transmit (command : String, headers : Headers, ?body : String) : Void {
		var transmission:StringBuf = new StringBuf();
		var h:haxe.ds.StringMap<String>;
		h = if (headers !=null) headers.getHeaders() else null;
		
		transmission.add(command);

		if (h != null) {
			var keys = h.keys();
			for (key in keys)
				transmission.add( NEWLINE + key + ":" + h.get(key));	       
		} else {
			transmission.add(NEWLINE);
		}

		transmission.add( BODY_START );
		
		if (body != null) transmission.add( body);
		
		//trace (transmission.toString());
		
		try{
			socket.write(transmission.toString()+String.fromCharCode(NULL_BYTE));
			//socket.writeChar(NULL_BYTE);
		} catch (e:Dynamic) {
			throw new SocketWriteException(e);
		}


		
	}
	/**
		Set socket timeout.
	**/
	public function setTimeout( timeout:Float )
	{
		//trace ("timeout=" + Std.string(timeout));
		socket.setTimeout(timeout);
		this.timeout = timeout;
		
	}

	/**
		Close STOMP connection.
	**/
	public function close(){
		try socket.close() catch(e:Dynamic) {}
	}
	
	/**
	 * Optionally wait for a matching receipt reply
	 * @param	h
	 * @param	?sync
	 */
	public function waitForReceipt(h:Headers, ?sync:Bool):Void {
		var _receipt:Bool = if (sync != null) sync else this.sync;
		//trace("_receipt="+ Std.string(_receipt));
		if (_receipt) {
			var _receiptID = if (h.getHeader("receipt") != null) h.getHeader("receipt") else null;
			if (_receiptID == null)
				return;
			var me = this;
			var gotReceipt:Bool = false;
			var loopCount:Int = 0;
			//trace("Wait for receipt");
			
			try {
				while (!gotReceipt && loopCount < MAXRECEIPTLOOPCOUNT) {
					readResponse(function(command:String, headers:Headers, body:String) {		
						if (command == "ERROR") {
							gotReceipt = true;
							throw new ReceiptErrorException(command,headers,body);
						}
						if (command == "RECEIPT") {
							if (headers.getHeader("receipt-id") == _receiptID) {
								//trace("Got receipt:" + _receiptID);
								gotReceipt = true;
								return;
							} else {
								// Raise error
								gotReceipt = true;
								throw new IncorrectReceiptException(headers.getHeader("receipt-id"),_receiptID);
							}
					
						}
						if (command == "MESSAGE") {
							// Save message to act on after processing the RECEIPT
							me.pendingMessageQueue.push( { command:command, headers:headers, body:body } );
						}

				
					});
					loopCount++;
				}	
			} catch (e:Dynamic) {
				throw(e);
			}
			
			if (loopCount == MAXRECEIPTLOOPCOUNT)
				throw new ReceiptTimeoutException(_receiptID, loopCount * timeout);
		}
	}

	/**
	 * Block and wait for response.
	 * Process response and pass response back to caller via the callbackFn function parameter
	 * @param	callbackFn
	 */
	public function readResponse(callbackFn:String->Headers->String->Void):Void {
		//trace ("\nWait for response");
		var ready:Bool;
		
		// If there are pending messages received (e.g. during waitForReceipt loop), send these before
		// reading from the socket again.
		if (pendingMessageQueue.length > 0) {
			var nextMsg = pendingMessageQueue.pop();
			callbackFn(nextMsg.command, nextMsg.headers, nextMsg.body);
			return;
		}
		
		try {
			ready = hasFrameToRead();
		} catch (e:Dynamic)
			throw new SocketReadException();
		
		if (!ready) {
			//trace ("\nNo data received");
			return; // No frame data to be read
		}	
		
		if (frameReader == null)
			frameReader = new FrameReader(socket);
		else if (!frameReader.isComplete())
			// Keep reading the message frame returned from the STOMP server
			frameReader.readBytes(socket);
			
			
		if (frameReader.isComplete()) {
			// OK .. we now have read the complete frame contents. Handle it.
			callbackFn(frameReader.command,frameReader.headers,frameReader.body);
			frameReader = null;
			return;
		}
		
		if (frameReader.isEmpty()) {
			// Gracefully handle scenario where read did not return any data after the socket timeout period expired
			callbackFn("TIMEDOUT",frameReader.headers,frameReader.body);
			frameReader = null;
			return;
		}
		
		
	}
	
	private function hasFrameToRead():Bool {
				
		return socket.hasFrameToRead(timeout);
		
	}
	
	

}