import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/api_service.dart';

const _accentColor = Color(0xFFFF2A54);
const _backgroundColor = Color(0xFF121214);
const _surfaceColor = Color(0xFF1A1A1E);

void main() {
  runApp(const LoveRadarApp());
}

class LoveRadarApp extends StatelessWidget {
  const LoveRadarApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData.dark();

    return MaterialApp(
      title: 'LoveRadar',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        scaffoldBackgroundColor: _backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _accentColor,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _accentColor, width: 1.5),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _carregando = false;
  Map<String, dynamic>? _resultado;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _executarAnalise() async {
    final texto = _controller.text.trim();

    if (texto.isEmpty) {
      setState(() => _resultado = _erroLocal('Cole algum texto antes de analisar.'));
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _carregando = true;
      _resultado = null;
    });

    final resposta = await ApiService.analisarTexto(texto);

    if (!mounted) return;

    setState(() {
      _resultado = resposta;
      _carregando = false;
    });
  }

  Map<String, dynamic> _erroLocal(String mensagem) {
    return {
      'nivel_risco': 'Erro',
      'porcentagem': 0,
      'red_flags': [mensagem],
      'conselho': 'Cole uma mensagem ou biografia para começar.',
    };
  }

  Color _obterCorRisco(String? risco) {
    switch (risco) {
      case 'Seguro':
        return Colors.greenAccent;
      case 'Atenção':
        return Colors.orangeAccent;
      case 'Perigo':
        return Colors.redAccent;
      default:
        return Colors.blueGrey.shade200;
    }
  }

  List<String> _obterAlertas(Map<String, dynamic> resultado) {
    final alertas = resultado['red_flags'];
    if (alertas is! List) return const [];
    return alertas.map((item) => item.toString()).where((item) => item.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final resultado = _resultado;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '🛡️ LOVERADAR',
          style: GoogleFonts.bebasNeue(fontSize: 28, letterSpacing: 2),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Amor sim. Golpe não.',
                style: GoogleFonts.bebasNeue(
                  fontSize: 42,
                  letterSpacing: 1,
                  color: _accentColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Cole uma biografia ou conversa suspeita para encontrar sinais de alerta.',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade400, height: 1.4),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                maxLines: 7,
                maxLength: 6000,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Ex.: Ele pediu dinheiro para a passagem porque a mãe está doente...',
                  counterStyle: TextStyle(color: Colors.white38),
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _carregando ? null : _executarAnalise,
                icon: _carregando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.radar),
                label: Text(_carregando ? 'Analisando...' : 'Analisar com IA'),
                style: FilledButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _accentColor.withOpacity(0.55),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'A análise é uma triagem automática. Ela não confirma sozinha que alguém é golpista.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.3),
              ),
              if (resultado != null) ...[
                const SizedBox(height: 28),
                _ResultadoCard(resultado: resultado, obterCorRisco: _obterCorRisco, obterAlertas: _obterAlertas),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultadoCard extends StatelessWidget {
  const _ResultadoCard({
    required this.resultado,
    required this.obterCorRisco,
    required this.obterAlertas,
  });

  final Map<String, dynamic> resultado;
  final Color Function(String?) obterCorRisco;
  final List<String> Function(Map<String, dynamic>) obterAlertas;

  @override
  Widget build(BuildContext context) {
    final risco = resultado['nivel_risco']?.toString() ?? 'Erro';
    final porcentagem = resultado['porcentagem'] ?? 0;
    final cor = obterCorRisco(risco);
    final conselho = resultado['conselho']?.toString() ?? '';
    final alertas = obterAlertas(resultado);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cor.withOpacity(0.55), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Nível de risco',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: cor.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$risco (${porcentagem.toString()}%)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cor, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Conselho',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          const SizedBox(height: 5),
          Text(conselho, style: const TextStyle(fontSize: 15, height: 1.45)),
          if (alertas.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text(
              'Sinais de alerta identificados',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            ...alertas.map(
              (alerta) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⚠️  ', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Text(
                        alerta,
                        style: const TextStyle(fontSize: 14, color: Colors.amberAccent, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
