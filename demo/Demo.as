package  {

	import flash.display.MovieClip;
	import alegorium.JSSpiderANE;
	import flash.events.Event;

	public class Demo extends MovieClip {

		public function Demo() {
			// Чтобы не портить данные телеметрии, лучше запустить со второго фрейма
			addEventListener(Event.ENTER_FRAME, demo);
		}

		public function demo(a) {
			trace("Hello!");
			trace(JSSpiderANE);
			trace("isSupported: " + JSSpiderANE.isSupported);

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

			JSSpiderANE.setScript(script);

			// Вызовем метод:
			var met:String = "demo"; // Имя метода
			var args:Object = {hello:"world-привет!яы•…ђіƒm‘'ѕѓ†ўџўz"}; // Параметры
			var res:Object = JSSpiderANE.callScriptMethod(met, args); // Вызов и результат

			// Результат уже обработан, и является объектом:
			trace(res);
			trace(JSON.stringify(res));
			trace(res.hello);
			trace(res.world);

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

			benchCalls();
			benchTraffic();
			benchJson();

			stage.frameRate = 1;
		}

		private function benchCalls(){
			// Замер количества вызовов:
			var bench:String = "bench"; // Имя метода
			for(var i:int = 0; i < 1000; i++) JSSpiderANE.callScriptMethod(bench, null);
		}

		private function benchTraffic(){
			// Замер скорости передачи голого траффика:
			var bench:String = "bench"; // Имя метода
			var data:String = longText;
			trace(JSSpiderANE.callScriptMethod(bench, data).length == data.length); // Проверка на корректность
			for(var k:int = 0; k < 1000; k++) JSSpiderANE.callScriptMethod(bench, data);
		}

		private function benchJson(){
			// Замер скорости передачи сложных обьектов:
			var bench:String = "bench"; // Имя метода
			var j:Object = complexJSON;
			// Проверка на корректность
			trace(JSSpiderANE.callScriptMethod(bench, j).glossary.GlossDiv.title == j.glossary.GlossDiv.title);
			for(var l:int = 0; l < 1000; l++) JSSpiderANE.callScriptMethod(bench, j);
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