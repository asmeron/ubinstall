# Инсталляция

1. Запуск инсталлятора.
2. Выводится окно приветствия с лицензионным соглашением.
3. Вывод меню выбора установки редакций операционных систем.

Меню формируется из результатов обработки скрипта, который обходит папки с редакциями ОС и проверятет в них наличие файлов os-release.
Структура os-release файла в каталоге (один файл на каталог с редакцией системы):
```
NAME="UBLinux"
ID=ublinux
VARIANT="Server"
VERSION="AR.03"
VERSION_ID="ar.03"
VERSION_CODENAME=andromeda
ID_LIKE=arch
PRETTY_NAME="UBLinux Server AR.01 (Andromeda)"
BUILD_ID="02.10.2019"
ANSI_COLOR="1;34"
HOME_URL="http://ublinux.com/"
```
```
NAME="UBLinux"
ID=ublinux
VARIANT="Desktop Enterprise"
VERSION="AL.02"
VERSION_ID="al.02"
VERSION_CODENAME=antlia
ID_LIKE=alpine
PRETTY_NAME="UBLinux Desktop Enterprise AL.02 (Antlia)"
BUILD_ID="02.11.2019"
ANSI_COLOR="1;34"
HOME_URL="http://ublinux.com/"
```
```
NAME="UBLinux"
ID=ublinux
VARIANT="Desktop Basic"
VERSION="DE.03"
VERSION_ID="de.03"
VERSION_CODENAME=apus
ID_LIKE=debian
PRETTY_NAME="UBLinux Desktop Basic DE.03 (Apus)"
BUILD_ID="02.12.2019"
ANSI_COLOR="1;34"
HOME_URL="http://ublinux.com/"
```
```
NAME="UBLinux Adara"
ID=ublinux
VARIANT="Server"
VERSION="AR.01"
VERSION_ID="ar.01"
VERSION_CODENAME=andromeda
ID_LIKE=arch
PRETTY_NAME="UBLinux Adara Server AR.01 (Andromeda)"
BUILD_ID="02.10.2019"
ANSI_COLOR="1;31"
HOME_URL="http://ublinux.com/"

```
```
NAME="UBLinux Adara"
ID=ublinux
VARIANT="Desktop Enterprise"
VERSION="AL.04"
VERSION_ID="al.04"
VERSION_CODENAME=aquila
ID_LIKE=alpine
PRETTY_NAME="UBLinux Desktop Enterprise AL.04 (Aquila)"
BUILD_ID="04.10.2019"
ANSI_COLOR="1;31"
HOME_URL="http://ublinux.com/"
```
Структура каталогов на носителе (локальный или сетевой):  
В корне накопителя или примонтированного каталога (в случае сетевой установки) содержится каталог или каталоги, доступных для установки, редакций дистрибутивов. Папки имеют названия по имени, версии ОС. Например, UBLinux Adara Server AR.01.

 

Данные, передающиеся с клиентской машины на сервер:
1.Идентификатор лицензии (ключ сгенерирован случайным образом для каждого экземпляра лицензии).

Данные лицензии содержат в себе:
Тип лицензии (Server, Enterprise, Basic или их комбинации), на это отводится два символа. Например, 01-Server, 02-Enterpise, 03-Basic, 04-Server&Enterprise, 11-Adara_Server, 12-Adara_Enterpise, 14-Adara_Server&Adara_Enterprise;
Дата окончания лицензии, на это отводится 8 символов. Например, 23012020;
Версия системы, на это отводится 4 символа (первые два символа - основная версия, последние два - минорная версия). Например, 0122;
Блоки разделяются двоеточием.

Структура файла с зашифрованными данными лицензии на клиенте:
8F0763A7-9630A7CC-7001177E-E199430C

Обработка на сервере:
1. Принять данные о лицензии (ключ);
2. Найти по идентификатору соответствующую запись в json файл-схеме

Структура JSON-файла на сервере:
```
{
"8F0763A7-9630A7CC-7001177E-E199430C":
{
"org": "John Doe",
"date": "01.01.2020",
"type": "03,02",
},
"6A1478C2-0367F3DD-5001673D-A400279F":
{
"org": "Vasya Pupkin",
"date": "01.01.2025",
"type": "02",
}
"8F0553A7-9630A7CC-7001177E-E192230C":
{
"org": "Tobias Boon",
"date": "01.01.2022",
"type": "11,12",
},
"6A6АF78C2-0367F3DD-5008873D-A40C279F":
{
"org": "To Yama To Kanawa",
"date": "01.01.2030",
"type": "12",
}
}
```
Где
* "XXXXXXXX-XXXXXXXX-XXXXXXXX-XXXXXXXX" - ключ лицензии, сгенерированный случайным образом;
* "org" - название организации, владельца лицензии;
* "date" - Дата окончания срока действия лицензии (дата окончания срока поддержки);
* "type" - код типа лицензии (Server, Enterprise, Basic или их комбинации).
  * 01 - UBLinux Desktop Basic
  * 02 - UBLinux Desktop Enterpise
  * 03 - UBLinux Server  
  
  * 11 - UBLinux Adara Desktop Enterpise
  * 12 - UBLinux Adara Server


3. Извлечь данные: дата окончания лицензии, тип лицензии;
4. Если дата окончания лицензии пройдена, формируем ответ клиенту, в котором содержится отказ;
5. Если дата окончания не пройдена, проверяем, какие типы лицензий доступны;
6. Формируем ответ клиенту, в котором содержатся данные для доступа к репозиторию.

