/// Tracks sync state between local DB and Firestore.
enum SyncStatus { synced, pendingUpload, pendingDownload, conflict }

class SyncInfo {
  final DateTime? lastSyncAt;
  final int pendingUploads;
  final int pendingDownloads;
  final SyncStatus status;

  const SyncInfo({
    this.lastSyncAt,
    this.pendingUploads = 0,
    this.pendingDownloads = 0,
    this.status = SyncStatus.synced,
  });

  bool get needsSync => pendingUploads > 0 || pendingDownloads > 0;

  SyncInfo copyWith({
    DateTime? lastSyncAt,
    int? pendingUploads,
    int? pendingDownloads,
    SyncStatus? status,
  }) {
    return SyncInfo(
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      pendingUploads: pendingUploads ?? this.pendingUploads,
      pendingDownloads: pendingDownloads ?? this.pendingDownloads,
      status: status ?? this.status,
    );
  }
}
