// test-function.js
const { initializeApp } = require("firebase/app");
const { getFunctions, connectFunctionsEmulator, httpsCallable } = require("firebase/functions");

// Firebase 초기화 (프로젝트 ID만 필요)
const app = initializeApp({ projectId: "weathercloset-b7a14" });
const functions = getFunctions(app);

// 로컬 에뮬레이터에 연결
connectFunctionsEmulator(functions, "127.0.0.1", 5001);

// 함수 호출
const analyzeMemo = httpsCallable(functions, "analyzeMemo");
analyzeMemo({memoText: "하늘을 날 수 있다면 참 좋겠구나야", categories: ["아이디어", "공부", "참조", "회고"]})
    .then((result) => {
      console.log("성공:", result.data);
    })
    .catch((error) => {
      console.error("오류:", error);
    });

// const testEcho = httpsCallable(functions, "testEcho");
// testEcho({
//   echo: "테스트 메모 내용"
// })
// .then(result => {
//   console.log("성공:", result.data);
// })