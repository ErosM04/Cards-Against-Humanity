abstract interface class DataList {
  final List list = [];

  bool get isEmpty;

  int get length;

  Object getQuestionAt(int index);

  Object removeQuestionAt(int index);
}
