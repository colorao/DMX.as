package colorao.devices.dmx
{
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	import benkuper.nativeExtensions.NativeSerial;
	import benkuper.nativeExtensions.SerialEvent;
	import benkuper.nativeExtensions.SerialPort;

	/**
	 * @author Colorao
	 */
	public class DMXDevice extends EventDispatcher
	{
		
		protected var _portName : String ;
		protected var _baudRate : int;
		protected var _port : SerialPort;
		
		protected var _samePackage : ByteArray;
		protected var _packager : DMXPackager;
		
		/**
		 * Creates a serial connection with a DMX device connected to a Enttec adapter .
		 * This class uses the fantastic NativeSerial.ane developed by Ben Kuperberg (https://github.com/benkuper/AIR-NativeExtensions/tree/master/NativeSerial) 
		 * If you want to connect through any other serial interface like Serproxy or any other, you can use the DMXPackager.as for getting the formatted ByteArray
		 * If the DMX device is bi-directional and returns data, then this instance dispatches a DMXDataEvent with the Bytearray returned by the device.
		 * 
		 * 
		 * @param $portName
		 * The COM Port name of the Enntec Device.
		 * In Mac could be something like  /dev/tty.usbserial-ENXQIH76
		 * In Windows, couldbe something like COM1 
		 * <br>
		 * 
		 * @param $baudRate
		 * The baudRate of the port.<br>
		 * The higher, the better, but in my test, 250000 is too much and NativeSerial crashes.<br>
		 * <br>
		 * 
		 * @param $length
		 * The channels length. Usually 512, but it depends on the device.<br>
		 * If your device (as mine) does not have 512, then set only the ones it has. <br>
		 * <br>
		 * <br>
		 * @throws
		 * Error if connection to NativeSerial is not available.
		 */
		public function DMXDevice($portName : String , $baudRate:int = 9600 , $length: int = 512)
		{
			super(null);
			
			_portName = $portName;
			_baudRate = $baudRate;
			
			_samePackage = new ByteArray();
			_packager = new DMXPackager($length);
			
			try
			{
				NativeSerial.init();
				
				//Logger.debug(NativeSerial.ports.toString());
				
				_port = NativeSerial.getPort(_portName);
				if (_port != null) 
				{
					_port.mode = SerialPort.MODE_RAW ;
					_port.open(_baudRate);
					_port.addEventListener(SerialEvent.DATA , _serialPortOnData);
				}
				else
				{
					throw new Error("Serial port ("+_portName +") no found ");
				}
			} 
			catch(error:Error) 
			{
				throw new Error("Unable to set NativeSerial : " + error.message);
			}
		}
		
		

		/**
		 * The portName of the serial device
		 */
		public function get portName():String
		{
			return _portName;
		}

		/**
		 * The baudRate of the device
		 */
		public function get baudRate():int
		{
			return _baudRate;
		}

		/**
		 * Tells the packager to clean the channels values.
		 */
		public function clearChannels() : void
		{
			_packager.cleanChannels();	
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
			_packager.setChannel($channel , $value);
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
			return _packager.getChannel($channel);
		}
		
		/**
		 * After setting channel values, get the package and send it to the serial port.
		 */
		public function flush() : void
		{
			_port.writeBytes(_packager.getPackage(_samePackage));
		}
		
		

		protected function _serialPortOnData (e : SerialEvent) : void
		{
			dispatchEvent(new DMXDataEvent(DMXDataEvent.DMX_RESPONSE , e.data));
		}
		
	}
}