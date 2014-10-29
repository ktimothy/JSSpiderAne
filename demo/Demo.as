package  {

	import flash.display.MovieClip;
	import alegorium.JSSpiderANE;
	import alegorium.JSONHelper;
	import flash.events.Event;
	import flash.events.UncaughtErrorEvent;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import flash.events.StatusEvent;

	public class Demo extends MovieClip {

		public function Demo() {
			// Чтобы не портить данные телеметрии, лучше запустить со второго фрейма
			addEventListener(Event.ENTER_FRAME, demo);
			loaderInfo.uncaughtErrorEvents.addEventListener (
                UncaughtErrorEvent.UNCAUGHT_ERROR, function(event:UncaughtErrorEvent)
                {
					text.appendText("\n"+event);
					event.preventDefault();
					event.stopImmediatePropagation();
					event.stopPropagation();
                }
			);
		}

		public function trace(x:*)
		{
			text.appendText("\n"+x);
		}

		public function onException(e:StatusEvent):void
		{
			trace("Exception internally from JS...");
			trace(e.code);
		}

		public function demo(a) {
			removeEventListener(Event.ENTER_FRAME, demo);
			trace("Hello!");
			trace(JSSpiderANE);
			trace("isSupported: " + JSSpiderANE.isSupported);
			// Testing internal safe JSON generator:
			trace(JSONHelper.convert(complexJSON));
			trace(JSONHelper.convert(
			      "abc123!@#$%^&*()_+\\|/'\";][{}/?.,:**//\t\b\f\rЫЮЯыюя[ё"));

			// Functions is unallowed:
			try {
				trace(JSONHelper.convert({
					obj: {
						func: function(){}
					}
				}));
			} catch(e:String) {
				trace("Demo: " + e);
			}

			// Setting JS-side exception listener:
			JSSpiderANE.setExceptionListener(onException);

			// Testing exception listener:
			trace("Suddenly, exceptions printed below of the log");
			JSSpiderANE.setScript("var exports = {\n\nblah-blah\n");
			JSSpiderANE.setScript("\nvar x = z.helloe;\n");

			var envDemo:String = "function Environment(){}";
			var envDemoObj:Object = {
				demo: function(params:String):String {
					// parse input:
					trace("params: "+params);
					var input:Object = JSON.parse(params);
					var output:Object = { hello: input.world };
					return JSONHelper.convert(output);
				}
			};

			JSSpiderANE.setEnvironment(envDemo, envDemoObj);
			var script:String =
				'var exports = {};'
				+'(function ($hx_exports) { "use strict";'
				+'var Context = $hx_exports.Context = function() {'
				+'};'

				+'Context.main = function() {'
				+'    Context.instance = new Context();'
				+'};'

				+'Context.prototype = {'
				+'    command: function(param) {'
				+'        return "command";'
				+'    }'
				+'    ,query: function(param) {'
				+'        return "query";'
				+'    }'

				+'    ,demo: function(param) {'
				+'         param.world = "Unicode: т!яы•…ђ";'
				+'         return param;'
				+'    }'
				+'    ,bench: function(param) {'
				+'        return param;'
				+'    }'

				+'};'
				+'Context.main();'
				+'})(typeof window != "undefined" ? window : exports);';

			trace("pre...setScript before");
			JSSpiderANE.setScript(script);
			trace("pre...setScript after");

			trace(JSSpiderANE.ext.call("call", "'exports: '+exports"));
			trace(JSSpiderANE.ext.call("call", "'exports.Context: '+exports.Context"));
			trace(JSSpiderANE.ext.call("call", "'window: '+window"));
			trace(JSSpiderANE.ext.call("call", "'window.Context: '+window.Context"));
			trace(JSSpiderANE.ext.call("call", "'window.Context.instance: '+window.Context.instance"));
			trace(JSSpiderANE.ext.call("call", "'window.Context.instance.demo: '+window.Context.instance.demo"));

			trace("ok...");

			trace(JSSpiderANE.ext.call("call", "''+(23+1)"));

			trace(JSSpiderANE.ext.call("call", "'{}:'+{}"));
			trace(JSSpiderANE.ext.call("call", "'window: '+window"));
			trace(JSSpiderANE.ext.call("call", "''+(window = {})"));
			trace(JSSpiderANE.ext.call("call", "'window: '+window"));
			trace(JSSpiderANE.ext.call("call", "''+(x = 7)"));
			trace(JSSpiderANE.ext.call("call", "'x: '+x"));

			trace(JSSpiderANE.ext.call("call", "var x = 7;"));
			trace(JSSpiderANE.ext.call("call", "'x: '+x"));

			// Вызовем метод:
			var met:String = "demo"; // Имя метода
			var args:Object = {hello:"world-привет!яы•…ђіƒm‘'ѕѓ†ўџўz"}; // Параметры
			var res:Object = JSSpiderANE.callScriptMethod(met, args); // Вызов и результат

			trace("ok...1");
			// Результат уже обработан, и является объектом:
			trace(res);
			trace(JSON.stringify(res));
			trace(res.hello);
			trace(res.world);
			trace("ok...2");

			// Проверим разные типы данных и кодировки:
			var bench:String = "bench"; // Имя метода
			trace(JSSpiderANE.callScriptMethod(bench, true) == true);
			trace(JSSpiderANE.callScriptMethod(bench, 777) == 777);
			trace(JSSpiderANE.callScriptMethod(bench, null) == null);
			trace(JSSpiderANE.callScriptMethod(bench, "true") == "true");
			trace(JSSpiderANE.callScriptMethod(bench, 0.5) == 0.5);
			trace(JSSpiderANE.callScriptMethod(bench, [1,2,3]).length == 3);
			trace(JSSpiderANE.callScriptMethod(bench, "привет") == "привет");
			trace(JSSpiderANE.callScriptMethod(bench, "ПРЫВЕТЯ") == "ПРЫВЕТЯ");
			trace(JSSpiderANE.callScriptMethod(bench, "ѕѓ†ўџўz") == "ѕѓ†ўџўz");
			trace(JSSpiderANE.callScriptMethod(bench, "متن درج کریں") == "متن درج کریں");

			// Проверка на корректность бенчмарка
			var data:String = longText;
			if(JSSpiderANE.callScriptMethod(bench, data).length != data.length) trace("FAIL!");

			var j:Object = complexJSON;
			if(JSSpiderANE.callScriptMethod(bench, j).glossary.GlossDiv.title != j.glossary.GlossDiv.title) trace("FAIL!");

			trace("ok...3");

			trace("Benchmarking...");
			var start_time:int;
			var all_time:int = getTimer();
			start_time = getTimer();

			// Замер количества вызовов:
			for(var i:int = 0; i < 1000; i++) JSSpiderANE.callScriptMethod(bench, null);

			trace("benchCalls execution time: "+ Math.round(1000*1000/(getTimer()-start_time)) + " op/sec");
			start_time = getTimer();

			// Замер скорости передачи голого траффика:
			for(var k:int = 0; k < 1000; k++) JSSpiderANE.callScriptMethod(bench, data);

			trace("benchTraffic execution time: "+ Math.round(1000*1000/(getTimer()-start_time)) + " op/sec");
			start_time = getTimer();

			for(var l:int = 0; l < 1000; l++) JSSpiderANE.callScriptMethod(bench, j);

			// Замер скорости передачи сложных объектов:
			trace("benchJson execution time: "+ Math.round(1000*1000/(getTimer()-start_time)) + " op/sec");
			start_time = getTimer();

			trace("Benchmarks all done in "+ (getTimer()-all_time) + " ms");

			trace("DONE!");
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
								"para": "A meta-markup language, used to create markup languages such as DocBook.",
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