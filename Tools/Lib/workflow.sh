
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

# Like take_transition but propagates HTTP errors (for use with assert_fails)
try_take_transition() {
  local transition="${1:?transition required}"
  local instance="${2:-$INSTANCE_ID}"
  request POST "/workflowInstances/$instance/takeTransition" \
    "{\"transitionProcessId\":\"$transition\"}" >/dev/null
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

# Start a workflow with initial data (JSON object for the data field)
# Usage: start_workflow_with_data "WorkflowId" '{"key":"value"}'
start_workflow_with_data() {
  local workflow_id="${1:?workflow_id required}"
  local initial_data="${2:?initial_data required}"
  local body
  body="$(jq -n --arg wid "$workflow_id" --argjson data "$initial_data" \
    '{workflowId: $wid, initialData: {data: $data}}')"
  LAST_RESPONSE="$(request POST "/workflowInstances" "$body")"
  INSTANCE_ID="$(jq -r '.id' <<<"$LAST_RESPONSE")"

  if [[ -z "$INSTANCE_ID" || "$INSTANCE_ID" == "null" ]]; then
    echo "Failed to start workflow '$workflow_id'" >&2
    exit 1
  fi
}

# Assert that a request fails (HTTP 4xx/5xx)
# Usage: assert_fails request POST "/path" '{"json":"body"}'
#        assert_fails take_transition "BadId"
assert_fails() {
  local output
  if output=$("$@" 2>&1); then
    echo "Expected failure but succeeded: $*" >&2
    echo "$output" >&2
    exit 1
  fi
}

# Assert instance data contains a key with expected value
assert_data() {
  local key="${1:?key required}"
  local expected="${2:?expected value required}"
  local instance="${3:-$INSTANCE_ID}"
  local response actual
  response="$(request GET "/workflowInstances/$instance")"
  actual="$(jq -r --arg k "$key" '.data.data[$k]' <<<"$response")"

  if [[ "$actual" != "$expected" ]]; then
    echo "Data '$key': expected '$expected', got '$actual'" >&2
    exit 1
  fi
}

# Assert a transition is available from current state
assert_transition_available() {
  local process_id="${1:?process_id required}"
  local instance="${2:-$INSTANCE_ID}"
  if ! request GET "/workflowInstances/$instance/transitions" \
    | jq -e --arg pid "$process_id" 'any(.[]; .processId == $pid)' >/dev/null
  then
    echo "Transition '$process_id' not available" >&2
    exit 1
  fi
}

# Assert a transition is NOT available
assert_transition_unavailable() {
  local process_id="${1:?process_id required}"
  local instance="${2:-$INSTANCE_ID}"
  if request GET "/workflowInstances/$instance/transitions" \
    | jq -e --arg pid "$process_id" 'any(.[]; .processId == $pid)' >/dev/null
  then
    echo "Transition '$process_id' should not be available" >&2
    exit 1
  fi
}

# Assert the instance has a failed transition state
assert_transition_failed() {
  local instance="${1:-$INSTANCE_ID}"
  local response state_type
  response="$(request GET "/workflowInstances/$instance")"
  state_type="$(jq -r '.transitionState.state | keys[0] // empty' <<<"$response")"

  if [[ "$state_type" != "failed" ]]; then
    echo "Expected transition state 'failed', got '$state_type'" >&2
    exit 1
  fi
}

# Get the number of workflow instances
instance_count() {
  request GET "/workflowInstances" | jq 'length'
}

# Assert workflow type exists in GET /workflows
assert_workflow_registered() {
  local workflow_id="${1:?workflow_id required}"
  if ! request GET "/workflows" \
    | jq -e --arg wid "$workflow_id" 'any(.[]; .id == $wid)' >/dev/null
  then
    echo "Workflow '$workflow_id' not registered" >&2
    exit 1
  fi
}
