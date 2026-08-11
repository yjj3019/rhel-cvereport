#!/usr/bin/env bash
# redhat-cve-report 스킬 자동 설치 스크립트
# 사용법:
#   curl -sL https://raw.githubusercontent.com/yjj3019/rhel-cvereport/main/install.sh | bash
#   또는: ./install.sh [--project]
#
# 옵션 없음(기본)  : 전역 설치 (모든 프로젝트에서 사용 가능) -> ~/.claude/skills/
# --project        : 현재 프로젝트에만 설치 -> ./.claude/skills/

set -euo pipefail

REPO_URL="https://github.com/yjj3019/rhel-cvereport.git"
SKILL_NAME="redhat-cve-report"

if [[ "${1:-}" == "--project" ]]; then
  TARGET_DIR="./.claude/skills/${SKILL_NAME}"
  SCOPE="프로젝트 전용"
else
  TARGET_DIR="${HOME}/.claude/skills/${SKILL_NAME}"
  SCOPE="전역(모든 프로젝트)"
fi

echo "📦 ${SKILL_NAME} 스킬을 설치합니다. (범위: ${SCOPE})"
echo "   대상 경로: ${TARGET_DIR}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

echo "⬇️  저장소 클론 중..."
git clone --depth 1 "${REPO_URL}" "${TMP_DIR}/repo" >/dev/null 2>&1

mkdir -p "$(dirname "${TARGET_DIR}")"
rm -rf "${TARGET_DIR}"
mkdir -p "${TARGET_DIR}"

cp "${TMP_DIR}/repo/SKILL.md" "${TARGET_DIR}/SKILL.md"
cp -r "${TMP_DIR}/repo/references" "${TARGET_DIR}/references"

if [[ -f "${TARGET_DIR}/SKILL.md" ]]; then
  echo "✅ 설치 완료: ${TARGET_DIR}"
  echo ""
  echo "다음 Claude Code 세션부터 자동으로 인식됩니다."
  echo "확인하려면: claude 실행 후 'CVE-2026-12329 리포트해줘' 라고 입력해 보세요."
else
  echo "❌ 설치 실패"
  exit 1
fi
