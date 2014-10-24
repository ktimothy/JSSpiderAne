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
		private static var ext:ExtensionContext = null;

		/**
		 * Инстанцирование запрещено
		 */
		public function JSSpiderANE(){
			throw "JSSpiderANE instantiation disallowed";
		}

		/**
		 * Вспомогательная фунция для автоматического получения контекста
		 */
		private static function getContext():ExtensionContext
		{
			if(ext != null) return ext;
			try {
				ext = ExtensionContext.createExtensionContext("alegorium.ane.JSSpiderANE","");
			} catch(e) { trace(e) }
			return ext;
		}

		/**
		 * Проверить, поддерживается ли ANE на текущей платформе
		 */
		public static function get isSupported() : Boolean
		{
			return getContext() != null;
		}

		/**
		 * Создать контекст исполнения (ели не создан) и выполнить в нем переданный код
		 * инициализации скриптинга. Созданный в результате объект должен
		 * существовать в глобальной области видимости (любой аналог window в
		 * браузере) и не должен удаляться сборщиком мусора во время
		 * существования контекста исполнения в JavaScript.
		 *
		 * @param script Код инициализации скриптинга
		 */
		public static function setScript(script:String):void {
			if(ext == null && getContext() == null) return ;
			ext.call( "eval", script +
				("\n$0 = JSON.stringify; $1 = window.Context.instance;")
			);
		};

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
		public static function callScriptMethod(name:String, jsonParams:Object):Object {
			if(ext == null && getContext() == null) return null;
			return JSON.parse((ext.call( "call",
				"$0($1." + name + '(' + JSON.stringify(jsonParams) + '))'
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