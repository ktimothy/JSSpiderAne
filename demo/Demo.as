package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class Demo extends MovieClip {
		
		public function Demo() {
			// Чтобы не портить данные телеметрии, лучше запустить со второго фрейма
			addEventListener(Event.ENTER_FRAME, demo);
		}	
		
		public function demo(a) {
			trace("Hello!");

			benchCalls();
			benchTraffic();
			benchJson();

			stage.frameRate = 1;
		}

		private function benchCalls(){
			// Замер количества вызовов:
		}

		private function benchTraffic(){
			// Замер скорости передачи голого траффика:
		}

		private function benchJson(){
			// Замер скорости передачи сложных обьектов:
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