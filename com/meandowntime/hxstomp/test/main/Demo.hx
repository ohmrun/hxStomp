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


package com.meandowntime.hxstomp.test.main;

	import com.meandowntime.hxstomp.headers.Headers;
	import com.meandowntime.hxstomp.ISTOMPClient;
	import com.meandowntime.hxstomp.net.ISocket;
	import com.meandowntime.hxstomp.net.NekoTCPSocket;
	import com.meandowntime.hxstomp.STOMPClient;

class Demo 
{
 
	public static function main():Void
	{
		
		// Test basic operation of Stomp client.
		var s:ISocket 			= new NekoTCPSocket();
		var st:ISTOMPClient = new STOMPClient(s);
		st.timeout = 1; // 1 second wait
		
		try {
			st.connect("localhost", 61613);
		} catch (e:Dynamic) {
			trace (e.toString());
			return;
		}
		
		var topic:String = "/topic/hxstomp/basicdemo";
		try {
			st.subscribe(topic,null,true);
		} catch (e:Dynamic) {
			trace (e.toString());
			return;
		}
		
		// Send a message
		try {
			st.sendString(topic,"Hello from haxe!");
		} catch (e:Dynamic) {
			trace (e.toString());
			return;
		}
		
		// Now go into read loop for a couple of minutes
		var endTS:Date = DateTools.delta(Date.now(),120000);
		var nextSend:Date = DateTools.delta(Date.now(),10000);
		st.onMessage = function(command:String, headers:Headers, body:String) {
			trace("\nonMessage:\nCommand:[" + command + "]\nHeaders:[" + headers.toString() + "]\nBody:[" + body + "]\n");
		};
		st.onFault = function(command:String, headers:Headers, body:String) {
			trace("\nonFault:\nCommand:[" + command + "]\nHeaders:[" + headers.toString() + "]\nBody:[" + body + "]\n");
		};
		
		do {
			try {
				if (Date.now().getTime() > nextSend.getTime()) {
					st.sendString(topic, "Hello from haxe!" + Date.now().toString());
					nextSend = DateTools.delta(Date.now(), 10000);
				}	
				st.readFrame();
			} catch (e:Dynamic) {
				trace (e.toString());
				break;
			}
		
		} while (Date.now().getTime() < endTS.getTime());

	}
	
}