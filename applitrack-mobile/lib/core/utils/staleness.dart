import '../constants/enums.dart';
import '../../models/job_application.dart';

/// An active application with no update in this many days is "stale" — worth a
/// follow-up nudge. Wishlist items aren't applied yet, so they don't count.
const int staleDays = 14;

int daysSinceUpdate(DateTime? d) =>
    d == null ? 0 : DateTime.now().difference(d).inDays;

bool isStaleApp(JobApplication a) =>
    a.status != ApplicationStatus.wishlist &&
    a.status.isActive &&
    daysSinceUpdate(a.updatedAt) >= staleDays;
