# GNU Smalltalk 프로젝트 분석 보고서

> 분석일: 2026-02-18
> 프로젝트 버전: 3.2.92
> 라이브러리 버전: 8:3:1 (libtool versioning)
> 라이선스: GNU General Public License v2+
> 홈페이지: http://smalltalk.gnu.org/
> 저장소: https://git.savannah.gnu.org/git/smalltalk.git

---

## 1. 프로젝트 개요

GNU Smalltalk은 **Smalltalk-80 언어 사양**의 구현체로, 빠른 프로토타이핑과 스크립팅에 최적화된 프로그래밍 환경이다. Smalltalk에서는 숫자, 메서드, 스택 프레임 등 모든 것이 객체이며, 클래스 브라우저와 포괄적인 시스템 클래스를 제공한다.

### 주요 특징
- Smalltalk-80 완전 호환
- 바이트코드 인터프리터 + 선택적 JIT 컴파일
- FFI (Foreign Function Interface)를 통한 C 라이브러리 연동
- 이미지 기반 객체 영속성 (snapshot save/restore)
- 멀티스레딩 (Process, Semaphore)
- 예외 처리 프레임워크
- 세대별 가비지 컬렉션
- 리플렉션 기능
- 패키지 관리 시스템 (47+ 옵션 패키지)
- 크로스 플랫폼 (Linux, Windows, macOS, BSD)
- Emacs 통합 (smalltalk-mode.el, gst-mode.el)

---

## 2. 주요 기여자

| 이름 | 역할 | 커밋 수 |
|------|------|---------|
| Paolo Bonzini (bonzini@gnu.org) | 현재 메인테이너 (1.6+) | 1,898 |
| Steve Byrne (sbb@gnu.org) | 원 개발자 (1.1.5) | - |
| Holger Hans Peter Freyther | 최근 유지보수 | 194 |
| Gwenael Casaccio | GUI/VisualGST 개발 | 109 |
| Lee Duhem | 기여자 | 20 |
| Mathieu Suen | 기여자 | 12 |

---

## 3. 디렉터리 구조

```
gnu-smalltalk/
├── main.c                  # VM 진입점 (Entry Point)
├── gst-tool.c              # 다목적 CLI 도구
├── smalltalk-mode.el       # Emacs 통합
├── configure.ac            # Autoconf 설정
├── Makefile.am             # Automake 마스터 빌드
├── README                  # 프로젝트 설명
├── COPYING                 # GPLv2 라이선스
├── COPYING.LIB             # LGPL (라이브러리용)
├── COPYING.DOC             # 문서 라이선스
├── AUTHORS                 # 기여자 목록
├── NEWS                    # 릴리스 노트
├── ChangeLog               # 변경 이력 (8,765줄)
├── THANKS                  # 감사 목록 (100+명)
│
├── libgst/                 # 핵심 VM/인터프리터 구현 (~50 C 파일)
│   ├── interp.c            #   바이트코드 인터프리터 (86KB)
│   ├── interp.h            #   인터프리터 헤더
│   ├── interp-bc.inl       #   바이트코드 실행 인라인
│   ├── interp-jit.inl      #   JIT 실행 인라인
│   ├── comp.c              #   Smalltalk 컴파일러 (84KB)
│   ├── lex.c               #   렉서 (어휘 분석)
│   ├── gst-parse.c         #   파서
│   ├── tree.c              #   AST 구성
│   ├── opt.c               #   최적화
│   ├── byte.c / byte.def   #   바이트코드 정의 (46KB)
│   ├── vm.def              #   VM 명령어 정의 (51KB)
│   ├── prims.def           #   프리미티브 정의 (141KB)
│   ├── dict.c              #   딕셔너리/심볼 테이블 (68KB)
│   ├── oop.c / oop.h       #   객체 관리 (63KB)
│   ├── alloc.c / alloc.h   #   메모리 할당
│   ├── heap.c / heap.h     #   힙 관리 (mmap 기반)
│   ├── save.c / save.h     #   이미지 저장/로드 (27KB)
│   ├── callin.c / callin.h #   C→Smalltalk FFI (26KB)
│   ├── cint.c / cint.h     #   Smalltalk→C 인터페이스
│   ├── sym.c               #   심볼 관리
│   ├── xlat.c / xlat.h     #   JIT 코드 변환
│   ├── jitpriv.h           #   JIT 내부 구조
│   ├── gstpriv.h           #   VM 전역 헤더
│   ├── gst.h               #   공개 API 헤더
│   └── sysdep/             #   플랫폼별 코드
│       ├── posix/          #     POSIX (events, files, mem, signals, time, timer)
│       ├── win32/           #     Windows
│       └── cygwin/          #     Cygwin
│
├── kernel/                 # Smalltalk 핵심 클래스 (130+ .st 파일)
│   ├── Object.st           #   최상위 객체 클래스
│   ├── Behavior.st         #   클래스 시스템 기반
│   ├── Class.st            #   구체 클래스
│   ├── Metaclass.st        #   메타클래스
│   ├── SmallInt.st         #   정수
│   ├── Float.st            #   부동소수점
│   ├── LargeInt.st         #   큰 정수
│   ├── String.st           #   문자열
│   ├── CharArray.st        #   문자 배열
│   ├── Symbol.st           #   심볼
│   ├── Array.st            #   배열
│   ├── Collection.st       #   컬렉션 (추상)
│   ├── Set.st              #   집합
│   ├── Dictionary.st       #   딕셔너리
│   ├── OrderCollect.st     #   순서 컬렉션
│   ├── BlkClosure.st       #   블록 클로저
│   ├── Process.st          #   프로세스 (동시성)
│   ├── Semaphore.st        #   세마포어
│   ├── Delay.st            #   타이머/지연
│   ├── File.st             #   파일 I/O
│   ├── Stream.st           #   스트림
│   ├── ExcHandling.st      #   예외 처리
│   ├── CObject.st          #   C 객체 래퍼
│   ├── CType.st            #   C 타입 디스크립터
│   ├── CStruct.st          #   C 구조체 매핑
│   └── ... (140+ 클래스)
│
├── lib-src/                # 지원 C 라이브러리 (~77 파일)
│   ├── getopt.c/h          #   명령줄 파싱
│   ├── regex.c/h           #   정규표현식 (104K줄)
│   ├── md5.c/h             #   MD5 해싱
│   ├── obstack.c/h         #   동적 메모리 스택
│   ├── socketx.c/h         #   네트워크 유틸리티
│   └── ...                 #   수학 함수, 이식성 코드
│
├── packages/               # 옵션 패키지 (48 디렉터리)
│   ├── dbi/                #   데이터베이스 인터페이스
│   ├── dbd-mysql/          #   MySQL 드라이버
│   ├── dbd-postgresql/     #   PostgreSQL 드라이버
│   ├── dbd-sqlite/         #   SQLite 드라이버
│   ├── gtk/                #   GTK+ 바인딩
│   ├── cairo/              #   Cairo 2D 그래픽
│   ├── opengl/             #   OpenGL 3D 그래픽
│   ├── glut/               #   GLUT 윈도잉
│   ├── sdl/                #   SDL 멀티미디어 (7 하위 패키지)
│   ├── blox/               #   GUI 프레임워크 (Tk/GTK)
│   ├── seaside/            #   웹 프레임워크 (5 하위 패키지)
│   ├── swazoo-httpd/       #   HTTP 서버
│   ├── httpd/              #   웹 서버
│   ├── xml/                #   XML 처리 (10 하위 패키지)
│   ├── sockets/            #   소켓 통신
│   ├── sunit/              #   단위 테스트 프레임워크
│   ├── glorp/              #   ORM
│   ├── visualgst/          #   GTK 기반 IDE
│   └── ...                 #   i18n, iconv, gdbm, zlib 등
│
├── lightning/              # JIT 컴파일 지원 (GNU Lightning)
│   ├── i386/               #   x86/x86-64 코드 생성
│   ├── ppc/                #   PowerPC 코드 생성
│   ├── sparc/              #   SPARC 코드 생성
│   ├── core-common.h       #   공통 코드 생성기 (27KB)
│   ├── asm-common.h        #   어셈블러 지원
│   └── fp-common.h         #   부동소수점 지원
│
├── superops/               # 바이트코드 슈퍼오퍼레이터 최적화
├── scripts/                # 빌드/유틸리티 스크립트
├── tests/                  # 자동화된 테스트 스위트
├── examples/               # 예제 프로그램 (30+ .st 파일)
├── doc/                    # 문서 (TeXinfo 형식)
├── build-aux/              # 빌드 설정 매크로 (.m4)
├── snprintfv/              # printf 구현 (서브모듈)
└── unsupported/            # 레거시/미지원 예제
```

---

## 4. 빌드 시스템

### 빌드 도구: GNU Autotools (Autoconf 2.63+ / Automake 1.11)

#### 필수 빌드 도구
| 도구 | 용도 |
|------|------|
| GCC | C 컴파일러 (strict 요구) |
| Flex | 어휘 분석기 생성 |
| Bison | 파서 생성기 |
| Gperf | 완벽 해시 함수 생성기 |
| pkg-config | 패키지 설정 |
| Autoconf 2.63+ | configure 스크립트 |
| Automake 1.11+ | Makefile 생성 |
| Libtool | 공유 라이브러리 관리 |
| Gawk | AWK 구현 |
| ZIP (InfoZIP) | 패키지 관리 (필수) |
| Texinfo | 문서 형식 |

#### 핵심 필수 라이브러리
| 라이브러리 | 용도 |
|-----------|------|
| libltdl | Libtool 동적 모듈 로더 (필수) |
| libffi | Foreign Function Interface (필수) |
| libsigsegv | 신호 안전 세그폴트 핸들러 (세대별 GC용, `--disable-generational-gc`로 비활성 가능) |

#### 빌드 명령
```bash
./configure
make
make install
```

#### 주요 configure 옵션
```
--disable-generational-gc    세대별 GC 비활성화 (libsigsegv 불필요)
--without-emacs              Emacs 모드 비활성화
--enable-gtk={yes,no,blox}   GTK 지원 설정
--enable-jit                 JIT 동적 변환 활성화
--disable-dld                런타임 모듈 로딩 비활성화
--enable-checking            런타임 어서션 활성화
--enable-preemption          선점적 멀티태스킹 활성화
--with-imagedir=PATH         이미지 디렉터리 설정
--with-moduledir=PATH        모듈 디렉터리 설정
```

#### 빌드 산출물
| 산출물 | 설명 |
|--------|------|
| `gst` | 메인 VM 실행 파일 |
| `gst-tool` | 다목적 CLI 도구 (아래 별칭 포함) |
| `gst-load` | 패키지 로딩 |
| `gst-package` | 패키지 관리 |
| `gst-reload` | 패키지 재로딩 |
| `gst-sunit` | 단위 테스트 실행 |
| `gst-blox` | GUI 실행 |
| `gst-browser` | 클래스 브라우저 |
| `gst-convert` | 코드 변환 |
| `gst-doc` | 문서 생성 |
| `gst-remote` | 원격 실행 |
| `gst-profile` | 프로파일링 |
| `gst.im` | Smalltalk 이미지 파일 |

---

## 5. VM 아키텍처 상세

### 5.1 시작 시퀀스

```
main() → 인수 파싱 → gst_initialize() → 이미지 로드/빌드
    → 커널 클래스 로드 → 프리미티브 설치 → 프로세스 스케줄러 초기화
    → 바이트코드 인터프리터 실행 또는 대화형 모드 진입
```

주요 플래그:
- `-i`: 이미지를 처음부터 재빌드
- `-I FILE`: 특정 이미지 파일 로드
- `-D/-E`: 선언/실행 추적
- `-q/-V`: 상세도 제어
- `-S`: 종료 전 스냅샷 저장

### 5.2 객체 표현 (OOP 시스템)

#### SmallInteger 인코딩 (Tagged Pointer)
```c
// 최하위 비트 = 1 → SmallInteger
FROM_INT(i) = (OOP)(((intptr_t)(i) << 1) + 1)
TO_INT(oop) = ((intptr_t)(oop) >> 1)
// 범위: 32비트 ±2^30, 64비트 ±2^62
```

#### 일반 객체 (최하위 비트 = 0)
```c
struct oop_s {
    gst_object object;     // 실제 객체 데이터 포인터
    unsigned long flags;   // 메타데이터 플래그
};

// 객체 헤더
#define OBJ_HEADER \
    OOP objSize;           // 워드 단위 크기
    OOP objClass           // 클래스 OOP
```

#### 객체 플래그
| 플래그 | 설명 |
|--------|------|
| `F_REACHABLE` | Mark 단계에서 도달 가능 |
| `F_XLAT` | JIT 변환 사용 가능 |
| `F_OLD` | Old space에 위치 |
| `F_FIXED` | Fixed space에 위치 |
| `F_WEAK` | 약한 참조 |
| `F_READONLY` | 읽기 전용 |
| `F_VERIFIED` | 바이트코드 검증 완료 |

### 5.3 메모리 관리 및 가비지 컬렉션

#### 메모리 공간 구조
```c
struct memory_space {
    heap_data *old, *fixed;        // Old/Fixed 공간
    struct new_space eden;         // 새 객체 할당 공간
    struct surv_space surv[2];     // 생존자 공간 (이중 힙)
    struct oop_s *ot, *ot_base;    // OOP 테이블
    grey_area_list grey_pages;     // Old→New 참조 페이지
};
```

#### 세대별 GC 전략

| 공간 | 설명 | 기본 크기 |
|------|------|----------|
| **Eden** | 새 객체 할당, 빈번한 스캐벤지 | 1-2 MB |
| **Survivor** | 이중 반공간 (even/odd), 테뉴어 전 생존 검증 | 각 512 KB |
| **Old Space** | 테뉴어된 장수 객체, Mark-Sweep 수집 | 4-8 MB |
| **Fixed Space** | 고정 객체, 수집 대상 아님 | 가변 |

#### GC 연산
| 연산 | 알고리즘 | 용도 |
|------|---------|------|
| `_gst_scavenge()` | Cheney 복사 | Eden → Survivor 복사 |
| `_gst_global_gc()` | Mark-Sweep | Old space 전체 수집 |
| `_gst_global_compact()` | Mark-Sweep-Compact | Old space 압축 |
| `_gst_incremental_gc_step()` | 증분 스위프 | 일시 정지 시간 감소 (~100 객체/단계) |

#### OOP 테이블
- 초기 크기: 128K OOP
- 최대: 8M OOP
- 내장: 256 문자 + nil/true/false

### 5.4 바이트코드 인터프리터

#### 인터프리터 레지스터
```c
ip_type ip;                      // 명령어 포인터
OOP *sp;                         // 스택 포인터
OOP _gst_this_context_oop;      // 현재 컨텍스트
gst_compiled_method _gst_this_method;  // 현재 메서드
OOP _gst_self;                  // 수신자 (self)
OOP *_gst_temporaries;          // 메서드 로컬 변수
OOP *_gst_literals;             // 메서드 리터럴
```

#### 실행 컨텍스트
```c
typedef struct gst_method_context {
    OBJ_HEADER;
    OOP parentContext;     // 호출 컨텍스트
    OOP native_ip;         // JIT 오프셋
    OOP ipOffset;          // 바이트코드 오프셋
    OOP spOffset;          // 스택 포인터 오프셋
    OOP receiver;          // self
    OOP method;            // CompiledMethod
    intptr_t flags;        // MCF_* 플래그
    OOP contextStack[1];   // 가변 길이 스택
};
```

#### 메서드 헤더 구조
```c
typedef struct method_header {
    unsigned intMark:1;         // 항상 1 (SmallInteger)
    unsigned numArgs:5;         // 인수 수 (0-31)
    unsigned stack_depth:6;     // 스택 깊이
    unsigned numTemps:6;        // 임시 변수 수 (0-63)
    unsigned primitiveIndex:9;  // 프리미티브 번호
    unsigned isOldSyntax:1;
    unsigned headerFlag:3;      // 반환 최적화 플래그
    unsigned :1;
};
```

반환 최적화:
| 플래그 | 설명 |
|--------|------|
| `MTH_NORMAL` | 일반 바이트코드 실행 |
| `MTH_RETURN_SELF` | self 반환 (바이트코드 없음) |
| `MTH_RETURN_INSTVAR` | 인스턴스 변수 반환 |
| `MTH_RETURN_LITERAL` | 리터럴 반환 |
| `MTH_PRIMITIVE` | 프리미티브 실행 |

#### 바이트코드 명령어 세트

**스택 연산:**
- `PUSH_RECEIVER_VARIABLE(n)` - 인스턴스 변수 접근
- `PUSH_TEMPORARY_VARIABLE(n)` - 로컬 변수
- `PUSH_OUTER_TEMP(n, scopes)` - 클로저 변수
- `PUSH_LIT_VARIABLE(n)` - 리터럴 변수
- `PUSH_INTEGER(n)` - 정수 리터럴
- `PUSH_LIT_CONSTANT(n)` - 리터럴 상수
- `PUSH_SPECIAL(n)` - nil, true, false, self
- `DUP_STACK_TOP` / `POP_STACK_TOP`

**메시지 전송:**
- `SEND(n, super, num_args)` - 일반 메시지
- `SEND_SPECIAL(n)` - 최적화 전송 (#at:, #at:put:, #size)
- `SEND_ARITH(n)` - 산술 연산 (+, -, *, /)
- `SEND_IMMEDIATE(n, super)` - 인라인 캐시 미스

**제어 흐름:**
- `JUMP(ofs)` - 무조건 분기
- `POP_JUMP_TRUE(ofs)` / `POP_JUMP_FALSE(ofs)` - 조건 분기
- `RETURN_METHOD_STACK_TOP` - 메서드 반환
- `RETURN_CONTEXT_STACK_TOP` - 블록 반환
- `EXIT_INTERPRETER` - 실행 종료

**저장:**
- `STORE_RECEIVER_VARIABLE(n)` / `STORE_TEMPORARY_VARIABLE(n)`
- `STORE_OUTER_TEMP(n, scopes)` / `STORE_LIT_VARIABLE(n)`

#### 메서드 캐시
```c
typedef struct method_cache_entry {
    OOP selectorOOP;           // 셀렉터
    OOP startingClassOOP;      // 시작 클래스
    OOP methodOOP;             // 찾은 메서드
    OOP methodClassOOP;        // 메서드 소유 클래스
    method_header methodHeader;
#ifdef ENABLE_JIT_TRANSLATION
    OOP receiverClass;
    PTR nativeCode;
#endif
};
```
- 크기: 2,048 항목
- 해시: 수신자 클래스 + 셀렉터
- 일반 적중률: 95%+

#### 인터프리터 실행 루프
```
1. 바이트코드 Fetch → 2. 인수 Decode → 3. 연산 Execute → 4. 인터럽트 Check
```

### 5.5 컴파일 파이프라인

```
Smalltalk 소스 코드
    ↓ Lexer (lex.c)
어휘 토큰
    ↓ Parser (gst-parse.c)
AST (tree.c)
    ↓ Optimizer (opt.c)
최적화된 AST
    ↓ Bytecode Compiler (comp.c)
CompiledMethod 객체
```

#### CompiledMethod 객체 구조
```c
typedef struct gst_compiled_method {
    OBJ_HEADER;
    OOP literals;              // 리터럴 배열
    method_header header;      // 최적화 플래그
    OOP descriptor;            // 소스/디버그 정보
    gst_uchar bytecodes[1];   // 가변 길이 바이트코드
};
```

### 5.6 JIT 컴파일 (선택적)

GNU Lightning 라이브러리 기반으로 바이트코드를 네이티브 코드로 변환한다.

#### 지원 아키텍처
| 아키텍처 | 디렉터리 |
|---------|---------|
| x86/x86-64 | `lightning/i386/` |
| PowerPC | `lightning/ppc/` |
| SPARC | `lightning/sparc/` |

#### JIT 기능
- 인라인 캐싱: 수신자 클래스→메서드 매핑 캐시
- 다중 특수화: 수신자 클래스별 다른 코드 생성
- 선택적 컴파일: 핫 메서드 우선 컴파일
- 역최적화 검사: 인라인 캐시 가드

### 5.7 FFI (Foreign Function Interface)

#### C→Smalltalk 메시지 전송
```c
OOP _gst_msg_send(OOP receiver, OOP selector, ...);
OOP _gst_vmsg_send(OOP receiver, OOP selector, OOP *args);
OOP _gst_str_msg_send(OOP receiver, const char *sel, ...);
void _gst_msg_sendf(PTR resultPtr, const char *fmt, ...);
```

#### 데이터 타입 변환
```c
// Smalltalk → C
long   _gst_oop_to_int(OOP oop);
double _gst_oop_to_float(OOP oop);
char*  _gst_oop_to_string(OOP oop);

// C → Smalltalk
OOP _gst_int_to_oop(long i);
OOP _gst_float_to_oop(double f);
OOP _gst_string_to_oop(const char *str);
```

#### OOP 레지스트리 (GC 보호)
```c
OOP  _gst_register_oop(OOP oop);         // 루트 셋에 추가
void _gst_unregister_oop(OOP oop);       // 루트 셋에서 제거
```

### 5.8 이미지 시스템 (Snapshot)

#### 이미지 파일 포맷
```
[Bourne Shell 명령]     (64 bytes)
[서명 "GSTIm"]          (6 bytes)
[버전 정보]              (2 bytes)
[플래그 (엔디안/크기)]    (1 byte)
[OOP 테이블]            (바이너리 덤프)
[메모리 공간]            (eden, survivor, oldspace)
```

#### 이미지 헤더 구조
```c
typedef struct save_file_header {
    char dummy[64];              // 실행 가능 래퍼
    char signature[6];           // "GSTIm"
    char flags;                  // 엔디안, 포인터 크기
    size_t version;
    size_t oopTableSize;
    size_t edenSpaceSize;
    size_t survSpaceSize;
    size_t oldSpaceSize;
    size_t big_object_threshold;
    size_t grow_threshold_percent;
    intptr_t prim_table_md5[2];  // 프리미티브 체크섬
};
```

### 5.9 프로세스 스케줄링

#### 우선순위 레벨
- 9단계 (0=최저 ~ 8=최고)
- 사용자 기본 우선순위: 4
- 기본 타임슬라이스: 40ms

#### 스케줄러 구조
```c
typedef struct gst_processor_scheduler {
    OBJ_HEADER;
    OOP processLists;         // 9개 우선순위 큐
    OOP activeProcess;        // 현재 프로세스
    OOP idleTasks;
    OOP processTimeslice;     // 밀리초
    OOP gcSemaphore;
    OOP eventSemaphore;
};
```

#### 동기화 프리미티브
- `_gst_sync_signal()` - 세마포어 시그널
- `_gst_sync_wait()` - 세마포어 대기
- `_gst_async_signal()` - 시그널 핸들러에서 시그널
- `_gst_async_call()` - C 콜백 큐잉

---

## 6. 커널 클래스 계층

```
Object
├── Behavior
│   ├── ClassDescription
│   │   ├── Class
│   │   └── Metaclass
│   └── BlockClosure
├── Magnitude
│   ├── Number
│   │   ├── Integer
│   │   │   ├── SmallInteger
│   │   │   └── LargeInteger
│   │   │       ├── LargePositiveInteger
│   │   │       └── LargeNegativeInteger
│   │   ├── Float
│   │   │   ├── FloatD
│   │   │   ├── FloatE
│   │   │   └── FloatQ
│   │   ├── Fraction
│   │   └── ScaledDecimal
│   ├── Character
│   ├── Date
│   ├── Time
│   └── Association
├── Collection
│   ├── SequenceableCollection
│   │   ├── ArrayedCollection
│   │   │   ├── Array
│   │   │   ├── ByteArray
│   │   │   └── String
│   │   │       └── Symbol
│   │   ├── OrderedCollection
│   │   │   └── SortedCollection
│   │   ├── LinkedList
│   │   │   └── Semaphore
│   │   └── Interval
│   ├── HashedCollection
│   │   ├── Set
│   │   │   └── IdentitySet
│   │   └── Dictionary
│   │       ├── IdentityDictionary
│   │       ├── MethodDictionary
│   │       └── SystemDictionary (Smalltalk)
│   └── Bag
├── Stream
│   ├── ReadStream
│   ├── WriteStream
│   ├── ReadWriteStream
│   └── FileStream
├── Boolean
│   ├── True
│   └── False
├── UndefinedObject (nil)
├── Process
├── CObject (FFI)
│   ├── CType
│   ├── CStruct
│   └── CPtr
├── Message
├── CompiledMethod
├── CompiledBlock
└── ContextPart
    ├── MethodContext
    └── BlockContext
```

---

## 7. 패키지 생태계

### 7.1 패키지 구성 방식

각 패키지는 `package.xml`로 메타데이터를 정의한다:
```xml
<package>
  <name>패키지명</name>
  <namespace>네임스페이스</namespace>
  <prereq>의존 패키지</prereq>
  <filein>소스파일.st</filein>
  <module>네이티브모듈</module>
  <test>테스트클래스</test>
</package>
```

### 7.2 패키지 분류 (48개)

#### 핵심/기반 (8)
| 패키지 | 설명 |
|--------|------|
| Announcements | 이벤트 알림 시스템 |
| Sockets | TCP/IP 소켓 (ObjectDumper 의존) |
| NetClients | 네트워크 클라이언트 (IMAP, POP, SMTP, NNTP, FTP, HTTP) |
| Complex | 복소수 지원 |
| Continuations | 연속(continuation) 지원 |
| Digest | 암호화 다이제스트 (MD5 등) |
| Numerics | 수치 메서드 |
| Regex | 정규표현식 |

#### 데이터베이스 (5)
| 패키지 | 설명 | 의존성 |
|--------|------|--------|
| DBI | 데이터베이스 인터페이스 | ROE |
| DBD-MySQL | MySQL 드라이버 | DBI, Sockets, Digest |
| DBD-PostgreSQL | PostgreSQL 드라이버 | libpq |
| DBD-SQLite | SQLite 드라이버 | sqlite3 |
| GDBM | GNU DB Manager 바인딩 | libgdbm |

#### GUI/그래픽 (13)
| 패키지 | 설명 | 의존성 |
|--------|------|--------|
| GTK | GTK+ 2.0 바인딩 | Cairo, GLib |
| Cairo | 2D 벡터 그래픽 | libcairo |
| GLib | GLib 2.0 지원 | gobject, gthread |
| GObject-Introspection | Introspection 지원 | gobject-introspection-1.0 |
| Blox/Tk | Tcl/Tk GUI | Tcl/Tk |
| Blox/GTK | GTK GUI (실험적) | GTK |
| VisualGST | 전체 IDE | Parser, GTK, Cairo, SUnit, DebugTools |
| OpenGL | 3D 그래픽 | gstopengl.la |
| GLUT | 윈도잉 | gstglut.la |
| SDL/libsdl | 멀티미디어 기반 | SDL 1.2.0+ |
| SDL/image | 이미지 로딩 | SDL_image |
| SDL/mixer | 오디오 믹싱 | SDL_mixer |
| SDL/ttf | 폰트 렌더링 | SDL_ttf |

#### 웹/HTTP (5)
| 패키지 | 설명 |
|--------|------|
| HTTPd | 웹 서버 |
| Swazoo-HTTPD | Swazoo HTTP 서버 |
| Seaside/core | 웹 앱 프레임워크 코어 |
| Seaside/dev | 개발 도구 |
| Seaside/magritte | 폼/필드 설명 프레임워크 |

#### XML (10)
| 패키지 | 설명 |
|--------|------|
| xml/builder | XML 빌더 |
| xml/parser | XML 파서 |
| xml/expat | Expat 통합 (libexpat) |
| xml/dom | DOM API |
| xml/pullparser | Pull 파서 |
| xml/saxdriver | SAX 드라이버 |
| xml/saxparser | SAX 파서 |
| xml/tests | XML 테스트 |
| xml/xpath | XPath 지원 |
| xml/xsl | XSL 지원 |

#### 개발/테스트 (7)
| 패키지 | 설명 |
|--------|------|
| SUnit | 단위 테스트 프레임워크 |
| Debug/DebugTools | 디버거 유틸리티 |
| Debugger | 대화형 디버거 |
| ObjectDumper | 객체 직렬화 |
| Parser (stinst/parser) | Smalltalk 파서 |
| Compiler (stinst/compiler) | Smalltalk 컴파일러 |
| ProfileTools | 프로파일링 |

### 7.3 내부 의존성 그래프 (주요)

```
VisualGST ─→ Parser, GTK, Cairo, SUnit, DebugTools, Announcements
GTK ─→ Cairo, GLib
DBD-MySQL ─→ DBI ─→ ROE
            ─→ Sockets ─→ ObjectDumper
            ─→ Digest
Seaside ─→ Swazoo, Magritte
NetClients ─→ Sockets ─→ ObjectDumper
XML-Expat ─→ XML-SAXParser, XML-PullParser
```

---

## 8. 외부 의존성 전체 목록

### 필수
| 라이브러리 | 용도 |
|-----------|------|
| libltdl | 동적 모듈 로더 |
| libffi | Foreign Function Interface |

### 선택적 - GUI/그래픽
| 라이브러리 | 용도 |
|-----------|------|
| GTK+ 2.0 (atk >= 1.0, pango >= 1.0) | GUI 위젯 |
| Cairo | 2D 벡터 그래픽 |
| GLib 2.0 (gobject, gthread) | 유틸리티 라이브러리 |
| GObject-Introspection 1.0+ | 타입 인트로스펙션 |
| Tcl/Tk | BLOX/Tk GUI |
| SDL 1.2.0+ | 멀티미디어 |
| SDL_image, SDL_mixer, SDL_sound, SDL_ttf | SDL 확장 |
| OpenGL, GLUT | 3D 그래픽 |

### 선택적 - 데이터베이스
| 라이브러리 | 용도 |
|-----------|------|
| libpq | PostgreSQL 클라이언트 |
| mysql | MySQL 클라이언트 |
| sqlite3 | SQLite 3 엔진 |
| libgdbm | GNU 데이터베이스 매니저 |

### 선택적 - 유틸리티
| 라이브러리 | 용도 |
|-----------|------|
| libexpat | XML 파싱 |
| libz (zlib) | 압축 |
| GMP | 다정밀도 산술 |
| Readline | 라인 편집 |
| NCurses | 터미널 제어 |
| GnuTLS | TLS/SSL |
| libsigsegv | 세그폴트 핸들링 (세대별 GC) |

---

## 9. 코드 통계

| 파일 유형 | 수량 |
|----------|------|
| C 소스 파일 (.c) | ~142 (libgst) + ~77 (lib-src) |
| C 헤더 파일 (.h) | ~94 |
| Smalltalk 소스 파일 (.st) | ~912 |
| 정의 파일 (.def) | 3 (byte.def, vm.def, prims.def) |
| Autoconf 매크로 (.m4) | ~20 |
| 빌드 파일 (.am/.in) | ~13 |
| Lightning/JIT 파일 | ~25 |
| **총 소스 파일** | **~1,148+** |

---

## 10. 문서 구조

| 파일 | 설명 | 크기 |
|------|------|------|
| doc/gst.texi | 메인 사용자 가이드 | 199 KB |
| doc/tutorial.texi | 언어 튜토리얼 | 142 KB |
| doc/gst-base.texi | 기본 클래스 문서 | - |
| doc/gst-libs.texi | 라이브러리 참조 | - |
| doc/using-xml.texi | XML 사용 가이드 | - |
| doc/Doxyfile | 소스코드 문서 설정 | - |

---

## 11. CI/CD 구성

Travis CI (`.travis.yml`) 사용:
- GCC 기반 C 빌드
- MySQL/PostgreSQL 데이터베이스 테스트
- 전체 빌드, 테스트, distcheck 사이클

CI 의존성 설치 목록:
```
autotools-dev libreadline-dev libncurses-dev libsdl1.2-dev
libsdl-image1.2-dev libsdl-mixer1.2-dev libsdl-sound1.2-dev
libsdl-ttf2.0-dev libexpat1-dev freeglut3-dev libgmp3-dev
libgdbm-dev libgtk2.0-dev libpq-dev libsigsegv-dev libffi-dev
zip libsqlite3-dev unzip pkg-config libltdl-dev chrpath gawk
libgnutls-dev automake autoconf libtool texinfo texlive
```

---

## 12. 최근 개발 활동

| 날짜 | 커밋 | 내용 |
|------|------|------|
| 2026-01-21 | 768d3ef4 | tutorial.texi: 코드 상속 설명 오타 수정 |
| 2024-03-17 | 4ba653ef | gst-package.m4: autoconf 인용 경고 해결 |
| 2024-03-16 | 7456c7a4 | macos/ffi: 실행 스택 사용 중단 |
| 2024-03-16 | bf3fd4b5 | macos ARM64: 실행 페이지 쓰기 제한 처리 |
| - | d2f0739b | genbc: 다중 정의 오류 처리 |

---

## 13. 아키텍처 다이어그램

```
┌─────────────────────────────────────────────────────┐
│              Main Entry Point (main.c)              │
│         인수 파싱, VM 초기화, 이미지 관리             │
└──────────────────────┬──────────────────────────────┘
                       ↓
┌──────────────────────────────────────────────────────┐
│              Smalltalk 시스템 부트스트랩               │
│  커널 클래스 로드 → 프리미티브 설치 → 스케줄러 초기화   │
└──────────────────────┬───────────────────────────────┘
                       ↓
┌──────────────────────────────────────────────────────┐
│           바이트코드 인터프리터 (interp.c)             │
│  ┌────────────────────────────────────────────────┐  │
│  │  실행 루프: Fetch → Decode → Execute → Check   │  │
│  └────────────────────────────────────────────────┘  │
└───────┬──────────┬──────────┬──────────┬─────────────┘
        │          │          │          │
        ↓          ↓          ↓          ↓
   ┌────────┐ ┌────────┐ ┌────────┐ ┌────────────┐
   │메시지   │ │스택    │ │제어    │ │GC/메모리   │
   │전송     │ │연산    │ │흐름    │ │관리        │
   │(캐시)   │ │(push)  │ │(jump)  │ │            │
   └───┬────┘ └────────┘ └────────┘ └─────┬──────┘
       │                                   │
       ↓                                   ↓
  ┌───────────────┐              ┌──────────────────┐
  │ 메서드 검색    │              │ GC 시스템         │
  │ - 클래스 탐색  │              │ - Scavenge (복사) │
  │ - 딕셔너리 탐색│              │ - Global GC      │
  │ - 캐시 (2048)  │              │ - Compact        │
  └───────────────┘              │ - Incremental    │
       │                         └──────────────────┘
       ↓                                   │
  ┌───────────────┐              ┌──────────────────┐
  │ 프리미티브     │              │ 메모리 공간       │
  │ 실행 (C 함수)  │              │ Eden → Survivor  │
  └───────────────┘              │ → Old → Fixed    │
                                 │ + OOP 테이블      │
                                 └──────────────────┘

  ┌──────────────────────────────────────────────────┐
  │          이미지 I/O (save.c)                      │
  │  스냅샷 저장/로드, 엔디안 변환, 주소 독립성         │
  └──────────────────────────────────────────────────┘

  ┌──────────────────────────────────────────────────┐
  │          FFI (callin.c, cint.c)                   │
  │  C↔Smalltalk 메시지 전송, 타입 마샬링, OOP 레지스트리│
  └──────────────────────────────────────────────────┘

  ┌──────────────────────────────────────────────────┐
  │          JIT (xlat.c + lightning/)                 │
  │  선택적 네이티브 코드 변환 (x86, PPC, SPARC)       │
  └──────────────────────────────────────────────────┘
```

---

## 14. 작업을 위한 핵심 참고 파일

| 용도 | 파일 경로 |
|------|----------|
| VM 진입점 | `main.c` |
| CLI 도구 | `gst-tool.c` |
| 바이트코드 인터프리터 | `libgst/interp.c` (86KB) |
| 객체 관리 | `libgst/oop.c` (63KB) |
| 컴파일러 | `libgst/comp.c` (84KB) |
| 딕셔너리/심볼 | `libgst/dict.c` (68KB) |
| 이미지 I/O | `libgst/save.c` (27KB) |
| FFI | `libgst/callin.c` (26KB) |
| 바이트코드 정의 | `libgst/byte.def` (46KB) |
| VM 명령어 정의 | `libgst/vm.def` (51KB) |
| 프리미티브 정의 | `libgst/prims.def` (141KB) |
| VM 전역 헤더 | `libgst/gstpriv.h` |
| 공개 API | `libgst/gst.h` |
| 빌드 설정 | `configure.ac` |
| 빌드 규칙 | `Makefile.am` |
| 커널 클래스 | `kernel/*.st` (130+ 파일) |
| 패키지 설정 | `packages/*/package.xml` |

---

## 15. 프로젝트 요약

GNU Smalltalk은 **성숙하고 잘 구조화된 Smalltalk-80 구현체**로, C로 작성된 포괄적인 VM (`libgst/`), Smalltalk으로 작성된 광범위한 표준 라이브러리 (`kernel/`), 데이터베이스/웹 프레임워크/그래픽/XML 처리 등을 다루는 47개 이상의 옵션 패키지를 포함한다.

저수준 VM, 유틸리티 라이브러리, 코어 클래스, 옵션 패키지 간의 **깔끔한 분리**를 유지하며, 표준 GNU Autotools 빌드 시스템으로 빌드된다. 태그 정수 인코딩, 세대별 복사 GC, 메서드 캐싱, 선택적 JIT 컴파일 등 다양한 최적화를 통해 이식성과 정확성을 우선하면서도 우수한 성능을 달성한다.
