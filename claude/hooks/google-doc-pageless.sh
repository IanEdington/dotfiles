#!/bin/bash
# Blank docs created via the Drive API honour the account's pageless default, but uploads converted to Docs always start paged.
# mcp_tool hooks can't read the ID out of the connector's string response, so this hands Claude the call to make.

input=$(cat)
jq -e '.tool_input | (.textContent // .base64Content // .content) != null' <<<"$input" >/dev/null || exit 0

file=$(jq '.tool_response | if type == "string" then (try fromjson catch {}) else . end' <<<"$input" 2>/dev/null)
[ "$(jq -r '.mimeType // ""' <<<"$file")" = application/vnd.google-apps.document ] || exit 0
doc_id=$(jq -r '.id // ""' <<<"$file")
[ -n "$doc_id" ] || exit 0

jq -n --arg id "$doc_id" '{
  hookSpecificOutput: {
    hookEventName: "PostToolUse",
    additionalContext: ("New Google Doc \($id) was converted from an upload and is paged. Call the Google Docs update_doc tool with documentId \"\($id)\" and requests [{\"updateDocumentStyle\": {\"documentStyle\": {\"documentFormat\": {\"documentMode\": \"PAGELESS\"}}, \"fields\": \"documentFormat\"}}].")
  }
}'
