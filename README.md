Beeline-reports
=================

CLI и веб-интерфейс для просмотра отчётов, которые присылает Билайн по расходам по мобильной связи.
Отчёты можно заказать через https://my.beeline.ru или мобильное приложение Билайна.

Это программа разрабатывается на версии Ruby 2.2. Её работа с другими версиями Ruby не проверялась.
Впрочем, её работоспособность вообще не гарантирована. Используйте на свой страх и риск.
В случае возникновения сомнений смотрите исходный код.

Эта программа ничего не знает о Вашем номере телефона, количестве денег на счету и пароле для https://my.beeline.ru.
Она знает только то, что получила из файлов, которые Вы ей даёте.

Подготовка к использованию
----------------------------

```
git clone <адрес репозитория>
cd beeline-reports
bundle
rake db:setup RAILS_ENV=production
unicorn_rails -p 5001 -E production -D # позже: foreman, faye или websocket-rails
```

Использование CLI
-------------------

```
rails c production
```

```ruby
f = UserFile.upload("<filename>")
f.import
sleep(0.3) until f.imported?
s = Subscriber.find_by_phone("<phone 9XXxxxxxxx>")
all_records = Call.by_subscriber(s)
```

Методы см. в Call.method_missing
```
2.2.0 :006 > all_records.sum_cost_by_service.t
+-------------------+--------------------------------+
| sum(cost) as cost | service                        |
+-------------------+--------------------------------+
|               0.0 | Premium Rate MO SMS            |
|               0.0 | исх/доп.сервис                 |
|               0.0 | VKONTAKTE                      |
|               0.0 | internet.beeline.ru            |
|               0.0 | Исходящее SMS на номер др.сети |
|               0.0 | HEADER_ENRICH                  |
|               0.0 | PRODUCT_SUPPORT                |
|               0.0 | Входящий с гор.номера          |
|               0.0 | REG_ZERO_ZONE                  |
|               0.0 | BEE_INFO                       |
|               0.0 | Исходящее SMS на Билайн        |
|               0.0 | Входящий c моб.номера          |
|               0.0 | WIKIPEDIA                      |
|               2.0 | Исходящий на номер др.сети     |
|               5.0 | Исходящий на Скай Линк         |
|               7.0 | Исходящий на гор. номер Билайн |
|              26.0 | Исходящий на Мегафон           |
|              57.0 | Исходящий на Билайн            |
|              60.0 | Исходящий на гор.номер         |
|             119.0 | Исходящий на МТС               |
+-------------------+--------------------------------+
2.2.0 :007 > Call.sum_cost_by_receiver.by_operator_name('МТС').t # МТС, Билайн, Мегафон, гор, Скай Линк, др.сети
+-------------------+----------+
| sum(cost) as cost | receiver |
+-------------------+----------+
|               2.0 | hidden   |
|               2.0 | hidden   |
|               4.0 | hidden   |
|               4.0 | hidden   |
|               6.0 | hidden   |
|               7.0 | hidden   |
|               8.0 | hidden   |
|              10.0 | hidden   |
|              76.0 | hidden   |
+-------------------+----------+
# Номера скрыты в этом примере
```

Использование веб-интерфейса
------------------------------

В веб-интерфейсе файл добавляется в очередь обработки, показывается статус "Файл загружен для обработки".
Очередь проверяется асинхронно. Каждый элемент очереди извлекается и обрабатывается, затем в очередь
результатов добавляется статус с результатом обработки (успешно или ошибка). В это же время браузер опрашивает очередь
результатов, чтобы извлечь элемент, связанный с загруженным файлом, и показать статус.
