# 📖 VocaBar

**맥북 메뉴바에 영어 단어를 띄워주는 macOS 네이티브 학습 앱**

<img width="400" alt="VocaBar Menu Bar" src="https://img.shields.io/badge/macOS-14%2B-blue?style=flat-square&logo=apple"> <img src="https://img.shields.io/badge/Swift-5.9-orange?style=flat-square&logo=swift"> <img src="https://img.shields.io/badge/SwiftUI-✓-purple?style=flat-square">

---

## 뭐하는 앱이야?

작업하면서 자연스럽게 영어 단어를 외울 수 있는 앱이에요.
메뉴바에 단어가 자동으로 바뀌면서 노출되고, 클릭하면 퀴즈도 볼 수 있어요.

```
메뉴바:  🔥 aberrant: 비정상적인
              ↓ (10초 후)
         🔥 ameliorate: 개선하다
              ↓ (10초 후)
         🔥 acquiesce: 묵인하다
```

---

## 주요 기능

| 기능 | 설명 |
|------|------|
| **메뉴바 단어 노출** | 설정한 간격(3~120초)으로 영어+뜻 자동 전환 |
| **매일 바뀌는 이모지** | 🔥⚡🧠💡🎯✨🚀📚💪🌟 10종 일일 로테이션 |
| **오늘의 단어** | 매일 랜덤으로 목표량만큼 선별, 클릭으로 학습완료 |
| **4지선다 퀴즈** | 10문제씩, 3회 정답 시 자동 학습완료 |
| **단어 추가** | 직접 입력 / 사진 OCR / CSV 파일 가져오기 |
| **TOEFL 단어 내장** | 검증된 소스 기반 234개 고급 학술 어휘 |

---

## 스크린샷

> (추후 추가 예정)

---

## 설치 방법

### 방법 1: 소스에서 빌드 (개발자)
```bash
git clone https://github.com/hajiy25n/VocaBar.git
cd VocaBar
open VocaBar.xcodeproj
# Xcode에서 Cmd+R 로 빌드 & 실행
```

### 방법 2: 앱 파일 직접 설치
1. [Releases](https://github.com/hajiy25n/VocaBar/releases)에서 `VocaBar-v{버전}.zip` 다운로드
2. 압축 풀기
3. `VocaBar.app`을 응용프로그램 폴더로 이동
4. 처음 열 때: 우클릭 > 열기 (또는 시스템 설정 > 보안에서 허용)

**요구사항:** macOS 14 (Sonoma) 이상

---

## 기술 스택

- **Swift + SwiftUI** — 네이티브 macOS UI
- **SwiftData** — 단어 데이터 저장
- **MenuBarExtra (.window)** — 메뉴바 앱 구현
- **Vision Framework** — OCR 텍스트 인식
- **날짜 기반 시드 랜덤** — 매일 다른 단어 세트, 같은 날은 동일 유지

---

## 프로젝트 구조

```
VocaBar/
├── VocaBarApp.swift              # 앱 진입점, MenuBarExtra
├── Models/
│   └── Word.swift                # SwiftData 단어 모델
├── Views/
│   ├── ContentView.swift         # 탭 네비게이션
│   ├── TodayWordsView.swift      # 오늘의 단어 + 진행률
│   ├── QuizView.swift            # 4지선다 퀴즈
│   ├── AddWordView.swift         # 단어 추가 (수동/OCR/CSV)
│   └── SettingsView.swift        # 설정 + 통계
├── Services/
│   ├── WordRotationService.swift # 메뉴바 단어 순환
│   ├── OCRService.swift          # Vision OCR
│   └── SampleDataService.swift   # 샘플 단어 로드
├── Resources/
│   └── toefl_words.json          # TOEFL 단어 234개
├── PRD.md                        # 제품 요구사항 문서
└── CONTRIBUTING.md               # 협업 가이드
```

---

## 내장 단어 출처

234개 단어는 아래 소스를 교차 참조하여 선별:

- [Magoosh TOEFL Vocabulary](https://magoosh.com/toefl/toefl-vocabulary-pdf/)
- [PrepScholar 327 TOEFL Words](https://blog.prepscholar.com/toefl-vocabulary-list)
- [McGraw-Hill 400 Must-Have Words for the TOEFL](https://www.vocabulary.com/lists/317515)
- [Barron's Essential Words for the TOEFL](https://www.vocabulary.com/lists/172112)
- [Britannica 100 Essential TOEFL Words](https://www.britannica.com/dictionary/eb/3000-words/topic/TOEFL%20Vocabulary%20Words)
- [Academic Word List (AWL)](https://www.wgtn.ac.nz/lals/resources/academicwordlist)

---

## 협업

자세한 협업 방법은 [CONTRIBUTING.md](./CONTRIBUTING.md)를 참고하세요.

```bash
# 브랜치 만들고 작업
git checkout -b feature/새기능
# ... 코딩 ...
git add .
git commit -m "새기능 설명"
git push origin feature/새기능
# GitHub에서 Pull Request 생성
```

---

## 팀

| 역할 | 담당 |
|------|------|
| 기획 + 개발 | 하지연 ([@hajiy25n](https://github.com/hajiy25n)) |
| UX 리서치 + 화면기획 | uxer |

---

## 라이선스

MIT License
