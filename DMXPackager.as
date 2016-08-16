package colorao.devices.dmx
{
	import flash.utils.ByteArray;

	/**
	 * @author
	 * Colorao
	 */
	public class DMXPackager
	{
		
		protected var _channels : Vector.<uint>;
		protected var _length : int;
		protected var _incChannels : int;
		
		private var BYTE_HEADER : int;
		private var BYTE_PACKET_START : int;
		private var BYTE_PACKET_LENGTH : int;
		private var BYTE_HALF_UNIVERSES : int;
		private var BYTE_CHANNELS_START : int;
		private var BYTE_END : int;
		
		/**
		 * Creates a uint vector with the given lenth and stores the values.
		 * When getPackage() is called, then creates a ByteArray with the DMX structure as explained in Enttec Site.
		 * 
		 * I also get this structure from this site: https://processing.org/discourse/beta/num_1128939792.html
		 */
		public function DMXPackager($length : int = 512)
		{
			
			_length = $length;
			_channels = new Vector.<uint>();
			_incChannels = _length+1;

			BYTE_HEADER = int(0x7E);
			BYTE_PACKET_START = 6 ;
			BYTE_PACKET_LENGTH = _incChannels & 255 ;
			BYTE_HALF_UNIVERSES = (_incChannels >> 8) & 255 ;
			BYTE_END = int(0xE7);
			BYTE_CHANNELS_START = 0;
			
			cleanChannels();
		}

		/**
		 * The channels length .
		 */
		public function get length():int
		{
			return _length;
		}

		/**
		 * Sets all the channels to 0
		 */
		public function cleanChannels() : void
		{
			var i:int;
			
			for(i=0;i<=_length;i++)
			{
				setChannel(i , 0 );
			}
		}
		
		/**
		 * Stores a value in one channel.
		 * 
		 * @param $channel
		 * The DMX channel number. 
		 * Channel numbers are in DMX order. NOT zero based array.
		 * 
		 * @param $value
		 * An unsigned integer (1-255) with the value.
		 * Values are limited to this range.
		 */
		public function setChannel($channel:uint , $value : uint) : void
		{
			if($value > 255) $value = 255; 
			
			_channels[$channel] = $value ; 
		}
		
		/**
		 * retrieves the value stored in one channel.
		 * 
		 * @param $channel
		 * The DMX channel number. 
		 * Channel numbers are in DMX order. NOT zero based array.
		 * 
		 * @return 
		 * An unsigned integer (1-255) with the stored value.
		 * Values are limited to this range.
		 */
		public function getChannel($channel:uint ) : uint
		{
			return _channels[$channel] ; 
		}
		
		
		/**
		 * Takes the data stored in all channels and composes a bytearray ready to be sent to the serial
		 * After packaging the channel values are not cleared.
		 * 
		 * @param $useThis : A given ByteArray.
		 * If a ByteArray is given, then it will be cleared and then filled with channel's data. 
		 * Else, a new Bytearray will used instead.
		 * 
		 * @return a Bytearray ready to be sent to the serial.
		 */
		public function getPackage($useThis : ByteArray = null) : ByteArray
		{
			var pack : ByteArray;
			var i:int;
			
			
			pack = $useThis ? $useThis : new ByteArray();
			pack.clear();
			
			pack.writeByte(BYTE_HEADER); 					//header
			pack.writeByte(BYTE_PACKET_START); 				//packet start
			pack.writeByte(BYTE_PACKET_LENGTH);				//Packet length ...
			pack.writeByte(BYTE_HALF_UNIVERSES);			//length / 256
			
			pack.writeByte(BYTE_CHANNELS_START); 			//Channel data start	
			for(i=0;i<_length;i++)
			{
				pack.writeByte(getChannel(i)); 				//Channel value
			}
			
			pack.writeByte(BYTE_END); 						//end
			
			return pack;
		}

	}
}