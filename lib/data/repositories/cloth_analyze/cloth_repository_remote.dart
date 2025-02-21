import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weathercloset/data/repositories/cloth_analyze/cloth_repository.dart';
import 'package:weathercloset/data/services/gemini_service.dart';
import 'package:weathercloset/domain/models/cloth/cloth_model.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:weathercloset/data/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:weathercloset/data/services/hive_service.dart';
import 'package:uuid/uuid.dart';
import 'package:weathercloset/data/services/runware_service.dart';
class ClothRepositoryRemote extends ClothRepository {
  final GeminiService _geminiService;
  final ImagePicker _picker;
  final FirestoreService _firestoreService;
  final HiveService _hiveService;
  final RunwareService _runwareService;
  ClothRepositoryRemote({
    required GeminiService geminiService,
    required FirestoreService firestoreService,
    required HiveService hiveService,
    required RunwareService runwareService,
  }) : _geminiService = geminiService,
       _picker = ImagePicker(),
       _firestoreService = firestoreService,
       _hiveService = hiveService,
       _runwareService = runwareService;

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
    return ClothModel(file: image, response: response);
  }

  @override
  Future<String> analyzeImage(Uint8List? bytes) async {
    return await _geminiService.analyzeImage(bytes);
  }

  @override
  Future<void> saveCloth(ClothModel cloth) async {
    // 옷 데이터 정리
    String cleanJson = cloth.response!
    .replaceAll("```json", "")
    .replaceAll("```", "");
    final responseMap = jsonDecode(cleanJson);

    final hiveCloth = ClothModel(
      id: cloth.id,
      major: responseMap["대분류"],
      minor: responseMap["소분류"],
      color: responseMap["색깔"],
      material: responseMap["재질"],
      localImagePath: cloth.file?.path,
      response: cloth.response!
    );

    final uuid = const Uuid().v4();

    //hive에 저장(hive에는 직접적인 이미지 파일 저장은 불가하기 때문에 이미지 경로만 저장)
    _hiveService.saveCloth(hiveCloth, uuid);
    debugPrint("✅ hive 옷 저장 성공!");

    //firestore에 저장
    await _firestoreService.saveCloth(responseMap, cloth.file!, uuid);
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
          .map(
            (map) {
              
              return Map.fromEntries(
                map.entries.map((e) => MapEntry(
                  e.key.toString(),
                  e.value as ClothModel,
                )),
              );
            }
          ).asBroadcastStream();
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

    // 단순히 말해 map 메서드는 iterable을 대상으로 foreach를 돌리는 것이라고 생각하면 됨
    final coordiClothes = uuidList.map((e) => cachedClothes[e]!).toList();
    return coordiClothes;
  }

  @override
  String getCoordiTexts(String response) {
    final responseMap = jsonDecode(response);
    final reason = responseMap["이유"] as String? ?? "";
    return reason;
  }

  //캐릭터가 코디를 실제로 입은 모습의 이미지를 생성하려면
  //세 가지 정보를 합쳐서 보내야 함
  //이미지 생성 템플릿 + 옷의 대분류 & 옷 묘사문 + seed값

    @override
    Future<String> getFinalCoordiImage(List<ClothModel> coordiClothes) async {
    final Map<String, String> clothMap = {
      for (var cloth in coordiClothes)
        if (cloth.major != null && cloth.response != null)
          cloth.major!: cloth.response!
    };

    // 1. entries로 MapEntry 반환
    // [MapEntry(상의, 티셔츠), MapEntry(하의, 청바지)]

    // 2. map으로 각각을 문자열로 변환
    // ["{상의: 티셔츠}", "{하의: 청바지}"]

    // 3. join(', ')으로 하나의 문자열로 합침
    // "{상의: 티셔츠}, {하의: 청바지}"
    final String clothesDetail = clothMap.entries
        .map((e) => '{${e.key}: ${e.value}}')
        .join(', ');
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
} 