import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Cliente do backend do LoveRadar.
///
/// A chave da OpenAI nunca deve ser colocada neste aplicativo. O app chama
/// somente o backend, que mantém a chave em uma variável de ambiente.
class ApiService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static Future<Map<String, dynamic>> analisarTexto(String texto) async {
    final textoLimpo = texto.trim();

    if (textoLimpo.isEmpty) {
      return _retornarErro('Cole uma biografia ou conversa para analisar.');
    }

    if (textoLimpo.length > 6000) {
      return _retornarErro('O texto deve ter no máximo 6.000 caracteres.');
    }

    try {
      final baseUrl = _baseUrl.endsWith('/')
          ? _baseUrl.substring(0, _baseUrl.length - 1)
          : _baseUrl;

      final response = await http
          .post(
            Uri.parse('$baseUrl/analyze'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json; charset=utf-8',
            },
            body: jsonEncode({'text': textoLimpo}),
          )
          .timeout(const Duration(seconds: 45));

      final dynamic payload = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic analysis =
            payload is Map<String, dynamic> ? payload['analysis'] : null;

        if (analysis is Map) {
          return Map<String, dynamic>.from(analysis);
        }

        return _retornarErro('A resposta do servidor veio em formato inválido.');
      }

      final mensagem = payload is Map<String, dynamic>
          ? payload['error']?.toString()
          : null;
      return _retornarErro(mensagem ?? 'Não foi possível concluir a análise.');
    } on TimeoutException {
      return _retornarErro('A análise demorou demais. Tente novamente.');
    } on FormatException {
      return _retornarErro('O servidor retornou uma resposta inválida.');
    } catch (_) {
      return _retornarErro(
        'Não foi possível conectar ao LoveRadar. Verifique sua internet.',
      );
    }
  }

  static Map<String, dynamic> _retornarErro(String mensagem) {
    return {
      'nivel_risco': 'Erro',
      'porcentagem': 0,
      'red_flags': [mensagem],
      'conselho': 'Confira a conexão e tente novamente em instantes.',
    };
  }
}
