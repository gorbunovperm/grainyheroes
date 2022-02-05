import logo from './logo.png';
import './App.css';
import grainy from '../contract/contract.json';
import { ethers } from 'ethers';
import { useState, useEffect } from 'react'

function App() {
  const initialInfo = {
    connected: false,
    status: null,
    account: null,
    contract: null
  };

  const [info, setInfo] = useState(initialInfo);
  
  const init = async () => {
    if (window.ethereum?.isMetaMask) {
      const accounts = await window.ethereum.request({
        method: "eth_requestAccounts"
      });
      const networkId = await window.ethereum.request({
        method: "net_version"
      });
      if (networkId == 4) {
        const provider = new ethers.providers.Web3Provider(window.ethereum, "any");
        const signer = provider.getSigner();
        const signerAddress = await signer.getAddress();
        const grainyContract = new ethers.Contract(grainy.address, grainy.abi, signer);

        setInfo({
          ...initialInfo,
          connected: true,
          account: accounts[0],
          contract: grainyContract
        });
      } else {
        setInfo({ ...initialInfo, status: "Please, use ethereum testnet." });
      }
      
    } else {
      setInfo({ ...initialInfo, status: "Metamask is not installed." });
    }
    console.log("Yeah!!!!!");
  };

  console.log(info);

  const initOnChanged = () => {
    if (window.ethereum) {
      window.ethereum.on("accountsChanged", async () => {
        window.location.reload();
      });
      window.ethereum.on("chainChanged", async () => {
        window.location.reload();
      });
    }
  }

  useEffect(() => {
    init();
    initOnChanged();
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.js</code> and save to reload.
        </p>
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React
        </a>
      </header>
    </div>
  );
}

export default App;
