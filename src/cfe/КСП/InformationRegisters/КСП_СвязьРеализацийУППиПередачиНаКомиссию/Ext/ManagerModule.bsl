﻿
// Описание_метода
//
// Параметры:
//	ВнешняяСистема 	- строка - например, "upp"
//	ГУИД - строка, 36 - гуид док-а РеализацияТоваровУслуг и УПП
//	
//
Процедура ДобавитьЗапись(
		ВнешняяСистема, 
		ГУИД,
		ЗаказКлиента,
		РеализацияТоваровУслуг,
		РасходныйОрдерНаТовары, 
		ПредставлениеРТУ,
		Комментарий) Экспорт     
		
		
	
	НЗ = РегистрыСведений.КСП_СвязьРеализацийУППиПередачиНаКомиссию.СоздатьНаборЗаписей();
	НЗ.Отбор.ВнешняяСистема.Установить(ВнешняяСистема);
	НЗ.Отбор.ГУИД.Установить(ГУИД);
	
	НовСтр = НЗ.Добавить();
	НовСтр.ВнешняяСистема = ВнешняяСистема;
	НовСтр.ГУИД = ГУИД;
	НовСтр.ЗаказКлиента = ЗаказКлиента;
	НовСтр.ПередачаТоваровХранителю = РеализацияТоваровУслуг;
	НовСтр.РасходныйОрдерНаТовары = РасходныйОрдерНаТовары;
	НовСтр.ПредставлениеРТУ = ПредставлениеРТУ;
	НовСтр.Комментарий = Комментарий;
	НовСтр.ДатаИмпорта = ТекущаяДатаСеанса();
	
	НЗ.Записать();
		
КонецПроцедуры
