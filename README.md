# **Black Mindz Flow Ca$h**

**Transforme seu flow em $USD na sua conta.**
Plataforma de tokenização musical construída na Scroll Network, integrante do Programa de Aceleração Scroll Brasil.

---

## **1. Instalação**

```bash
# Clonar o projeto
git clone <seu-repo>
cd black-mindz-flow-cash

# Instalar dependências
npm install
```

---

## **2. Configuração**

```bash
# Criar arquivo .env
cp .env.example .env

# Editar .env
PRIVATE_KEY=sua_private_key_sem_0x
SCROLLSCAN_API_KEY=opcional_para_verificacao
```

---

## **3. Deploy na Scroll Testnet**

```bash
npm run compile        # Compilar contratos
npm run deploy:testnet # Deploy na Scroll Sepolia
npm run test:testnet   # Testar ambiente
```

**Comandos disponíveis:**

* `npm run compile` – Compilar contratos
* `npm run deploy:testnet` – Deploy na Scroll Sepolia
* `npm run test:testnet` – Executar testes
* `npm run verify` – Verificar contratos

---

## **Pré-requisitos**

* Node.js (v18+)
* NPM ou Yarn
* Wallet com ETH na Scroll Sepolia
* Private key da sua carteira

**Faucet e Bridge:**
[https://sepolia.scroll.io/faucet](https://sepolia.scroll.io/faucet)
[https://sepolia.scroll.io/bridge](https://sepolia.scroll.io/bridge)

---

## **Arquitetura**

### **Smart Contracts**

* `BlackMindzFlowCash.sol`: contrato principal (ERC-721 + distribuição automatizada)
* `RoyaltyDistributor.sol`: sistema otimizado de royalties em padrão pull-based
* `MockUSDT.sol`: token de testes compatível EVM

### **Recursos Principais**

* Tokenização de músicas e beats via NFTs
* Distribuição automática de royalties em USDT
* Pagamentos diretos para carteiras EVM
* Governança gasless via meta-transactions
* Dashboard de análise e auditoria on-chain

---

## **Economia Interna**

* Taxa da plataforma: 2.5%
* Royalties do artista: 97.5%
* Pagamentos em USDT direto na wallet
* Gas fees otimizadas para Scroll

---

## **Fluxo Operacional**

1. O artista realiza o upload da faixa e define o número de NFTs.
2. O contrato realiza o **lazy minting**, criando apenas a estrutura base.
3. As vendas em **pre-sale** geram liquidez inicial para o artista e investidores.
4. Os royalties são automatizados via **MerkleProof + pull pattern**, eliminando loops de distribuição.
5. As receitas são armazenadas e redistribuídas via contrato EVM compatível, com suporte a HODL automático.

---

## **Integrações**

* **Scroll Network** – execução e deploy
* **Transfero BaaSiC API** – conversão BRL/USDT e distribuição de receitas
* **Telegram Mini App** – interface social (Engaja Rap Club)
* **WalletConnect + Wagmi + Viem** – integração multiconta e multi-chain

---

## **Sistemas Otimizados**

### **Distribuição de Royalties**

Modelo pull-based com provas Merkle:
Cada artista executa seu próprio claim, reduzindo o custo de gas em até 90%.

### **Governança**

Meta-transactions off-chain, com processamento batch em uma única chamada.
Redução de até 99% no custo de votação.

### **Tokenização Musical**

Armazenamento otimizado via `PackedMusicData`, economizando até 35% no gas total e mantendo rastreabilidade via IPFS.

---

## **Custos Médios na Scroll**

| Operação                                 | Gas Médio | Custo USD |
| ---------------------------------------- | --------- | --------- |
| Deploy Completo                          | 800k      | $2.40     |
| Criação de Música                        | 80k       | $0.24     |
| Venda de NFT                             | 120k      | $0.36     |
| Distribuição de Royalties (100 artistas) | 210k      | $0.63     |

---

## **Monitoramento**

* Hardhat Gas Reporter com tracking em USD
* Storage Layout Analyzer
* Logs e análises com Sentry e Dune Analytics

---

## **Visão Estratégica**

O Black Mindz Flow Ca$h é a primeira infraestrutura musical descentralizada da América Latina voltada ao mercado de **rap e trap**, eliminando intermediários como ECAD, UBC e distribuidoras.
O modelo combina tokenização musical (RWA), pagamentos estáveis em USDT e governança cultural, com integração direta a marketplaces e mini apps sociais.

---

## **Licença**

MIT License – consulte LICENSE para detalhes.

**Contato:**
Twitter: @dg_doublegreen
Email: [dguedz07@gmail.com](mailto:dguedz07@gmail.com)

---

Deseja que eu adicione também a parte do **código atualizado dos contratos otimizados (FlowCash + Distributor + MusicNFT)** com as melhorias de gas e estrutura modular (EVM/Scroll)? Isso permitiria fechar a documentação técnica para o repositório.
