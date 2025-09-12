class DashboardData {
  final int doctors;
  final int patients;
  final int publicCommunities;
  final int privateCommunities;

  DashboardData({
    required this.doctors,
    required this.patients,
    required this.publicCommunities,
    required this.privateCommunities,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      doctors: json['approvedDoctors'] ?? 0,
      patients: json['patient'] ?? 0,
      publicCommunities: json['publicCommunity'] ?? 0,
      privateCommunities: json['privateCommunity'] ?? 0,
    );
  }
}
