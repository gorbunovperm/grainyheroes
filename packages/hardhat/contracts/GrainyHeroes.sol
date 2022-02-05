// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IERC721 {
  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

  function balanceOf(address owner) external view returns (uint256 balance);
  function ownerOf(uint256 tokenId) external view returns (address owner);
  function safeTransferFrom(address from, address to, uint256 tokenId) external;
  function transferFrom(address from, address to, uint256 tokenId) external;
  function approve(address to, uint256 tokenId) external;
  function getApproved(uint256 tokenId) external view returns(address operator);
  function setApprovalForAll(address operator, bool approved) external;
  function isApprovedForAll(address owner, address operator) external view returns(bool approved);
  function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

contract GrainyHeroes is IERC721 {
  address payable contractOwner;
  uint256 public constant COST_TO_MINT = 0.05 ether;
  uint256 public maxHeroes = 5;
  uint256 public amountMintedHeroes = 0;
  mapping(address => uint256) private _balances;
  mapping(uint256 => address) private _owners;
  mapping(uint256 => address) private _approvals;
  mapping(address => mapping(address => bool)) private _operators;

  constructor() {
    contractOwner = payable(msg.sender);
  }

  function mintHero() external payable {
    require(COST_TO_MINT <= msg.value);
    amountMintedHeroes += 1;
    uint256 tokenId = amountMintedHeroes;
    require(amountMintedHeroes <= maxHeroes);
    _balances[msg.sender] += 1;
    _owners[tokenId] = msg.sender;
    emit Transfer(address(0), msg.sender, tokenId);
  }

  function withdraw() external {
    require(msg.sender == contractOwner);
    uint256 balance = address(this).balance;
    (bool sent,) = contractOwner.call{value: balance}("");
    require(sent);
  }

  /* IERC20 */

  function balanceOf(address owner) external view override returns (uint256 balance) {
    balance = _balances[owner];
  }

  function ownerOf(uint256 tokenId) public view override returns (address owner) {
    //require(_exists(tokenId), "Owner query for nonexistent token");

    owner = _owners[tokenId];
  }

  function safeTransferFrom(address from, address to, uint256 tokenId) external override {
    transferFrom(from, to, tokenId);
    //require(
    //  _checkOnERC721Received(from, to, tokenId, ''),
    //  'Transfer to non ERC721Receiver implementer'
    //);
  }

  function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external override {
    transferFrom(from, to, tokenId);
    //require(
    //  _checkOnERC721Received(from, to, tokenId, data),
    //  'Transfer to non ERC721Receiver implementer'
    //);
  }

  function transferFrom(address from, address to, uint256 tokenId) public override {
    bool isApprovedOrOwner = (
      msg.sender == from ||
      msg.sender == getApproved(tokenId) ||
      isApprovedForAll(from, msg.sender));
    require(isApprovedOrOwner, "Caller is not owner nor approved");

    _balances[from] -= 1;
    _balances[to] += 1;
    _owners[tokenId] = to;
    approve(address(0), tokenId);
    emit Transfer(from, to, tokenId); 
  }

  function approve(address to, uint256 tokenId) public override {
    address owner = ownerOf(tokenId);
    require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
      "Caller is not owner nor approved for all");
    _approvals[tokenId] = to;
    emit Approval(owner, to,  tokenId);
  }

  function getApproved(uint256 tokenId) public view override returns(address operator) {
    operator = _approvals[tokenId];
  }

  function setApprovalForAll(address operator, bool approved) external override {
    _operators[msg.sender][operator] = approved;
    emit ApprovalForAll(msg.sender, operator, approved);
  }

  function isApprovedForAll(address owner, address operator) public view override returns(bool) {
    return _operators[owner][operator];
  } 

  /* Enumerable */
  
  function totalSupply() public view returns (uint256) {
    return amountMintedHeroes;
  }

  /* TODO: Remove on production. Only for dev env. */

  function devDestroy() public {
    selfdestruct(contractOwner);
  }
}
