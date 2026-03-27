# VocaBar - Product Requirements Document (PRD)

## 1. 제품 개요

**제품명:** VocaBar
**플랫폼:** macOS (네이티브)
**버전:** v1.3
**최소 요구사항:** macOS 14 (Sonoma) 이상
**기술 스택:** Swift, SwiftUI, SwiftData, Vision Framework

VocaBar는 맥북 상단 메뉴바에 영어 단어를 자동으로 띄워주는 학습 앱이다. 사용자가 작업 중에도 자연스럽게 단어에 노출되어 반복 학습 효과를 얻을 수 있다.

---

## 2. 타겟 사용자

- TOEFL/GRE 등 영어 시험을 준비하는 학습자
- 맥북을 주로 사용하는 직장인/학생
- 별도 앱을 열지 않고 자연스러운 단어 노출을 원하는 사람

---

## 3. 핵심 기능

### 3.1 메뉴바 단어 노출
| 항목 | 상세 |
|------|------|
| 위치 | macOS 상단 메뉴바 |
| 표시 형식 | `🔥 aberrant: 비정상적인` (이모지 + 영어 + 뜻) |
| 전환 방식 | 설정된 간격(3~120초)으로 자동 순환 |
| 순서 | 오늘의 단어 목록 내에서 랜덤 셔플 |
| 이모지 | 매일 자동 변경 (🔥⚡🧠💡🎯✨🚀📚💪🌟 10종 로테이션) |
| 표시 옵션 | 영어만 / 영어+뜻 (설정에서 변경) |
| Dock 아이콘 | 숨김 (LSUIElement=YES), 메뉴바에만 존재 |

### 3.2 오늘의 단어
| 항목 | 상세 |
|------|------|
| 선택 방식 | 날짜 기반 시드 랜덤 — 매일 다른 단어 세트, 같은 날은 동일 유지 |
| 선택 풀 | 미학습 단어 우선, 전부 학습 시 전체에서 선택 |
| 목표량 | 사용자 설정 (기본 20개, 5~100개 조절 가능) |
| 진행률 | 원형 프로그레스바 + "N/M개 학습 완료" 텍스트 |
| 현재 단어 | 상단 하이라이트 영역에 영어 + 뜻 + 예문 표시 |

### 3.3 학습 완료 기준
| 방법 | 설명 |
|------|------|
| 수동 완료 | 오늘의 단어 목록에서 단어 클릭 → 학습완료 토글 |
| 자동 완료 | 퀴즈에서 해당 단어를 3회 정답 처리 시 자동 완료 |
| 완료 표시 | 초록색 체크마크 + 취소선 + 배경색 변경 |
| 되돌리기 | 다시 클릭하면 미학습으로 복원 |

### 3.4 퀴즈
| 항목 | 상세 |
|------|------|
| 형식 | 4지선다 (영어 보고 뜻 선택) |
| 문제 수 | 10문제/회 |
| 출제 풀 | 전체 단어에서 랜덤 |
| 오답 생성 | 전체 단어 뜻에서 중복 없이 3개 추출 |
| 정답 피드백 | 즉시 — 정답(초록), 오답(빨강) 색상 표시 |
| 결과 화면 | 정답 수, 오답 수, 정답률(%) 표시 |
| 학습 기록 | correctCount, wrongCount 누적 저장 |

### 3.5 단어 추가
| 입력 방식 | 상세 |
|-----------|------|
| 직접 입력 | 영어 단어 + 뜻 (필수), 예문 (선택) |
| 사진 인식 (OCR) | 이미지 파일 선택 또는 드래그앤드롭 → Vision framework로 텍스트 추출 → 단어-뜻 쌍 자동 파싱 → 사용자 확인 후 추가 |
| CSV 가져오기 | CSV/TSV/TXT 파일 선택 → 콤마/탭/세미콜론 구분자 자동 인식 → 미리보기 후 일괄 추가 |

**OCR 지원 형식:**
- `word - meaning`
- `word: meaning`
- `word\tmeaning`
- 영어 텍스트만 있는 경우 단어만 추출 (뜻은 사용자가 입력)

**CSV 지원 형식:**
- `영어,뜻` 또는 `영어,뜻,예문`
- 헤더 행 자동 스킵

### 3.6 설정
| 설정 항목 | 범위 | 기본값 |
|-----------|------|--------|
| 하루 목표 단어 수 | 5~100개 (5단위) | 20개 |
| 단어 전환 간격 | 3~120초 | 10초 |
| 메뉴바 표시 형식 | 영어만 / 영어+뜻 | 영어+뜻 |
| 학습 기록 초기화 | 전체 정답/오답/학습완료 리셋 | — |
| 통계 | 전체/학습완료/미학습 단어 수 표시 | — |

---

## 4. 데이터 모델

### Word (SwiftData @Model)
```
english: String        — 영어 단어
meaning: String        — 한글 뜻
example: String        — 예문 (선택)
source: WordSource     — 입력 경로 (manual/ocr/csv/sample)
isLearned: Bool        — 학습 완료 여부
correctCount: Int      — 퀴즈 정답 횟수
wrongCount: Int        — 퀴즈 오답 횟수
createdAt: Date        — 생성일
lastStudiedAt: Date?   — 마지막 학습일
```

### 저장
- **단어 데이터:** SwiftData (로컬 SQLite)
- **설정값:** UserDefaults (rotationInterval, dailyGoal, displayMode)
- **데이터 버전:** sampleDataVersion (샘플 단어 업데이트 관리)

---

## 5. 내장 단어

### 출처
234개 TOEFL 고급 학술 어휘, 다음 소스를 교차 참조하여 선별:

| 출처 | 신뢰도 |
|------|--------|
| Magoosh TOEFL Vocabulary (magoosh.com) | 높음 |
| PrepScholar 327 TOEFL Words (prepscholar.com) | 높음 |
| McGraw-Hill 400 Must-Have Words for the TOEFL | 높음 |
| Barron's Essential Words for the TOEFL | 높음 |
| Britannica 100 Essential TOEFL Words | 높음 |
| Academic Word List — Dr. Averil Coxhead (Victoria Univ.) | 최고 |

참고: ETS는 공식 단어 리스트를 별도 발행하지 않으며, Academic vocabulary의 문맥 학습을 권장함.

### 데이터 형식
```json
{
  "english": "aberrant",
  "meaning": "비정상적인, 일탈한",
  "example": "The aberrant weather patterns concerned climatologists."
}
```

---

## 6. 앱 구조

```
VocaBar/
├── VocaBarApp.swift                    — 앱 진입점, MenuBarExtra
├── Models/
│   └── Word.swift                      — SwiftData 모델
├── Views/
│   ├── ContentView.swift               — 탭 네비게이션 (메인 팝오버)
│   ├── TodayWordsView.swift            — 오늘의 단어 + 진행률
│   ├── QuizView.swift                  — 4지선다 퀴즈
│   ├── AddWordView.swift               — 단어 추가 (수동/OCR/CSV)
│   └── SettingsView.swift              — 설정 + 통계
├── Services/
│   ├── WordRotationService.swift       — 메뉴바 단어 순환 + 날짜 기반 랜덤
│   ├── OCRService.swift                — Vision framework OCR
│   └── SampleDataService.swift         — 내장 단어 로드 + 버전 관리
└── Resources/
    └── toefl_words.json                — 내장 TOEFL 단어 234개
```

---

## 7. UI 플로우

```
[메뉴바]  🔥 aberrant: 비정상적인
    │
    ▼ (클릭)
[팝오버 — 380×520]
    ┌─────────────────────────────────┐
    │  오늘의 단어 | 퀴즈 | 단어 추가 | 설정  │  ← 탭 바
    ├─────────────────────────────────┤
    │                                 │
    │  [선택된 탭의 콘텐츠]              │
    │                                 │
    └─────────────────────────────────┘
```

### 오늘의 단어 탭
```
🔥 오늘의 단어          [진행률 원형]
5/20개 학습 완료

┌──────────────────────────────┐
│  ameliorate                   │  ← 현재 메뉴바 노출 중인 단어
│  개선하다, 향상시키다            │
│  New policies were introduced │
│  to ameliorate living...      │
└──────────────────────────────┘

  ○ abrogate — 폐지하다
  ○ acquiesce — 묵인하다
  ✅ adamant — 단호한           ← 학습완료 (클릭으로 토글)
  ○ admonish — 경고하다
  ...

전체 단어: 234개
```

### 퀴즈 탭
```
[퀴즈 시작] 버튼
    ↓
3/10          ✅ 2  ❌ 0
━━━━━━━━━━━━━━━━━━━━━━━━

        ameliorate

      이 단어의 뜻은?

  ┌─────────────────────┐
  │ 개선하다, 향상시키다    │  ← 정답 (초록)
  ├─────────────────────┤
  │ 폐지하다              │
  ├─────────────────────┤
  │ 억제하다              │
  ├─────────────────────┤
  │ 묵인하다              │
  └─────────────────────┘

      [다음 문제]
```

---

## 8. 기술적 결정사항

| 결정 | 선택 | 이유 |
|------|------|------|
| 데이터 저장 | SwiftData | CoreData보다 코드 적고 SwiftUI 네이티브 통합 |
| 메뉴바 구현 | MenuBarExtra (.window) | SwiftUI 네이티브, 팝오버 커스텀 자유로움 |
| OCR | Vision framework | 외부 라이브러리 불필요, 영어+한글 인식 지원 |
| 단어 순환 | Timer + @Observable | SwiftUI 반응형 업데이트와 자연스럽게 통합 |
| 일일 랜덤 | 날짜 기반 시드 RNG | 같은 날은 동일 세트 유지, 매일 다른 단어 |
| 파일 가져오기 | NSOpenPanel + SecurityScoped | 앱 샌드박스 호환 |

---

## 9. 권한 및 샌드박스

| 권한 | 용도 |
|------|------|
| com.apple.security.app-sandbox | 앱 샌드박스 |
| com.apple.security.files.user-selected.read-only | 파일 선택 (이미지/CSV 가져오기) |

---

## 10. 버전 히스토리

| 버전 | 날짜 | 주요 변경 |
|------|------|-----------|
| v1.0 | 2026-03-27 | 최초 빌드 — 메뉴바 단어 노출, 퀴즈, 단어 추가, 설정 |
| v1.1 | 2026-03-27 | 설정 반영 버그 수정 (Observable computed property → stored property) |
| v1.2 | 2026-03-27 | 실제 TOEFL 단어 234개 교체, 팝오버 리셋 버그 수정, 파일 선택 수정 |
| v1.3 | 2026-03-27 | 매일 바뀌는 이모지, 학습완료 카운트 버그 수정, 날짜 기반 랜덤 선택 |

---

## 11. 향후 로드맵

### Phase 2 (계획)
- [ ] 에빙하우스 망각곡선 기반 복습 스케줄링
- [ ] 단어 검색 기능
- [ ] 단어 삭제/편집 기능
- [ ] 다크모드 대응

### Phase 3 (계획)
- [ ] xlsx 파일 지원 (CoreXLSX)
- [ ] 단어장 카테고리/태그 분류
- [ ] 학습 통계 그래프 (일별/주별)
- [ ] 키보드 단축키 (다음 단어, 퀴즈 시작 등)

### Phase 4 (계획)
- [ ] iPhone/iPad 연동 (CloudKit)
- [ ] TestFlight / Mac App Store 배포
- [ ] 다국어 지원 (일본어, 중국어 등)
- [ ] AI 기반 맥락 예문 생성

---

## 12. 팀

| 역할 | 담당 |
|------|------|
| 기획 + 개발 | 하지연 |
| UX 리서치 + 화면기획 + 개발 | uxer |
| 초기 개발 (v1.0~1.3) | Claude (AI) |

---

## 13. 협업 가이드

### Git 브랜치 전략
```
main ← 안정 버전
 └── feature/기능명 ← 각자 작업 브랜치
```

### 커밋 규칙
- 한글 OK: `"퀴즈 결과 저장 로직 추가"`
- 작은 단위로 자주 commit
- 같은 파일 동시 수정 금지 (담당 분류 따르기)

### Xcode 프로젝트
- 위치: `/Users/hajiyeon/Desktop/VocaBar/VocaBar.xcodeproj`
- Xcode에서 열어서 빌드: Cmd+R
