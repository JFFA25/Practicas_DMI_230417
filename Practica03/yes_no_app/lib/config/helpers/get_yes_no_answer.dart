import 'dart:math';

import 'package:dio/dio.dart';
import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/infrastructure/models/yes_no_model.dart';

class GetYesNoAnswer {
  static const _answers = ['yes', 'yes', 'no', 'no', 'maybe'];

  final _random = Random();
  final _dio = Dio();

  Future<Message> getAnswer() async {
    final answer = _answers[_random.nextInt(_answers.length)];
    final response = await _dio.get(
      'https://yesno.wtf/api',
      queryParameters: {'force': answer},
    );
    final yesNoModel = YesNoModel.fromJsonMap(response.data);

    return yesNoModel.toMessageEntity();
  }
}
