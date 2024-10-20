abstract interface class DataList {
  final List list = [];

  bool get isEmpty;

  Object getQuestionAt(int index);

  Object removeQuestionAt(int index);
}
