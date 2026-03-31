#!/bin/bash
echo "Content-type: text/html"
echo ""

PID="$(pgrep openconnect)";

cat <<EOF
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>VPN Control Panel</title></head>
<body style="font-family: sans-serif; padding: 20px;">
    <h2>Статус VPN: $([ -n "$PID" ] && echo "<b style='color:green'>ПОДКЛЮЧЕНО К "$VPN_ADDR" (PID: $PID)</b>" || echo "<b style='color:red'>ОТКЛЮЧЕНО</b>")</h2>
    <form action="/cgi-bin/connect.sh" method="POST">
        Адрес: <input type="text" value="$VPN_ADDR"  name="VPN_ADDR" required><br><br>
        Логин: <input type="text" value="$VPN_USER" name="VPN_USER" required><br><br>
        Пароль: <input type="password" value="$VPN_PASS" name="VPN_PASS" required><br><br>
        <button type="submit">$([ -n "$PID" ] && echo "Переподключиться" || echo "Подключиться")</button>
        <button onclick="location.href='/cgi-bin/index.sh'" type='button'>Обновить статус</button>
    </form>
    <br>

    <h3>Логи процесса</h2>
    <pre>$(cat "$VPN_LOG_FILE" 2>/dev/null)</pre>
</body>
</html>
EOF