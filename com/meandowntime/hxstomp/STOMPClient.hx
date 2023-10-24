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

package com.meandowntime.hxstomp;


import haxe.ds.StringMap;
import com.meandowntime.hxstomp.exception.InvalidArgumentsException;
import com.meandowntime.hxstomp.exception.ReceiptErrorException;
import com.meandowntime.hxstomp.exception.SocketCreationException;
import com.meandowntime.hxstomp.exception.SocketWriteException;
import com.meandowntime.hxstomp.headers.Headers;
import com.meandowntime.hxstomp.headers.SendHeaders;
import com.meandowntime.hxstomp.headers.AckHeaders;
import com.meandowntime.hxstomp.headers.SubscribeHeaders;
import com.meandowntime.hxstomp.headers.UnsubscribeHeaders;
import com.meandowntime.hxstomp.headers.BeginHeaders;
import com.meandowntime.hxstomp.headers.CommitHeaders;
import com.meandowntime.hxstomp.headers.AbortHeaders;
import com.meandowntime.hxstomp.headers.ConnectHeaders;
import com.meandowntime.hxstomp.net.Connection;
import com.meandowntime.hxstomp.net.ISocket;

import haxe.crypto.Md5;

typedef SubListType = {
	headers:SubscribeHeaders,
	connected:Bool };

typedef MessageFrameType = {
	command:String,
	headers:Headers,
	body:String };


/**
 * A STOMP Client for Haxe/neko
 * 
 * See <a href="http://stomp.codehaus.org/Protocol">STOMP Protocol</a>
 * 
 * Portions of this class and related classes were ported from the AS3 and PHP STOMP clients at http://stomp.codehaus.org
 * 
 */
class STOMPClient implements ISTOMPClient {


	public var errorMessages : Array<String>;
	public var sessionID : String;
	public var connectTime : Date;
	public var disconnectTime : Date;
	public var autoReconnect : Bool;
	public var timeout : Float;		// Socket timeout in seconds
	
	private var cnx : Connection;
	private var socket:ISocket;
	private var server : String;
	private var port : Int;
	private var connectHeaders : ConnectHeaders;			
	private var socketConnected:Bool;
	private var protocolPending : Bool;
	private var protocolConnected : Bool;
	private var expectDisconnect : Bool;
	
	
	private var subscriptions:StringMap<SubListType>;

	private static var SECRET_KEY : String = "MDT-DEMO";
	

	// Class Constructor
	public function new(socket:com.meandowntime.hxstomp.net.ISocket) {

		if (socket == null)
			throw new InvalidArgumentsException();
			
		// provide default values for public instance variables
		errorMessages = new Array();
		autoReconnect = true;
		timeout = 1.0;	// Default Socket timeout 1 second
		
		this.socket = socket;
		
		// Default values for private instance variables
		socketConnected = false;
		protocolPending = false;
		protocolConnected = false;
		expectDisconnect = false;
		
		subscriptions = new StringMap();
		
	}
	
	// Connect to a STOMP broker
	public function connect( host : String, port : Int, ?connectHeaders : ConnectHeaders,?sync:Bool) : Void { 

		if (host == null || port == null)
			throw new InvalidArgumentsException();
			
		if (socketConnected==true)
			return;

		
		if (cnx != null)
			close();
			
		try {
			cnx = new Connection(this.socket);

			cnx.sync = if (sync != null) sync else null;
			
			cnx.connect(host, port);
			cnx.setTimeout(timeout);
		}
		catch (e:Dynamic){
			cnx = null;
			throw e;
		}

		socketConnected = true;
		protocolConnected = false;
		protocolPending = true;
		expectDisconnect = false;
		try {
			cnx.transmit("CONNECT", connectHeaders);
		} catch (e:Dynamic) {
			onError(e);
		}
		
		// Wait for CONNECTED reply
		// NB: Trying to read here allows the using class to use the onConnected callback after calling this connect method,
		// without needing to issue its own read request.
		readFrame();
	}	

	/**
	 * Send DISCONNECT to external STOMP broker
	 */
	public function disconnect():Void {
		
		if (socketConnected && cnx != null) {
			cnx.sync = false;
			try{
				cnx.transmit("DISCONNECT",null);
				close();
			} catch (e:SocketWriteException) {
				onError(e);
			}
			protocolConnected = false;
			
		}
	}
	public function close(){
		if (cnx != null){
			cnx.close();
			cnx = null;
			
		}
		expectDisconnect = true;
		socketConnected = false;
	}

	public function isAvailable() : Bool {
		return cnx != null && socketConnected;
	}

	public function subscribe(destination:String, ?subscribeHeaders : SubscribeHeaders,?sync:Bool):Void 
	{
		var h = if (subscribeHeaders != null) subscribeHeaders else new Headers();
				
		if (socketConnected) {
			if (h.getHeader("destination") == null)
				h.addHeader("destination", destination);

			prepareReceipt(h, sync);
			try {
				cnx.transmit("SUBSCRIBE", h);
				cnx.waitForReceipt(h, sync);
			} catch (e:ReceiptErrorException) {
				// Call the external onFault callback function
				onFault(e.command, e.headers, e.body);
			} catch (e:Dynamic) {
				onError(e);
			}
			
		}
		
		subscriptions.set(destination,{ headers:subscribeHeaders,connected:socketConnected } );
		
	}

	public function unsubscribe(destination:String, ?unSubscribeHeaders : UnsubscribeHeaders,?sync:Bool):Void 
	{
		var h = if (unSubscribeHeaders != null) unSubscribeHeaders else new Headers();
				
		if (socketConnected) {
			if (h.getHeader("destination") == null)
				h.addHeader("destination", destination);

			prepareReceipt(h, sync);
			try {
				cnx.transmit("UNSUBSCRIBE", h);
				cnx.waitForReceipt(h, sync);
			} catch (e:ReceiptErrorException) {
				// Call the external onFault callback function
				onFault(e.command, e.headers, e.body);
			} catch (e:Dynamic) {
				onError(e);
			}
			
			
		}
		
		subscriptions.remove(destination);
		
	}
	
	public function sendString(destination:String, message:String, ?sendHeaders : Headers, ?sync:Bool):Void
	{
		var h = if (sendHeaders != null) sendHeaders else new Headers();
		var body:String;
		
		if (socketConnected) {
			if (h.getHeader("destination") == null)
				h.addHeader("destination", destination);
				
			body = message;
			h.addHeader("content-length", Std.string(body.length));
			
			prepareReceipt(h, sync);
			try {
				cnx.transmit("SEND", h, body);
				cnx.waitForReceipt(h, sync);
			} catch (e:ReceiptErrorException) {
				// Call the external onFault callback function
				onFault(e.command, e.headers, e.body);
			} catch (e:SocketWriteException) {
				onError(e);
			}
			
		
		}
		
		
	}

	public function ack(messageID:String, ?ackHeaders:AckHeaders, ?sync:Bool):Void {
		
		
		var h = if (ackHeaders != null) ackHeaders else new Headers();
		
		if (socketConnected) {
			if (h.getHeader("message-id") == null)
				h.addHeader("message-id", messageID);

			prepareReceipt(h, sync);
			try {
				cnx.transmit("ACK", h);
				cnx.waitForReceipt(h, sync);
			} catch (e:ReceiptErrorException) {
				// Call the external onFault callback function
				onFault(e.command, e.headers, e.body);
			} catch (e:Dynamic) {
				onError(e);
			}
			
		}
	}
			
	public function begin(transaction:String, ?beginHeaders : BeginHeaders, ?sync:Bool):Void {
		var h = if (beginHeaders != null) beginHeaders else new Headers();
				
		if (socketConnected) {
			if (h.getHeader("transaction") == null)
				h.addHeader("transaction", transaction);

			prepareReceipt(h, sync);
			try {
				cnx.transmit("BEGIN", h);
				cnx.waitForReceipt(h, sync);
			} catch (e:ReceiptErrorException) {
				// Call the external onFault callback function
				onFault(e.command, e.headers, e.body);
			} catch (e:Dynamic) {
				onError(e);
			}

			
		}
		
	}

	public function commit(transaction:String, ?commitHeaders : CommitHeaders, ?sync:Bool):Void {
		var h = if (commitHeaders != null) commitHeaders else new Headers();
				
		if (socketConnected) {
			if (h.getHeader("transaction") == null)
				h.addHeader("transaction", transaction);

			prepareReceipt(h, sync);
			try {
				cnx.transmit("COMMIT", h);
				cnx.waitForReceipt(h, sync);
			} catch (e:ReceiptErrorException) {
				// Call the external onFault callback function
				onFault(e.command, e.headers, e.body);
			} catch (e:Dynamic) {
				onError(e);
			}
			
		}
		
	}

	public function abort(transaction:String, ?abortHeaders : AbortHeaders, ?sync:Bool):Void {
		var h = if (abortHeaders != null) abortHeaders else new Headers();
				
		if (socketConnected) {
			if (h.getHeader("transaction") == null)
				h.addHeader("transaction", transaction);

			prepareReceipt(h, sync);
			try {
				cnx.transmit("ABORT", h);
				cnx.waitForReceipt(h, sync);
			} catch (e:ReceiptErrorException) {
				// Call the external onFault callback function
				onFault(e.command, e.headers, e.body);
			} catch (e:Dynamic) {
				onError(e);
			}
			
		}
		
	}
	
	
	/**
	 * Public API Read the next message received from the STOMP broker
	 * Result dispatched to appropriate callback function
	 */
	public function readFrame():Void {
		
		try {
			cnx.readResponse(onReadFrameResponse); 
		} catch (e:Dynamic) {
			onError(e);
		}
	}
	
	private function onReadFrameResponse(command:String, headers:Headers, body:String):Void {
			//trace("["+command+"]\nHeaders:["+headers+"]\nBody:["+body+"]\n");
			// Determine what message, if any, we have
			switch (command) {
				case "CONNECTED":
					protocolConnected = true;
					protocolPending = false;
					expectDisconnect = false;
					connectTime = Date.now();
					sessionID = headers.getHeader("session");
					processSubscriptions();
					onConnected(command,headers,body);				
				
				case "MESSAGE":
					onMessage(command,headers,body);
				
				case "RECEIPT":
					onReceipt(command,headers,body);
				
				case "ERROR":
					onFault(command, headers, body);				
				case "TIMEDOUT":
					return;
				default:
					throw "UNKNOWN STOMP FRAME";
				
			}			
		
	}
	
	// Callback functions
	// Re-assigned by using object
	// eg. mySTOMPClientInstance.onConnected = function() { ... do something ...};
	
	public dynamic function onConnected(command:String,headers:Headers,body:String):Void {}
	public dynamic function onMessage(command:String,headers:Headers,body:String):Void {}
	public dynamic function onReceipt(command:String,headers:Headers,body:String):Void {}
	public dynamic function onFault(command:String,headers:Headers,body:String):Void {}
	
	// *********************************************************************************************
	
	// Optionally add a Receipt header if synchronous response required
	private function prepareReceipt(h, ?sync):Void {
		
		var _receipt:Bool = if (sync != null) sync else cnx.sync;
		
		if (_receipt) {
			if (h.getHeader("receipt") == null)
				h.addHeader("receipt", createUniqueID());
				
		}
	}
	
		/**
	 * Creates a messageID token that is guranteed to be unique for this process lifetime
	 * @return	created sessionID string.
	 */
	private function createUniqueID() : String
	{
		//TODO Make this threadsafe to prevent race conditions and duplicate sessionIDs.
		var sessionID : String = null;
		
			// Create a random sessionID
		sessionID = Md5.encode(Std.string((Math.random() * Date.now().getTime())+(Math.random() * Date.now().getTime()))+SECRET_KEY);
	
		//trace ("Created SessionID+" + sessionID);
		
		return sessionID;
	}

	
	/**
	 * Re-subscribes to any previous queue or topic subscriptions, following a re-connection
	 */
	private function processSubscriptions() : Void 
		{
			var sub:SubListType;
			
			for (key in subscriptions.keys())
			{
				if (!subscriptions.get(key).connected)
					this.subscribe(key, subscriptions.get(key).headers);
			}
		}
	
	private function onError(e:Dynamic):Void {
		
		socketConnected = false;
		protocolConnected = false;
		protocolPending = false;
		disconnectTime = Date.now();

		throw e;
		
			
	}

}