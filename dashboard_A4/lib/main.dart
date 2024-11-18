import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class ChartData {
  final String label;
  final double value;

  ChartData(this.label, this.value);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<double> _chartData = [];
  List<Employee> _employees = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _generateData();

    // Configura el temporizador para actualizar los datos cada 5 segundos
    _timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
      setState(() {
        _generateData();  // Genera nuevos datos
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();  // Cancela el temporizador si está activo
    super.dispose();
  }

  void _generateData() {
    _chartData = generateRandomData(5);
    _employees = List.generate(10, (index) => Employee(
      index + 1,
      'Empleado ${index + 1}',
      Random().nextDouble() * 10000,
    ));
  }

  List<double> generateRandomData(int count) {
    Random random = Random();
    return List.generate(count, (_) => random.nextDouble() * 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBarChart(),
              SizedBox(height: 20),
              _buildCircularIndicator(),
              SizedBox(height: 20),
              _buildGauge(),
              SizedBox(height: 20),
              _buildDataTable(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: () {
          setState(() {
            _generateData();
          });
        },
      ),
    );
  }

  Widget _buildBarChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      series: <ChartSeries<ChartData, String>>[
        ColumnSeries<ChartData, String>(
          dataSource: _chartData
              .asMap()
              .entries
              .map((entry) => ChartData('Label ${entry.key}', entry.value))
              .toList(),
          xValueMapper: (ChartData data, _) => data.label,
          yValueMapper: (ChartData data, _) => data.value,
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildCircularIndicator() {
    double percent = Random().nextDouble();
    return CircularPercentIndicator(
      radius: 100.0,
      lineWidth: 10.0,
      percent: percent,
      center: Text('${(percent * 100).toStringAsFixed(1)}%'),
      progressColor: Colors.green,
    );
  }

  Widget _buildGauge() {
    double value = Random().nextDouble() * 100;
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 0,
          maximum: 100,
          pointers: <GaugePointer>[
            NeedlePointer(value: value),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Text(
                value.toStringAsFixed(1),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              angle: 90,
              positionFactor: 0.5,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    return Container(
      height: 300,
      child: SfDataGrid(
        source: EmployeeDataSource(_employees),
        columns: [
          GridColumn(
            columnName: 'id',
            label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(
                'ID',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          GridColumn(
            columnName: 'name',
            label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(
                'Nombre',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          GridColumn(
            columnName: 'salary',
            label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(
                'Salario',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Employee {
  final int id;
  final String name;
  final double salary;

  Employee(this.id, this.name, this.salary);
}

class EmployeeDataSource extends DataGridSource {
  List<DataGridRow> _employeeData = [];

  EmployeeDataSource(List<Employee> employees) {
    _employeeData = employees.map<DataGridRow>((employee) {
      return DataGridRow(cells: [
        DataGridCell<int>(columnName: 'id', value: employee.id),
        DataGridCell<String>(columnName: 'name', value: employee.name),
        DataGridCell<double>(columnName: 'salary', value: employee.salary),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _employeeData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: row.getCells().map<Widget>((cell) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0),
        child: Text(cell.value.toString()),
      );
    }).toList());
  }
}
