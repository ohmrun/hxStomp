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
package com.meandowntime.hxstomp.exception;

import com.meandowntime.hxstomp.headers.Headers;

/**
 * When the client gets an explicit ERROR frame when waiting for a receipt,
 * it will invoke the STOMPClient OnFault callback with the ERROR frame details, instead of throwing a Haxe error
 */
class ReceiptErrorException extends Exception {

	public var command:String;
	public var headers:Headers;
	public var body:String;
	
	public function new(command:String, headers:Headers, body:String,?info : haxe.PosInfos ) {
		
		super("ERROR response received " + body, info);
		
		// Store ERROR frame details in exception object so the STOMPCLient can pass them to the onFault callback
		this.command = command;
		this.headers = headers;
		this.body = body;
	}
	
}