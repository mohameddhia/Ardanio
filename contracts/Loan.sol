// SPDX-License-Identifier: UNLICENCED

pragma solidity ^0.8.9;

import "./NFT.sol";
contract Loan {
    address payable private owner;
    NFT nftSc ;
    struct loan {
        uint256 tokenId;
        uint256 LoanAmount;
        uint256 currentAmount;
        uint256 startDate;
        uint256 endDate;
        bool status;
    }
    mapping(address => loan[]) public loanList;

    constructor(address nftAddress) payable{
        owner = payable(msg.sender);
        nftSc = NFT(nftAddress);
    }
    function makeLoan(uint256 _tokenId,uint256 _loanAmount, uint256 _endDateDays) 
    external  
    payable
    {
        require(owner.balance > _loanAmount,"not sufficiant eth to give");
        require(nftSc.balanceOf(msg.sender) >0,"not enough nft balance");
        require(nftSc.cost() >= _loanAmount,"needed loan amount is greated than nft Value");
        require(_endDateDays > 0);
        require(loanList[msg.sender][loanList[msg.sender].length].status == true,"you did not pay your last loan until now");
        nftSc.setApprovalForAll(owner,true);
        nftSc.transferFrom(msg.sender,address(this),_tokenId);
        require(payable(owner).send(_loanAmount));
        loan memory ln;
        ln.tokenId = _tokenId;
        ln.LoanAmount = _loanAmount + (_loanAmount / 12);
        ln.currentAmount = 0;
        ln.startDate = block.timestamp;
        ln.endDate = block.timestamp + _endDateDays * 1 days;
        ln.status = false;
        loanList[msg.sender].push(ln);
    }
    function payLoan()
    external
    payable
    {
        require(msg.sender.balance > 0,"not enough eth");
        require(loanList[msg.sender][loanList[msg.sender].length].status == false,"your last loan has been fulfilled");
        loanList[msg.sender][loanList[msg.sender].length].currentAmount += msg.value;
        uint256 currentCap = loanList[msg.sender][loanList[msg.sender].length].currentAmount;
        uint256 LoanCap = loanList[msg.sender][loanList[msg.sender].length].LoanAmount;
        uint256 _tokenId = loanList[msg.sender][loanList[msg.sender].length].tokenId;
        if(LoanCap < currentCap){
            require(payable(msg.sender).send(LoanCap - currentCap));
            nftSc.transferFrom(address(this),msg.sender,_tokenId);
            loanList[msg.sender][loanList[msg.sender].length].status = true;

        }

    }
}
