# LoveRadar

Aplicativo Flutter de segurança digital para analisar biografias e conversas de aplicativos de relacionamento em busca de sinais de golpe, manipulação ou comportamento tóxico.

O LoveRadar faz uma triagem automática. O resultado não prova que uma pessoa é golpista e não substitui bom senso, confirmação de identidade ou orientação profissional.

## Estrutura

- `lib/`: aplicativo Flutter.
- `lib/services/api_service.dart`: cliente HTTP do backend.
- `backend/`: API Node.js que mantém a chave da OpenAI fora do celular.
- `.env.example`: variáveis de ambiente necessárias no backend.

## Por que existe um backend

Uma chave da OpenAI embutida no aplicativo pode ser extraída por qualquer pessoa que baixe o APK/AAB. Por isso, o Flutter chama `POST /analyze` e somente o backend chama a OpenAI usando `OPENAI_API_KEY`.

O backend não salva o texto analisado e não o escreve nos logs. Ainda assim, configure HTTPS, autenticação/rate limit de produção e uma política de privacidade antes de publicar o app.

## Rodar a API localmente

Requisitos: Node.js 18 ou superior.

```bash
cd backend
export OPENAI_API_KEY="sua-chave-real"
npm run check
npm start
```

Teste de saúde:

```bash
curl http://localhost:3000/health
```

## Rodar o Flutter

Requisitos: Flutter instalado e um emulador/dispositivo conectado.

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

`10.0.2.2` aponta para o computador host a partir do emulador Android. No iOS Simulator ou em um celular físico, use o endereço acessível do computador, por exemplo `http://192.168.0.10:3000`, ou uma API HTTPS publicada.

## Gerar o AAB

O endereço da API deve ser o backend HTTPS de produção:

```bash
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://api.seudominio.com
```

Não use `OPENAI_API_KEY` em `--dart-define`. A chave pertence somente ao ambiente do backend.

## Próximas etapas antes da loja

1. Adicionar autenticação e limite de uso por conta.
2. Configurar rate limit persistente no backend e monitoramento de custo.
3. Criar política de privacidade, termos e fluxo de exclusão de dados.
4. Adicionar Firebase apenas quando histórico, login e analytics forem realmente necessários.
5. Testar falsos positivos e falsos negativos com casos revisados por pessoas.
