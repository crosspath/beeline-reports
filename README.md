== Beeline-reports

CLI и веб-интерфейс для просмотра отчётов, которые присылает Билайн по расходам по мобильной связи.
Отчёты можно заказать через https://my.beeline.ru или мобильное приложение Билайна.

Это программа разрабатывается на версии Ruby 2.2. Её работа с другими версиями Ruby не проверялась.
Впрочем, её работоспособность вообще не гарантирована. Используйте на свой страх и риск.
В случае возникновения сомнений смотрите исходный код.

Эта программа ничего не знает о Вашем номере телефона, количестве денег на счету и пароле для https://my.beeline.ru.
Она знает только то, что получила из файлов, которые Вы ей даёте.

=== Подготовка к использованию

<code>
git clone <адрес репозитория>
cd beeline-reports
bundle
rake db:setup RAILS_ENV=production
unicorn_rails -p 5001 -E production -D # позже: foreman, faye или websocket-rails
</code>

=== Использование CLI

<code>
rails c production
</code>

<code ruby>
UserFile.upload("<filename>").import
s = Subscriber.find_by_phone("<phone 9XXxxxxxxx>")
all_records = Call.by_subscriber(s)
services = all_records.group_by(:service).select('sum(cost) as cost, service')
</code>

=== Использование веб-интерфейса


В веб-интерфейсе файл добавляется в очередь обработки, показывается статус "Файл загружен для обработки".
Очередь проверяется асинхронно. Каждый элемент очереди извлекается и обрабатывается (parse), затем в очередь
результатов добавляется статус с результатом обработки (успешно или ошибка). В это же время браузер опрашивает очередь
результатов, чтобы извлечь элемент, связанный с загруженным файлом, и показать статус.
