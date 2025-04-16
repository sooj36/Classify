// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const {logger} = require("firebase-functions/logger");
const {onRequest} = require("firebase-functions/v2/https");

// The Firebase Admin SDK to access Firestore.
const {initializeApp} = require("firebase-admin/app");

// Google Generative AI SDK for Gemini
const genai = require("@google/genai");

// Initialize Firebase Admin
initializeApp();

// 메모 분석 함수
exports.analyzeMemo = onRequest({
  cors: true,
  // 환경 변수 접근 설정
  secrets: ["GEMINI_API_KEY"],
}, async (request, response) => {
  try {
    // POST 요청으로부터 데이터 추출
    const {memoText, categories} = request.body;

    if (!memoText) {
      response.status(400).json({error: "메모 내용이 필요합니다."});
      return;
    }

    // 카테고리가 없으면 기본값 설정
    const memoCategories = categories || ["할 일", "공부", "아이디어"];

    // 환경 변수에서 API 키 가져오기
    const apiKey = process.env.GEMINI_API_KEY;

    if (!apiKey) {
      logger.error("Gemini API 키가 설정되지 않았습니다.");
      response.status(500).json({
        error: "서버 구성 오류: API 키가 없습니다.",
        category: memoCategories[0],
        title: "처리 실패한 메모",
        content: memoText,
        tags: [],
      });
      return;
    }

    // Gemini 클라이언트 초기화
    const ai = new genai.GoogleGenAI({apiKey});

    // 프롬프트 구성
    const prompt = `
      아래의 메모를 분류해줘
      ${memoText}
      분류할 수 있는 카테고리는 다음과 같아
      ${memoCategories} 중 하나로 분류해야 해.
      그리고 10자 이내의 적절한 제목도 붙여줘야 해.
      또한 메모 원문을 그대로 복사해서 붙여넣어야 해.
      마지막으로 1개에서 3개의 태그를 붙여야 해.
      특히 조심해. 아래의 JSON 형식은 말 그대로 예시일 뿐이고
      네가 적절히 판단해서 최적의 태그 갯수를 산정한 다음에 태그를 붙이도록 해.
      그리고 마지막으로 메모 원문을 보고 카테고리가 공부라고 판단했을 경우
      이 내용을 가지고 복습이 가능하도록 질문을 하나 만들어줘.
      아래와 같이 JSON 형식으로 답변할 수 있도록 해
      {
        "category": "카테고리",
        "title": "제목",
        "content": "메모 원문",
        "tags": ["태그1", "태그2", ...],
        "question": "content 내용으로 만든 질문"
      }
    `;

    try {
      // Gemini API 호출
      const responseAi = await ai.models.generateContent({
        model: "gemini-2.0-flash",
        contents: prompt,
      });

      let responseText = responseAi.text || "";

      // JSON 형식 정제
      responseText =
      responseText.replaceAll("```json", "").replaceAll("```", "");

      // JSON 파싱 및 유효성 검사
      let parsedResponse;
      try {
        // 유효한 JSON인지 확인
        if (!responseText.trim().startsWith("{") ||
          !responseText.trim().endsWith("}")) {
          throw new Error("유효하지 않은 JSON 형식");
        }

        parsedResponse = JSON.parse(responseText);

        // 필수 필드 검증
        if (!parsedResponse.category || !parsedResponse.title ||
          !parsedResponse.content) {
          throw new Error("필수 필드 누락");
        }
      } catch (error) {
        logger.error("JSON 파싱 오류", error);
        // 기본값으로 대체
        parsedResponse = {
          category: memoCategories[0],
          title: "기본 제목",
          content: memoText,
          tags: [],
          question: "",
        };
      }

      // 응답 전송
      logger.info("메모 분석 완료", {structuredData: true});
      response.json(parsedResponse);
    } catch (apiError) {
      logger.error("Gemini API 호출 오류", apiError);
      response.status(500).json({
        error: "AI 서비스 호출 중 오류가 발생했습니다: " + apiError.message,
        category: memoCategories[0],
        title: "처리 실패한 메모",
        content: memoText,
        tags: [],
      });
    }
  } catch (error) {
    logger.error("메모 분석 중 오류 발생", error);
    response.status(500).json({
      error: error.message,
      category: request.body.categories[0] || "할 일",
      title: "처리 실패한 메모",
      content: request.body.memoText || "",
      tags: [],
    });
  }
});

// 테스트용 기본 함수
exports.helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});
