import 'dart:io';

final memoryStream = Stream<double>.periodic(Duration(seconds: 5), (timer) {
  return memoryUtil();
});


double memoryUtil(){
      final String kProcDirectory = "/proc/";
  final String kMeminfoFilename = "/meminfo";
  final tmpPath =
      kProcDirectory.substring(0, kProcDirectory.length - 1) + kMeminfoFilename;

  final file = File(tmpPath);
  Map<String, int> meminfo = {};
  final data = file.readAsLinesSync();

  for (int i = 0; i < data.length; i++) {
    final tmp = data[i].split(":");
    var val = tmp[1].trim();
    val = val.split(" ")[0];

    meminfo[tmp[0]] = val.isEmpty ? 0 : int.parse(val);
  }

  int totalMemoryUse = meminfo["MemTotal"] - meminfo["MemFree"];


  int nonBufferMemory =
      totalMemoryUse - (meminfo["Buffers"] + meminfo["Cached"]);
  int bufferMemory = meminfo["Buffers"];

  int cachedMemory =
      meminfo["Cached"] + meminfo["SReclaimable"] - meminfo["Shmem"];

  return ((nonBufferMemory + bufferMemory + cachedMemory) /
      meminfo['MemTotal']);
}


Future<int> getTotalMemory() async {
   final String kProcDirectory = "/proc/";
  final String kMeminfoFilename = "/meminfo";
  final tmpPath =
      kProcDirectory.substring(0, kProcDirectory.length - 1) + kMeminfoFilename;

  final file = File(tmpPath);

  final data = await file.readAsLines();

  for (int i = 0; i < data.length; i++) {
    final tmp = data[i].split(":");
    var val = tmp[1].trim();
    val = val.split(" ")[0];

    if (tmp[0] == "MemTotal")
      return int.parse(val);
  }
  return 0;
}
