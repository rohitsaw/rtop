// import 'dart:convert';
import 'dart:io';

import 'package:rtop/util/upTimeUtil.dart';

class MyProcess {
  int pid, uptime, ram;
  String command, user;
  double cpuUtil;

  MyProcess(int p) {
    this.pid = p;
    this.user = getUser(p);
    this.command = getCommand(p);
    this.ram = getRam(p);
    this.uptime = getUpTime(p);
    this.cpuUtil = getCpuUtil(p);
  }

  /*
  @override
  int compareTo(MyProcess other) {
    return (double.parse(other.cpuUtil) - double.parse(cpuUtil)).round();
  }
  */

  String getCommand(int p) {
    // print("check point getCommand");
    final String kProcDirectory = "proc";
    final String kCmdlineFilename = "cmdline";
    final tmpPath = "/$kProcDirectory/$p/$kCmdlineFilename";
    final file = File(tmpPath);
    List<String> data = [];
    if (file.existsSync()) {
      data = file.readAsLinesSync();
    }

    if (data.length == 0) return "- - -";
    return data[0];
  }

  // helper for getUid
  bool isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  int getUid(int p) {
    // print("check point getUid");

    final String kProcDirectory = "proc";
    final String kStatusFilename = "status";
    final tmpPath = "/$kProcDirectory/$p/$kStatusFilename";
    final file = File(tmpPath);
    if (!file.existsSync()) {
      return -1;
    }
    final data = file.readAsLinesSync();
    for (int i = 0; i < data.length; i++) {
      final tmp = data[i].split(":").toList();
      if (tmp[0] == "Uid") {
        var tmp2 = tmp[1].trim();

        var tmp3 = tmp2.split("");
        String res = "";
        for (int i = 0; i < tmp3.length; i++) {
          if (isNumeric(tmp3[i])) {
            res += tmp3[i];
          } else
            break;
        }
        //print(tmp3);

        return int.parse(res);
      }
    }
    return -1;
  }

  String getUser(int p) {
    // print("check point getUser");

    final int uid = getUid(p);

    String user = "";
    final String kPasswordPath = "/etc/passwd";
    final file = File(kPasswordPath);

    if (!file.existsSync()) {
      return "null";
    }

    final data = file.readAsLinesSync();

    for (int i = 0; i < data.length; i++) {
      final tmp = data[i].replaceAll(":", " ").split(" ");
      if (int.parse(tmp[2]) == uid) {
        return tmp[0];
      }
    }
    return user;
  }

  int getRam(int p) {
    //  print("check point getRam");

    final String kProcDirectory = "proc";
    final String kStatusFilename = "status";

    final tmpPath = "/$kProcDirectory/$p/$kStatusFilename";
    final file = File(tmpPath);
    if (!file.existsSync()) {
      return -1;
    }
    final data = file.readAsLinesSync();

    for (int i = 0; i < data.length; i++) {
      final tmp = data[i].split(":");
      if (tmp[0] == "VmSize") {
        final res = int.parse(tmp[1].substring(0, tmp[1].length - 2));
        return (res ~/ 1024);
      }
    }
    return -1;
  }

  int getUpTime(int p) {
    // print("check point getUpTime");

    final String kProcDirectory = "proc";
    final String kStatFilename = "stat";

    final tmpPath = "/$kProcDirectory/$p/$kStatFilename";

    final file = File(tmpPath);

    if (!file.existsSync()) {
      return -1;
    }

    final data = file.readAsStringSync();

    final res = data.split(" ");
    res.removeWhere((element) => element == "" || element == " ");

    return int.parse(res[21]) ~/ 100;
  }

  double getCpuUtil(int p) {
    // print("check point getCpuUtil");

    List<String> info = getProcessStat(p);
    int totalTime = int.parse(info[14]) +
        int.parse(info[15]) +
        int.parse(info[16]) +
        int.parse(info[17]);
    int upTime = upTimeUtill();

    /*
    final res = await Process.start('getconf', ['CLK_TCK']);
	  final tmp = res.stdout.transform(utf8.decoder);
    */

    final hertz = 100;

    double secondsActive = upTime - (int.parse(info[22]) / hertz);
    double cpuUsage = (totalTime / hertz) / secondsActive;
    return cpuUsage;
  }

  List<String> getProcessStat(int p) {
    // print("check point getProcessStst");

    final String kProcDirectory = "proc";
    final String kStatFilename = "stat";

    List<String> info = ["0"];

    final tmpPath = "/$kProcDirectory/$p/$kStatFilename";
    final file = File(tmpPath);

    if (!file.existsSync()) {
      return [];
    }

    final data = file.readAsLinesSync();

    for (int i = 0; i < data.length; i++) {
      final res = data[i].split(" ");
      res.removeWhere((element) => element == " " || element == "");
      info.addAll(res);
    }
    return info;
  }
}
