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

class SendHeaders extends Headers
{

		// The following headers are for mapping to JMS Brokers.
		// The header descriptions are from: http://activemq.apache.org/stomp.html
		
		/**
		 * Maps To: JMSCorrelationID 	 
		 * Good consumers will add this header to any responses they send
		 **/
		public static var CORRELATION_ID : String =  "correlation-id";
		 	
		/**
		 * JMSExpiration 	
		 * Expiration time of the message
		 **/
		public static var EXPIRES : String =  "expires";
		
		/**
		 * Maps To: JMSDeliveryMode 	
		 * Whether or not the message is persistent
		 */
		public static var PERSISTANT : String = "persistent";
		
		/**
		 * Maps To: JMSPriority 	
		 * Priority on the message
		 **/
		public static var PRIORITY : String =  "priority"; 	
		
		/**
		 * Maps To: JMSReplyTo 	
		 * Destination you should send replies to
		 **/
		public static var REPLY_TO : String = "reply-to";
		
		/** 
		 * Maps To: JMSType 	
		 * Type of the message
		 **/
		public static var TYPE : String = "type";
		
		/** 
		 * Maps To: JMSXGroupID 	
		 * Specifies the Message Groups
		 **/
		public static var JMSX_GROUP_ID : String = "JMSXGroupID";
		
		/**
		 * Maps To: JMSXGroupSeq 	
		 * Optional header that specifies the sequence number in the Message Groups
		 **/
		public static var JMSX_GROUP_SEQ  : String = "JMSXGroupSeq";
		
		/**
		 * Used to bind a message to a named transaction.
		 **/		
		public static var TRANSACTION : String = 'transaction';
		
		public function setReceipt (id : String) : Void
		{
			addHeader(SharedHeaders.RECEIPT, id);
		}
		
		public function setCorrelationID (id : String) : Void
		{
			addHeader(CORRELATION_ID, id);
		}
		
		public function setExpires (time : String) : Void
		{
			addHeader(EXPIRES, time);
		}
		
		public function setPersistant (isPersistant : String) : Void
		{
			addHeader(PERSISTANT, isPersistant);
		}		
		
		public function setPriority (priority : String) : Void
		{
			addHeader(PRIORITY, priority);
		}
		
		public function setReplyTo (destination : String) : Void
		{
			addHeader(REPLY_TO, destination);
		}
		
		public function setType (type : String) : Void
		{
			addHeader(TYPE, type);
		}
		
		public function setJsmxGroupID (id : String) : Void
		{
			addHeader(JMSX_GROUP_ID, id);
		}
		
		public function setJsmxGroupSeq (number : String) : Void
		{
			addHeader(JMSX_GROUP_SEQ, number);
		}
		
		public function setTransaction (id : String) : Void
		{
			addHeader(TRANSACTION, id);
		}
	
}