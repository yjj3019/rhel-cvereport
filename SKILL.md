---
name: redhat-cve-report
description: Generate a fixed-format Korean-language Red Hat CVE security report from a CVE ID. Use this skill whenever the user gives a CVE ID (e.g. "CVE-2026-12329") and asks for a "리포트" / "보안 리포트" / report / summary about it, especially in the context of Red Hat Enterprise Linux (RHEL), firefox/thunderbird, or any Red Hat-tracked package. Always use this skill instead of improvising a one-off report — the output format is fixed and must not be changed. Trigger even if the user just pastes a Red Hat CVE URL (access.redhat.com/security/cve/CVE-xxxx-xxxxx) with no further instruction.
---

# Red Hat CVE 보안 리포트 생성

CVE ID 하나를 입력받아, 고정된 한국어 리포트를 생성한다. **아래 섹션 순서, 제목, 표 컬럼, 문구 톤을 절대 바꾸지 않는다.** 데이터가 없는 항목은 표 자체를 생략하지 말고 "정보 없음"으로 채우거나, 해당 섹션 안내에 따른다.

이 스킬은 반드시 `references/TEMPLATE.md`를 읽고 그 구조를 그대로 따른다. 최종 산출물은 마크다운(.md) 파일이며 `/mnt/user-data/outputs/CVE-{ID}_리포트.md`로 저장 후 `present_files`로 제공한다.

## 진행 순서

### 1. CVE ID 정규화
사용자가 준 입력에서 `CVE-YYYY-NNNNN` 형식을 추출한다 (URL로 줬을 경우 마지막 경로에서 추출).

### 2. 데이터 수집 (반드시 이 순서로, 모두 시도)

**2-1. Red Hat CVE 페이지 (필수)**
`web_fetch`로 `https://access.redhat.com/security/cve/{CVE-ID}` 를 가져온다.
- Description (영문 원문) → 한국어로 자연스럽게 의역해 "취약점 설명"에 사용
- Statement (있으면) → 완화 방법 섹션 작성에 참고
- CVSS v3 Score Breakdown 표 (Red Hat / NVD / cve.org 컬럼과 각 벡터, 점수)
- Mitigation 섹션이 명시적으로 존재하는지 확인 (있으면 내용을 번역해서 3번 섹션에 반영, 없으면 템플릿의 기본 문구 사용)
- 공개일(Public Date), 최종 갱신일
- **"Affected Products / Services" 표 (Products/services, Components, State, Justification, Errata, Release date 컬럼)를 반드시 확인한다.** 이 표는 JavaScript로 렌더링되어 기본 `web_fetch`로는 보이지 않을 수 있다 — 이 경우 CSAF/VEX JSON(2-2)의 `product_status` 필드(`fixed`, `known_affected`, `known_not_affected`, `under_investigation`, `out_of_support_scope` 등)로 반드시 교차 확인한다. **Statement 본문의 일반적 서술("이 제품군이 영향받는다")만 보고 특정 제품의 상태를 추정하지 않는다 — 반드시 이 표/JSON에 명시된 개별 제품별 상태를 확인한다.**

**2-2. Red Hat CSAF/VEX JSON (필수, 패키지 버전 정확성을 위해)**
CVE ID를 소문자로 바꾸고 연도를 추출해 다음 URL을 `web_fetch`:
`https://security.access.redhat.com/data/csaf/v2/vex/{YYYY}/{cve-yyyy-nnnnn}.json`
- 이 JSON의 `product_tree` > `branches` > architecture별 `product_version`에서 `x86_64` 아키텍처의 `purl`을 파싱해 `{package}-{version}` 형태의 정확한 수정 버전을 추출한다. RPM 버전 문자열 형식은 `{package}-0:{version}-{release}.el{major}_{minor}` 패턴이다.
- 절대 버전을 추측하지 않는다. 이 JSON에 없는 조합은 표에 넣지 않는다.

**2-3. 각 RHSA 정보 (필수)**
CSAF JSON 또는 Red Hat CVE 페이지에 나열된 RHSA 목록 각각에 대해, 가능하면 `web_fetch`로 `https://access.redhat.com/errata/{RHSA-ID}` 를 가져와 발행일(Issued)과 대상 제품명을 확인한다. (동일 정보가 CSAF JSON의 `document > tracking` 또는 `product_tree`에 이미 있다면 중복 호출 생략 가능)

**2-4. EPSS 점수 (필수)**
`web_fetch`로 `https://api.first.org/data/v1/epss?cve={CVE-ID}` 를 시도한다. **이 API는 도구 캐시 문제로 종종 엉뚱한 CVE 데이터를 반환하니, 응답의 `data[0].cve` 값이 요청한 CVE ID와 정확히 일치하는지 반드시 확인한다.** 일치하지 않으면 즉시 아래 대체 경로로 전환한다(재시도하지 말 것):

```bash
curl -sL "https://raw.githubusercontent.com/lucacapacci/epss/main/data_single/{YYYY}/{CVE-ID}.csv"
```
(`bash_tool` 사용, `raw.githubusercontent.com`은 네트워크 허용 목록에 있어 안정적으로 동작한다.) CSV 두 번째 줄이 `cve,epss,percentile`, 세 번째 줄이 실제 값이다. epss 값을 %로, percentile 값을 %로 변환해 사용한다.

**2-5. CISA KEV 등재 여부 (필수)**
`bash_tool`로 다음을 실행:
```bash
curl -s -o /tmp/kev.json https://raw.githubusercontent.com/cisagov/kev-data/main/known_exploited_vulnerabilities.json
python3 -c "
import json
d = json.load(open('/tmp/kev.json'))
hits = [v for v in d['vulnerabilities'] if v['cveID']=='{CVE-ID}']
print('등재됨' if hits else '미등재', hits)
"
```

**2-6. Mozilla 등 업스트림 보안 권고 (해당 시)**
firefox/thunderbird 계열 CVE라면 Red Hat CVE 페이지 References에서 mfsa 번호를 확인해 출처에 기재.

### 3. 완화 방법(Mitigation) 판단 로직
- Red Hat CVE 페이지에 **명시적인 "Mitigation" 섹션이 있으면**: 그 내용을 한국어로 의역해서 사용한다.
- **없으면**: 템플릿의 기본 문구("공식 완화 조치는 제공되지 않습니다... 패치가 유일한 근본 해결책입니다")를 사용하되, 해당 CVE 성격에 맞는 일반적 노출 최소화 팁 3~4개를 상황에 맞게 조정해 작성한다 (예: 브라우저/메일 클라이언트 계열이면 "출처 불분명한 사이트/이메일 자제" 등, 서버 데몬이면 "방화벽으로 신뢰할 수 없는 접속 차단" 등).

### 4. 리포트 작성
`references/TEMPLATE.md`의 구조를 정확히 따라 채운다. 아래 "고정 규칙"을 반드시 지킨다.

### 5. 저장 및 제공
`create_file`로 `/mnt/user-data/outputs/CVE-{ID}_리포트.md` 생성 → `present_files`로 제공.
파일명 형식: `CVE-YYYY-NNNNN_리포트.md` (한글 "리포트" 그대로 사용).

## 고정 규칙 (절대 변경 금지)

- 문서 최상단 제목: `# CVE-{ID} 보안 취약점 리포트`
- 섹션 번호와 제목은 정확히 다음 6개, 이 순서 그대로:
  1. `## 1. 개요` (표 + `### 취약점 설명` 소제목의 서술 문단)
  2. `## 2. 심각도(CVSS) 비교` (표 + `>` 인용구 해설 1줄)
  3. `## 3. 실제 악용 가능성 (EPSS · CISA KEV)` (표 + `**해석**` 불릿 3개)
  4. `## 4. 완화 방법 (Mitigation)`
  5. `## 5. 영향받는 제품 및 패치` (표 + `>` 인용구 — Red Hat 공식 안내문 한국어 번역 및 상태 요약)
  6. `## 6. 출처`
- **소제목은 "취약점 설명"으로 고정** ("CVE-xxxx-xxxx 에 대한 설명", "쉬운 설명" 등으로 쓰지 않는다)
- "5. 영향받는 제품 및 패치" 표 마지막에 **날짜, 생성일, 타임스탬프 등 어떤 메타정보도 추가하지 않는다** — 이전 반복 시행착오 끝에 이 항목은 완전히 제거하기로 확정되었다.
- **"권장 조치 순서" 섹션은 만들지 않는다** — 명시적으로 제거 결정됨.
- HTML 태그(`<div>`, `<p align=...>` 등)는 절대 사용하지 않는다 — 렌더링 안 되는 뷰어가 있어 텍스트로 그대로 노출되는 문제가 확인됨.
- 우측 정렬이 필요한 요소도 만들지 않는다 (표 우측 정렬 시도는 불필요한 구분선을 만들어 제거하기로 결정됨). 모든 텍스트는 좌측 정렬 기본값 그대로 둔다.
- 전체 문체는 한국어 존댓말, 평서형 설명체. 기술 용어는 영어 병기 가능하나 (예: "메모리 안전성(Memory Safety)") 문장 자체는 쉬운 한국어로 푼다.
- "5. 영향받는 제품 및 패치" 표는 **패치가 나온 제품만 넣지 않는다. Red Hat이 분류한 모든 관련 제품(Fixed / Not affected / Out of support scope / Will not fix / Under investigation 등)을 빠짐없이 표시한다.** 이는 사용자가 "내 제품이 왜 표에 없지?"라고 헷갈리지 않고, 지원 종료되었거나 영향이 없는 제품도 명확히 인지하도록 하기 위함이다.
  - 패치가 있는 행의 컬럼: `제품 | 컴포넌트 | RHSA | 수정 버전(x86_64) | 발행일`
  - 패치가 없는 행(Not affected / Out of support / Will not fix 등)은 아래처럼 별도 표를 쓰거나, 위 표에 `상태 | 근거` 컬럼을 추가한 확장 표로 합쳐서 표시한다 (어느 쪽이든 빠짐없이 다 보여주는 것이 핵심):
    `제품 | 컴포넌트 | 상태 | 근거 | RHSA | 수정 버전`
  - "Out of support scope"는 "지원 범위 밖", "Not affected"는 "영향 없음", "Vulnerable Code not Present"는 "취약한 코드 없음", "Will not fix"는 "패치 계획 없음"으로 번역한다.
  - 표 아래 `>` 인용구에는 Red Hat 공식 안내문 번역과 함께, 정리된 한 줄 요약(예: "이 CVE는 RHEL 7/8/9/10 어느 버전도 조치가 필요하지 않습니다" 등)을 반드시 덧붙인다.
- "2. 심각도" 표 컬럼은 정확히: `평가 기관 | 버전 | 점수 | 벡터 | 등급`
- "3. 실제 악용 가능성" 표 컬럼은 정확히: `지표 | 값 | 조회 기준일`, 행은 `EPSS 점수`, `EPSS 백분위`, `CISA KEV 등재 여부` 3개 고정.
- 출처 섹션은 항상 다음 순서로, 해당 사항 있는 것만 포함: Red Hat CVE 페이지 → Red Hat Bugzilla → (있으면) Mozilla 보안 권고 → Red Hat 생명주기 정책(`https://access.redhat.com/support/policy/updates/errata`) → EPSS API URL → CISA KEV JSON URL.

## 정확한 완성본 예시

`references/TEMPLATE.md`에 CVE-2026-12329로 실제 검증된 완성본 전체가 들어있다. 새 CVE로 리포트를 만들 때 이 파일을 열어 구조와 톤을 그대로 복제하고, 내용만 새로 조사한 데이터로 교체한다.
