class SessionStorage{
  var savedCourses = null;
  var activeCourses = null;
  int calendarBeginPage = 0;
  List<List<bool>> checkboxMatrix = List.generate(7, (row) {
    return List.generate(24, (col) {
      return false;
    });
  });

  var savedWeekday = 0;
}