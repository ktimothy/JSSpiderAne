package alegorium
{
	import flash.utils.ByteArray;
	public class JSONHelper {

		public static function convert( value:* ):String {
			var s:String;
			if(value is Function) {
				throw "Functions in JSON are disallowed";
			} else if (value is Array) {
				var v:Array = value;
				var l:int = v.length;
				var i:int = 0;
				s = "[";
				while(i < l) {
					if (s != "[") s += ",";
					s += convert(v[i]);
					i++;
				}
				return s + "]";
			}

			if (value is String) return _escape(value);
			s = String(value);
			if(s != "[object Object]") return s;

			s = "{";
			for (var key:String in value)
			{
				s += (s == "{"? "":",") + "\"" + key + "\":" + convert(value[key]);
			}
			return s + "}";
		}

		private static function _escape( str:String ):String
		{
			var s:String = "\"";
			var ch:String;
			var cc:int;
			var len:int = str.length;
			var sub:int = 0;
			var hexCode:String;
			// fully valid strings converted faster:
			var i:int = 0;
			for (i = 0; i < len; i++)
			{
				ch = str.charAt(i);
				cc = ch.charCodeAt(0);
				if(!(cc > 34 && cc != 92)) break ;
				sub++;
			}

			s += str.substr(0, sub);
			if(sub == len) return s + "\"";

			for (i = i; i < len; i++)
			{
				ch = str.charAt(i);
				cc = ch.charCodeAt(0);

				if(cc > 34 && cc != 92)
				{
					s += ch;
					continue ;
				} else
				if(cc == 34) {
					s += "\\\"";
					continue ;
				} else
				if(cc == 92) {
					s += "\\\\";
					continue ;
				} else
				if(cc < 14)
				{
					switch (cc)
					{
						case 8:s += "\\b";
						break;
						case 12:s += "\\f";
						break;
						case 10:s += "\\n";
						break;
						case 13:s += "\\r";
						break;
						case 9:s += "\\t";
						break;
						default:
						hexCode = ch.charCodeAt( 0 ).toString( 16 );
						s += "\\u" + (hexCode.length == 2 ? "00" : "000") + hexCode;
					}
				} else
				if(cc < 32)
				{
					hexCode = ch.charCodeAt( 0 ).toString( 16 );
					s += "\\u" + (hexCode.length == 2 ? "00" : "000") + hexCode;
				} else
				{
					s += ch;
				}
			}
			return s + "\"";
		}

		private static function _escapeOld( str:String ):String
		{
			var s:String = "\"";
			var ch:String;
			var cc:int;
			var len:int = str.length;
			var sub:int = 0;
			var hexCode:String;
			// fully valid strings converted faster:
			var i:int = 0;
			for (i = 0; i < len; i++)
			{
				ch = str.charAt(i);
				cc = ch.charCodeAt(0);
				if(!(cc > 34 && cc != 92)) break ;
				sub++;
			}

			s += str.substr(0, sub);
			if(sub == len) return s + "\"";

			for (i = i; i < len; i++)
			{
				ch = str.charAt(i);
				cc = ch.charCodeAt(0);

				if(cc > 34 && cc != 92)
				{
					s += ch;
					continue ;
				} else
				if(cc == 34) {
					s += "\\\"";
					continue ;
				} else
				if(cc == 92) {
					s += "\\\\";
					continue ;
				} else
				if(cc < 14)
				{
					switch (cc)
					{
						case 8:s += "\\b";
						break;
						case 12:s += "\\f";
						break;
						case 10:s += "\\n";
						break;
						case 13:s += "\\r";
						break;
						case 9:s += "\\t";
						break;
						default:
						hexCode = ch.charCodeAt( 0 ).toString( 16 );
						s += "\\u" + (hexCode.length == 2 ? "00" : "000") + hexCode;
					}
				} else
				if(cc < 32)
				{
					hexCode = ch.charCodeAt( 0 ).toString( 16 );
					s += "\\u" + (hexCode.length == 2 ? "00" : "000") + hexCode;
				} else
				{
					s += ch;
				}
			}
			return s + "\"";
		}

		/*private static function _escape( str:String ):String
		{
			var s:String = "\"";
			var ch:String;
			var len:int = str.length;
			for (var i:int = 0; i < len; i++)
			{
				ch = str.charAt(i);
				switch (ch)
				{
					case '"':s += "\\\"";
					break;
					case '\\':s += "\\\\";
					break;
					case '\b':s += "\\b";
					break;
					case '\f':s += "\\f";
					break;
					case '\n':s += "\\n";
					break;
					case '\r':s += "\\r";
					break;
					case '\t':s += "\\t";
					break;
				default:
					if ( ch < ' ' )
					{
						var hexCode:String = ch.charCodeAt( 0 ).toString( 16 );
						s += "\\u" + (hexCode.length == 2 ? "00" : "000") + hexCode;
					}
					else
					{
						s += ch;
					}
				}
			}
			return s + "\"";
		}*/
	}
}