package alegorium
{
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;

	public class JSSpiderANE
	{
		private static var _context:ExtensionContext = null;
		private static var _exceptionListener:Function = null;

		public function JSSpiderANE(){
			throw "JSSpiderANE instantiation disallowed";
		}

		/**
		 * Sets the exception listener
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
			try {
				_context =
				ExtensionContext.createExtensionContext("alegorium.ane.JSSpiderANE",
				                                        "");

				if (_exceptionListener)
				{
					_context.addEventListener(StatusEvent.STATUS,_exceptionListener);
				}
			} catch(error:Error) { trace(error) }
			return _context;
		}

		public static function get isSupported():Boolean
		{
			return getContext() != null;
		}

		/**
		 * Specify object of AS3-environment to be accessed from JS
		 * @param object Объект окружения, с перечислением доступных
		 *               AS3-функций, вида:
		 *               { func: function(params:String):String {
		 *               	// Данные необходимо обработать:
		 *               	var input:Object = JSON.parse(params);
		 *               	...
		 *               	// Результатом выражения есть строка
		 *               	// или закодированный JSON-объект:
		 *               	return JSONHelper.convert(output);
		 *               }}
		 */
		public static function setScriptEnvironment(object:Object):void {
			getContext().actionScriptData = object;
		}

		public static function evaluateScript(script:String):Object
		{
			if(_context == null) getContext();
			var callResultString:String = _context.call("eval",script) as String;
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
		public static function dispose():void {
			if(_context == null) return ;
			_context.dispose();
			_context = null;
		}
	}
}