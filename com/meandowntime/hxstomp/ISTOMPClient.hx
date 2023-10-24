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

	import com.meandowntime.hxstomp.headers.AckHeaders;
	import com.meandowntime.hxstomp.headers.Headers;
	import com.meandowntime.hxstomp.headers.ConnectHeaders;
	import com.meandowntime.hxstomp.headers.SubscribeHeaders;
	import com.meandowntime.hxstomp.headers.UnsubscribeHeaders;
	import com.meandowntime.hxstomp.headers.BeginHeaders;
	import com.meandowntime.hxstomp.headers.CommitHeaders;
	import com.meandowntime.hxstomp.headers.AbortHeaders;

/**
 * Defines the Public API for the Haxe STOMP Client class
 * 
 * Interface can be used to inject a STOMPClient object via a Spring - like framework, for example.
 * 
 */
interface ISTOMPClient {


	public var errorMessages : Array<String>;
	public var sessionID : String;
	public var connectTime : Date;
	public var disconnectTime : Date;
	public var autoReconnect : Bool;
	public var timeout:Float;	//Socket timeout (in seconds)

	public function connect( host : String, port : Int, ?connectHeaders : ConnectHeaders, ?sync:Bool) : Void;
	public function disconnect():Void;	// Sends DISCONNECT to STOMP broker & close socket
	public function close():Void; 		// Closes socket connection without sending DISCONNECT message
	public function isAvailable() : Bool;
	public function subscribe(destination:String, ?subscribeHeaders : SubscribeHeaders,?sync:Bool):Void;
	public function unsubscribe(destination:String, ?unSubscribeHeaders : UnsubscribeHeaders,?sync:Bool):Void;
	public function sendString(destination:String, message:String, ?sendHeaders : Headers, ?sync:Bool):Void;
	public function ack(messageID:String, ?ackHeaders:AckHeaders, ?sync:Bool):Void;
	public function begin(transaction:String, ?beginHeaders : BeginHeaders, ?sync:Bool):Void;
	public function commit(transaction:String, ?commitHeaders : CommitHeaders, ?sync:Bool):Void;
	public function abort(transaction:String, ?abortHeaders : AbortHeaders, ?sync:Bool):Void;
	public function readFrame():Void;

	// Callback functions
	public dynamic function onConnected(command:String,headers:Headers,body:String):Void;
	public dynamic function onMessage(command:String,headers:Headers,body:String):Void;
	public dynamic function onReceipt(command:String,headers:Headers,body:String):Void;
	public dynamic function onFault(command:String,headers:Headers,body:String):Void;
	
	
}