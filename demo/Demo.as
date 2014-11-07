package  {

	import flash.display.MovieClip;
	import alegorium.JSSpiderANE;
	import flash.events.Event;
	import flash.events.UncaughtErrorEvent;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import flash.events.StatusEvent;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class Demo extends MovieClip {

		public function Demo() {
			// Чтобы не портить данные телеметрии, лучше запустить со второго фрейма
			addEventListener(Event.ENTER_FRAME, demo);
			loaderInfo.uncaughtErrorEvents.addEventListener (
				UncaughtErrorEvent.UNCAUGHT_ERROR, function(event:UncaughtErrorEvent)
				{
					textField.appendText("\n"+event);
					event.preventDefault();
					event.stopImmediatePropagation();
					event.stopPropagation();
				}
			);
			createTextField();
		}

		private static var textField;

		public static function trace(x:*)
		{
			textField.appendText("\n"+x);
		}

		public final function onException(e:StatusEvent):void
		{
			trace("Exception internally from JS...");
			trace(e.code);
		}

		private final function createTextField():void
		{
			textField = new TextField();
			textField.x = 3;
			textField.y = 5;
			textField.border = true;
			textField.width = 540;
			textField.height = 387;
			textField.wordWrap = true;

			var myFormat:TextFormat = new TextFormat();
			myFormat.size = 18;
			myFormat.align = TextFormatAlign.LEFT;

			textField.defaultTextFormat = myFormat;
			textField.text = ">";
			addChild(textField);
		}

		public final function demo(a) {
			removeEventListener(Event.ENTER_FRAME, demo);
			trace("Hello!");
			trace(JSSpiderANE);
			trace("isSupported: " + JSSpiderANE.isSupported);

			// Setting JS-side exception listener:
			JSSpiderANE.setExceptionListener(onException);
			trace("exception listener defined");

			// Testing exception listener:

			try {
				JSSpiderANE.evaluateScript("var exports = {\n\nblah-blah\n");
			}catch(e) {
				trace(e);
			}

			try {
				JSSpiderANE.evaluateScript("\nvar x = z.helloe;\n");
			}catch(e) {
				trace(e);
			}

			trace("Suddenly, async exceptions printed below of the log");

			trace("ok...");

			evalTest("''+(23+1)");
			evalTest("'{}:'+{}");
			evalTest("'window: '+window");
			evalTest("''+(window = {})");
			evalTest("'window: '+window");
			evalTest("''+(x = 7)");
			evalTest("'x: '+x");
			evalTest("var x = 7;");
			evalTest("'x: '+x");
			evalTest("[1,2,3]");
			evalTest("{a:1,b:true,c:null,e:'hi',d:8.05,f:{a:0}}"); // ERROR!
			evalTest("({a:1,b:true,c:null,e:'hi',d:8.05,f:{a:0}})"); // USE ( obj )
			evalTest("function demo(x){return x * 7;}");
			evalTest("demo(7)");
			evalTest("({hello:\"world-привет!яы•…ђіƒm‘'ѕѓ†ўџўz\"})");

			trace("ok...");

			// Проверим разные типы данных и кодировки:
			trace(evalCheck(true) == true);
			trace(evalCheck(777) == 777);
			trace(evalCheck(null) == null);
			trace(evalCheck("true") == "true");
			trace(evalCheck(0.5) == 0.5);
			trace(evalCheck([1,2,3]).length == 3);
			trace(evalCheck("привет") == "привет");
			trace(evalCheck("ПРЫВЕТЯ") == "ПРЫВЕТЯ");
			trace(evalCheck("ѕѓ†ўџўz") == "ѕѓ†ўџўz");
			trace(evalCheck("متن درج کریں") == "متن درج کریں");

			trace("ok...");

			// Проверка на корректность бенчмарка
			var data:String = longText;
			if(evalCheck(data).length != data.length) trace("FAIL!");

			var j:Object = complexJSON;
			if(evalCheck(j).glossary.GlossDiv.title != j.glossary.GlossDiv.title)
				trace("FAIL!");

			trace("Benchmarking...");
			var start_time:int;
			var all_time:int = getTimer();
			start_time = getTimer();

			// Замер количества вызовов:
			for(var i:int = 0; i < 1000; i++) evalCheck(null);

			trace("benchCalls execution time: "+
			 Math.round(1000*1000/(getTimer()-start_time)) + " op/sec");
			start_time = getTimer();

			// Замер скорости передачи голого траффика:
			for(var k:int = 0; k < 1000; k++) evalCheck(data);

			trace("benchTraffic execution time: "+
			 Math.round(1000*1000/(getTimer()-start_time)) + " op/sec");
			start_time = getTimer();

			for(var l:int = 0; l < 1000; l++) evalCheck(j);

			// Замер скорости передачи сложных объектов:
			trace("benchJson execution time: "+
			 Math.round(1000*1000/(getTimer()-start_time)) + " op/sec");
			start_time = getTimer();

			trace("Benchmarks all done in "+ (getTimer()-all_time) + " ms");

			trace("Simulation of real case usage...");

			var J:Object = {name: 'cellClick', time: 1234567, params:
			{cellX: 12, xellY: 34, tool: 'sellTool'}};

			try {
				JSSpiderANE.evaluateScript(""
				+"\n	function brc(x){"
				+"\n		var y = [x];"
				+"\n		y.length = 30;"
				+"\n		for(var i = 0; i < 30; i++) {"
				+"\n			y[i] = x;"
				+"\n		}"
				+"\n		return y;"
				+"\n	}");

				var r = JSSpiderANE.evaluateScript("brc(" + JSON.stringify(J) + ")");
				if(r[7].params.tool != 'sellTool') trace("FAIL!");
				//trace(JSON.stringify(r));
			} catch(e) {
				trace(e);
			}

			start_time = getTimer();

			for(var m:int = 0; m < 1000; m++)
			r = JSSpiderANE.evaluateScript("brc(" + JSON.stringify(J) + ")");

			trace("benchRealCase execution time: "+
			 Math.round(1000*1000/(getTimer()-start_time)) + " op/sec");

			var jsonstr:String = "brc(" + JSON.stringify(J) + ")";

			start_time = getTimer();
			for(var n:int = 0; n < 1000; n++)
			r = JSSpiderANE.evaluateScript(jsonstr);

			trace("benchRealCase w/precomputed JSON execution time: "+
			 Math.round(1000*1000/(getTimer()-start_time)) + " op/sec");

			trace("Testing Environment Object:");

			var envDemoObj:Object = {
				doString: function(params:Object):String { return "hello!"; },
				doInt: function(params:Object):int { return params.hello + 42; },
				doArray: function(params:Object):Array { return [params]; },
				doObject: function(params:Object):Object { return {params:params}; },
				doThrow: function(params:Object):Object { throw "as3 error"; }
			};

			JSSpiderANE.setScriptEnvironment(envDemoObj);

				trace("doString: " + JSON.stringify(JSSpiderANE.evaluateScript(
					  "callAIR('doString', {hello:77})")));

				trace("doInt: " + JSON.stringify(JSSpiderANE.evaluateScript(
					  "callAIR('doInt', {hello:77})")));

				trace("doArray: " + JSON.stringify(JSSpiderANE.evaluateScript(
					  "callAIR('doArray', {hello:77})")));

				trace("doObject: " + JSON.stringify(JSSpiderANE.evaluateScript(
					  "callAIR('doObject', {hello:77})")));

			try {
				trace("doError");
				JSON.stringify(JSSpiderANE.evaluateScript(
					  "callAIR('doError', {hello:77})"));
			} catch(e) {
				trace(e);
			}

			try {
				trace("doThrow");
				JSON.stringify(JSSpiderANE.evaluateScript(
					  "callAIR('doThrow', {hello:77})"));
			} catch(e) {
				trace(e);
			}

			trace("Benchmarking Environment Object:");

			start_time = getTimer();

			for(var u:int = 0; u < 1000; u++)
			JSSpiderANE.evaluateScript("callAIR('doInt',{hello:77})");

			trace("benchEnvObj execution time: "+
			 Math.round(1000*1000/(getTimer()-start_time)) + " op/sec");

			trace("DONE!\n|");
		}

		private final function evalCheck(src:*):*
		{
			return JSSpiderANE.evaluateScript("("+JSON.stringify(src)+")");
		}

		private final function evalTest(src:String):void
		{
			try {
				trace(JSON.stringify(JSSpiderANE.evaluateScript(src)));
			} catch(e) {
				trace(e); // _JAVASCRIPT_ ERRORS!
			}
		}

		private var longText:String = ''
		+'Мороз и солнце; день чудесный!'
		+'\nЕще ты дремлешь, друг прелестный —'
		+'\nПора, красавица, проснись:'
		+'\n4 Открой сомкнуты негой взоры'
		+'\nНавстречу северной Авроры,'
		+'\nЗвездою севера явись!'
		+'\n'
		+'\nВечор, ты помнишь, вьюга злилась,'
		+'\n8 На мутном небе мгла носилась;'
		+'\nЛуна, как бледное пятно,'
		+'\nСквозь тучи мрачные желтела,'
		+'\nИ ты печальная сидела —'
		+'\n12 А нынче... погляди в окно:'
		+'\n'
		+'\nПод голубыми небесами'
		+'\nВеликолепными коврами,'
		+'\nБлестя на солнце, снег лежит;'
		+'\n16 Прозрачный лес один чернеет,'
		+'\nИ ель сквозь иней зеленеет,'
		+'\nИ речка подо льдом блестит.'
		+'\n'
		+'\nВся комната янтарным блеском'
		+'\n20 Озарена. Веселым треском'
		+'\nТрещит затопленная печь.'
		+'\nПриятно думать у лежанки.'
		+'\nНо знаешь: не велеть ли в санки'
		+'\n24 Кобылку бурую запречь?'
		+'\n'
		+'\nСкользя по утреннему снегу,'
		+'\nДруг милый, предадимся бегу'
		+'\nНетерпеливого коня'
		+'\n28 И навестим поля пустые,'
		+'\nЛеса, недавно столь густые,'
		+'\nИ берег, милый для меня.';

		private var complexJSON:Object =
		{
			"glossary": {
				"title": "example glossary",
				"GlossDiv": {
					"title": "S",
					"GlossList": {
						"GlossEntry": {
							"ID": "SGML",
							"SortAs": "SGML",
							"GlossTerm": "Standard Generalized Markup Language",
							"Acronym": "SGML",
							"Abbrev": "ISO 8879:1986",
							"GlossDef": {
								"para": "A meta-markup language, used to create"
								+" markup languages such as DocBook.",
								"GlossSeeAlso": ["GML", "XML"]
							},
							"GlossSee": "markup"
						}
					}
				}
			}
		}
	}
}