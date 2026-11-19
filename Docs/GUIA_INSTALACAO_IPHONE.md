# Guia de Instalação no iPhone — Los Primos Music iOS

Como o aplicativo é para **uso pessoal e privado** (sem publicação na App Store), você pode instalá-lo diretamente no seu iPhone através de qualquer um dos métodos abaixo.

---

## Método 1: Instalação Direta via Xcode (Recomendado se você tiver um Mac)

Este é o método oficial e mais seguro da Apple. Você não precisa de uma conta de desenvolvedor paga; qualquer **Apple ID gratuito** funciona.

### Passo a Passo:
1. Abra a pasta `Los Primos Music iOS` no **Xcode** (Versão 15 ou superior).
2. Conecte seu iPhone ao Mac via cabo USB ou Wi-Fi.
3. No Xcode, vá em **Signing & Capabilities** (no alvo do projeto):
   * Marque a opção **Automatically manage signing**.
   * Em **Team**, selecione sua conta pessoal (Apple ID).
   * Se o Bundle Identifier (`com.losprimos.music`) já estiver em uso, altere para algo único (ex: `com.seunome.losprimosmusic`).
4. Selecione o seu iPhone como dispositivo de destino no topo da janela.
5. Clique no botão **Play / Run (Cmd + R)**.
6. **No iPhone:**
   * A primeira vez que abrir o app, o iOS mostrará um aviso de desenvolvedor não confiável.
   * Vá em **Ajustes > Geral > VPN e Gerenciamento de Dispositivos**.
   * Toque no seu e-mail da Apple e selecione **"Confiar"**.
   * O app abrirá normalmente com reprodução de áudio em background!

---

## Método 2: Instalação no Windows via Sideloadly

Se você usa Windows e não quer abrir o Xcode:

1. Baixe o **Sideloadly** (gratuito para Windows e Mac) em [sideloadly.io](https://sideloadly.io/).
2. Conecte o iPhone ao computador via cabo USB e abra o iTunes (para o Windows reconhecer o aparelho).
3. No Sideloadly:
   * Selecione o seu iPhone detectado.
   * Arraste o arquivo `LosPrimosMusic.ipa` gerado para dentro do Sideloadly.
   * Insira o seu Apple ID pessoal.
   * Clique em **Start**.
4. O app será instalado diretamente na tela inicial do seu iPhone.
5. No iPhone, autorize em **Ajustes > Geral > VPN e Gerenciamento de Dispositivos**.

---

## Método 3: AltStore / SideStore (Sem computador após configurar)

1. Instale o **AltServer** no seu PC/Mac e sincronize com o iPhone para instalar o **AltStore**.
2. No AltStore dentro do iPhone, selecione **"My Apps" > "+"** e escolha o arquivo `LosPrimosMusic.ipa`.
3. O app será assinado e funcionará perfeitamente. O AltStore renova a assinatura automaticamente via Wi-Fi toda semana.

---

## Funcionalidades Nativas Ativas no iOS:
* **Background Audio:** A música continua tocando normalmente quando o app é minimizado ou com a tela bloqueada.
* **Lock Screen & Control Center:** A capa da música, título, artista e barra de progresso aparecem na tela de bloqueio e na central de controle, com comandos de Play, Pause, Próxima, Anterior e Seek.
* **Letras Sincronizadas (LRCLIB):** Sincronização em tempo real conforme a música toca.
* **YouTube Streams Diretos:** Sem anúncios e com carregamento instantâneo via cliente VisionOS.
