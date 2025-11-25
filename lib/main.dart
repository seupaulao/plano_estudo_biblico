import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

// =====================================================================
// =========================== APP ROOT =================================
// =====================================================================
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Plano de Estudo Biblico",
      home: Tela1(),
    );
  }
}

// =====================================================================
// ======================= ANIMAÇÃO: PAGE FLIP ==========================
// =====================================================================
class PageFlipRoute extends PageRouteBuilder {
  final Widget page;

  PageFlipRoute({required this.page})
    : super(
        transitionDuration: Duration(milliseconds: 650),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (context, animation, secondary, child) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              double value = animation.value;
              return Transform(
                alignment: Alignment.centerLeft,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(1.3 * (1 - value)),
                child: child,
              );
            },
          );
        },
      );
}

// =====================================================================
// ======================= ANIMAÇÃO: FADE OUT ===========================
// =====================================================================
class FadeOutRoute extends PageRouteBuilder {
  final Widget page;

  FadeOutRoute({required this.page})
    : super(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (context, animation, secondary, child) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(animation),
            child: child,
          );
        },
      );
}

// =====================================================================
// ======================= MODELO DE STATUS DO DIA =====================
// =====================================================================
class DayStatus {
  bool a;
  bool b;

  DayStatus({this.a = false, this.b = false});

  Color get dayColor {
    if (a && b) return Colors.green;
    if (a || b) return Colors.yellow;
    return Colors.blue;
  }
}

// =====================================================================
// ============================ TELA 1 =================================
// =====================================================================
class Tela1 extends StatelessWidget {
  final List<String> meses = [
    "Janeiro",
    "Fevereiro",
    "Março",
    "Abril",
    "Maio",
    "Junho",
    "Julho",
    "Agosto",
    "Setembro",
    "Outubro",
    "Novembro",
    "Dezembro",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tela 1 - Meses")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: List.generate(12, (i) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(),
              ),
              child: Text(
                meses[i],
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  PageFlipRoute(page: Tela2(mesIndex: i + 1)),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

// =====================================================================
// ============================ TELA 2 =================================
// =====================================================================
class Tela2 extends StatefulWidget {
  final int mesIndex;

  Tela2({required this.mesIndex});

  @override
  _Tela2State createState() => _Tela2State();
}

class _Tela2State extends State<Tela2> {
  Map<int, DayStatus> dias = {};

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  // ===================== CARREGAR PERSISTÊNCIA ======================
  Future<void> carregarDados() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int qtd = diasDoMes(widget.mesIndex);

    for (int d = 1; d <= qtd; d++) {
      bool a = prefs.getBool("${widget.mesIndex}-$d-A") ?? false;
      bool b = prefs.getBool("${widget.mesIndex}-$d-B") ?? false;
      dias[d] = DayStatus(a: a, b: b);
    }

    setState(() {});
  }

  int diasDoMes(int mes) {
    int ano = DateTime.now().year;
    if (mes == 2) {
      bool bissexto = (ano % 4 == 0 && ano % 100 != 0) || ano % 400 == 0;
      return bissexto ? 29 : 28;
    }
    if ([4, 6, 9, 11].contains(mes)) return 30;
    return 31;
  }

  @override
  Widget build(BuildContext context) {
    int qtdDias = diasDoMes(widget.mesIndex);

    return Scaffold(
      appBar: AppBar(title: Text("Dias do Mês ${widget.mesIndex}")),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              padding: EdgeInsets.all(12),
              children: List.generate(qtdDias, (i) {
                int dia = i + 1;
                DayStatus status = dias[dia] ?? DayStatus();

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: status.dayColor,
                  ),
                  child: Text(
                    dia.toString().padLeft(2, "0"),
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      PageFlipRoute(
                        page: Tela3(
                          mes: widget.mesIndex,
                          dia: dia,
                          status: status,
                        ),
                      ),
                    );
                    carregarDados();
                  },
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text("Voltar"),
              onPressed: () {
                Navigator.pushReplacement(context, FadeOutRoute(page: Tela1()));
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// ============================ TELA 3 =================================
// =====================================================================
class Tela3 extends StatefulWidget {
  final int mes;
  final int dia;
  final DayStatus status;

  Tela3({required this.mes, required this.dia, required this.status});

  @override
  _Tela3State createState() => _Tela3State();
}

class _Tela3State extends State<Tela3> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dia ${widget.dia}")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.status.a
                          ? Colors.green
                          : Colors.blue,
                    ),
                    child: Text("Botão A"),
                    onPressed: () {
                      setState(() {
                        widget.status.a = !widget.status.a;
                      });
                      salvar("A", widget.status.a);
                    },
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.status.b
                          ? Colors.green
                          : Colors.blue,
                    ),
                    child: Text("Botão B"),
                    onPressed: () {
                      setState(() {
                        widget.status.b = !widget.status.b;
                      });
                      salvar("B", widget.status.b);
                    },
                  ),
                ],
              ),
              SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: Text("Voltar"),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    FadeOutRoute(page: Tela2(mesIndex: widget.mes)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================== SALVAR ESTADO ============================
  Future<void> salvar(String qual, bool valor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("${widget.mes}-${widget.dia}-$qual", valor);
  }
}
