# Rack 3 は既定で Forwarded ヘッダを X-Forwarded-For より優先する。前段のロードバランサは
# 利用者が付けた Forwarded をそのまま通すため、優先されると request.remote_ip が利用者の申告値に
# なる。ロードバランサが追記する X-Forwarded-For だけを読む。
Rack::Request.forwarded_priority = [:x_forwarded]
