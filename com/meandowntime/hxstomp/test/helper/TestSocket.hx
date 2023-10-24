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

package com.meandowntime.hxstomp.test.helper;
import com.meandowntime.hxstomp.net.ISocket;
import Sys;

class TestSocket implements ISocket
{
	private var test:String;
	private var s:String;
	
	private static var NEWLINE : String = "\n";
	private static var BODY_START : String = "\n\n";
	private static var NULL_BYTE : Int = 0x00;
	
	private var T1040_1_Receipt:StringBuf;
	private var T1040_2_Receipt:StringBuf;
	private var T0300_Connect:StringBuf;
	private var T0300_Error:StringBuf;
	
	private var bufPtr:Int;
	private var timeout:Float;
	
	public function new(test:String) 
	{
		this.test = test;
		
		this.T1040_1_Receipt = new StringBuf();
		this.T1040_1_Receipt.add("RECEIPT"+NEWLINE);
		this.T1040_1_Receipt.add("receipt-id:dummy-receipt-id" + BODY_START);
		this.T1040_1_Receipt.addChar(NULL_BYTE);
		this.T1040_1_Receipt.addChar(NEWLINE.charCodeAt(0));

		this.T1040_2_Receipt = new StringBuf();
		this.T1040_2_Receipt.add("ERROR"+NEWLINE);
		this.T1040_2_Receipt.add("message:simulated ERROR Frame" + BODY_START);
		this.T1040_2_Receipt.addChar(NULL_BYTE);
		this.T1040_2_Receipt.addChar(NEWLINE.charCodeAt(0));
		
		this.T0300_Connect = new StringBuf();
		this.T0300_Connect.add("CONNECTED"+NEWLINE);
		this.T0300_Connect.add("session:T300" + BODY_START);
		this.T0300_Connect.addChar(NULL_BYTE);
		this.T0300_Connect.addChar(NEWLINE.charCodeAt(0));

		this.T0300_Error = new StringBuf();
		this.T0300_Error.add("ERROR"+NEWLINE);
		this.T0300_Error.add("message:simulated ERROR Frame for T0300" + BODY_START);
		this.T0300_Error.add("Simulated Error body");
		this.T0300_Error.addChar(NULL_BYTE);
		this.T0300_Error.addChar(NEWLINE.charCodeAt(0));
		
		timeout = 1.0;
		}

	public function connect(host:String, port:Int):Void {
		switch (test) {
			case "[T1000]":
					throw "socket error";
		}			
	}
	
	public function close():Void {
		// Do nothing
	}
	
	public function readChar():Int {
		switch (test) {
			case "[T1000-3]":
				if (s.indexOf("CONNECT",0)!= -1)
					throw "socket read error";
			case "[T1030-2]":
				if (s.indexOf("CONNECT", 0) != -1) {
					bufPtr++;
					return T0300_Connect.toString().charCodeAt(bufPtr);
				}
				if (s.indexOf("SUBSCRIBE",0)!= -1)
					throw "socket read error";
			case "[T1040-1]":
				if (s.indexOf("CONNECT", 0) != -1) {
					bufPtr++;
					return T0300_Connect.toString().charCodeAt(bufPtr);
				}
				if (s.indexOf("SUBSCRIBE", 0) != -1) {
					bufPtr++;
					return T1040_1_Receipt.toString().charCodeAt(bufPtr);
				}
			case "[T1040-2]":
				if (s.indexOf("CONNECT", 0) != -1) {
					bufPtr++;
					return T0300_Connect.toString().charCodeAt(bufPtr);
				}
				if (s.indexOf("SUBSCRIBE", 0) != -1) {
					bufPtr++;
					return T1040_2_Receipt.toString().charCodeAt(bufPtr);
				}
			case "[T0300]":
				if (s.indexOf("CONNECT", 0) != -1) {
					bufPtr++;
					return T0300_Connect.toString().charCodeAt(bufPtr);
				}
				if (s.indexOf("SUBSCRIBE", 0) != -1) {
					bufPtr++;
					return T0300_Error.toString().charCodeAt(bufPtr);
				}
			default:
				if (s.indexOf("CONNECT", 0) != -1) {
					bufPtr++;
					return T0300_Connect.toString().charCodeAt(bufPtr);
				}
			
		}
		return 0;
	}
	
	public function write(s:String):Void {
		this.s = s;
		switch (test) {
			case "[T1000-1]":
				if (s.indexOf("CONNECT",0)!= -1)
					throw "socket error";
			case "T1010":
				if (s.indexOf("CONNECT", 0) != -1)
					bufPtr = -1; // Reset in readiness of read
				if (s.indexOf("SUBSCRIBE",0)!= -1)
					throw "socket error";
			case "T1020":
				if (s.indexOf("CONNECT", 0) != -1)
					bufPtr = -1; // Reset in readiness of read
				if (s.indexOf("SEND",0)!= -1)
					throw "socket error";
			case "[T1030-2]":
				if (s.indexOf("CONNECT", 0) != -1)
					bufPtr = -1; // Reset in readiness of read
			case "[T1040-1]":
				if (s.indexOf("CONNECT", 0) != -1)
					bufPtr = -1; // Reset in readiness of read
				if (s.indexOf("SUBSCRIBE", 0) != -1)
					bufPtr = -1; // Reset in readiness of read
			case "[T1040-2]":
				if (s.indexOf("CONNECT", 0) != -1)
					bufPtr = -1; // Reset in readiness of read
				if (s.indexOf("SUBSCRIBE", 0) != -1)
					bufPtr = -1; // Reset in readiness of read
			case "[T0300]":
				if (s.indexOf("CONNECT", 0) != -1)
					bufPtr = -1; // Reset in readiness of read
				if (s.indexOf("SUBSCRIBE", 0) != -1)
					bufPtr = -1; // Reset in readiness of read
			default:
				if (s.indexOf("CONNECT", 0) != -1)
					bufPtr = -1; // Reset in readiness of read
				if (s.indexOf("SUBSCRIBE", 0) != -1)
					bufPtr = -1; // Reset in readiness of read
			
			
			
		}
		
	}
	public function writeChar(c:Int):Void {
		// Do nothing;
	}
	
	public function setTimeout(timeout:Float):Void {
		this.timeout = timeout;
	}
	
	// Tests if there is data to be read by this socket
	public function hasFrameToRead(timeout:Float):Bool {
		switch (test) {
			case "[T1000-3]":
				if (s.indexOf("CONNECT",0)!= -1)
					throw "socket read error";
			case "[T1030-1]":
				if (s.indexOf("SUBSCRIBE",0)!= -1)
					throw "socket read error";
			case "[T1050]":
				if (s.indexOf("SUBSCRIBE", 0) != -1) {
					Sys.sleep(timeout);
					return false;
				}
		}
		
		return true;
	}
	

}