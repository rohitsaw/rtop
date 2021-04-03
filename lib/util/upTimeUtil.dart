import 'dart:io';

final upTimeStream = Stream<int>.periodic(Duration(seconds: 1), (timer) {
  return upTimeUtill();
});


int upTimeUtill(){
  final String kProcDirectory = "/proc/";
  final String kUptimeFilename = "/uptime";

  final tmpPath =
      kProcDirectory.substring(0, kProcDirectory.length - 1) + kUptimeFilename;

  final file = File(tmpPath);
  final data = file.readAsStringSync();

  final tmp = int.parse(data.split(" ")[0].split(".")[0]);
  return tmp;
}
