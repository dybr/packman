
Перем мБазовыйКаталог;

Функция ИмяЛогаСистемы() Экспорт
	Возврат "vanessa.app.packman";
КонецФункции

Процедура ПриРегистрацииКомандПриложения(Знач КлассыРеализацииКоманд) Экспорт
    
    КлассыРеализацииКоманд["help"]           = "КомандаСправкаПоПараметрам";
    КлассыРеализацииКоманд["version"]        = "КомандаВерсия";
    КлассыРеализацииКоманд["load-storage"]   = "КомандаВыгрузитьИзХранилища";
    КлассыРеализацииКоманд["set-database"]   = "КомандаПодключитьИнформационнуюБазу";
    КлассыРеализацииКоманд["drop-support"]   = "КомандаСнятьСПоддержки";
    КлассыРеализацииКоманд["load-src"]       = "КомандаСобратьИзИсходныхФайлов";
    КлассыРеализацииКоманд["make-cf"]        = "КомандаСоздатьФайлыПоставки";
    КлассыРеализацииКоманд["make-dist"]      = "КомандаСоздатьДистрибутив";
    КлассыРеализацииКоманд["zip-dist"]       = "КомандаАрхивироватьДистрибутив";
    КлассыРеализацииКоманд["clear"]          = "КомандаОчиститьКаталог";
    КлассыРеализацииКоманд["check"]          = "КомандаПроверитьСинтаксис";
    //...
    //КлассыРеализацииКоманд["<имя команды>"] = "<КлассРеализации>";

КонецПроцедуры

// Одна из команд может вызываться неявно, без указания команды.
// Иными словами, здесь указывается какой обработчик надо вызывать, если приложение запущено без какой-либо команды
//  myapp /home/user/somefile.txt будет аналогично myapp default-action /home/user/somefile.txt 
Функция ИмяКомандыПоУмолчанию() Экспорт
	// Возврат "default-action";
КонецФункции

Функция БазовыйКаталогЗапуска(Знач Каталог = Неопределено) Экспорт
    
    Если Каталог <> Неопределено Тогда
        мБазовыйКаталог = Каталог;
    КонецЕсли;
    
    Возврат ?(мБазовыйКаталог = Неопределено, СтартовыйСценарий().Каталог, мБазовыйКаталог);
    
КонецФункции // БазовыйКаталогЗапуска() Экспорт

Функция ВерсияПродукта() Экспорт

    Возврат "0.6.0";

КонецФункции // ВерсияПродукта() Экспорт