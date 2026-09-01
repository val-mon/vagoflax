class DateFormat {
  static String formatDate(DateTime date) {
    return date.toLocal().toString().substring(0, 16);
  }
}
