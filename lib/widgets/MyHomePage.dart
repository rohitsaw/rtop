import 'dart:async';
import 'dart:io';
//import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rtop/util/processesUtil.dart';
// import 'package:system_info/system_info.dart';

import '../util/memoryUtil.dart' show memoryStream, memoryUtil, getTotalMemory;
import '../util/upTimeUtil.dart' show upTimeUtill, upTimeStream;
import '../util/runningProcessUtil.dart'
    show runningProcessStream, runningProcessUtill;
import '../util/totalProcessUtil.dart'
    show totalProcessStream, totalProcessUtill;

import '../util/cpuUtil.dart' show cpuStream, cpuUtil, getCpuInfo;

class MyHomePage extends StatelessWidget {
  final title;

  MyHomePage({this.title});

  // get OS details

  final String kOSPath = "/etc/os-release";
  final String kProcDirectory = "/proc/";
  final String kVersionFilename = "/version";

  //final String kCmdlineFilename = "/cmdline";
  //final String kCpuinfoFilename = "/cpuinfo";
  //final String kStatusFilename = "/status";
  //final String kStatFilename = "/stat";
  //final String kUptimeFilename = "/uptime";
  //final String kMeminfoFilename = "/meminfo";

  //final String kPasswordPath = "/etc/passwd";

  Future<String> operatingSystem() async {
    final file = File(kOSPath);
    final data = await file.readAsLines();

    for (int i = 0; i < data.length; i++) {
      final tmp = data[i].split("=");
      if (tmp[0] == "PRETTY_NAME") {
        //print(tmp[1]);
        return tmp[1].substring(1, tmp[1].length - 1);
      }
    }
    return "OS details not found";
  }

  Future<String> kernel() async {
    final tmpPath = kProcDirectory.substring(0, kProcDirectory.length - 1) +
        kVersionFilename;
    final file = File(tmpPath);

    final data = await file.readAsString();
    //print(data.split(" ")[2]);
    return data.split(" ")[2];
  }

  String _printDuration(int durationInSec) {
    final duration = Duration(seconds: durationInSec);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // operating system info
                  FutureBuilder(
                    future: operatingSystem(),
                    builder: (context, snapshot) => (snapshot.hasData
                        ? Text(
                            "OS :   ${snapshot.data}",
                            style: TextStyle(letterSpacing: 1),
                          )
                        : Text("OS :   Loading... ")),
                  ),

                  SizedBox(
                    height: 5,
                  ),

                  // kernel info
                  FutureBuilder(
                    future: kernel(),
                    builder: (context, snapshot) => (snapshot.hasData
                        ? Text(
                            "Kernel :   ${snapshot.data}",
                            style: TextStyle(letterSpacing: 1),
                          )
                        : Text("Kernel :   Loading... ")),
                  ),

                  SizedBox(
                    height: 5,
                  ),

                  // cpu info
                  Row(
                    children: [
                      Expanded(
                        child: StreamBuilder(
                          stream: cpuStream,
                          initialData: cpuUtil(),
                          builder: (context, snapshot) {
                            return Row(
                              children: [
                                Text(
                                  "CPU :   ${(snapshot.data * 100).toStringAsFixed(2)}%  ",
                                  style: TextStyle(letterSpacing: 1),
                                ),
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: snapshot.data,
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      FutureBuilder(
                        future: getCpuInfo(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData)
                            return Text(
                              "  ${snapshot.data}",
                              style: TextStyle(letterSpacing: 1),
                            );
                          else
                            return Text("...");
                        },
                      )
                    ],
                  ),

                  SizedBox(
                    height: 5,
                  ),

                  // memory info
                  Row(
                    children: [
                      Expanded(
                        child: StreamBuilder(
                          stream: memoryStream,
                          initialData: memoryUtil(),
                          builder: (context, snapshot) {
                            return Row(
                              children: [
                                Text(
                                  "Memory :   ${(snapshot.data * 100).toStringAsFixed(2)}%  ",
                                  style: TextStyle(letterSpacing: 1),
                                ),
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: snapshot.data,
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      FutureBuilder(
                        future: getTotalMemory(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData)
                            return Text(
                              "  Total Memory :  ${snapshot.data ~/ 1024} MB",
                              style: TextStyle(letterSpacing: 1),
                            );
                          else
                            return Text("...");
                        },
                      )
                    ],
                  ),

                  SizedBox(
                    height: 5,
                  ),

                  // running processes
                  StreamBuilder(
                    initialData: runningProcessUtill(),
                    stream: runningProcessStream,
                    builder: (context, snapshot) {
                      return Text(
                        "Running Processes :   ${snapshot.data}",
                        style: TextStyle(letterSpacing: 1),
                      );
                    },
                  ),

                  SizedBox(
                    height: 5,
                  ),

                  // total processes
                  StreamBuilder(
                    initialData: totalProcessUtill(),
                    stream: totalProcessStream,
                    builder: (context, snapshot) {
                      return Text(
                        "Total Processes :   ${snapshot.data}",
                        style: TextStyle(letterSpacing: 1),
                      );
                    },
                  ),

                  SizedBox(
                    height: 5,
                  ),

                  // uptime info
                  StreamBuilder(
                    initialData: upTimeUtill(),
                    stream: upTimeStream,
                    builder: (context, snapshot) {
                      return Text(
                        "Up Time :   ${_printDuration(snapshot.data)}",
                        style: TextStyle(letterSpacing: 1),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
                      child: Table(
                        children: [
                          TableRow(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8.0, bottom: 8),
                                child: Text(
                                  "PID",
                                  style: TextStyle(color: Colors.greenAccent),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 8),
                                child: Text(
                                  "USER",
                                  style: TextStyle(color: Colors.greenAccent),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 8),
                                child: Text(
                                  "CPU[%]",
                                  style: TextStyle(color: Colors.greenAccent),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 8),
                                child: Text(
                                  "RAM[ MB ]",
                                  style: TextStyle(color: Colors.greenAccent),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 8),
                                child: Text(
                                  "TIME[ HH:MM:SS ]",
                                  style: TextStyle(color: Colors.greenAccent),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 8, bottom: 8, left: 8),
                                child: Text(
                                  "Command",
                                  style: TextStyle(color: Colors.greenAccent),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: ProcessList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProcessList extends StatefulWidget {
  @override
  _ProcessListState createState() => _ProcessListState();
}

class _ProcessListState extends State<ProcessList> {
  Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //print("build run");
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Table(
        children: [...getRow()],
      ),
    );
  }
}

Iterable<TableRow> getRow() sync* {
  var demo = getProcessListSort();
  // print(demo.length);

  var demo1 = demo.getRange(0, 30);

  for (int i = 0; i < demo1.length; i++) {
    yield TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 2),
          child: Text("${demo[i].pid}"),
        ),
        Text(demo[i].user),
        Text((demo[i].cpuUtil * 100).toStringAsFixed(2)),
        Text("${demo[i].ram}"),
        Text(formatUpTime(demo[i].uptime)),
        Text(
          demo[i].command,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      ],
    );
  }
}

String formatUpTime(int seconds) {
  final now = Duration(seconds: seconds);
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(now.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(now.inSeconds.remainder(60));
  return "${twoDigits(now.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}
