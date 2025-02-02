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
  "system": "너는 세계 최고의 의류 분석가야. 그 어떤 옷도 아래의 기준을 통해서 완벽하게 분류해낼 수 있어.",
  "task": "내가 준 사진을 분석한 후 내가 준 분류 데이터셋을 바탕으로 옷 대분류, 옷 소분류, 재질, 색깔 이 4가지 데이터를 json 형태로 답변해줘. 네가 반환하는 json 객체는 단순 property가 4개가 있는 구조여야 해. ",
  "output_format": {
    "type": "json",
    "structure": {
      "대분류": "string",
      "소분류": "string",
      "재질": "string",
      "색깔": "string"
    }
  },
  "classification_criteria": {
    "상의": ["티셔츠", "긴팔 티", "민소매 티", "카라 티", "캐미솔/탱크탑", "크롭탑", "블라우스", "셔츠", "맨투맨", "후드", "니트", "니트조끼", "스포츠 상의", "바디수트"],
    "원피스": ["캐주얼 원피스", "티셔츠 원피스", "셔츠 원피스", "맨투맨/후드 원피스", "니트 원피스", "자켓 원피스", "멜빵 원피스", "점프수트", "파티/이브닝 원피스", "미니 원피스"],
    "바지": ["청바지", "긴바지", "정장바지", "운동복", "레깅스", "반바지"],
    "치마": ["미니스커트", "롱스커트"],
    "아우터": ["코트", "트렌치", "털코트", "무스탕", "블레이저", "자켓", "블루종", "야구잠바", "트러커", "라이더 자켓", "가디건", "집업", "야상", "스포츠 아우터", "후리스", "파카", "경량 패딩", "패딩", "조끼"],
    "신발": ["스니커즈", "슬립온", "운동화", "등산화", "부츠", "워커", "어그부츠", "로퍼/블로퍼", "보트/모카슈즈", "플랫슈즈", "힐", "샌들", "샌들힐", "슬리퍼", "뮬 힐"],
    "가방": ["토트백", "숄더백", "크로스백", "웨이스트백", "에코백", "백팩", "보스턴백", "클러치백", "서류가방", "짐색", "캐리어"],
    "모자": ["캡", "햇", "비니", "베레모", "페도라", "썬햇"]
  }
}
''';
