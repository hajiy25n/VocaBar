# VocaBar 프로젝트 규칙

## 프로젝트 위치
- 소스코드: `/Users/hajiyeon/Desktop/하지연/VocaBar/`
- PRD: `/Users/hajiyeon/Desktop/하지연/VocaBar/PRD.md`
- 배포 zip: `/Users/hajiyeon/Desktop/하지연/VocaBar-v{버전}.zip`

## PRD 자동 업데이트 규칙
VocaBar 코드를 수정할 때마다 **반드시** 다음을 수행할 것:

1. **버전 히스토리 추가**: PRD.md의 "10. 버전 히스토리" 섹션에 새 버전 행 추가
   - 형식: `| v{버전} | {날짜} | {주요 변경 요약} |`
2. **변경된 기능 반영**: 기능이 추가/수정/삭제되면 해당 섹션(3~6번)도 업데이트
3. **로드맵 정리**: 구현 완료된 항목은 로드맵에서 체크 처리 `[x]`
4. **zip 파일 생성**: 빌드 성공 시 새 버전 zip을 `하지연` 폴더에 생성하고, 이전 zip은 삭제할지 사용자에게 확인

## 빌드/배포
- Xcode 프로젝트: `/Users/hajiyeon/Desktop/하지연/VocaBar/VocaBar.xcodeproj`
- 빌드 후 앱 위치: Xcode DerivedData 내 `Build/Products/Debug/VocaBar.app`
- 빌드 명령: `xcodebuild -project VocaBar.xcodeproj -scheme VocaBar -configuration Debug build`

## 기술 스택
- Swift + SwiftUI + SwiftData + Vision Framework
- macOS 14+ (MenuBarExtra .window 스타일)
- 메뉴바 전용 앱 (LSUIElement=YES)
