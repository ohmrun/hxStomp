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

package com.meandowntime.hxstomp.headers;

class ConnectHeaders extends Headers
{

	/**
	  * Specifies the JMS Client ID which is used in combination with the activemq.subcriptionName 
	  * to denote a durable subscriber.
	  **/
	public static var CLIENT_ID : String = "client-id";
		
	public static var LOGIN : String = "login";
		
	public static var PASSCODE : String = "passcode";

	public function setClientID (id : String) : Void
		{
			addHeader(CLIENT_ID, id);
		}
		
	public function setLogin(username: String) : Void
		{
			addHeader(LOGIN, username);
		}
		
	public function setPasscode(password: String) : Void
		{
			addHeader(PASSCODE, password);
		}
	

}