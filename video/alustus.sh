# Ladataan vhs-istunnon alussa (piilossa videolta)
export PATH=/usr/local/mysql/bin:$PATH
export MYSQL_UNIX_PORT="$DEMO_SOCK"
export MYSQL_TEST_LOGIN_FILE=/dev/null
export BAT_THEME="Catppuccin Mocha"
export PS1='\[\e[1;35m\]pokestock\[\e[0m\] \[\e[1;34m\]$\[\e[0m\] '
banner() {
  local t="$1" w=$(( ${#1} + 6 ))
  local viiva=$(printf '═%.0s' $(seq $w))
  printf '\n\e[1;33m  ╔%s╗\n  ║   %s   ║\n  ╚%s╝\e[0m\n\n' "$viiva" "$t" "$viiva"
}
