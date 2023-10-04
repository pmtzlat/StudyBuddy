class SessionStorage{
  var savedCourses = null;
  var activeCourses = null;
  int calendarBeginPage = 0;
  List<List<bool>> checkboxMatrix = List.generate(7, (row) {
  return List.generate(24, (col) {
    return col < 10; // Set the first 10 elements to true
  });
});


  var savedWeekday = 0;
  int? schedulePresent = null;
}