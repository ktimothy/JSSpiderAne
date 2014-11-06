package alegorium
{
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;

	public class JSSpiderANE
	{
		private static var _context:ExtensionContext = null;
		private static var _exceptionListener:Function = null;

		public function JSSpiderANE(){
			throw "JSSpiderANE instantiation is not allowed";
		}

		/**
		 * Sets the exception listener
		 *
		 * @param listener Listener function that takes e:StatusEvent as argument
		 */
		public static function setExceptionListener(listener:Function):void
		{
			if (_exceptionListener && _context)
			{
				_context.removeEventListener(StatusEvent.STATUS, _exceptionListener);
			}

			_exceptionListener = listener;

			if (_context)
			{
				_context.addEventListener(StatusEvent.STATUS, _exceptionListener);
			}
		}

		private static function getContext():ExtensionContext
		{
			if(_context != null) return _context;
			_context =
			ExtensionContext.createExtensionContext("alegorium.ane.JSSpiderANE",
													"");

			_context.actionScriptData = new MethodHolder();

			if (_exceptionListener)
			{
				_context.addEventListener(StatusEvent.STATUS,_exceptionListener);
			}

			evaluateScript(""
						+"function callAIR(name, params)						"
						+"{														"
						+"	return JSON.parse(									"
						+"			callAIRI(									"
						+"			JSON.stringify({name:name,data:params})));	"
						+"}");
			return _context;
		}

		public static function get isSupported():Boolean
		{
			try
			{
				return getContext() != null;
			}
			catch(error:Error)
			{
				trace(error);
			}
			return false;
		}

		/**
		 * Specify object of AS3-environment to be accessed from JS
		 *
		 * @param object Object, with enumeration of functions
		 */
		public static function setScriptEnvironment(object:Object):void
		{
			(getContext().actionScriptData as MethodHolder).holder = object;
		}

		public static function evaluateScript(script:String):Object
		{
			if(_context == null) getContext();

			var callResultString:String = _context.call("eval", script) as String;
			var callResult:Object = JSON.parse(callResultString);

			if(callResult.error)
			{
				throw new Error(String(callResult.error));
			}

			return callResult.result;
		}

		/**
		 * Frees extension memory and unloads JS engine
		 */
		public static function dispose():void
		{
			if(_context == null) return ;

			_context.dispose();
			_context = null;
		}
	}
}

internal final class MethodHolder
{
	public var holder:Object;
	private var _result:Object;

	public function get run():String
	{
		return JSON.stringify(_result);
	}

	public function set run(json:String):void
	{
		var callInfo:Object = JSON.parse(json);

		if(holder != null)
		{
			try
			{
				_result = {
					result :
					holder[callInfo.name](callInfo.data),
					error : null
				};
			}
			catch(error:Error)
			{
				_result = { error : error.message, result : null };
			}
		} else _result = {
			error : "Script environment was not specified",
			result : null
		};
	}
}