#!/usr/bin/env bash
# Configure SSM Session Manager default run-as user.
# Usage: setup-ssm-preferences.sh [apply|revert|status] [region]
set -euo pipefail

ACTION="${1:-status}"
REGION="${2:-ap-southeast-1}"
DOC="SSM-SessionManagerRunShell"

current_user() {
  aws ssm get-document --name "$DOC" --region "$REGION" --query Content --output text \
    | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d.get("inputs",{}).get("runAsDefaultUser",""))'
}

set_user() { # $1=user, $2=enable(true/false)
  local content newver
  content=$(aws ssm get-document --name "$DOC" --region "$REGION" --query Content --output text \
    | python3 -c "
import sys,json
d=json.load(sys.stdin)
inp=d.setdefault('inputs',{})
inp['runAsEnabled']=$2
if $2: inp['runAsDefaultUser']='$1'
else: inp.pop('runAsDefaultUser',None)
print(json.dumps(d))")
  newver=$(aws ssm update-document --name "$DOC" --content "$content" --region "$REGION" \
    --query 'DocumentDescription.DocumentVersion' --output text)
  aws ssm update-document-default-version --name "$DOC" --document-version "$newver" --region "$REGION" >/dev/null
  echo "SSM session default user set to '${1:-ssm-user}' (document version $newver)."
}

echo "Region: $REGION"
echo "Current SSM session run-as user: '$(current_user)'"

case "$ACTION" in
  apply)
    if [ "$(current_user)" = "ubuntu" ]; then
      echo "Already configured as ubuntu. Nothing to do."
    else set_user ubuntu true; fi ;;
  revert)
    if [ -z "$(current_user)" ]; then
      echo "Already default (ssm-user). Nothing to do."
    else set_user "" false; fi ;;
  status) ;;
esac