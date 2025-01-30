

//전체 경로(/search)가 필요할 때는 search를 사용하고,
//다른 경로의 일부분으로 'search'만 필요할 때는 searchRelative를 사용하는 식

abstract final class Routes {
  static const home = '/';
  static const login = '/login';
  static const search = '/$searchRelative';
  static const searchRelative = 'search';
  static const results = '/$resultsRelative';
  static const resultsRelative = 'results';
  static const activities = '/$activitiesRelative';
  static const activitiesRelative = 'activities';
  static const booking = '/$bookingRelative';
  static const bookingRelative = 'booking';
}