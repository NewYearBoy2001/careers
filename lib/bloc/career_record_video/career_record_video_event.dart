abstract class CareerRecordVideoEvent {}

/// Fetch the short home list.
class FetchHomeVideos extends CareerRecordVideoEvent {}

/// Fetch page 1 of the full list (resets any existing data).
class FetchVideosFirstPage extends CareerRecordVideoEvent {}

/// Fetch the next page of the full list.
class FetchVideosNextPage extends CareerRecordVideoEvent {}

/// Pull-to-refresh: reload from page 1 while keeping current list visible.
class RefreshVideos extends CareerRecordVideoEvent {}

class RefreshHomeVideos extends CareerRecordVideoEvent {}