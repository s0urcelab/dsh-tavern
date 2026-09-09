#!/bin/sh

set -eu

export DSH_HOME="${DSH_HOME:-/home/node/.dsh}"
export DSH_TAVERN_RUNTIME_HOST=docker

BIND_HOST=127.0.0.1
PORT=${DSH_TAVERN_PORT:-3081}

node -e '
const port = Number(process.argv[1])
if (!Number.isSafeInteger(port) || port < 1 || port > 65535) {
  console.error(`DSH_TAVERN_PORT 必须是 1 到 65535 之间的整数，当前值：${process.argv[1]}`)
  process.exit(1)
}
' "${PORT}"

echo "正在初始化 DSH Tavern Docker Profile……"
node /app/bin/dsh-tavern.mjs install --host docker

echo "DSH Tavern 正在监听 ${BIND_HOST}:${PORT}"
exec dsh --profile tavern --host "${BIND_HOST}" --port "${PORT}" --no-open
