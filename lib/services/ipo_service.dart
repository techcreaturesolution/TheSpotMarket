import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/models.dart';
import 'sample_data.dart';

class IpoFeed {
  const IpoFeed({required this.ipos, required this.isLive});
  final List<Ipo> ipos;
  final bool isLive;
}

/// IPO calendar + subscription figures.
///
/// There is no free, official IPO API in India, so the app expects a small
/// backend (`BACKEND_URL/ipos`) that scrapes NSE/BSE/Chittorgarh and returns
/// the JSON shape in `Ipo.fromJson`. Without it, bundled sample data is shown.
class IpoService {
  IpoService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<IpoFeed> fetchIpos() async {
    if (AppConfig.backendBaseUrl.isNotEmpty) {
      try {
        final res = await _client
            .get(Uri.parse('${AppConfig.backendBaseUrl}/ipos'))
            .timeout(const Duration(seconds: 12));
        if (res.statusCode == 200) {
          final list = (jsonDecode(res.body) as List)
              .cast<Map<String, dynamic>>()
              .map(Ipo.fromJson)
              .toList();
          return IpoFeed(ipos: _sorted(list), isLive: true);
        }
      } catch (_) {}
    }
    return IpoFeed(ipos: _sorted(SampleData.ipos()), isLive: false);
  }

  List<Ipo> _sorted(List<Ipo> list) {
    const order = {
      IpoStatus.open: 0,
      IpoStatus.upcoming: 1,
      IpoStatus.closed: 2,
      IpoStatus.listed: 3,
    };
    list.sort((a, b) {
      final s = order[a.status]!.compareTo(order[b.status]!);
      return s != 0 ? s : a.openDate.compareTo(b.openDate);
    });
    return list;
  }
}
