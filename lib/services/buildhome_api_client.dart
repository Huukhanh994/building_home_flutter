import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/component_estimate.dart';
import '../models/house_component.dart';
import '../models/house_model_dto.dart';

/// HTTP client for the BuildHome Laravel backend.
///
/// Base URL is configurable via [BuildhomeApiClient.baseUrl].
/// In dev, Herd serves at http://buildhome-api.test
/// In production, set to your deployed API domain.
class BuildhomeApiClient {
  BuildhomeApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Override before first use for staging / prod.
  /// Android emulator: http://10.0.2.2:8000/api/v1
  /// iOS simulator / macOS: http://127.0.0.1:8000/api/v1
  /// Physical device: http://<LAN-IP>:8000/api/v1
  static String baseUrl = 'http://192.168.1.130:8000/api/v1';

  static const Duration _timeout = Duration(seconds: 30);

  /// POST /api/v1/component/calculate
  Future<ComponentEstimate> calculateComponent({
    required HouseComponent component,
    String houseType = 'thai_roof',
    int floors = 1,
    String location = 'default',
  }) async {
    final uri = Uri.parse('$baseUrl/component/calculate');

    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode({
            'component':  component.id,
            'area':       component.area,
            'house_type': houseType,
            'floors':     floors,
            'location':   location,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body),
      );
    }

    return _parseEstimate(component, jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// GET /api/v1/house-models
  Future<List<HouseModelDto>> fetchHouseModels() async {
    final uri = Uri.parse('$baseUrl/house-models');
    final response = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body),
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final list = body['data'] as List<dynamic>;
    return list
        .cast<Map<String, dynamic>>()
        .map(HouseModelDto.fromJson)
        .toList();
  }

  // ── Parsing ───────────────────────────────────────────────────────────────

  ComponentEstimate _parseEstimate(
      HouseComponent component, Map<String, dynamic> json) {
    final mat  = json['materials'] as Map<String, dynamic>;
    final cost = json['cost']      as Map<String, dynamic>;
    final meta = json['meta']      as Map<String, dynamic>;

    return ComponentEstimate(
      component: component,
      materials: ComponentMaterials(
        cement:   (mat['cement']    as num).toDouble(),
        sand:     (mat['sand']      as num).toDouble(),
        steel:    (mat['steel']     as num).toDouble(),
        brick:    (mat['brick']     as num).toDouble(),
        concrete: (mat['concrete']  as num).toDouble(),
        roofTile: (mat['roof_tile'] as num).toDouble(),
      ),
      cost: ComponentCost(
        materialCost: (cost['material_cost'] as num).toDouble(),
        laborCost:    (cost['labor_cost']    as num).toDouble(),
      ),
      calculationVersion: meta['calculation_version'] as String? ?? 'v1.0',
    );
  }

  String _parseErrorMessage(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      if (json['message'] != null) return json['message'] as String;
      final errors = json['errors'] as Map<String, dynamic>?;
      return errors?.values.first?.toString() ?? 'Lỗi không xác định';
    } on Exception {
      return 'Lỗi kết nối máy chủ';
    }
  }

  void dispose() => _client.close();
}

class ApiException implements Exception {
  const ApiException({required this.statusCode, required this.message});

  final int    statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
