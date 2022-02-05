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

  const initialPortfolio = {
    loading: false,
    list: []
  }

  const [info, setInfo] = useState(initialInfo);
  const [portfolio, setPortfolio] = useState(initialPortfolio);
  
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

  const getDrops = async () => {
    info.contract.tokenOfOwnerByIndex("0x2272ecf43a7481088fa2d4ba9109804ed5a31901", 0).then((res) => {
      console.log(res.toString());
    }).catch((err) => {
      console.log(err);
    });
  };

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

  console.log(123);

  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <div> 111
          <button onClick={() => getDrops()}>Get My NFT</button>
        </div>
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
