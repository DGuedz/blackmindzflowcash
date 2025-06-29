require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-verify");
require("hardhat-gas-reporter");
require("solidity-coverage");
require("hardhat-contract-sizer");
require("dotenv").config();

/** 
 * 🎵 Black Mindz Flow Ca$h - Hardhat Configuration
 * Optimized for Scroll Network deployment
 */

const PRIVATE_KEY = process.env.PRIVATE_KEY || "";
const SCROLLSCAN_API_KEY = process.env.SCROLLSCAN_API_KEY || "abc";
const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY || "";
const INFURA_PROJECT_ID = process.env.INFURA_PROJECT_ID || "";

// Validate private key
if (!PRIVATE_KEY && process.env.NODE_ENV !== "test") {
  console.warn("PRIVATE_KEY not found in .env file");
}

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "hardhat",
  
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200, // Optimized for deployment cost vs execution cost
      },
      metadata: {
        // Remove metadata hash for deterministic builds
        bytecodeHash: "none",
      },
    },
  },

  networks: {
    // Local development
    hardhat: {
      chainId: 31337,
      gas: 12000000,
      blockGasLimit: 12000000,
      allowUnlimitedContractSize: true,
      accounts: {
        mnemonic: "test test test test test test test test test test test junk",
        count: 20,
        accountsBalance: "10000000000000000000000", // 10,000 ETH
      },
    },

    localhost: {
      url: "http://127.0.0.1:8545",
      chainId: 31337,
    },

    // SCROLL SEPOLIA TESTNET (Primary testnet)
    scrollSepolia: {
      url: process.env.SCROLL_SEPOLIA_RPC || "https://sepolia-rpc.scroll.io/",
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
      chainId: 534351,
      gasPrice: 1000000000, // 1 gwei - muito baixo na Scroll
      gas: 3000000,
      timeout: 60000,
      confirmations: 1,
    },

    // SCROLL MAINNET
    scroll: {
      url: process.env.SCROLL_MAINNET_RPC || "https://rpc.scroll.io/",
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
      chainId: 534352,
      gasPrice: "auto",
      gas: "auto",
      timeout: 120000,
      confirmations: 2,
    },

    // ETHEREUM SEPOLIA (para bridge testing)
    sepolia: {
      url: `https://sepolia.infura.io/v3/${INFURA_PROJECT_ID}`,
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
      chainId: 11155111,
      gasPrice: 20000000000, // 20 gwei
    },

    // ETHEREUM MAINNET (para bridge production)
    mainnet: {
      url: `https://mainnet.infura.io/v3/${INFURA_PROJECT_ID}`,
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
      chainId: 1,
      gasPrice: "auto",
      timeout: 120000,
    },

    // POLYGON (future expansion)
    polygon: {
      url: "https://polygon-rpc.com/",
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
      chainId: 137,
    },

    // BSC (future expansion)
    bsc: {
      url: "https://bsc-dataseed1.binance.org/",
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
      chainId: 56,
    },
  },

  // Contract Verification
  etherscan: {
    apiKey: {
      scrollSepolia: SCROLLSCAN_API_KEY,
      scroll: SCROLLSCAN_API_KEY,
      sepolia: process.env.ETHERSCAN_API_KEY || "",
      mainnet: process.env.ETHERSCAN_API_KEY || "",
      polygon: process.env.POLYGONSCAN_API_KEY || "",
      bsc: process.env.BSCSCAN_API_KEY || "",
    },
    customChains: [
      {
        network: "scrollSepolia",
        chainId: 534351,
        urls: {
          apiURL: "https://api-sepolia.scrollscan.com/api",
          browserURL: "https://sepolia.scrollscan.com/",
        },
      },
      {
        network: "scroll",
        chainId: 534352,
        urls: {
          apiURL: "https://api.scrollscan.com/api",
          browserURL: "https://scrollscan.com/",
        },
      },
    ],
  },

  // Gas Reporter Configuration
  gasReporter: {
    enabled: process.env.REPORT_GAS === "true",
    currency: "USD",
    gasPrice: 20, // gwei
    coinmarketcap: process.env.COINMARKETCAP_API_KEY,
    showTimeSpent: true,
    showMethodSig: true,
    maxMethodDiff: 10,
    outputFile: "gas-report.txt",
    noColors: false,
    rst: true,
    rstTitle: "Gas Usage Report",
  },

  // Contract Sizer
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: true,
    only: [':BlackMindzFlowCash$', ':MockUSDT$'],
  },

  // Documentation Generation
  docgen: {
    path: './docs',
    clear: true,
    runOnCompile: false,
    except: ['contracts/test'],
  },

  // Testing Configuration
  mocha: {
    timeout: 40000,
    grep: process.env.MOCHA_GREP,
  },

  // Paths Configuration
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },

  // Compilation Configuration
  typechain: {
    outDir: "typechain-types",
    target: "ethers-v6",
    alwaysGenerateOverloads: false,
    externalArtifacts: ["node_modules/@openzeppelin/contracts/build/contracts/*.json"],
  },

  // Tenderly Configuration (optional)
  tenderly: {
    project: process.env.TENDERLY_PROJECT || "",
    username: process.env.TENDERLY_USERNAME || "",
    privateVerification: false,
  },

  // Warnings Configuration
  warnings: {
    'contracts/**/*': {
      'code-size': 'error',
      'unused-param': 'warning',
      'unused-var': 'warning',
    },
  },

  // Custom Tasks Configuration
  external: {
    contracts: [
      {
        artifacts: "node_modules/@openzeppelin/contracts-upgradeable/build/contracts",
        deploy: "node_modules/@openzeppelin/hardhat-upgrades/src/deploy",
      },
    ],
    deployments: {
      scrollSepolia: ["deployments/scrollSepolia"],
      scroll: ["deployments/scroll"],
    },
  },
};

// 🎵 Custom Hardhat Tasks
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();
  for (const account of accounts) {
    const balance = await account.provider.getBalance(account.address);
    console.log(`${account.address}: ${hre.ethers.formatEther(balance)} ETH`);
  }
});

task("balance", "Prints an account's balance")
  .addParam("account", "The account's address")
  .setAction(async (taskArgs, hre) => {
    const balance = await hre.ethers.provider.getBalance(taskArgs.account);
    console.log(hre.ethers.formatEther(balance), "ETH");
  });

task("deploy-testnet", "Deploy to Scroll Sepolia")
  .setAction(async (taskArgs, hre) => {
    await hre.run("compile");
    await hre.run("run", { script: "scripts/deploy.js", network: "scrollSepolia" });
  });

task("verify-all", "Verify all contracts")
  .addParam("address", "Contract address to verify")
  .setAction(async (taskArgs, hre) => {
    try {
      await hre.run("verify:verify", {
        address: taskArgs.address,
        constructorArguments: [],
      });
      console.log(" Contract verified successfully!");
    } catch (error) {
      console.log("❌ Verification failed:", error.message);
    }
  });

// etwork-specific tasks
task("testnet-info", "Show testnet information")
  .setAction(async (taskArgs, hre) => {
    console.log("🌐 Scroll Sepolia Testnet Information:");
    console.log("- RPC URL:", "https://sepolia-rpc.scroll.io/");
    console.log("- Chain ID:", "534351");
    console.log("- Explorer:", "https://sepolia.scrollscan.com/");
    console.log("- Faucet:", "https://sepolia.scroll.io/faucet");
    console.log("- Bridge:", "https://sepolia.scroll.io/bridge");
  });

task("mainnet-info", "Show mainnet information")
  .setAction(async (taskArgs, hre) => {
    console.log("🚀 Scroll Mainnet Information:");
    console.log("- RPC URL:", "https://rpc.scroll.io/");
    console.log("- Chain ID:", "534352");
    console.log("- Explorer:", "https://scrollscan.com/");
    console.log("- Official Bridge:", "https://scroll.io/bridge");
  });

Principais Features do Hardhat Config:
🌐 Redes Configuradas:
✅ Scroll Sepolia (testnet principal)
✅ Scroll Mainnet (produção)
✅ Ethereum Sepolia (para bridge)
✅ Localhost (desenvolvimento local)
🔮 Polygon/BSC (expansão futura)

Otimizações:
Gas Reporter ativo com relatórios detalhados
Contract Sizer para monitorar tamanho dos contratos
Solidity Optimizer configurado para Scroll
Verificação automática no ScrollScan
Tasks Customizadas:
# Ver informações da testnet
npx hardhat testnet-info

# Deploy rápido na testnet
npx hardhat deploy-testnet

# Verificar contrato
npx hardhat verify-all --address <ENDEREÇO>

# Ver contas disponíveis
npx hardhat accounts

# Ver saldo de uma conta
npx hardhat balance --account <ENDEREÇO>
Relatórios e Análises:
Gas Usage detalhado
Contract Size monitoring
Test Coverage reports
Documentation auto-generation
Segurança:
Private keys seguras via .env
Multiple confirmations na mainnet
Timeout configurações adequadas
Gas limits otimizados para Scroll
