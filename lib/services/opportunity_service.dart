import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/opportunity.dart';
import '../models/tag.dart';

class OpportunityService {
  final String baseUrl;
  OpportunityService({required this.baseUrl});

  Future<List<Opportunity>> getOpportunities({int? tagId}) async {
    final response = await http.get(Uri.parse('$baseUrl/opportunities${tagId != null ? '?tag_id=$tagId' : ''}'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Opportunity.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load opportunities');
    }
  }

  Future<List<Tag>> getTags() async {
    final response = await http.get(Uri.parse('$baseUrl/opportunity_tags'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Tag.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load tags');
    }
  }

  Future<Opportunity> createOpportunity(Opportunity opportunity) async {
    final response = await http.post(
      Uri.parse('$baseUrl/opportunities'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(opportunity.toJson()),
    );
    if (response.statusCode == 201) {
      return Opportunity.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create opportunity');
    }
  }

  Future<void> updateOpportunity(Opportunity opportunity) async {
    final response = await http.put(
      Uri.parse('$baseUrl/opportunities/${opportunity.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(opportunity.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update opportunity');
    }
  }

  Future<void> deleteOpportunity(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/opportunities/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete opportunity');
    }
  }
}
