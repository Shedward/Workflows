
# Workflow integration test DSL
# Source after request.sh

INSTANCE_ID=""
LAST_RESPONSE=""

start_workflow() {
  local workflow_id="${1:?workflow_id required}"
  LAST_RESPONSE="$(request POST "/workflowInstances" \
    "{\"workflowId\":\"$workflow_id\"}")"
  INSTANCE_ID="$(jq -r '.id' <<<"$LAST_RESPONSE")"

  if [[ -z "$INSTANCE_ID" || "$INSTANCE_ID" == "null" ]]; then
    echo "Failed to start workflow '$workflow_id'" >&2
    exit 1
  fi
}

take_transition() {
  local transition="${1:?transition required}"
  local instance="${2:-$INSTANCE_ID}"
  LAST_RESPONSE="$(request POST "/workflowInstances/$instance/takeTransition" \
    "{\"transitionProcessId\":\"$transition\"}")"
}

assert_state() {
  local expected="${1:?expected state required}"
  local instance="${2:-$INSTANCE_ID}"
  local response state
  response="$(request GET "/workflowInstances/$instance")"
  state="$(jq -r '.state' <<<"$response")"

  if [[ "$state" != "$expected" ]]; then
    echo "Expected state '$expected', got '$state'" >&2
    exit 1
  fi
}

assert_exists() {
  local instance="${1:-$INSTANCE_ID}"
  if ! request GET "/workflowInstances" \
    | jq -e --arg id "$instance" 'any(.[]; .id == $id)' >/dev/null
  then
    echo "Instance $instance not found" >&2
    exit 1
  fi
}

assert_finished() {
  local instance="${1:-$INSTANCE_ID}"
  if request GET "/workflowInstances" \
    | jq -e --arg id "$instance" 'any(.[]; .id == $id)' >/dev/null
  then
    echo "Instance $instance still exists (expected finished)" >&2
    exit 1
  fi
}

response_field() {
  local field="${1:?jq field required}"
  jq -r "$field" <<<"$LAST_RESPONSE"
}
