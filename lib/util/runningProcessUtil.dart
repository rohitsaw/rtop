import 'dart:io';

final runningProcessStream =
    Stream<int>.periodic(Duration(seconds: 1), (timer) {
  return runningProcessUtill();
});

int runningProcessUtill() {
  final String kProcDirectory = "/proc/";
  final String kStatFilename = "/stat";

  final tmpPath =
      kProcDirectory.substring(0, kProcDirectory.length - 1) + kStatFilename;

  final file = File(tmpPath);
  final data = file.readAsLinesSync();

  for (int i = 0; i < data.length; i++) {
    final tmp = data[i].split(" ");
    if (tmp[0] == "procs_running") {
      //print("return proc ${tmp[1]}");
      return int.parse(tmp[1]);
    }
  }
  return 0;
}
