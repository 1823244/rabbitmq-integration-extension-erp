﻿
// Описание_метода
//
// Параметры:
//	Параметр1 	- Тип1 - 
//
Процедура ВыполнитьКод(ИдВызова,Код) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	логгер = мис_ЛоггерСервер.getLogger(ИдВызова, "ВыполнитьКод");
	
	Выполнить(Код);
	
	логгер.инфо("Выполнен код: " + Код);
	
	УстановитьПривилегированныйРежим(Ложь);
	
КонецПроцедуры
