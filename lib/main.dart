// kala_capsule_pro.dart (Pro Edition with teleportation simulation based on formulas)
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/rendering.dart';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(const KalaTimeCapsule());

class KalaTimeCapsule extends StatelessWidget {
  const KalaTimeCapsule({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kala Time Capsule Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0B0B),
        textTheme: GoogleFonts.orbitronTextTheme(ThemeData.dark().textTheme),
        sliderTheme: const SliderThemeData(thumbColor: Colors.tealAccent, activeTrackColor: Colors.tealAccent),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.tealAccent,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const Stack(children: [StarfieldBackground(), ControlPanel()]),
    );
  }
}

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> with SingleTickerProviderStateMixin {
  bool teleportTriggered = false;
  double alpha = 0.5, omega = 2, time = 1;
  double mass = 5.972e24, radius = 6.371e6;
  double distance = 0.000001, area = 0.01;
  double velocity = 3e5, universeN = 1;
  late AnimationController _controller;
  double teleportProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get phi => 1 + alpha * sin(omega * time);
  double get futureTimeJump => time * (1 - 1 / phi);
  double get whiteHoleCurvature {
    const G = 6.67430e-11;
    const c = 3e8;
    return (-1 / pow(radius, 2)) * (1 - (2 * G * mass) / (radius * pow(c, 2))).abs().reciprocal;
  }

  double get quantumEnergy {
    const hbar = 1.054e-34;
    const c = 3e8;
    return (hbar * c * pow(pi, 2)) / (240 * pow(distance, 4)) * area;
  }

  double get power => quantumEnergy / time;
  double get kalaSchwarzschild {
    const G = 6.67430e-11;
    const c = 3e8;
    return (2 * G * mass / pow(c, 2)) * phi;
  }

  double get multiverseJumpTime => velocity * phi * universeN * time;
  double get teleportDistance => velocity * phi * time;

  List<FlSpot> get phiGraph {
    return List.generate(21, (i) {
      double t = i * 0.5;
      return FlSpot(t, 1 + alpha * sin(omega * t));
    });
  }

  void simulateTeleportation() async {
    setState(() {
      teleportTriggered = true;
      teleportProgress = 0;
    });

    double totalDistance = teleportDistance;
    int steps = 20;
    for (int i = 1; i <= steps; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      setState(() => teleportProgress = (i / steps) * totalDistance);
    }

    await Future.delayed(const Duration(seconds: 1));
    setState(() => teleportTriggered = false);
  }

  @override
  Widget build(BuildContext context) {
    final scale = 1 + 0.3 * sin(_controller.value * 2 * pi);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Kala Capsule Pro Control"),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => GraphScreen(graphData: phiGraph)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListView(
          children: [
            Transform.scale(
              scale: scale,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.cyanAccent.withOpacity(0.9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.tealAccent.withOpacity(0.8),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.blur_circular, size: 60, color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            if (teleportTriggered)
              Column(
                children: [
                  const Text("Teleportation Progress"),
                  LinearProgressIndicator(
                    value: teleportProgress / teleportDistance,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.tealAccent),
                  ),
                  Text("Distance: ${teleportProgress.toStringAsFixed(2)} / ${teleportDistance.toStringAsFixed(2)} m"),
                ],
              ),
            const Divider(),
            SliderTile(label: "Alpha (α)", value: alpha, onChanged: (v) => setState(() => alpha = v)),
            SliderTile(label: "Omega (ω)", value: omega, max: 10, onChanged: (v) => setState(() => omega = v)),
            SliderTile(label: "Time (t)", value: time, max: 10, onChanged: (v) => setState(() => time = v)),
            SliderTile(label: "Mass (kg)", value: mass, max: 1e25, min: 1e20, onChanged: (v) => setState(() => mass = v)),
            SliderTile(label: "Radius (m)", value: radius, max: 1e7, min: 1e6, onChanged: (v) => setState(() => radius = v)),
            SliderTile(label: "Distance (m)", value: distance, max: 0.00001, min: 1e-9, onChanged: (v) => setState(() => distance = v)),
            SliderTile(label: "Area (m²)", value: area, max: 1, min: 0.001, onChanged: (v) => setState(() => area = v)),
            SliderTile(label: "Velocity", value: velocity, max: 1e6, min: 1e3, onChanged: (v) => setState(() => velocity = v)),
            SliderTile(label: "Universe uₙ", value: universeN, max: 10, min: 1, onChanged: (v) => setState(() => universeN = v)),
            const Divider(),
            Text("Φ(t): ${phi.toStringAsFixed(4)}"),
            Text("ΔT_future: ${futureTimeJump.toStringAsFixed(4)} s"),
            Text("White Hole Curvature: ${whiteHoleCurvature.toStringAsExponential(2)}"),
            Text("Casimir Energy: ${quantumEnergy.toStringAsExponential(2)} J"),
            Text("Power Output: ${power.toStringAsExponential(2)} W"),
            Text("Kala Schwarzschild Radius: ${kalaSchwarzschild.toStringAsExponential(2)} m"),
            Text("Multiverse ΔTₘ: ${multiverseJumpTime.toStringAsExponential(2)} s"),
            Text("Teleport Distance: ${teleportDistance.toStringAsExponential(2)} m"),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.rocket_launch),
              label: const Text("Simulate Teleportation"),
              onPressed: simulateTeleportation,
            ),
          ],
        ),
      ),
    );
  }
}

class SliderTile extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final double min;
  final ValueChanged<double> onChanged;

  const SliderTile({super.key, required this.label, required this.value, required this.onChanged, this.max = 1.0, this.min = 0.0});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("$label: ${value.toStringAsExponential(2)}", style: const TextStyle(fontSize: 14)),
      Slider(value: value, min: min, max: max, divisions: 100, label: value.toStringAsExponential(2), onChanged: onChanged),
    ]);
  }
}

class StarfieldBackground extends StatefulWidget {
  const StarfieldBackground({super.key});

  @override
  State<StarfieldBackground> createState() => _StarfieldBackgroundState();
}

class _StarfieldBackgroundState extends State<StarfieldBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Offset> stars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    stars = List.generate(150, (index) => Offset(Random().nextDouble(), Random().nextDouble()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => CustomPaint(
        painter: StarfieldPainter(stars, _controller.value),
        child: Container(),
      ),
    );
  }
}

class StarfieldPainter extends CustomPainter {
  final List<Offset> stars;
  final double time;
  StarfieldPainter(this.stars, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.7);
    for (final star in stars) {
      final dx = (star.dx + time) % 1.0 * size.width;
      final dy = star.dy * size.height;
      canvas.drawCircle(Offset(dx, dy), 1.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

extension on double {
  double get reciprocal => this == 0 ? 0 : 1 / this;
}

class GraphScreen extends StatelessWidget {
  final List<FlSpot> graphData;
  const GraphScreen({super.key, required this.graphData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Φ(t) vs t")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            minY: 0,
            titlesData: FlTitlesData(show: true),
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: graphData,
                isCurved: true,
                color: Colors.tealAccent,
                barWidth: 3,
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.tealAccent.withOpacity(0.2),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
