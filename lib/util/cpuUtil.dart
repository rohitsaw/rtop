import 'dart:io';


final cpuStream = Stream<double>.periodic(Duration(seconds: 2), (timer) {
  return cpuUtil();
});


double cpuUtil(){
  final String kProcDirectory = "/proc/";
  final String kStatFilename = "/stat";

  final tmpPath =
      kProcDirectory.substring(0, kProcDirectory.length - 1) + kStatFilename;

  final file = File(tmpPath);

  final data = file.readAsLinesSync();

  final rawCpuInfo = data[0].split(" ");

  rawCpuInfo.removeWhere((element) => element == "" || element == " " || element == "cpu");

  //print(rawCpuInfo);

  final cpuInfo = rawCpuInfo.map((e) => int.parse(e)).toList();


  int idleTime = cpuInfo[3] + cpuInfo[4];
  int nonIdleTie = cpuInfo[0] + cpuInfo[1] + cpuInfo[2] + cpuInfo[5] + cpuInfo[6] + cpuInfo[7];

  int totalTime = idleTime + nonIdleTie;

  return (totalTime - idleTime) / totalTime;

}


Future<String> getCpuInfo() async {

  final String kProcDirectory = "/proc/";
    final String kCpuInfoFilename = "/cpuinfo";

    final tmpPath =
      kProcDirectory.substring(0, kProcDirectory.length - 1) + kCpuInfoFilename;

    final file = File(tmpPath);

    final data = await file.readAsLines();


    for(int i=0; i<data.length; i++){
      final tmp = data[i].split(":").map((e) => e.trim()).toList();
      if (tmp[0] == "model name")
        return tmp[1];
    }

    return "error";

    /*
    await file.openRead()
    .map(utf8.decode)
    .transform(LineSplitter())
    .forEach((l){ 
      final tmp = l.split(":").map((e) => e.trim()).toList();
      if (tmp[0] == "model name")
        return tmp[1];
    });
    */
}


