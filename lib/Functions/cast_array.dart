List<T> castList<T>(List<dynamic> list) {
  return list.map((dynamic e) {
    return e as T;
  }).toList();
}
