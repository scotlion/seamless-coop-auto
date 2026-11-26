# Elden Ring Seamless Co-op Auto

Atualizador automático do mod **Seamless Co-op** para Elden Ring, desenvolvido em PowerShell.

O objetivo deste projeto é simplificar o processo de atualização do mod, eliminando a necessidade de acessar manualmente o GitHub, baixar arquivos ZIP, extrair e substituir os arquivos do jogo.

## ✨ Funcionalidades

- 🔍 Detecta automaticamente a pasta do Elden Ring através do arquivo `eldenring.exe`.
- 🌐 Consulta a API do GitHub para encontrar a versão mais recente do Seamless Co-op.
- 📥 Baixa automaticamente o arquivo ZIP da última Release.
- 📦 Extrai os arquivos do mod.
- 💾 Cria backup dos arquivos da versão anterior.
- ⚙️ Preserva o arquivo `ersc_settings.ini`, mantendo as configurações do usuário.
- 🧹 Remove os arquivos temporários após uma instalação bem-sucedida.
- ✅ Permite testar o download e a extração sem modificar os arquivos do jogo.

## 🚀 Como utilizar

Não é necessário baixar ou instalar o atualizador manualmente.

### 1. Abra a pasta do jogo

Localize a pasta que contém o arquivo:

`eldenring.exe`

Exemplo:

```text
Elden.Ring/
└── Game/
    ├── eldenring.exe
    └── ...
```

O nome da pasta não importa, desde que ela contenha o executável do jogo.

### 2. Abra o PowerShell

Dentro da pasta do jogo, abra uma janela do PowerShell.

### 3. Execute o comando

```powershell
irm "https://raw.githubusercontent.com/scotlion/seamless-coop-auto/main/Atualizar-SeamlessCoop.ps1" | iex
```


### 4. Aguarde a atualização

O atualizador irá:

1. Detectar o Elden Ring.
2. Consultar a última versão publicada no GitHub.
3. Localizar o arquivo ZIP.
4. Baixar os arquivos.
5. Extrair e validar a estrutura do mod.
6. Solicitar confirmação antes de instalar.
7. Fazer backup da instalação anterior.
8. Instalar a nova versão.
9. Preservar as configurações existentes.
10. Limpar os arquivos temporários após a instalação bem-sucedida.

## 💾 Backups

Os backups são armazenados localmente em:

```text
%LOCALAPPDATA%\SeamlessCoopUpdater\Backups\
```

Cada atualização cria uma pasta identificada pela data e horário da instalação.

## 📦 Arquivos temporários

Durante a atualização, os arquivos são armazenados em:

```text
%TEMP%\SeamlessCoopUpdater\
```

Após uma instalação bem-sucedida, os arquivos temporários daquela versão são removidos.

## 🛠️ Tecnologias utilizadas

- PowerShell
- GitHub REST API
- Invoke-RestMethod
- Invoke-WebRequest
- Expand-Archive


## ⚙️ Configurador do Seamless Co-op

# O projeto disponibiliza um configurador para editar o arquivo ersc_settings.ini, permitindo modificar as configurações do Seamless Co-op, incluindo a senha da sessão.

📂 Localização do configurador

O configurador é baixado automaticamente para:

C:\Users\usuario\AppData\Local\SeamlessCoopUpdater\Configurator\

## Após o download, um atalho é criado automaticamente na Área de Trabalho. Basta abrir o configurador pelo atalho.

⚠️ Restrição ao selecionar o arquivo de configuração

## ⚠️ ⚠️ O configurador apresenta uma limitação ao tentar selecionar o arquivo ersc_settings.ini quando ele está localizado em pastas protegidas do Windows, como:

C:\Program Files\
C:\Program Files (x86)\

Nessas situações, não é possível selecionar e modificar o arquivo diretamente pelo configurador.

Como contornar essa limitação:

Acesse a pasta SeamlessCoop do jogo.

Copie o arquivo ersc_settings.ini.

Cole o arquivo em uma pasta fora dos diretórios protegidos, como a Área de Trabalho.

Abra o configurador pelo atalho.

Selecione o arquivo copiado e faça as alterações desejadas.

Salve as configurações.

Copie o arquivo atualizado de volta para a pasta SeamlessCoop do jogo, substituindo o anterior.

Importante: essa limitação ocorre devido às restrições de acesso do navegador a arquivos localizados em diretórios protegidos do Windows. Não é necessário mover o jogo ou reinstalar o mod.



## 🔗 Observações

O atualizador utiliza/baixa as Releases disponibilizadas em:

https://github.com/yuiamoroll/EldenRingSeamlessCoopRelease

Mod original: Elden Ring Seamless Co-op.

## ⚠️ Avisos

- Feche o Elden Ring antes de iniciar a atualização.
- Execute o PowerShell na pasta que contém `eldenring.exe`.
- Confira a versão e os arquivos encontrados antes de confirmar a instalação.
- Mantenha seus backups até confirmar que o mod está funcionando corretamente.
- Este projeto é uma ferramenta independente de atualização e não é afiliado oficialmente aos desenvolvedores do Elden Ring ou do Seamless Co-op.

## 📄 Licença

Projeto disponibilizado para uso pessoal e educacional. O mod Seamless Co-op pertence aos seus respectivos desenvolvedores e distribuidores.

---

Desenvolvido para facilitar a atualização do Elden Ring Seamless Co-op.
