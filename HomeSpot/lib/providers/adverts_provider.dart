import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/advert.dart';
import '../services/api.dart';

class AdvertsProvider extends ChangeNotifier {
  List<Advert> _adverts = [];
  AdvertMeta? _meta;
  AdvertFilters _filters = const AdvertFilters();
  bool _loading = false;
  String? _error;

  List<Advert> get adverts => _adverts;
  AdvertMeta? get meta => _meta;
  AdvertFilters get filters => _filters;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetch([AdvertFilters? overrideFilters]) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final params = (overrideFilters ?? _filters).copyWith(page: 1);
      final result = await apiGetAdverts(params);
      _adverts = result.data;
      _meta = result.meta;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMore() async {
    if (_loading) return;
    if (_meta != null && _meta!.page >= _meta!.totalPages) return;
    final nextPage = (_meta?.page ?? 1) + 1;
    _loading = true;
    notifyListeners();
    try {
      final result = await apiGetAdverts(_filters.copyWith(page: nextPage));
      _adverts = [..._adverts, ...result.data];
      _meta = result.meta;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> setFilters(AdvertFilters newFilters) async {
    _filters = newFilters;
    await fetch(_filters);
  }

  Future<void> clearFilters() async {
    _filters = const AdvertFilters();
    await fetch(_filters);
  }

  Future<Advert> create({
    required Map<String, String> fields,
    File? imageFile,
  }) async {
    final advert = await apiCreateAdvert(fields: fields, imageFile: imageFile);
    _adverts = [advert, ..._adverts];
    notifyListeners();
    return advert;
  }

  Future<Advert> update(
    int id, {
    required Map<String, String> fields,
    File? imageFile,
  }) async {
    final advert = await apiUpdateAdvert(id, fields: fields, imageFile: imageFile);
    _adverts = _adverts.map((a) => a.id == id ? advert : a).toList();
    notifyListeners();
    return advert;
  }

  Future<void> remove(int id) async {
    await apiDeleteAdvert(id);
    _adverts = _adverts.where((a) => a.id != id).toList();
    notifyListeners();
  }
}
