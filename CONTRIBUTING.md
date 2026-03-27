# VocaBar 협업 가이드

## 시작하기 전에

### 1. 필수 도구
- **Xcode** (App Store에서 설치)
- **Git** (macOS에 기본 포함)
- **GitHub CLI** (선택): `brew install gh`
- **GitHub 계정**

### 2. 프로젝트 클론
```bash
# HTTPS (추천)
git clone https://github.com/hajiy25n/VocaBar.git

# 클론 후 Xcode에서 열기
cd VocaBar
open VocaBar.xcodeproj
```

### 3. Xcode에서 빌드
- `Cmd + R` → 빌드 & 실행
- 메뉴바에 VocaBar 아이콘이 뜨면 성공!

---

## 작업 흐름 (매일 반복)

### Step 1: 최신 코드 받기
```bash
git checkout main
git pull origin main
```

### Step 2: 브랜치 만들기
```bash
git checkout -b feature/내가만들기능

# 브랜치 이름 예시:
# feature/search-words    → 단어 검색 기능
# feature/dark-mode       → 다크모드
# fix/quiz-crash          → 퀴즈 크래시 수정
# design/new-icons        → 새 아이콘 디자인
```

### Step 3: 코딩하기
Xcode에서 작업 후 저장

### Step 4: 변경사항 저장 (커밋)
```bash
# 변경된 파일 확인
git status

# 변경사항 스테이징
git add .

# 커밋 (한글 OK!)
git commit -m "퀴즈 결과 화면에 애니메이션 추가"
```

### Step 5: GitHub에 올리기
```bash
git push origin feature/내가만들기능
```

### Step 6: Pull Request 만들기
1. GitHub 웹사이트에서 저장소 방문
2. "Compare & pull request" 버튼 클릭
3. 제목과 설명 작성
4. "Create pull request" 클릭
5. 상대방이 리뷰 후 Merge

---

## 규칙

### 브랜치 규칙
| 브랜치 | 용도 |
|--------|------|
| `main` | 항상 동작하는 안정 버전. **직접 push 금지** |
| `feature/기능명` | 새 기능 작업 |
| `fix/버그명` | 버그 수정 |
| `design/이름` | 디자인/UI 작업 |

### 커밋 메시지 규칙
```
좋은 예:
  "단어 검색 기능 추가"
  "퀴즈에서 타이머 버그 수정"
  "설정 화면 레이아웃 개선"

나쁜 예:
  "수정"
  "ㅎㅎ"
  "asdf"
```

### 충돌 방지
- **같은 파일을 동시에 수정하지 않기** (아래 담당 분류 참고)
- 작업 시작 전 항상 `git pull`
- 작은 단위로 자주 commit (하루 1~3회)

---

## 파일 담당 분류

### 하지연 담당 (로직/데이터)
- `Models/Word.swift`
- `Services/WordRotationService.swift`
- `Services/SampleDataService.swift`
- `Services/OCRService.swift`
- `Views/QuizView.swift` (퀴즈 로직)
- `Resources/toefl_words.json`

### uxer 담당 (UI/디자인)
- `Views/ContentView.swift` (탭 레이아웃)
- `Views/TodayWordsView.swift` (UI 부분)
- `Views/AddWordView.swift` (입력 폼 UI)
- `Views/SettingsView.swift` (설정 UI)
- `Assets.xcassets/` (아이콘, 이미지)

### 공동
- `VocaBarApp.swift`
- `README.md`
- `PRD.md`

---

## 자주 쓰는 Git 명령어

| 상황 | 명령어 |
|------|--------|
| 현재 상태 확인 | `git status` |
| 변경 내용 보기 | `git diff` |
| 모든 변경 스테이징 | `git add .` |
| 커밋 | `git commit -m "메시지"` |
| GitHub에 올리기 | `git push origin 브랜치명` |
| 최신 코드 받기 | `git pull origin main` |
| 브랜치 목록 | `git branch` |
| 브랜치 이동 | `git checkout 브랜치명` |
| 새 브랜치 만들면서 이동 | `git checkout -b 브랜치명` |
| 작업 취소 (커밋 전) | `git checkout -- 파일명` |
| 커밋 히스토리 | `git log --oneline` |

---

## 문제 해결

### "Updates were rejected because the remote contains work"
```bash
git pull origin main --rebase
# 그 다음 다시
git push origin 브랜치명
```

### merge conflict (충돌) 발생
1. 충돌 파일 열기 (<<<< ==== >>>> 표시 있음)
2. 원하는 코드만 남기고 나머지 삭제
3. `git add .` → `git commit -m "충돌 해결"`

### 실수로 main에 직접 커밋함
```bash
# 마지막 커밋을 새 브랜치로 이동
git checkout -b feature/실수한작업
git push origin feature/실수한작업

# main 원복
git checkout main
git reset --hard origin/main
```

---

## uxer 초대 방법
1. GitHub 저장소 > Settings > Collaborators
2. "Add people" 클릭
3. uxer의 GitHub 사용자명 입력
4. uxer가 이메일로 온 초대 수락
5. 이제 uxer도 push/pull 가능!
