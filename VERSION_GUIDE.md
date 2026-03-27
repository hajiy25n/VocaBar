# VocaBar 버전 관리 & Git 워크플로우 가이드

> 하지연(개발) + uxer(UX 디자인) 두 명이 함께 쓰는 Git 가이드.
> Git 처음이어도 이 문서만 따라하면 된다!

---

## 목차

1. [커밋(Commit) 이란?](#1-커밋commit-이란)
2. [푸시(Push) / 풀(Pull)](#2-푸시push--풀pull)
3. [GitHub에 변경사항 올리는 전체 흐름](#3-github에-변경사항-올리는-전체-흐름)
4. [변경사항 기록 관리](#4-변경사항-기록-관리)
5. [Pull Request(PR) 만들고 리뷰/머지하는 법](#5-pull-requestpr-만들고-리뷰머지하는-법)
6. [브랜치 전략](#6-브랜치-전략)
7. [머지(Merge) 기준](#7-머지merge-기준)
8. [버전 번호 규칙](#8-버전-번호-규칙)
9. [실전 예시: v1.4 올리기](#9-실전-예시-v14-올리기)
10. [자주 하는 실수와 해결법](#10-자주-하는-실수와-해결법)

---

## 1. 커밋(Commit) 이란?

### 한 줄 요약

**커밋 = 게임 세이브 포인트**

게임하다 보스전 전에 세이브하듯이, 코드를 변경한 후 "여기까지 잘 됐어!" 하는 지점에서 저장하는 거다.
나중에 뭔가 잘못되면 이 세이브 포인트로 돌아올 수 있다.

### 커밋하는 법 (단계별)

```bash
# 1단계: 지금 뭐가 바뀌었는지 확인
git status

# 2단계: 바뀐 파일을 "세이브할 목록"에 추가
git add 파일이름.swift          # 특정 파일만
git add .                       # 바뀐 거 전부

# 3단계: 세이브! (메시지와 함께)
git commit -m "퀴즈 자동넘김 기능 추가"
```

### 커밋 메시지 쓰는 법

```
[타입] 설명

예시:
feat: 퀴즈 자동넘김 기능 추가
fix: 학습완료 단어 카운트 버그 수정
design: 하이라이트 고정 높이 적용
docs: README 업데이트
```

| 타입 | 언제 쓰나 | 예시 |
|------|----------|------|
| `feat` | 새 기능 추가 | `feat: 폴더/카테고리 분류` |
| `fix` | 버그 수정 | `fix: 설정 반영 안 되는 버그` |
| `design` | UI/UX 변경 | `design: 메뉴바 아이콘 교체` |
| `docs` | 문서 수정 | `docs: CHANGELOG 업데이트` |
| `refactor` | 코드 정리 (기능 변화 X) | `refactor: WordManager 구조 개선` |

---

## 2. 푸시(Push) / 풀(Pull)

### 푸시(Push) = 내 컴퓨터 → GitHub

내 맥에서 커밋한 걸 GitHub 서버에 올리는 것.
"내가 한 작업을 팀원도 볼 수 있게 업로드한다"고 생각하면 된다.

```bash
git push origin main
```

### 풀(Pull) = GitHub → 내 컴퓨터

GitHub에 있는 최신 변경사항을 내 맥으로 가져오는 것.
"팀원이 올린 작업을 내 컴퓨터에 다운로드한다"고 생각하면 된다.

```bash
git pull origin main
```

### 언제 쓰나?

```
작업 시작 전 → git pull   (최신 상태로 맞추기)
작업 끝난 후 → git push   (내 작업 올리기)
```

> **중요:** 항상 push 전에 pull 먼저 하는 습관을 들이자!

---

## 3. GitHub에 변경사항 올리는 전체 흐름

코드를 수정하고 GitHub에 올리기까지의 전체 순서:

```
코드 수정 → git add → git commit → git pull → git push
```

### 실제 터미널 명령어

```bash
# 0. 작업 시작 전, 최신 코드 받기
git pull origin main

# 1. 코드 수정 (Xcode에서 작업)

# 2. 뭐가 바뀌었는지 확인
git status

# 3. 바뀐 파일 추가
git add .

# 4. 커밋
git commit -m "feat: 퀴즈 진행도 표시 추가"

# 5. 혹시 그 사이에 팀원이 올린 게 있을 수 있으니 한 번 더 풀
git pull origin main

# 6. GitHub에 올리기
git push origin main
```

### 흐름도

```
내 맥(로컬)                          GitHub(원격)
    │                                    │
    │  ← git pull ──────────────────────│  최신 코드 받기
    │                                    │
    │  코드 수정 (Xcode)                 │
    │                                    │
    │  git add .                         │
    │  git commit -m "메시지"             │
    │                                    │
    │  ── git push ─────────────────→   │  코드 올리기
    │                                    │
```

---

## 4. 변경사항 기록 관리

### CHANGELOG.md 사용법

프로젝트 루트에 `CHANGELOG.md` 파일을 만들어서 버전별 변경사항을 기록한다.

**규칙:**
- 새 버전이 위에, 오래된 버전이 아래에 온다
- 변경 유형별로 분류한다:
  - `Added` - 새 기능
  - `Changed` - 기존 기능 변경
  - `Fixed` - 버그 수정
  - `Removed` - 삭제된 기능

**작성 예시:**

```markdown
## [v1.4] - 2026-03-28

### Added
- 폴더/카테고리 분류 기능
- 퀴즈 자동넘김 기능

### Changed
- 이모지 3시간 로테이션으로 변경

### Fixed
- 학습완료 단어 카운트 버그
```

### 커밋 메시지 규칙

위 [1번 섹션](#1-커밋commit-이란)의 커밋 메시지 표 참고.

### GitHub Release 만드는 법

1. GitHub 저장소 페이지에서 오른쪽 **Releases** 클릭
2. **Draft a new release** 버튼 클릭
3. **Tag version**에 `v1.4` 입력
4. **Release title**에 `v1.4 - 폴더 분류 & 퀴즈 개선` 같이 작성
5. 설명에 CHANGELOG 내용 복사 붙여넣기
6. 빌드된 `.zip` 파일이 있으면 하단에 드래그해서 첨부
7. **Publish release** 클릭

또는 터미널에서:

```bash
# 태그 만들기
git tag -a v1.4 -m "v1.4 - 폴더 분류 & 퀴즈 개선"

# 태그 푸시
git push origin v1.4
```

그러면 GitHub에서 태그 기반으로 Release를 자동 생성할 수 있다.

---

## 5. Pull Request(PR) 만들고 리뷰/머지하는 법

PR은 "내가 이런 작업을 했는데, 확인하고 합쳐줘"라는 요청이다.
두 명이 작업할 때 서로의 코드를 확인하는 안전장치 역할을 한다.

### PR 만드는 단계

```bash
# 1. 작업용 브랜치 만들기 (아래 브랜치 전략 참고)
git checkout -b feature/quiz-progress

# 2. 코드 수정 후 커밋
git add .
git commit -m "feat: 퀴즈 진행도 표시"

# 3. 브랜치를 GitHub에 올리기
git push origin feature/quiz-progress
```

4. **GitHub 웹사이트**로 이동
5. 상단에 뜨는 **"Compare & pull request"** 초록 버튼 클릭
6. PR 제목과 설명 작성:
   - 제목: `feat: 퀴즈 진행도 표시 추가`
   - 설명: 뭘 바꿨는지, 왜 바꿨는지 간단히 작성
7. 오른쪽에서 **Reviewers**에 상대방 선택
8. **Create pull request** 클릭

### 리뷰하는 법

1. GitHub에서 PR 페이지 열기
2. **Files changed** 탭에서 바뀐 코드 확인
3. 궁금한 줄에 `+` 버튼 눌러서 코멘트 작성
4. 다 확인했으면 **Review changes** → **Approve** (승인) 선택 후 **Submit review**

### 머지하는 법

1. 리뷰가 끝나면 **Merge pull request** 버튼 클릭
2. **Confirm merge** 클릭
3. (선택) **Delete branch** 눌러서 사용한 브랜치 정리

---

## 6. 브랜치 전략

### 브랜치란?

원본 코드(main)를 건드리지 않고 별도 공간에서 작업하는 것.
실험하다 망해도 원본은 안전하다.

### 브랜치 이름 규칙

| 접두사 | 누가 | 언제 | 예시 |
|--------|------|------|------|
| `feature/` | 하지연 | 새 기능 추가 | `feature/quiz-auto-next` |
| `fix/` | 하지연 | 버그 수정 | `fix/word-count-bug` |
| `design/` | uxer | UI/UX 변경 | `design/menubar-icon` |
| `docs/` | 둘 다 | 문서 작업 | `docs/update-readme` |

### 브랜치 쓰는 법

```bash
# 브랜치 만들고 이동
git checkout -b feature/quiz-progress

# 작업 끝난 후 main으로 돌아가기
git checkout main

# 브랜치 목록 보기
git branch

# 안 쓰는 브랜치 삭제
git branch -d feature/quiz-progress
```

### 언제 브랜치를 만드나?

- **간단한 수정** (오타, 작은 버그): main에 바로 커밋해도 OK
- **새 기능 개발**: 브랜치 만들기
- **큰 UI 변경**: 브랜치 만들기
- **실험적 시도**: 반드시 브랜치 만들기

---

## 7. 머지(Merge) 기준

### 머지 전 체크리스트

- [ ] Xcode에서 빌드가 성공하는가?
- [ ] 기존 기능이 깨지지 않았는가?
- [ ] 커밋 메시지가 규칙에 맞는가?
- [ ] CHANGELOG.md를 업데이트했는가?
- [ ] 상대방이 PR을 리뷰했는가?

### 누가 머지하나?

| 브랜치 유형 | 작업자 | 리뷰어 | 머지하는 사람 |
|------------|--------|--------|-------------|
| `feature/` | 하지연 | uxer | 하지연 |
| `fix/` | 하지연 | uxer | 하지연 |
| `design/` | uxer | 하지연 | uxer |
| `docs/` | 누구든 | 상대방 | 작업자 |

### 머지 타이밍

- PR 만든 후 **최소 1시간** 기다리기 (급할 때는 카톡으로 리뷰 요청)
- 리뷰 코멘트가 있으면 반영 후 머지
- 밤늦게 머지하지 말기 (문제 생기면 다음 날까지 모름)

---

## 8. 버전 번호 규칙

### 기본 구조

```
v주.부.패치
v1.4.1
 │ │ └── 패치: 작은 버그 수정
 │ └──── 부: 새 기능 추가
 └────── 주: 대규모 변경, 호환성 깨질 때
```

### VocaBar 기준

| 변경 유형 | 버전 변경 | 예시 |
|----------|----------|------|
| 새 기능 추가 | 부 버전 +1 | v1.4 → **v1.5** |
| 버그 수정 | 패치 +1 | v1.4 → **v1.4.1** |
| UI만 변경 | 패치 +1 | v1.4 → **v1.4.1** |
| 대규모 개편 | 주 버전 +1 | v1.4 → **v2.0** |
| 단어 데이터 추가 | 부 버전 +1 | v1.4 → **v1.5** |

### 지금까지의 VocaBar 버전 흐름

```
v1.0  최초 빌드
 ↓
v1.1  버그 수정 (설정 반영)
 ↓
v1.2  단어 추가 + 파일 선택 수정
 ↓
v1.3  이모지 로테이션 + 버그 수정 + 랜덤
 ↓
v1.4  폴더 분류 + 퀴즈 개선 + 여러 기능 추가  ← 지금 여기
```

---

## 9. 실전 예시: v1.4 올리기

v1.4에 포함된 변경사항을 GitHub에 올리는 전체 과정:

```bash
# 1. 최신 코드 받기
git pull origin main

# 2. 현재 상태 확인
git status

# 3. 변경된 파일 전부 추가
git add .

# 4. 커밋 (v1.4의 주요 내용을 메시지에)
git commit -m "feat: v1.4 - 폴더 분류, 퀴즈 자동넘김/진행도, 전환 프리셋

- 폴더/카테고리 분류 기능
- 퀴즈 자동넘김, 진행도 표시
- 학습완료 단어 메뉴바 제외
- 하이라이트 고정 높이
- 전환 간격 프리셋
- 100% 달성 축하 효과
- 이모지 3시간 로테이션"

# 5. CHANGELOG.md 업데이트 (이미 했다면 건너뛰기)
# CHANGELOG.md에 v1.4 내용 추가 후:
git add CHANGELOG.md
git commit -m "docs: CHANGELOG v1.4 업데이트"

# 6. GitHub에 올리기
git push origin main

# 7. 태그 만들기
git tag -a v1.4 -m "v1.4 - 폴더 분류 & 퀴즈 개선"
git push origin v1.4

# 8. (선택) 빌드 파일 zip으로 만들어서 GitHub Release에 첨부
# Xcode → Product → Archive → Export
# 그 후 GitHub Releases 페이지에서 업로드
```

---

## 10. 자주 하는 실수와 해결법

### 실수 1: 커밋 메시지 오타

```bash
# 방금 한 커밋 메시지 수정
git commit --amend -m "fix: 올바른 메시지"
```

> 주의: push한 후에는 이 방법 쓰지 말기!

### 실수 2: 커밋에 빠뜨린 파일 있음

```bash
# 빠뜨린 파일 추가 후 직전 커밋에 합치기
git add 빠뜨린파일.swift
git commit --amend --no-edit
```

### 실수 3: git pull 안 하고 push 했더니 에러

```
error: failed to push some refs to ...
hint: Updates were rejected because the remote contains work that you do not have locally.
```

**해결:**

```bash
git pull origin main
# 충돌 없으면 자동 머지됨
git push origin main
```

### 실수 4: 충돌(Conflict) 발생

pull 했는데 같은 파일을 둘 다 수정한 경우:

```
<<<<<<< HEAD
내가 쓴 코드
=======
상대방이 쓴 코드
>>>>>>> origin/main
```

**해결:**
1. 파일을 열어서 `<<<<<<<`, `=======`, `>>>>>>>` 표시를 찾는다
2. 둘 중 맞는 코드를 남기고 나머지와 표시를 삭제한다
3. 저장 후:

```bash
git add 충돌난파일.swift
git commit -m "fix: merge conflict 해결"
git push origin main
```

### 실수 5: 잘못된 파일을 git add 했음

```bash
# 스테이징 취소 (파일 내용은 그대로, add만 취소)
git reset HEAD 파일이름.swift
```

### 실수 6: 방금 커밋을 취소하고 싶음

```bash
# 커밋만 취소 (코드 변경은 유지)
git reset --soft HEAD~1
```

### 실수 7: .DS_Store 같은 쓸데없는 파일이 올라감

`.gitignore` 파일에 추가:

```bash
# .gitignore에 추가
echo ".DS_Store" >> .gitignore
echo "*.xcuserstate" >> .gitignore
echo "xcuserdata/" >> .gitignore

git add .gitignore
git commit -m "docs: gitignore 업데이트"
```

### 실수 8: 어떤 브랜치에 있는지 모르겠음

```bash
# 현재 브랜치 확인
git branch

# main으로 돌아가기
git checkout main
```

---

## 빠른 참조 카드

매일 쓰는 명령어만 모았다:

```bash
git status                    # 현재 상태 확인
git add .                     # 변경 파일 전부 추가
git commit -m "메시지"         # 커밋
git pull origin main          # 최신 코드 받기
git push origin main          # GitHub에 올리기
git checkout -b 브랜치이름     # 새 브랜치 만들기
git checkout main             # main으로 돌아가기
git log --oneline -5          # 최근 커밋 5개 보기
```

---

*이 문서는 VocaBar 프로젝트를 위해 작성되었다. 궁금한 거 있으면 하지연에게 물어보기!*
