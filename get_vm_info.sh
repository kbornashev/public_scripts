EXCLUDE='-nip|build|e2e|runner|c019|c005|c004|c016|c012|ru103'
rg --pcre2 --multiline --no-filename --no-line-number \
"^\s*(?:\d+\s+)?VM\s+(?P<id>\d+):\s*(?P<name>(?!.*(?:$EXCLUDE))[^\r\n]+)\s+(?:(?!^\s*(?:\d+\s+)?VM\s+\d+:).)*?(?P<ip>10\.10\.(?:25[0-5]|2[0-4]\d|1?\d?\d)\.(?:25[0-5]|2[0-4]\d|1?\d?\d))(?:\s*\(null\))?" \
--replace '$name $ip' ./*
