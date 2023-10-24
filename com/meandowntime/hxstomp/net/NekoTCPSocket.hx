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

import com.meandowntime.hxstomp.exception.InvalidArgumentsException;
import com.meandowntime.hxstomp.exception.SocketCreationException;
import haxe.io.Bytes;
import sys.net.Host;
import sys.net.Socket;

/**
 * Provides wrapper around the Neko neko.net.Socket object
 * for direct tcp socket connections
 */
class NekoTCPSocket implements ISocket
{

	private var _s:Socket;
	
	public function new():Void  {
		_s = new Socket();
	}
	
	public  function connect(host:String, port:Int):Void {
		if (host == null || port == null)
			throw new InvalidArgumentsException();
		_s.connect(new Host(host), port);
	}
	public  function close():Void {
		_s.close();
	}
	
	public  function readChar():Int {
		var c:Int;
		c = _s.input.readByte();
		return c;
	}
	
	public  function write(s:String):Void {
		_s.output.writeString(s);
	}
		
	public  function setTimeout(timeout:Float):Void {
		_s.setTimeout(timeout);
	}
	
	public  function hasFrameToRead(timeout:Float):Bool {
		
		var _read:Array<Socket> = [this._s];
		var _write:Array<Socket> = null;
		var _others:Array<Socket> = null;
		//trace ("select with timeout" + timeout);
		var ret = Socket.select(_read, _write, _others, timeout);
		// return ret.read != null
		return ret.read.length == 1;
		
	}
		

	
}