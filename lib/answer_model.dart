
///主机应答model
class AnswerModel {
  String _answer;

  AnswerModel({String answer}) {
    this._answer = answer;
  }

  String get answer => _answer;

  AnswerModel.fromJson(Map<String, dynamic> json) {
    _answer = json['answer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['answer'] = this._answer;
    return data;
  }
}