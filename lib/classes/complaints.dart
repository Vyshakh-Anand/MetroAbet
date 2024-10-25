class Complaint {
  final int userId;
  final int compId;
  final int? metroNo;
  final int? stationNo;
  final String compStatus;
  final DateTime date;
  final String time;
  final String type;
  final String photo;
  final String? comType;

  Complaint({
    required this.userId,
    required this.compId,
    this.metroNo,
    this.stationNo,
    required this.compStatus,
    required this.date,
    required this.time,
    required this.type,
    required this.photo,
    this.comType,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    int? metroNo = json['metro_no'];
    int? stationNo = json['station_no'];

    if (json['com_type'] == 'metro') {
      stationNo = null; // Set stationNo to null if com_type is metro
    } else if (json['com_type'] == 'station') {
      metroNo = null; // Set metroNo to null if com_type is station
    }

    return Complaint(
      userId: json['u_id'],
      compId: json['comp_id'],
      metroNo: metroNo,
      stationNo: stationNo,
      compStatus: json['comp_status'],
      date: DateTime.parse(json['date']),
      time: json['time'], 
      type: json['type'],
      photo: json['photo'],
      comType: json['com_type'],
    );
  }
}
