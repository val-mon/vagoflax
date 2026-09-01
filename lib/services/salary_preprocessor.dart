import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:vagoflax/models/salary_prediction_model.dart';

class SalaryPreprocessor {
  static const String _assetPath = 'assets/ml/preprocessing.json';
  static const String _unknownToken = '__UNKNOWN__';

  late final List<String> _featureNames;
  late final List<String> _scaledNumericColumns;
  late final List<String> _binaryColumns;

  late final Map<String, List<String>> _oneHotCategories;
  late final Map<String, List<String>> _multiHotCategories;

  late final Map<String, double> _numericMeans;
  late final Map<String, double> _numericStds;

  late final bool _scaleNumeric;
  late final bool _addUnknownCategory;

  late final double targetMean;
  late final double targetStd;

  bool _initialized = false;

  bool get isInitialized => _initialized;

  int get inputDimension => _featureNames.length;

  List<String> get featureNames => List.unmodifiable(_featureNames);

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    final rawJson = await rootBundle.loadString(_assetPath);

    final config = jsonDecode(rawJson) as Map<String, dynamic>;

    _featureNames = List<String>.from(config['feature_names'] as List);

    _scaledNumericColumns = List<String>.from(
      config['scaled_numeric_columns'] as List,
    );

    _binaryColumns = List<String>.from(config['binary_columns'] as List);

    _oneHotCategories = _parseCategoryMap(
      config['one_hot_categories'] as Map<String, dynamic>,
    );

    _multiHotCategories = _parseCategoryMap(
      config['multi_hot_categories'] as Map<String, dynamic>,
    );

    _numericMeans = _parseDoubleMap(
      config['numeric_means'] as Map<String, dynamic>,
    );

    _numericStds = _parseDoubleMap(
      config['numeric_stds'] as Map<String, dynamic>,
    );

    _scaleNumeric = config['scale_numeric'] as bool? ?? true;

    _addUnknownCategory = config['add_unknown_category'] as bool? ?? true;

    targetMean = (config['target_mean'] as num).toDouble();
    targetStd = (config['target_std'] as num).toDouble();

    _validateConfiguration();

    _initialized = true;
  }

  List<double> transform(SalaryPredictionInput input) {
    _ensureInitialized();

    final featureValues = <String, double>{};

    final numericValues = <String, double>{
      'MinYearsExperience': input.minYearsExperience,
      'MaxYearsExperience': input.maxYearsExperience,
      'ContractMonths': input.contractMonths,
      'Holidays': input.holidays,
      'WorkloadPercent': input.workloadPercent,
    };

    for (final column in _scaledNumericColumns) {
      final value = numericValues[column];

      if (value == null) {
        throw StateError('Missing numeric value for column $column.');
      }

      featureValues[column] = _scaleNumeric ? _scale(column, value) : value;
    }

    final binaryValues = <String, double>{
      'IsPermanent': input.isPermanent ? 1.0 : 0.0,
    };

    for (final column in _binaryColumns) {
      featureValues[column] = binaryValues[column] ?? 0.0;
    }

    _encodeMultiHot(
      output: featureValues,
      column: 'Diploma',
      values: input.diplomas,
    );

    _encodeOneHot(output: featureValues, column: 'Role', value: input.role);

    _encodeOneHot(
      output: featureValues,
      column: 'Industry',
      value: input.industry,
    );

    _encodeOneHot(output: featureValues, column: 'Canton', value: input.canton);

    _encodeOneHot(
      output: featureValues,
      column: 'CompanySize',
      value: input.companySize,
    );

    _encodeMultiHot(
      output: featureValues,
      column: 'Perks',
      values: input.perks,
    );

    _encodeMultiHot(
      output: featureValues,
      column: 'Languages',
      values: input.languages,
    );

    return _featureNames
        .map((featureName) {
          return featureValues[featureName] ?? 0.0;
        })
        .toList(growable: false);
  }

  double denormalizeTarget(double normalizedValue) {
    _ensureInitialized();

    return normalizedValue * targetStd + targetMean;
  }

  double _scale(String column, double value) {
    final mean = _numericMeans[column];
    final std = _numericStds[column];

    if (mean == null || std == null) {
      throw StateError('Missing scaling statistics for $column.');
    }

    if (std == 0.0) {
      throw StateError('Standard deviation for $column cannot be zero.');
    }

    return (value - mean) / std;
  }

  void _encodeOneHot({
    required Map<String, double> output,
    required String column,
    required String value,
  }) {
    final categories = _oneHotCategories[column];

    if (categories == null) {
      throw StateError('Missing one-hot categories for $column.');
    }

    final knownCategories = categories
        .where((category) => category != _unknownToken)
        .toSet();

    for (final category in categories) {
      final featureName = '${column}__$category';

      if (category == _unknownToken) {
        output[featureName] =
            !knownCategories.contains(value) && _addUnknownCategory ? 1.0 : 0.0;
      } else {
        output[featureName] = category == value ? 1.0 : 0.0;
      }
    }
  }

  void _encodeMultiHot({
    required Map<String, double> output,
    required String column,
    required List<String> values,
  }) {
    final categories = _multiHotCategories[column];

    if (categories == null) {
      throw StateError('Missing multi-hot categories for $column.');
    }

    final valueSet = values.toSet();

    for (final category in categories) {
      final featureName = '${column}__$category';
      output[featureName] = valueSet.contains(category) ? 1.0 : 0.0;
    }
  }

  void _validateConfiguration() {
    if (_featureNames.isEmpty) {
      throw StateError('The preprocessing configuration contains no features.');
    }

    if (targetStd == 0.0) {
      throw StateError('Target standard deviation cannot be zero.');
    }

    for (final column in _scaledNumericColumns) {
      if (!_numericMeans.containsKey(column)) {
        throw StateError('Missing numeric mean for $column.');
      }

      if (!_numericStds.containsKey(column)) {
        throw StateError('Missing numeric standard deviation for $column.');
      }
    }
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('SalaryPreprocessor must be initialized before use.');
    }
  }

  static Map<String, List<String>> _parseCategoryMap(
    Map<String, dynamic> input,
  ) {
    return input.map(
      (key, value) => MapEntry(key, List<String>.from(value as List)),
    );
  }

  static Map<String, double> _parseDoubleMap(Map<String, dynamic> input) {
    return input.map((key, value) => MapEntry(key, (value as num).toDouble()));
  }
}
