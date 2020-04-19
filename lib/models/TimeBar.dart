class TimeBar{
  final int num;
  final int nextAvailable;

  TimeBar(this.num, this.nextAvailable);

  TimeBar.fromDatabase({this.num, this.nextAvailable});

  factory TimeBar.fromJson(Map<String, dynamic> json){
    return TimeBar.fromDatabase(
      num: json['num'],
      nextAvailable: json['nextAvailable'],
    );
  }

  @override
  String toString() {
    return '${this.num} ${this.nextAvailable}';
  }

}