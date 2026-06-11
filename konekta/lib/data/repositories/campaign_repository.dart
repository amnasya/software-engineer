import '../../core/api_client.dart';
import '../models/campaign.dart';

class Applicant {
  final int id;
  final int influencerId;
  final String name;
  final String? username;
  final String? avatarUrl;
  final String? niche;
  final int? followersCount;
  final double? engagementRate;
  final String? message;
  final num? proposedRate;
  final String status;

  Applicant({
    required this.id,
    required this.influencerId,
    required this.name,
    this.username,
    this.avatarUrl,
    this.niche,
    this.followersCount,
    this.engagementRate,
    this.message,
    this.proposedRate,
    required this.status,
  });

  factory Applicant.fromJson(Map<String, dynamic> json) {
    num? _n(dynamic v) {
      if (v == null) return null;
      if (v is num) return v;
      return num.tryParse(v.toString());
    }
    return Applicant(
      id: (_n(json['id']) ?? 0).toInt(),
      influencerId: (_n(json['influencer_id']) ?? 0).toInt(),
      name: (json['name'] ?? '') as String,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      niche: json['niche'] as String?,
      followersCount: _n(json['followers_count'])?.toInt(),
      engagementRate: _n(json['engagement_rate'])?.toDouble(),
      message: json['message'] as String?,
      proposedRate: _n(json['proposed_rate']),
      status: (json['status'] ?? 'pending') as String,
    );
  }
}

class CampaignRepository {
  final ApiClient api;
  CampaignRepository(this.api);

  Future<List<Campaign>> listOffers({
    String role = 'influencer',
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final data = await api.get('/offers', query: {
      'role': role,
      if (status != null && status.isNotEmpty) 'status': status,
      'page': page,
      'limit': limit,
    });
    final list = (data as List).cast<Map>();
    return list.map((e) => Campaign.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<Campaign> offer(int id) async {
    final data = await api.get('/offers/$id');
    return Campaign.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<Campaign> create(Map<String, dynamic> body) async {
    final data = await api.post('/offers', body);
    return Campaign.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<List<Applicant>> listApplicants(int offerId) async {
    final data = await api.get('/offers/$offerId/applicants');
    final list = (data as List).cast<Map>();
    return list.map((e) => Applicant.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> setApplicantStatus(int offerId, int appId, String status) async {
    await api.patch('/offers/$offerId/applicants/$appId/status', {'status': status});
  }

  Future<void> apply(int offerId, {String? message}) async {
    await api.post('/offers/$offerId/applicants', {
      if (message != null && message.isNotEmpty) 'message': message,
    });
  }
}
