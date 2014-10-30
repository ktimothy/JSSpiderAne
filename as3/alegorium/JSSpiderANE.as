// Oleg github/PeyTy (skype:alegorium mailto:alegorium@gmail.com)
package alegorium
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.external.ExternalInterface;
	/**
	 * Класс взаимодействия c JavaScript движком
	 */
	public class JSSpiderANE
	{
		/**
		 * Контекст расширения
		 */
		public static var ext:ExtensionContext = null;

		/**
		 * Кеш слушателя исключений
		 */
		private static var _exceptionListener:Function = null;

		/**
		 * Инстанцирование запрещено
		 */
		public function JSSpiderANE(){
			throw "JSSpiderANE instantiation disallowed";
		}

		/**
		 * Устанавливает слушателя исключений
		 * @param listener Функция, принимающая e:StatusEvent
		 */
		public static function setExceptionListener(listener:Function):void
		{
			if(_exceptionListener != null)
				ext.removeEventListener(StatusEvent.STATUS, _exceptionListener);
			_exceptionListener = listener;
			ext.addEventListener(StatusEvent.STATUS, _exceptionListener);
		}

		/**
		 * Вспомогательная фунция для автоматического получения контекста
		 */
		private static function getContext():ExtensionContext
		{
			if(ext != null) return ext;
			try {
				ext =
				ExtensionContext.createExtensionContext("alegorium.ane.JSSpiderANE",
				                                        "");
				ext.call("call", "''+(window = {})");
			} catch(e) { trace(e) }
			return ext;
		}

		/**
		 * Проверить, поддерживается ли ANE на текущей платформе
		 * Этот метод необходимо вызвать, чтобы провести инициализацию
		 */
		public static function get isSupported():Boolean
		{
			return getContext() != null;
		}

		/**
		 * Создать контекст исполнения (если не создан) и выполнить в нем переданный
		 * код инициализации скриптинга. Созданный в результате объект должен
		 * существовать в глобальной области видимости (любой аналог window в
		 * браузере) и не должен удаляться сборщиком мусора во время
		 * существования контекста исполнения в JavaScript.
		 *
		 * @param script Код инициализации скриптинга
		 */
		public static function setScript(script:String):void {
			ext.call( "eval", script +
				("\n$0 = JSON.stringify; $1 = window.Context.instance;")
			);
		};

		/**
		 * Задать объект AS3-окружения для доступа из JS
		 * @param script Код вспомогательного класса окружения вида
		 *               function Environment() { this.func = ... };
		 *               Вызов функции вида callAIRI("name", params:String) из JS
		 *               будет проброшен в Объект окружения AS3
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
		public static function setEnvironment(script:String, object:Object):void {
			ext.actionScriptData = object;
			ext.call( "eval", script + '\n/* */ environment = new Environment();\n');
		}

		/**
		 * Вызвать метод объекта exports.Context.instance и вернуть результат
		 * его исполнения как json-строку. Если метод setScript был вызван
		 * более одного раза, то метод callScriptMethod вызывается у последнего
		 * созданного объекта exports.Context.instance
		 *
		 * @param name          Имя метода, вызываемого у
		 *                        exports.Context.instance
		 * @param jsonParams    json-строка, передаваемая как параметр в метод
		 *
		 * @return  json-строка результата выполнения метода
		 */
		public static function callScriptMethod(name:String, jsonParams:Object):* {
			return JSON.parse((ext.call( "call",
				"$0($1." + name + '(' + JSONHelper.convert(jsonParams) + '))'
			)) as String);
		};

		/**
		 * Очищает память расширения и выгружает движок JS в том числе
		 */
		public static function dispose():void {
			if(ext == null) return ;
			ext.dispose();
			ext = null;
		}
	}
}