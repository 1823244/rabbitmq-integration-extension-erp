﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	НЗ = РегистрыСведений.ЗагрузкаДанныхИзФулфилмент.СоздатьНаборЗаписей();
	НЗ.Отбор.ИмяФайла.Установить(Запись.ИмяФайла);
	
	НЗ.Прочитать();
	
	
	
	Дд = НЗ[0].ДанныеФайла.Получить();
	Попытка
		ИмяФ = ПолучитьИмяВременногоФайла("xml");
		Дд.Записать(ИмяФ);
		ДанныеФайла.Прочитать(ИмяФ);//ДанныеФайла.УстановитьТекст();
		УдалитьФайлы(ИмяФ);
	Исключение
	    ЗаписьЖурналаРегистрации("РС_ЗагрузкаДанныхИзФулфилмент", 
			УровеньЖурналаРегистрации.Ошибка,,,ОписаниеОшибки());
	КонецПопытки;
	
КонецПроцедуры
