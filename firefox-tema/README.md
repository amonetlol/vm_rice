# FoxOne + Catppuccin Frappe Blue

Esta pasta contém a cópia do tema que está aplicado no Firefox desta máquina: **FoxOne 3.5**, com layout one-line, cores **Catppuccin Frappé Blue** e barra de favoritos dinâmica.

## Instalar o FoxOne

1. No Firefox, abra `about:config`.
2. Ative `toolkit.legacyUserProfileCustomizations.stylesheets`.
3. Abra `about:support` e clique em **Abrir pasta** em **Pasta do perfil**.
4. Crie uma pasta chamada `chrome`.
5. Copie os arquivos de `FoxOne/` para essa pasta:

   - `userChrome.css`
   - `userContent.css`

6. Reinicie o Firefox.

Esta cópia foi sincronizada diretamente do perfil local usado nesta máquina. A configuração atual mantém `--uc-dynamic-bookmarks: 0`, portanto a barra de favoritos segue o comportamento nativo configurado no Firefox, em vez de aparecer somente ao passar o mouse na barra de endereço.

O arquivo `FoxOne/installation.md` contém as instruções originais detalhadas.

## Instalar as cores Catppuccin

Em `about:addons`, abra **Temas** e instale o arquivo:

`firefox-tema/catppuccin-frappe-blue.xpi`

Depois ative o tema e reinicie o Firefox. O FoxOne controla o layout e a cópia local já contém as variáveis Catppuccin Frappe Blue aplicadas. O XPI fornece apenas o complemento opcional de cores do navegador.

## Fonte

FoxOne: https://github.com/Firnschnee/FoxOne

Catppuccin Frappe Blue: https://addons.mozilla.org/en-US/firefox/addon/catppuccin-frappe-blue/
