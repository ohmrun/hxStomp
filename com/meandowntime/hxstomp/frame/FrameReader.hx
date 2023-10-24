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
package com.meandowntime.hxstomp.frame;


	import com.meandowntime.hxstomp.exception.SocketReadException;
	import com.meandowntime.hxstomp.headers.Headers;
	import com.meandowntime.hxstomp.net.ISocket;
	import com.meandowntime.hxstomp.util.StringHelper;
	import haxe.io.Bytes;
	import haxe.io.Eof;

	
/**
 * Helper class that reads and parses the received message data from the external STOMP server
 */
class FrameReader 
{


	private static var NEWLINE : String = "\n";
	private static var NEWLINEBYTE = NEWLINE.charCodeAt(0);
	private static var BODY_START : String = "\n\n";
	private static var NULL_BYTE : Int = 0x00;

	private var socket:ISocket;
	private var msgBuf:StringBuf;
	
	private var frameComplete: Bool;
	private var frameEmpty:Bool;
	
	private var contentLength: Int;
	
	public var command : String;
	public var headers : Headers;
	public var body : String;
	
	public function new(socket:ISocket): Void
	{

		this.socket = socket;
		this.msgBuf = new StringBuf();
		
		// Read all of the available data into the msgBuf buffer
		readAll();
		
		this.frameComplete = false;
		this.contentLength = -1;
		processBytes();
	}
 
	//** Read all available data until we get to a null byte followed by a carriage return
	//TODO This may need to be altered to handle valid null bytes in the body
	
	private function readAll():Void {
	
		var c:Int=0;
		var rxdNullByte:Bool = false;
		
		do {
	
			try {
				c = socket.readChar();
				//trace (c);
			} catch (eof:Eof) {
				break;
				
			} catch (e:Dynamic) {
				//TODO: Figure out why running this on linux throws a socket error at the end of each frame
				throw new SocketReadException();
				
			} 
			msgBuf.addChar(c);
			if (c == NULL_BYTE && !rxdNullByte) {
				rxdNullByte = true;
			} else {
				if (c == NEWLINEBYTE && rxdNullByte) break;  // Reached end of frame
				if (c != NEWLINEBYTE && rxdNullByte) rxdNullByte = false;
			}
			
		} while (true);		
	}
	
	/*
	 * Parse returned data into separate STOMP Message Frame command, headers and body components
	 */
	private function processBytes(): Void
	{
		
		var msg:String = msgBuf.toString();
		
		//trace("\nFrame rxd:\n[" + StringTools.urlEncode(msg) + "]\n");
		
		if (msg.length == 0) {
			frameEmpty = true;
			return;
		} else
			frameEmpty = false;
		
		// Put in a check in case the toString() conversion has added extra 0x00 bytes at the start
		while (msg.charCodeAt(0) == NULL_BYTE)
			msg = msg.substr(1);
			
		//trace("\nFrame modified:\n[" + StringTools.urlEncode(msg) + "]\n");
		
		//if (msg.charCodeAt(0) == NEWLINE.charCodeAt(0))
		//s	msg = msg.substr(1);	// Remove unwanted \n NEWLINE at start of string
			
		// If we have enough data in the message buffer to get the STOMP command...
		var indexOf1stNewLine:Int = StringHelper.indexOfByte(NEWLINE.charCodeAt(0), msg);
		if (command==null &&  indexOf1stNewLine != -1)
			processCommand(msg,indexOf1stNewLine);
		

		// If we have enough data to process the STOMP headers in the message frame...	
		var indexOfBodyStart:Int = msg.indexOf(BODY_START);
		if (command!=null && headers==null && indexOfBodyStart != -1)
			processHeaders(msg.substr(indexOf1stNewLine+1),indexOfBodyStart);
		
	
		// If we have received the complete body data ...	
		if (command!=null && headers != null && bodyComplete(msg,indexOfBodyStart+2))
			processBody(msg,indexOfBodyStart+2);
			
		
		if (command!=null && headers!=null && body!=null)
			frameComplete = true;
				
	}
	
	public function isComplete():Bool {
		return frameComplete;
	}
	
	public function isEmpty():Bool {
		return frameEmpty;
	}
	public function readBytes(socket:ISocket):Void 
	{
		//trace ("readBytes msg=" + StringTools.urlEncode(msgBuf.toString()));
		readAll();
		processBytes();
	}
	
	private function processCommand(msg:String,indexOf1stNewLine:Int):Void {
		command = msg.substr(0, indexOf1stNewLine);
		//trace("\nprocessCommand command=[" + command + "], command.length="+command.length+"indexOf1stNewLine="+indexOf1stNewLine);
	}
	
	/*
	 * Parse headers from "msg" string, which contains Message Frame from start of headers to end of Frame (incl. body)
	 */
	private function processHeaders(msg:String,indexOfBodyStart):Void {
		headers = new Headers();
					
		var headerString : String = msg.split(BODY_START)[0];
		var headerValuePairs : Array<String> = headerString.split(NEWLINE);
		
		var pair:String;
		for (pair in headerValuePairs) 
		{
			var separator : Int = pair.indexOf(":");
			headers.addHeader(pair.substr(0, separator), pair.substr(separator + 1));
		}
		
		contentLength = Std.parseInt(headers.getHeader("content-length"));
		
		//trace("\nProcessHeaders headers=" + headers.toString());
	}
	
	/**
	 * Determine if we have received all of the body data yet
	 * s = full MessageFrame string
	 * indexOfActualBodyStart = position of actual start of body data, after the \n\n substring
	 */
	private function bodyComplete(s:String,indexOfActualBodyStart:Int) : Bool
	{
		//trace("\nbodyComplete s="+s+" contentLength=" + contentLength + " s.length=" + s.length + " indexOfActualBodyStart=" + indexOfActualBodyStart);
		
		// STOMP protocol requires us to read contentLength bytes, if specified in header of MessageFrame
		if(contentLength != -1) {
			if(contentLength > s.length - indexOfActualBodyStart)
				return false;
		}
		else {
			// Read body data until encounter first NULL_BYTE
			var nullByteIndex: Int = StringHelper.indexOfByte(NULL_BYTE,s.substr(indexOfActualBodyStart));
			if(nullByteIndex != -1)
				contentLength = nullByteIndex;	
			else
				return false;
		}

		return true;
	}
	
	
	/**
	 * Process full body data
	 * s = full MessageFrame string
	 * indexOfActualBodyStart = position of actual start of body data, after the \n\n substring
	 */
	private function processBody(s:String, indexOfActualBodyStart:Int):Void {
		

		body = s.substr(indexOfActualBodyStart);
		// Added to strip out last character
		if (body.charCodeAt(body.length - 1) == 10) {
			body = body.substr(0, body.length - 2);
		}	
		//trace("\nprocessBody body=[" + body + "]");
	}

	
}