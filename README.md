# rhel-cvereport

[English](./README.en.md) | 한국어

Claude Skill: Red Hat CVE 취약점 보안 리포트를 **고정된 한국어 형식**으로 자동 생성합니다.

CVE ID(또는 Red Hat CVE URL)만 주면, Red Hat CVE 페이지 · CSAF/VEX · EPSS · CISA KEV 4곳의 데이터를 자동으로 조사해서 아래 6개 섹션으로 구성된 리포트를 만들어 줍니다.

---

## 1. 설치 방법

이 스킬은 **Claude Code**(CLI/데스크톱 앱의 코드 에이전트)용입니다. Claude.ai 웹 채팅에서는 스킬 파일을 직접 업로드하는 방식(3번 참고)을 사용해야 합니다.

### 방법 A — 자동 설치 스크립트 (권장)

터미널에서 아래 한 줄을 실행하면 끝입니다.

```bash
curl -sL https://raw.githubusercontent.com/yjj3019/rhel-cvereport/main/install.sh | bash
```

- 기본은 **전역 설치**입니다 (`~/.claude/skills/redhat-cve-report/`) — 모든 프로젝트에서 사용 가능.
- 특정 프로젝트에만 설치하려면, 그 프로젝트 폴더 안에서:
  ```bash
  curl -sL https://raw.githubusercontent.com/yjj3019/rhel-cvereport/main/install.sh -o install.sh
  bash install.sh --project
  ```
  → `./.claude/skills/redhat-cve-report/`에 설치됩니다 (그 프로젝트에서만 동작).

### 방법 B — 수동 설치 (git clone)

```bash
mkdir -p ~/.claude/skills
git clone https://github.com/yjj3019/rhel-cvereport.git ~/.claude/skills/redhat-cve-report
```

이렇게 하면 저장소 자체가 스킬 폴더가 되고, 이후 `git pull`만으로 최신 버전 업데이트가 가능합니다.
(방법 A의 install.sh는 `.git` 폴더 없이 파일만 복사하는 방식이라 더 깔끔하지만 업데이트 시 재실행이 필요합니다.)

### 방법 C — Claude.ai 웹 / Claude Desktop (수동 업로드)

Claude.ai 웹 채팅이나 Claude Desktop 앱은 git 저장소를 직접 읽지 못합니다. 대신:
1. 이 저장소를 로컬에 클론하거나 `SKILL.md` + `references/TEMPLATE.md`를 다운로드
2. Claude 설정 → Capabilities(기능) → Skills 메뉴에서 해당 파일(또는 폴더를 압축한 zip)을 업로드
3. 조직 관리자가 스킬 사용을 허용한 경우에만 저장(Save skill) 버튼이 나타납니다.

---

## 2. 설치 확인

```bash
# Claude Code 세션 시작 후
claude
```
대화창에 아래처럼 입력해 스킬 목록에 잡히는지 확인하세요.
```
어떤 스킬을 사용할 수 있어?
```
`redhat-cve-report`가 보이면 설치 성공입니다.

## 3. 사용법

새 Claude Code 세션에서 CVE ID(또는 Red Hat CVE 페이지 URL)를 언급하며 리포트를 요청하면 자동으로 트리거됩니다. 슬래시 커맨드 없이 자연어로 충분합니다.

**예시 입력:**
```
CVE-2026-12329 리포트해줘
```
```
https://access.redhat.com/security/cve/CVE-2026-55200 취약점 분석해줘
```
```
libssh2 CVE-2026-55200 보안 리포트 만들어줘
```

**리포트 산출물:**
- 파일로 저장됩니다: `CVE-{ID}_리포트.md`
- 6개 섹션 고정 구성:
  1. 개요 (CVE 기본정보 + 취약점 설명)
  2. 심각도(CVSS) 비교 — Red Hat / NVD / cve.org
  3. 실제 악용 가능성 — EPSS 점수·백분위, CISA KEV 등재 여부
  4. 완화 방법(Mitigation) — 공식 완화책 유무에 따라 자동 분기
  5. 영향받는 제품 및 패치 — RHEL 버전별 RHSA, 정확한 수정 패키지 버전
  6. 출처 — 조사에 사용한 모든 원본 URL

## 4. 업데이트

**방법 A로 설치한 경우** — install.sh를 다시 실행하면 최신 버전으로 덮어씁니다.
```bash
curl -sL https://raw.githubusercontent.com/yjj3019/rhel-cvereport/main/install.sh | bash
```

**방법 B(git clone)로 설치한 경우:**
```bash
cd ~/.claude/skills/redhat-cve-report
git pull
```

## 5. 제거

```bash
rm -rf ~/.claude/skills/redhat-cve-report
# 프로젝트 전용으로 설치했다면:
rm -rf ./.claude/skills/redhat-cve-report
```

## 6. 파일 구성

```
rhel-cvereport/
├── install.sh              # 자동 설치 스크립트
├── SKILL.md                # 스킬 정의: 데이터 수집 순서, 고정 리포트 규칙
├── references/
│   └── TEMPLATE.md         # 검증된 완성본 예시 (CVE-2026-12329) — 형식의 기준
└── README.md                # 이 문서
```

## 7. 동작 원리 (참고)

`SKILL.md`는 다음을 순서대로 조회하도록 지시합니다.
1. Red Hat CVE 페이지 (`access.redhat.com/security/cve/{CVE-ID}`) — 설명, CVSS, Mitigation 유무
2. Red Hat CSAF/VEX JSON — 정확한 수정 패키지 버전 (추측 금지, 이 JSON에 없으면 표에 넣지 않음)
3. 각 RHSA 발행일
4. EPSS 점수 (`api.first.org`, 실패 시 GitHub 미러로 자동 전환)
5. CISA KEV 등재 여부 (`cisagov/kev-data` GitHub 미러 전수 조회)

`references/TEMPLATE.md`는 위 데이터를 채워 넣을 **틀 자체**이며, 섹션 제목·순서·표 컬럼·문체를 절대 바꾸지 않도록 SKILL.md에 명시되어 있습니다.

## 8. 보안 참고사항

이 저장소와 스킬은 비밀번호, API 키, 개인정보를 전혀 다루지 않습니다. 조회하는 모든 API(Red Hat, EPSS, CISA)는 인증이 필요 없는 공개 데이터입니다.
