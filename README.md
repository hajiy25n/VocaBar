# VocaBar

**맥북 메뉴바에 영어 단어를 띄워주는 macOS 네이티브 학습 앱**

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue?style=flat-square&logo=apple) ![Swift](https://img.shields.io/badge/Swift-5.9-orange?style=flat-square&logo=swift) ![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-purple?style=flat-square) ![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

---

## 뭐하는 앱이야?

작업하면서 자연스럽게 영어 단어를 외울 수 있는 앱.
메뉴바에 단어가 자동으로 바뀌면서 노출되고, 클릭하면 학습 관리와 퀴즈를 할 수 있어.

```
메뉴바:  🔥 aberrant: 비정상적인
              ↓ (자동 전환)
         ⚡ ameliorate: 개선하다
              ↓
         🧠 acquiesce: 묵인하다
```

---

## 주요 기능

- **메뉴바 단어 노출** — 설정한 간격으로 영어+뜻 자동 전환
- **오늘의 단어** — 매일 랜덤 선별, 클릭으로 학습완료 관리
- **4지선다 퀴즈** — 오늘의 단어에서 출제, 3회 정답 시 자동 학습완료
- **폴더 분류** — 단어를 폴더별로 분류하고 폴더 단위로 학습
- **단어 추가** — 직접 입력 / 사진 OCR / CSV 파일 가져오기
- **TOEFL 단어 내장** — 검증된 소스 기반 234개 고급 학술 어휘

---

## 설치

```bash
git clone https://github.com/hajiy25n/VocaBar.git
cd VocaBar
open VocaBar.xcodeproj
# Xcode에서 Cmd+R 로 빌드 & 실행
```

**요구사항:** macOS 14 (Sonoma) 이상, Xcode

---

## 기술 스택

Swift · SwiftUI · SwiftData · MenuBarExtra · Vision Framework

---

## 문서

| 문서 | 설명 |
|------|------|
| [PRD.md](./PRD.md) | 제품 요구사항 + 기능 상세 |
| [CHANGELOG.md](./CHANGELOG.md) | 버전별 변경 내역 |
| [VERSION_GUIDE.md](./VERSION_GUIDE.md) | Git/버전 관리 가이드 |
| [CONTRIBUTING.md](./CONTRIBUTING.md) | 협업 가이드 |

---

## 팀

| 역할 | 담당 |
|------|------|
| 기획 + 개발 | 하지연 ([@hajiy25n](https://github.com/hajiy25n)) |
| UX 리서치 + 화면기획 | uxer |

---

## 라이선스

MIT License
