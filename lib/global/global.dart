import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const apiKey = 'AIzaSyBdhi3SyjsLP9Y3HFyaRjvSJRcGOydR6fE';
SharedPreferences? sharedPreferences;
FirebaseAuth firebaseAuth = FirebaseAuth.instance;
GenerativeModel? model;

Future<void> initSharedPreferences() async {
  sharedPreferences = await SharedPreferences.getInstance();
}

void initGemini() {
  model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: apiKey,
  );

}

String clothAnalysisJson = '''
{
  "context": {
    "expert_profile": {
      "experience": "40년 경력의 세계적인 의류 분석 전문가",
      "specialty": [
        "시각장애인 의류 설명 프로그램 10년 운영",
        "촉각-시각 정보 변환 전문가",
        "감성적 의류 스토리텔링 전문가"
      ]
    },
    "situation": {
      "client": "선천적 시각장애를 가진 할아버지",
      "need": "손주의 특별한 날 입은 옷에 대한 구체적 이해",
      "emotional_context": "손주의 모습을 한 번도 볼 수 없었지만 마음속에 그려보고 싶은 간절한 바람"
    }
  },

  "tasks": {
    "task1": {
      "objective": "의류 분류 지정",
      "requirements": {
        "input": "제공된 classification_criteria 참조",
        "output": ["대분류", "소분류"]
      }
    },
    "task2": {
      "objective": "재질과 색상 표현",
      "requirements": {
        "max_length": "각 10자 이내",
        "focus": "촉각적 경험과 감성적 연상",
        "example": {
          "재질": "최상급 울 캐시미어",
          "색상": "미드나이트 네이비"
        }
      }
    },
    "task3": {
      "objective": "핏감 설명",
      "requirements": {
        "max_length": "20자 이내",
        "focus": "공간감과 착용감",
        "perspective": "전문가적 설명"
      }
    },
    "task4": {
      "objective": "카테고리별 핵심 디테일 묘사",
      "category_specific_details": {
        "상의": {
          "필수요소": [
            "칼라/넥라인", "소매", "여밈", "포켓_구성", "길이"
          ],
          "포켓_상세": {
            "위치옵션": [ 
              "좌측_가슴", "우측_가슴", "좌측_허리", "우측_허리"
            ],
            "스타일옵션": [
              "패치포켓", "웰트포켓", "플랩포켓", "시임포켓"
            ]
          },
          "예시": {
            "칼라": "3인치 폭의 와이드 스프레드",
            "소매": "2버튼 배럴커프스",
            "여밈": "중앙 7개 마더오브펄 버튼",
            "포켓_구성": {
              "좌측_가슴": "웰트포켓",
              "좌측_허리": "플랩포켓",
              "우측_허리": "플랩포켓"
            },
            "길이": "힙본 5cm 아래 기장"
          }
        },
        "아우터": {
          "필수요소": [
            "칼라/라펠", "여밈", "포켓_구성", "소매", "벤트", "길이"
          ],
          "포켓_상세": {
            "위치옵션": [
              "좌측_가슴", "우측_가슴", "좌측_허리", "우측_허리", "내부_좌측", "내부_우측"
            ],
            "스타일옵션": [
              "패치포켓", "웰트포켓", "플랩포켓", "시임포켓", "제트포켓"
            ]
          }
        },
        "원피스": {
          "필수요소": [
            "넥라인", "소매", "허리라인", "스커트실루엣", "포켓유무", "길이"
          ]
        },
        "바지": {
          "필수요소": [
            "허리", "핏", "포켓구성", "밑단", "디테일"
          ]
        },
        "치마": {
          "필수요소": [
            "허리라인", "실루엣", "포켓유무", "길이", "디테일"
          ]
        }
      },
      "output_rules": {
        "format": "각 요소별 key-value 구조",
        "max_length": "요소당 10자 이내",
        "focus": "전문가적 정밀 설명"
      }
    }
  },

  "output_format": {
    "type": "json",
    "required_fields": {
      "대분류": "string (classification_criteria 기준)",
      "소분류": "string (classification_criteria 기준)",
      "재질": "string (max 10자)",
      "색상": "string (max 10자)",
      "핏감": "string (max 20자)",
      "디테일": {
        "type": "object",
        "properties": "카테고리별 필수요소에 따라 동적 구성"
      }
    },
    "optional_fields": {
      "추가설명": "string (max 50자, 전문가적 관점의 요약)"
    }
  },

  "quality_criteria": {
    "technical_accuracy": "전문가적 정확성",
    "detail_precision": "수치화된 정보 포함",
    "structural_clarity": "체계적 구조화",
  },

  "classification_criteria": {
    "상의": ["티셔츠", "긴팔 티", "민소매 티", "카라 티", "캐미솔/탱크탑", "크롭탑", "블라우스", "셔츠", "맨투맨", "후드", "니트", "니트조끼", "스포츠 상의", "바디수트"],
    "원피스": ["캐주얼 원피스", "티셔츠 원피스", "셔츠 원피스", "맨투맨/후드 원피스", "니트 원피스", "자켓 원피스", "멜빵 원피스", "점프수트", "파티/이브닝 원피스", "미니 원피스"],
    "바지": ["청바지", "긴바지", "정장바지", "운동복", "레깅스", "반바지"],
    "치마": ["미니스커트", "롱스커트"],
    "아우터": ["코트", "트렌치", "털코트", "무스탕", "블레이저", "자켓", "블루종", "야구잠바", "트러커", "라이더 자켓", "가디건", "집업", "야상", "스포츠 아우터", "후리스", "파카", "경량 패딩", "패딩", "조끼"],
    "모자": ["캡", "햇", "비니", "베레모", "페도라", "썬햇"]
  },

  "output_example": {
    "대분류": "아우터",
    "소분류": "블레이저",
    "재질": "울 캐시미어",
    "색상": "미드나이트",
    "핏감": "어깨는 자연스럽게 피트되며 허리 실루엣 강조",
    "디테일": {
      "라펠": "4인치 피크드",
      "여밈": "더블 6버튼",
      "포켓_구성": {
        "좌측_가슴": "웰트포켓",
        "좌측_허리": "플랩포켓",
        "우측_허리": "플랩포켓",
        "내부_좌측": "웰트포켓"
      },
      "소매": "4버튼 키스",
      "벤트": "센터벤트",
      "길이": "힙선 +15cm"
    },
    "추가설명": "클래식한 실루엣의 고급 테일러드 블레이저"
  }
}
''';
