import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weathercloset/data/repositories/cloth_analyze/cloth_repository.dart';
import 'package:weathercloset/data/services/gemini_service.dart';
import 'package:weathercloset/domain/models/cloth/cloth_model.dart';
import 'dart:convert';
import 'package:weathercloset/data/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:weathercloset/data/services/hive_service.dart';
import 'package:uuid/uuid.dart';
import 'package:weathercloset/data/services/runware_service.dart';
import 'package:weathercloset/data/services/klingai_service.dart';
import 'package:weathercloset/data/services/comfyicu_service.dart';
import 'package:flutter/services.dart';
import 'package:weathercloset/data/services/image_storage_service.dart';

/*
  [기본 가이드]
  ClothRepository에서는 [데이터 변환이 빈번하게 발생]하므로 아래 개념을 정확히 이해해야 함:
   - Map: 키-값 쌍을 저장하는 자료구조
   - map(): 데이터를 변환하는 메서드(원본 데이터는 유지되고 새로운 컬렉션 반환)
   - Entry: Map의 각 키-값 쌍을 나타내는 단위
   예: map.entries.map((e) => ...) 
      => Map 자료구조의 각 Entry에 대해 map 메서드가 인자로 받는 변환 함수 적용
*/


class ClothRepositoryRemote extends ClothRepository {
  final GeminiService _geminiService;
  final ImagePicker _picker;
  final FirestoreService _firestoreService;
  final HiveService _hiveService;
  final RunwareService _runwareService;
  final KlingService _klingService;
  final ComfyICUService _comfyICUService;
  final ImageStorageService _imageStorageService;
  ClothRepositoryRemote({
    required GeminiService geminiService,
    required FirestoreService firestoreService,
    required HiveService hiveService,
    required RunwareService runwareService,
    required KlingService klingService,
    required ComfyICUService comfyICUService,
    required ImageStorageService imageStorageService,
  }) : _geminiService = geminiService,
       _picker = ImagePicker(),
       _firestoreService = firestoreService,
       _hiveService = hiveService,
       _runwareService = runwareService,
       _klingService = klingService,
       _comfyICUService = comfyICUService,
       _imageStorageService = imageStorageService;

  @override
  Future<bool> requestPermissions() async {
    final camera = await Permission.camera.request();
    final storage = await Permission.storage.request();
    return camera.isGranted && storage.isGranted;
  }

  @override
  Future<ClothModel> getImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    final bytes = await image?.readAsBytes();
    final response = await analyzeImage(bytes);
    return ClothModel(file: image, response: response);
  }

  @override
  Future<ClothModel> getImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    final bytes = await image?.readAsBytes();
    final response = await analyzeImage(bytes);

    // 인물 모델 이미지 로드
    final ByteData humanBytes = await rootBundle.load('assets/woman_model.jpg');
    final humanBase64 = base64Encode(humanBytes.buffer.asUint8List());
    
    // 선택된 의류 이미지를 base64로 변환
    final clothBase64 = base64Encode(bytes!);

    // 가상 피팅 API 호출
    final imageURL = await _klingService.virtualTryOn(
      humanImageBase64: humanBase64,
      clothImageBase64: clothBase64,
    );

    // 가상 피팅 이미지에서 옷 이미지"만" 추출
    final resultURL = await _comfyICUService.processImage(imageURL);

    return ClothModel(
      file: image, 
      response: response,
      imageUrl: resultURL,
    );
  }

  @override
  Future<String> analyzeImage(Uint8List? bytes) async {
    return await _geminiService.analyzeImage(bytes);
  }

  @override
  Future<void> saveCloth(ClothModel cloth) async {
    String cleanJson = cloth.response!
    .replaceAll("```json", "")
    .replaceAll("```", "");

    final responseMap = jsonDecode(cleanJson);

    final uuid = const Uuid().v4();

    // comfyicu에서 다운로드받은 최종 옷 이미지를 로컬(앱 내부)에 저장
    final localImagePath = await _imageStorageService.downloadAndSaveImage(cloth.imageUrl!);

    // 로컬에 저장된 최종 옷 이미지의 경로를 포함한 cloth 객체를 다시 생성
    final hiveCloth = ClothModel(
      id: cloth.id,
      major: responseMap["대분류"],
      minor: responseMap["소분류"],
      color: responseMap["색깔"],
      material: responseMap["재질"],
      localImagePath: localImagePath,
      response: cloth.response!
    );

    // localimagepath를 추가한 새 cloth 객체 생성(객체의 불변성 유지를 위해) 
    // final clothWithLocalPath = cloth.copyWith(localImagePath: localImagePath);


    _hiveService.saveCloth(hiveCloth, uuid);
    debugPrint("✅ hive 옷 저장 성공!");

    await _firestoreService.saveCloth(responseMap, XFile(localImagePath), uuid);
    debugPrint("✅ firestore 옷 저장 성공!");
  }

  @override
  Stream<List<ClothModel>> watchClothRemote() {
    final clothStream = _firestoreService.watchCloth();
    
    return clothStream.map(
      (snapshot) {
      return snapshot.docs.map(
          (doc) {
         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        debugPrint("✅ 옷 데이터 체크! - clothrepositoryremote - ${data["대분류"]}");
        debugPrint("✅ 옷 데이터 체크! - clothrepositoryremote - ${data["소분류"]}");
        debugPrint("✅ 옷 데이터 체크! - clothrepositoryremote - ${data["색깔"]}");
        debugPrint("✅ 옷 데이터 체크! - clothrepositoryremote - ${data["재질"]}");
        debugPrint("✅ 옷 데이터 체크! - clothrepositoryremote - ${data["imagePath"]}");
        return ClothModel(
          id: doc.id,
          major: data["대분류"] as String? ?? "",
          minor: data["소분류"] as String? ?? "",
          color: data["색깔"] as String? ?? "",
          material: data["재질"] as String? ?? "",
          remoteImagePath: data["imagePath"] as String? ?? "",
          );
        }
      )
      .toList();
    });
  }

  @override
  Stream<Map<String, ClothModel>> watchClothLocal() {
    return _hiveService
      .watchCloths()
      .map((map) {
        return Map.fromEntries(
          map.entries.map((e) {
            final cloth = e.value as ClothModel; // Hive에서 가져온 value를 ClothModel로 캐스팅
            return MapEntry(
              e.key.toString(),
              cloth.copyWith(id: e.key.toString()),
            );
          }),
        );
      }).asBroadcastStream();
  }

  @override
  Future<String> requestCoordi(Map<String, dynamic> request) async {
    final response = await _geminiService.requestCoordi(request);
    response.replaceAll("```json", "");
    response.replaceAll("```", "");
    return response;
  }

  @override
  List<ClothModel> getCoordiClothes(String response, Map<String, ClothModel> cachedClothes) {
    response.replaceAll("```json", "");
    response.replaceAll("```", "");
    final responseMap = jsonDecode(response);

    final uuidMap = responseMap["uuid"] as Map<String, dynamic>;
    final uuidList = uuidMap.values.toList();

    final coordiClothes = uuidList.map((e) => cachedClothes[e]!).toList();
    return coordiClothes;
  }

  @override
  String getCoordiTexts(String response) {
    final responseMap = jsonDecode(response);
    final reason = responseMap["이유"] as String? ?? "";
    return reason;
  }

    @override
    Future<String> getFinalCoordiImage(List<ClothModel> coordiClothes) async {
    final Map<String, String> clothMap = {
      for (var cloth in coordiClothes)
        if (cloth.major != null && cloth.response != null)
          cloth.major!: cloth.response!
    };

    final String clothesDetail = clothMap.entries
        .map((e) => '{${e.key}: ${e.value}}')
        .join(', ');

    //캐릭터가 코디를 실제로 입은 모습의 이미지를 생성하려면 세 가지 정보를 positivePrompt에 합쳐서 보내야 함
    //이미지 생성 프롬프트 템플릿 + 옷의 대분류 & 옷 묘사문 + seed값(나중에 추가할 예정)
    final positivePrompt = '''
    [Base Character Template]
    Young woman in her 20s, full body front view from head to toe. 
    Natural standing pose with arms slightly away from body. 
    Neutral face expression with shoulder-length black hair. 
    Clean detailed style, neutral lighting. 
    Complete figure with all body parts visible. 
    Flat colour anime style.

    [Outfit Description]
    Wearing: {
      $clothesDetail
    }
    ''';
    final response = await _runwareService.generateImage(positivePrompt);
    return response;
  }

  @override
  Future<void> deleteCloth(String clothId) async {
    _hiveService.deleteCloth(clothId);
    debugPrint("✅ hive 옷 삭제 성공!");
    await _firestoreService.deleteCloth(clothId);
    debugPrint("✅ firestore 옷 삭제 성공!");
  }
} 