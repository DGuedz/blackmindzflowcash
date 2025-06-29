🎵 Black Mindz Flow Ca$h

Transforme seu flow em $USD na sua conta
Plataforma de tokenização musical na Scroll Network - Programa de Aceleração Scroll Brasil.

🚀 Start
1. Instalação
# Clonar o projeto
git clone <seu-repo>
cd black-mindz-flow-cash
# Instalar dependências
npm install


2. Configuração
# Criar arquivo .env
cp .env.example .env
# Editar .env com suas chaves
PRIVATE_KEY=sua_private_key_sem_0x
SCROLLSCAN_API_KEY=opcional_para_verificacao


3. Deploy na Scroll Testnet
# Compilar contratos
npm run compile
# Deploy
npm run deploy:testnet
# Testar
npm run test:testnet

🛠️ Comandos Disponíveis
npm run compile - Compilar contratos
npm run deploy:testnet - Deploy na Scroll Sepolia
npm run test:testnet - Executar testes
npm run verify - Verificar contratos

📋 Pré-requisitos
Node.js (v18+)
NPM ou Yarn
Wallet com ETH na Scroll Sepolia
Private Key da sua wallet

🪙 Obter ETH de Teste
Scroll Faucet: https://sepolia.scroll.io/faucet
Bridge: https://sepolia.scroll.io/bridge
QuickNode: https://faucet.quicknode.com/scroll/sepolia

🎯 Arquitetura

Smart Contracts
BlackMindzFlowCash.sol - Contrato principal (ERC-721 + pagamentos)
MockUSDT.sol - Token USDT para testes

Features
✅ Tokenização de música (NFTs)
✅ Pagamentos em USDT por stream
✅ Royalties automáticos (97.5% para artista)
✅ Dashboard de analytics
✅ Compatibilidade total EVM

🌐 Redes Suportadas
Scroll Sepolia Testnet (ChainID: 534351)
Scroll Mainnet (ChainID: 534352) - Em breve

📊 Economia do Token
Taxa da Plataforma: 2.5%
Royalties do Artista: 97.5%
Pagamentos: USDT direto na wallet
Gas Fees: Otimizadas para Scroll

🏆 Programa Scroll Brasil

Este projeto foi desenvolvido para o Programa de Aceleração Scroll Brasil, focando em:
✅ RWA (Real World Assets) - Música como ativo tokenizado
✅ Stablecoins - Pagamentos em USDT
✅ Soluções de Pagamento - Monetização musical
🤝 Contribuindo

Fork o projeto
Crie sua feature branch (git checkout -b feature/nova-feature)
Commit suas mudanças (git commit -m 'Add nova feature')
Push para a branch (git push origin feature/nova-feature)
Abra um Pull Request

📄 Licença

MIT License - veja LICENSE para detalhes.

📞 Contato
Twitter: @dg_doublegreen
Email: dguedz07@gmail.com

Black Mindz Flow Ca$h - Revolucionando a música brasileira na Web3! 🇧🇷✨
