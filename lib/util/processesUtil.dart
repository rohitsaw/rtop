import 'dart:io';

import '../model.dart';

Comparator<MyProcess> processComparator =
    (a, b) => b.cpuUtil.compareTo(a.cpuUtil);

List<MyProcess> getProcessListSort() {
  List<int> pids = getPids();
  List<MyProcess> processes = [];

  pids.forEach((element) {
    processes.add(MyProcess(element));
  });

  processes.sort(processComparator);
  return processes;
}

List<MyProcess> getProcessList() {
  List<int> pids = getPids();

  List<MyProcess> res = [];
  pids.forEach((element) {
    res.add(MyProcess(element));
  });

  return res;
}

// todo
List<int> getPids() {
  final String kProcDirectory = "/proc";

  var dir = Directory(kProcDirectory);
  // var isThere = dir.existsSync();
  var tmp = dir.listSync();
  tmp.removeWhere((element) => element is File);
  var tmp1 = tmp.map((e) => e.path.substring(6)).toList();
  var tmp2 = tmp1.map((element) => int.tryParse(element)).toList();
  tmp2.removeWhere((element) => element == null);
  //print(tmp2);
  return tmp2;
}
