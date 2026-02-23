
readonly BASE="http://127.0.0.1:8080"

request() {
  local method="$1"
  local path="$2"
  local data="${3:-}"

  echo "$@" >&2

  local response
  local http_code

  response=$(curl -sS -X "$method" "$BASE$path" \
    ${data:+-H "Content-Type: application/json" -d "$data"} \
    -w "\n%{http_code}")

  http_code="${response##*$'\n'}"
  body="${response%$'\n'*}"

  if [[ "$http_code" -ge 400 ]]; then
    echo "$body" >&2
    return 1
  fi

  echo "$body"
}

assert_length() {
  local json="$1"
  local expected="$2"
  local message="${3:-}"
  local actual
  actual="$(jq 'length' <<<"$json")"

  if [[ "$actual" -ne "$expected" ]]; then
    echo "$message; Expected $expected, got $actual" >&2
    exit 1
  fi
}
