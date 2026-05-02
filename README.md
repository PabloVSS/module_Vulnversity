# Vulnversity Exploitation Framework 

## Visão Geral

Estou realizando estudos no site da TryHackMe sobre cibersegurança e, neste laboratório, além do estudo normal pela plataforma, resolvi desenvolver uma suíte de automação para agregar ao meu conhecimento.

Este pipeline é um pentest automatizado focado em exploração web + escalada de privilégios.


## Objetivo

Simular um fluxo real de pentest:

- Reconhecimento
- Enumeração
- Exploração
- Pós-exploração
- Escalada de Privilégios

Com automação via scripts Bash e orquestração via Makefile.

## Conceitos aplicados

- Varredura de rede (Network Scanning)
- Força bruta de diretórios (Directory Bruteforce)
- Exploração de upload de arquivos
- Reverse Shell
- Pós-exploração
- Escalada de privilégios (SUID, pkexec, etc)

## Tecnologias e Ferramentas

- Ambiente: CachyOS / Kali Linux
- Linguagem: Bash Scripting
- Orquestração: Makefile
- Ferramentas: Nmap, Gobuster, Netcat, Curl 

## Estrutura

Pastas

```
.
├── Makefile                # Orquestrador de tarefas
├── common.sh               # Variáveis globais (IP, Portas, Paths)
├── reports/                # Relatórios gerados automaticamente
├── scripts/
│   ├── recon/              # nmap.sh, gobuster.sh
│   ├── exploit/            # upload_shell.sh, trigger_shell.sh
│   ├── post/               # privsec.sh, enum.sh
│   └── report/             # show_reports.sh (Agregador)
└── payloads/
    └── php-reverse-shell.phtml
```

## Visão da Arquitetura

O projeto foi pensado para que cada fase seja isolada, seguindo boas práticas:

```
Recon -> Exploit -> Post -> Report
```

Segue a explicação de cada parte:

---

### Makefile - Orquestrador de tarefas

Controla o fluxo completo do ataque.

Função:

- Encadear scripts
- Padronizar execução
- Evitar comandos manuais repetitivos

---

### common.sh - variáveis globais

Centraliza a configuração do ambiente, evitando hardcode nos scripts, facilitando manutenção e reaproveitamento.

---

### reports/ - saída do pipeline

Armazena as saídas de cada script para manter as evidências do pentest.

Papel:

- Logging
- Auditoria
- Base para relatório final

---

### scripts/recon - reconhecimento

Mapeia a superfície de ataque.

#### nmap.sh

- Scan completo 
- Identificação de serviços

Resultado:

- Portas abertas
- Versões
- Sistema operacional provável

#### gobuster.sh

- Força bruta de diretórios

Resultado:

- Descoberta de endpoints ocultos  
  Ex: `/internal`

---

### scripts/exploit - exploração

Objetivo: obter acesso inicial (RCE)

#### upload_shell.sh

- Envia o payload via formulário vulnerável

Técnica:

- Vulnerabilidade de upload de arquivos
- Bypass de extensão (.phtml)

#### trigger_shell.sh

- Executa o payload no servidor

Resultado:

- Reverse shell iniciado

---

### scripts/post - pós-exploração

Coletar informações e preparar escalonamento

#### enum.sh  

- Coleta de informações do sistema

Incluindo:

- whoami
- id 
- /etc/passwd
- busca por user.txt 

Resultado:

- Contexto do usuário (www-data)
- Enumeração básica

#### privsec.sh

- Enumeração de escalada de privilégios

Inclui:

- SUID 
- possíveis vetores

Objetivo:

- Identificar caminhos para root 

---

### scripts/report - agregação

Junta todos os relatórios em uma única saída.

---

### payloads/


```
php-reverse-shell.phtml
```

Payload de reverse shell em php

Função:
-  Quando executado no servidor:
    - conecta de volta ao atacante

# Resultados do laborátorio

*Reconnaissance Report - nmap*

As perguntas que foram realizadas no exercicio:


| Pergunta | Resposta |
|--------|--------|
| How many ports are open? | **6** |
| Version of squid proxy | **Squid 4.10** |
|How many ports will Nmap scan if the flag -p-400 was used?| **400**
| Most likely OS | **Linux (Ubuntu)** |
| Web server port | **3333** |

Evidências

### 📊 Evidence

```bash
21/tcp   open  ftp         vsftpd 3.0.5
22/tcp   open  ssh         OpenSSH 8.2p1 Ubuntu
139/tcp  open  netbios-ssn Samba smbd 4
445/tcp  open  netbios-ssn Samba smbd 4
3128/tcp open  http-proxy  Squid 4.10
3333/tcp open  http        Apache 2.4.41 (Ubuntu)
```

O host expões múltiplos serviços críticos, indicando uma superfície de ataque ampla.

- **FTP (21)** -> Possível acesso anônimo ou credenciais fracas
- **SSH (22)** -> Vetor para brute-force ou acesso pós-comprometimento
- **SMB (139/445)** -> Possível enumeração de shares e exploração de permissões
- **Squid Proxy (3128)** -> Potencial para SSRF ou pivoting interno
- **Web Server (3333)** -> Principal vetor de ataque identificado

O serviço HTTP está rodando em uma **porta não padrão (3333)**, o que sugere aplicação customizada.

A identificação de serviços como OpenSSH e Apache em versão Ubuntu indica que o sistema operacional alvo é **Linux (Ubuntu)**.

#### Security Observations 

- A presença simultânea de **SMB + Proxy + Web** aumenta significativamente o risco de encadeamento de ataques
- O proxy Squid pode ser abusado para acesso indireto a recursos internos
- A porta web fora do padrão sugere menor hardening e maior probabilidade de vulnerabilidades

### 🎯 Likely Attack Vector

Com base nos serviços identificados, o vetor mais promissor é:

1. Enumeração do serviço web (porta 3333)
2. Descoberta de diretórios ocultos
3. Identificação de funcionalidades vulneráveis (ex: upload)
4. Exploração para execução remota de código (RCE)

Serviços como SMB e FTP podem ser explorados posteriormente para movimentação lateral ou coleta de credenciais.


*Directory Enumeration – Gobuster*

As perguntas que foram realizadas no exercicio:

| Pergunta | Resposta |
|--------|--------|
| Directory with upload form | **/internal** |

#### Evidence


```bash
/internal        (Status: 301)
/server-status   (Status: 403)
/css
/images
/js
/fonts
/server-status (403)
```

A enumeração mostra diversos diretórios padrão de aplicações web, como:

- `/css`, `/js`, `/images`, `/fonts`

O diretório crítico identificado foi:

-`/internal` -> indica funcionalidade interna potencialmente sensivel

Este endpoint é usado frequentemente para:

- Upload de arquivos
- Painéis administrativos
- Funcionalidades não expostas publicamente

Além disso:

- `/server-status` retornando **403** confirma que o servidor Apache possui módulos ativos, mas com restriçao de acessos.

#### ⚠️ Security Observations


- A presença de `/internal` sugere falta de controle adequado de acesso
- Diretórios internos expostos são frequentemente vetores de RCE
- O código 301 indica que o diretório existe e é acessível
- O endpoint `/server-status` exposto (mesmo com 403) indica má configuração do Apache

### 🎯 Attack Path Integration

O diretório `/internal` foi identificado como o principal ponto de interesse.

Durante a análise manual, esse endpoint revelou uma funcionalidade de **upload de arquivos**, permitindo:

1. Testar restrições de extensão
2. Identificar bypass de filtro
3. Fazer upload de payload malicioso

Esse comportamento levou diretamente à exploração via **upload de reverse shell**.


*Exploitation Report — File Upload Bypass*

Identificar e explorar falhas no mecanismo de upload de arquivos da aplicação web para obter execuçao remota de codigo (RCE)

O que foi identificado:

**Upload Filter behavior**
- Extensão **.php** -> bloqueada
- Extensão **.phtml** -> permitida

O sistema possui um filtro baseado apenas em extensão, sem validação robusta de conteudo (MIME/type cheking ou parsing server-side).

### Attack Execution

Payload Utilizado
- Tipo: Reverse Shell em php
- Nome do arquivo: php-reverse-shell.phtml

Técnica aplicada
- Bypass de filtro de extensão
- Upload de payload disfarçado
- Execução remota via endpoint acessível

```
[*] Upload confirmado ✔
```
Quando o upload é confirmado quer dizer:
- O servidor aceitou o arquivo sem validação efetiva
- O payload foi Armazenado com sucesso
- O endpoint de upload é vulneravel a execuçao remota

### Impacto de Segurança

Essa vulnerabilidades permite:

- Execução remota de código(RCE)
- Compromentimento total do servidor web
- Escalada de Privilégios posterior 
- Possível pivoting na rede interna 

***Classificação: Crítica***


*Post-Exploitation*

As perguntas que foram realizadas no exercicio:

| Pergunta | Resposta |
|--------|--------|
| On the system, search for all SUID files. Which file stands out? | **/bin/systemctl** |

### Evidence


```
uid=33(www-data) gid=33(www-data) groups=33(www-data)

/bin/sh: 0: can't access tty; job control turned off

[+] User:
www-data

[+] User flag:
8bd7992fbe8a6ad22a63361004cfcedb

[+] SUID files:
/bin/systemctl
/usr/bin/sudo
/usr/bin/passwd
/usr/bin/pkexec
/bin/mount
/bin/su
...

```
Após a exploração via upload de shell reversa, o acesso obtido foi:
- Shell: limitada(sem TTY)
- Privilégios: baixos(web server context)

Cenário típico de comprometimento inicial em aplicações web vulneráveis.

Enumeração do Sistema revelou:

- Sistema operacional: Ubuntu Linux
- Kernel: 5.15.x
- Usuário ativo: www-data
- Acesso a multiplos binários SUID 

A presença de diversos binários com SUID indica uma superfície significativa para Privilege Escalation (PrivEsc).

Vetor Critico

O binário de mais revante identificado foi:
- *** /bin/systemctl ***

Pois, o systemctl com permissões SUID permite:
- Criar serviços arbitrários
- Executar comandos como root
- Persistência no sistema
Isso representa um vetor direto para escalonamento de Privilégios

Security Observations

- Execução de comandos privilegiados via systemctl
- Configuração insegura de permissões SUID
- Falta de isolamento entre serviços
- Usuário www-data com acesso indireto a root

Impacto de Segurança

Essa vulnerabilidade permite:

- Escalada completa de privilégios (root)
- Comprometimento total do sistema
- Execução arbitrária de comandos
- Persistência via serviços systemd
- Possível movimentação lateral (pivoting)


## Mapeamento MITRE ATT&CK

As técnicas utilizadas neste laboratório podem ser mapeadas para a matriz MITRE ATT&CK:

- **T1190 - Exploit Public-Facing Application**
  - Exploração do serviço web vulnerável via upload de arquivos

- **T1059 - Command and Scripting Interpreter**
  - Execução de comandos via reverse shell em PHP

- **T1105 - Ingress Tool Transfer**
  - Upload de payload malicioso para o servidor

- **T1068 - Exploitation for Privilege Escalation**
  - Exploração de binários SUID para escalada de privilégios

- **T1005 - Data from Local System**
  - Coleta de arquivos sensíveis como `user.txt`

## Impacto de Negócio

Embora este ambiente seja um laboratório, as vulnerabilidades encontradas representam riscos reais em ambientes de produção:

- Comprometimento total do servidor web (RCE)
- Possível vazamento de dados sensíveis
- Execução de comandos arbitrários no sistema
- Persistência do atacante no ambiente comprometido
- Possível movimentação lateral para outros sistemas internos
- Interrupção de serviços críticos caso explorado em produção

Em um cenário corporativo, esse tipo de falha poderia resultar em:

- Perda de integridade dos sistemas
- Exposição de dados de clientes
- Impacto financeiro e reputacional
- Violação de conformidade (LGPD / GDPR)




## Execução

## Configuração do ambiente (.env)

Antes de executar o projeto, é necessário criar um arquivo `.env` na raiz do projeto.

Esse arquivo contém as variáveis de configuração do atacante e do alvo.

Exemplo de estrutura:

# TARGET (máquina alvo do laboratório)
TARGET_IP=
PORT_WEB=

# ATTACKER (sua máquina local)
ATTACKER_IP=
LISTENER_PORT=

# PATHS
WORDLIST=
PAYLOAD_PATH=payloads/php-reverse-shell.phtml

# ENDPOINTS
UPLOAD_ENDPOINT=
UPLOAD_PATH=/

# FLAGS
AUTO_LISTENER=true
VERBOSE=true

```

Após isso, pode ser feito a Execução do Makefile, seguindo a ordem:

*1- Make setup*

Para realizar a liberação de acesso.


```
 make setup
```
    
*2- Make recon*


```
 make recon
```

*3- Make exploit*


```
 make exploit
```

Nesses proximos tem que ser feito da seguinte forma, você roda o post primeiro, abri um segundo terminal e roda o trigger

```
 make post
```

Em outro terminal:

```
 make trigger
```
## Author

- Pablo Vinícius Sousa Silva
Software Engineer | Sistemas | Programação de Baixo Nível
