# CVE-2026-12329 보안 취약점 리포트

## 1. 개요

| 항목 | 내용 |
|---|---|
| CVE ID | CVE-2026-12329 |
| 영향받는 소프트웨어 | Firefox, Thunderbird |
| 요약 | Thunderbird ESR 140.12에서 수정된 메모리 안전성(Memory Safety) 결함 |
| 공개일 | 2026-06-16 |
| 최종 갱신일 | 2026-07-15 |
| CWE 분류 | 메모리 손상(Memory Corruption) 계열 |

### 취약점 설명
브라우저(Firefox)나 메일 클라이언트(Thunderbird)가 특정 웹페이지나 이메일 콘텐츠를 처리하는 과정에서 메모리를 잘못 다루는 결함입니다. 공격자가 조작한 웹페이지를 열람하거나 악성 이메일의 콘텐츠를 렌더링하게 만들면, 메모리 손상을 통해 비정상 종료(충돌)를 유발하거나 최악의 경우 임의 코드 실행으로 이어질 수 있습니다.

## 2. 심각도(CVSS) 비교

| 평가 기관 | 버전 | 점수 | 벡터 | 등급 |
|---|---|---|---|---|
| **Red Hat** | v3.1 | **7.5** | `AV:N/AC:H/PR:N/UI:R/S:U/C:H/I:H/A:H` | High (Important) |
| Red Hat | v2 | 7.6 | `AV:N/AC:H/Au:N/C:C/I:C/A:C` | High |
| cve.org (Mitre) | v3.1 | 5.3 | `AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:L` | Medium |

> Red Hat과 Mitre의 점수 차이는 각 기관이 실제 악용 난이도를 다르게 평가했기 때문이며, Red Hat 점수가 자사 제품 빌드 기준으로 더 신뢰도 높은 참고치입니다.

## 3. 실제 악용 가능성 (EPSS · CISA KEV)

| 지표 | 값 | 조회 기준일 |
|---|---|---|
| **EPSS 점수** | 0.313% (0.00313) | 2026-08-10 |
| **EPSS 백분위** | 23.7% | 2026-08-10 |
| **CISA KEV 등재 여부** | ❌ 미등재 | 2026-08-11 |

**해석**
- EPSS 0.313%는 향후 30일 내 실제 악용 발생 확률이 매우 낮다는 의미입니다(전체 CVE의 상위 24% 수준으로, 위험도가 높은 편은 아님).
- CISA KEV(실제 악용이 확인된 취약점 목록) 전체 1,662건 중에도 이 CVE는 **포함되어 있지 않습니다.** 즉, 아직 실제 공격에 활용된 사례가 공식적으로 확인되지 않았습니다.
- CVSS 점수(7.5, High)가 높다고 해서 실제 악용 가능성(EPSS)도 비례해서 높은 것은 아니라는 점이 이 CVE에서도 드러납니다. **심각도는 High지만, 실제 공격 위험도는 낮은 편**으로 종합 평가할 수 있습니다.

## 4. 완화 방법 (Mitigation)

**공식 완화 조치(패치 외 임시 대응책)는 Red Hat 및 Mozilla 어느 쪽에서도 별도로 제공되지 않습니다.** 이는 이 CVE가 브라우저/메일 클라이언트의 렌더링 엔진 자체 결함이라 코드 수정 없이는 근본적으로 막을 수 없기 때문입니다.

다만 패치 적용 전까지 노출을 줄이는 일반적 권장 사항은 다음과 같습니다.

- 출처가 불분명한 웹사이트 방문 자제
- 발신자를 알 수 없는 이메일의 첨부파일·링크·이미지 자동 로딩 차단
- Thunderbird의 "원격 콘텐츠 자동 로딩 차단" 옵션 활성화
- 최종적으로는 **패치 적용이 유일한 근본 해결책**

## 5. 영향받는 제품 및 패치

| 제품 | 컴포넌트 | RHSA | 수정 버전(x86_64) | 발행일 |
|---|---|---|---|---|
| RHEL 9 | firefox | [RHSA-2026:27734](https://access.redhat.com/errata/RHSA-2026:27734) | `firefox-0:140.12.0-1.el9_8` | 2026-06-22 |
| RHEL 9 | thunderbird | [RHSA-2026:29940](https://access.redhat.com/errata/RHSA-2026:29940) | `thunderbird-0:140.12.0-1.el9_8` | 2026-06-25 |
| RHEL 10 | firefox | [RHSA-2026:27733](https://access.redhat.com/errata/RHSA-2026:27733) | `firefox-0:140.12.0-1.el10_2` | 2026-06-22 |
| RHEL 10 | thunderbird | [RHSA-2026:30846](https://access.redhat.com/errata/RHSA-2026:30846) | `thunderbird-0:140.12.0-1.el10_2` | 2026-06-29 |
| RHEL 10.0 EUS | firefox | [RHSA-2026:36100](https://access.redhat.com/errata/RHSA-2026:36100) | `firefox-0:140.12.0-1.el10_0` | 2026-07-07 |
| RHEL 10.0 EUS | thunderbird | [RHSA-2026:38751](https://access.redhat.com/errata/RHSA-2026:38751) | `thunderbird-0:140.12.0-1.el10_0` | 2026-07-13 |
| RHEL 8 | firefox | [RHSA-2026:27717](https://access.redhat.com/errata/RHSA-2026:27717) | `firefox-0:140.12.0-1.el8_10` | 2026-06-22 |
| RHEL 8 | thunderbird | [RHSA-2026:33445](https://access.redhat.com/errata/RHSA-2026:33445) | `thunderbird-0:140.12.0-1.el8_10` | 2026-06-30 |
| RHEL 8.4 AMC | firefox | [RHSA-2026:36102](https://access.redhat.com/errata/RHSA-2026:36102) | `firefox-0:140.12.0-1.el8_4` | 2026-07-07 |
| RHEL 8.4 AMC | thunderbird | [RHSA-2026:39428](https://access.redhat.com/errata/RHSA-2026:39428) | `thunderbird-0:140.12.0-1.el8_4` | 2026-07-14 |
| RHEL 7 ELS | firefox | [RHSA-2026:38506](https://access.redhat.com/errata/RHSA-2026:38506) | `firefox-0:140.12.0-1.el7_9` | 2026-07-13 |

> 이 목록에서 명시적으로 "영향 없음(not affected)"으로 표기되지 않은 이상, 목록에 포함된 제품의 모든 마이너 업데이트 스트림에 포함된 기존 패키지 버전은 전체 분석이 수행되지 않았더라도 취약한 것으로 간주해야 합니다.

## 6. 출처

- Red Hat CVE 페이지: https://access.redhat.com/security/cve/CVE-2026-12329
- Red Hat Bugzilla: https://bugzilla.redhat.com/show_bug.cgi?id=2489214
- Mozilla 보안 권고: mfsa2026-61, mfsa2026-58
- Red Hat 생명주기 정책: https://access.redhat.com/support/policy/updates/errata
- EPSS 점수: https://api.first.org/data/v1/epss?cve=CVE-2026-12329
- CISA KEV 카탈로그: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
