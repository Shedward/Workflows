# Workflow Server REST API

## Overview

- **Base URL**: `http://127.0.0.1:8080`
- **Content-Type**: `application/json` for all request and response bodies
- **Framework**: Hummingbird 2.0+

### Conventions

- List endpoints return a raw JSON array `[...]`, not wrapped in an object.
- All workflow data values are JSON-encoded strings (e.g., the string `hello` is stored as `"\"hello\""` in the data map).
- Finished workflow instances are removed from storage and will not appear in any listing.
- Automatic transitions execute inline before the HTTP response is returned.

---

## Endpoints

### GET /health

Server liveness check.

- **Response**: `200 OK`, empty body

---

### GET /workflows

List all registered workflow definitions.

- **Response**: `200 OK`

```json
[
  {
    "id": "SimpleWorkflow",
    "stateId": ["a", "b"],
    "transitions": [
      {
        "processId": "StartA",
        "fromState": "_start",
        "toState": "a",
        "trigger": "manual"
      }
    ]
  }
]
```

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Workflow type identifier |
| `stateId` | [string] | User-defined states (excludes implicit `_start` and `_finish`) |
| `transitions` | [Transition] | All transitions defined for this workflow |

---

### GET /workflowInstances

List all active workflow instances.

- **Response**: `200 OK`

```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "workflowId": "SimpleWorkflow",
    "state": "a",
    "transitionState": null,
    "data": { "data": {} }
  }
]
```

Only active (non-finished) instances are returned. Completed instances are removed from storage.

---

### POST /workflowInstances

Start a new workflow instance.

- **Request Body**:

```json
{
  "workflowId": "SimpleWorkflow",
  "initialData": {
    "data": {
      "greeting": "\"hello\""
    }
  }
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `workflowId` | string | Yes | ID of a registered workflow |
| `initialData` | WorkflowData | No | Initial data to seed the instance |

- **Response**: `200 OK`, WorkflowInstance

If the workflow has automatic transitions from `_start`, they execute inline. The response reflects the state after all automatic transitions complete.

- **Errors**:

| Status | Condition |
|--------|-----------|
| 404 | Workflow ID not found |

---

### GET /workflowInstances/:id

Get a specific workflow instance.

- **Path Parameters**: `id` — instance UUID
- **Response**: `200 OK`, WorkflowInstance

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "workflowId": "SimpleWorkflow",
  "state": "a",
  "transitionState": null,
  "data": {
    "data": {
      "valueA": "\"some_value\""
    }
  }
}
```

- **Errors**:

| Status | Condition |
|--------|-----------|
| 404 | Instance not found (nonexistent or already finished) |

---

### POST /workflowInstances/:id/takeTransition

Execute a transition on a workflow instance.

- **Path Parameters**: `id` — instance UUID
- **Request Body**:

```json
{
  "transitionProcessId": "StartA"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `transitionProcessId` | string | Yes | ID of the transition to execute |

- **Response**: `200 OK`, WorkflowInstance reflecting the state after the transition

If subsequent automatic transitions exist from the new state, they also execute inline.

- **Errors**:

| Status | Condition |
|--------|-----------|
| 404 | Instance not found |
| 404 | Transition ID not found in workflow definition |
| 500 | Transition not available from the instance's current state |
| 500 | Transition action threw an error |

When a transition fails, the instance remains in its original state but `transitionState` is set to `failed` with error details.

---

### GET /workflowInstances/:id/transitions

List transitions available from the instance's current state.

- **Path Parameters**: `id` — instance UUID
- **Response**: `200 OK`

```json
[
  {
    "processId": "StartA",
    "fromState": "_start",
    "toState": "a",
    "trigger": "manual"
  }
]
```

Only transitions whose `fromState` matches the instance's current state are returned.

- **Errors**:

| Status | Condition |
|--------|-----------|
| 404 | Instance not found |

---

### POST /workflowInstances/:id/answer

Provide data to answer an asking (user-input) transition.

- **Path Parameters**: `id` — instance UUID
- **Request Body**:

```json
{
  "data": {
    "data": {
      "name": "\"Alice\"",
      "approved": "true"
    }
  }
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `data` | WorkflowData | Yes | User-provided data matching the expected fields |

- **Response**: `200 OK`, WorkflowInstance reflecting the state after the ask completes

The ask transition's `process()` method runs with the provided data. If subsequent automatic transitions exist, they also execute inline.

- **Errors**:

| Status | Condition |
|--------|-----------|
| 404 | Instance not found |
| 409 | Instance is not in an asking state |
| 500 | Ask processing failed |

---

## Models

### WorkflowInstance

```json
{
  "id": "string (UUID)",
  "workflowId": "string",
  "state": "string",
  "transitionState": TransitionState | null,
  "data": WorkflowData
}
```

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Auto-generated UUID |
| `workflowId` | string | Workflow definition this instance belongs to |
| `state` | string | Current state (`_start`, user-defined states, or `_finish`) |
| `transitionState` | TransitionState? | Present when a transition is waiting or has failed; null otherwise |
| `data` | WorkflowData | Accumulated key-value data from transitions |

### TransitionState

```json
{
  "id": {
    "workflow": "SimpleWorkflow",
    "processId": "StartA",
    "from": "_start",
    "to": "a"
  },
  "state": { ... }
}
```

The `state` field is one of:

**Waiting for time:**
```json
{ "waitingTime": { "date": "2026-03-22T12:00:00Z" } }
```

**Waiting for subflow:**
```json
{ "waitingWorkflow": { "workflowId": "child-instance-uuid" } }
```

**Asking for user input:**
```json
{
  "asking": {
    "prompt": "What is your name?",
    "expectedFields": [
      { "key": "name", "valueType": "String" }
    ]
  }
}
```

**Failed:**
```json
{
  "failed": {
    "error": {
      "userDescription": "Intentional test failure",
      "debugDescription": "..."
    }
  }
}
```

### Transition

```json
{
  "processId": "string",
  "fromState": "string",
  "toState": "string",
  "trigger": "string"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `processId` | string | Transition identifier (used in `takeTransition`) |
| `fromState` | string | Source state |
| `toState` | string | Target state |
| `trigger` | string | `"manual"` or `"automatic"` |

### WorkflowData

```json
{
  "data": {
    "key": "\"json-encoded-value\""
  }
}
```

All values are JSON-encoded strings. A string value `hello` is stored as `"\"hello\""`. A number `42` is stored as `"42"`.

### ErrorResponse

```json
{
  "userDescription": "Workflow not found",
  "debugDescription": "WorkflowNotFound(id: \"BadId\")"
}
```

---

## Error Reference

| Error | HTTP Status | userDescription |
|-------|-------------|-----------------|
| Workflow not found | 404 | "Workflow not found" |
| Instance not found | 404 | "Workflow instance not found" |
| Transition not found | 404 | "Transition not found" |
| Transition not available from state | 500 | "Transition process not found for instance" |
| Instance/workflow mismatch | 500 | "Workflow instance does not match expected workflow" |
| Instance not asking | 409 | "Workflow instance is not waiting for an answer" |

---

## Behavioral Notes

### Automatic Transitions

Workflows can define transitions with `trigger: "automatic"`. These execute inline without an explicit API call:

- When starting a workflow (`POST /workflowInstances`), all automatic transitions from `_start` execute before the response.
- When taking a transition (`POST takeTransition`), any automatic transitions from the resulting state also execute.
- Only one automatic transition is allowed per state. Multiple automatics from the same state cause an error.
- A safety limit of 1000 automatic steps prevents infinite loops.

### Subflows

A subflow transition starts a child workflow instance:

- The parent enters `waitingWorkflow` state with the child's instance ID.
- The child instance is fully independent and appears in `GET /workflowInstances`.
- The child can be queried and transitioned like any other instance.
- When the child reaches `_finish`, the parent automatically resumes.
- If the child is fully automatic, it completes inline and the parent never enters a waiting state.

### Waiting

Wait transitions suspend the instance until a condition is met:

- The instance enters `waitingTime` state with a target date.
- The server's internal scheduler resumes the transition when the time arrives.
- Poll `GET /workflowInstances/:id` to observe state changes.

### Asking (User Input)

Ask transitions suspend the instance waiting for user-provided data:

- The instance enters `asking` state with an optional prompt message and a list of expected fields.
- The client reads the expected fields from `transitionState.state.asking.expectedFields`.
- Submit data via `POST /workflowInstances/:id/answer` with a `WorkflowData` body containing the required fields.
- The ask's `process()` method runs with the provided data, producing outputs.
- `@Ask` fields are automatically persisted as outputs to the workflow data.
- Answering a non-asking instance returns 409 Conflict.

### Finished Instances

When an instance reaches `_finish`:

- It is removed from in-memory storage.
- It no longer appears in `GET /workflowInstances`.
- `GET /workflowInstances/:id` returns 404.
- Any parent workflows waiting on it are notified and resumed.
