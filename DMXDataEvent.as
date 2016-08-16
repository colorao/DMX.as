package colorao.devices.dmx
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	public class DMXDataEvent extends Event
	{
		public static const DMX_RESPONSE : String = "dmxResponse";
		
		public var data : ByteArray;
		
		public function DMXDataEvent(type:String, $data:ByteArray=null)
		{
			super(type, false , false);
			data = $data;
		}
		
		override
		public function clone() : Event
		{
			return new DMXDataEvent(type , data);
		}
	}
}