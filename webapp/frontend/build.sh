BE_URL=$(jq -r '
.ALBStack
| to_entries[]
| select(.key | test("ALBURL"))
| .value
' ../../infrastructure/outputs.json)


VITE_API_URL="$BE_URL/api" pnpm build