pragma solidity ^0.4.8;


contract Nasdex{
    
    address owner;
    uint private reserveBalanceEther;
    uint private reserveRatio;
    uint public tokenPrice;
    uint public tokenMarketSupply;
    
    
    
    
    
    //mapping balances to addresses
    mapping (address=>uint) tokenBalance;
   
    
    
    //recording events
    event buy(address buyer,uint amount);
    event sell(address seller,uint amount);
    
    
    //modifiers
     modifier onlyOwner(){
        if (msg.sender!=owner){
            revert();
        }
        _;
    }
    
    
    //constructor
    function Nasdex(uint price,uint crr,uint supply) payable{
        owner=msg.sender;
        reserveBalanceEther=msg.value;
        tokenPrice=price;
        reserveRatio=crr;
        tokenMarketSupply=supply;
    
        
    }
    
    
   // calculate token Price based on reserveether,supply and reserveratio
   function tokenPrice() returns(uint tokenPrice){
       return tokenPrice;
       
   }
    
    //buyToken Nasdex    
    function buyToken() payable returns(bool){
        uint amount=msg.value;
        if (amount==0) throw;
        uint tokens=amount/tokenPrice;
        tokenBalance[msg.sender]+=tokens;
        tokenMarketSupply+=tokens;
        reserveBalanceEther+=amount;
        tokenPrice=reserveBalanceEther/(tokenMarketSupply*reserveRatio);
        buy(msg.sender,tokens);
        return true;
    }
    
    
    
    //withdraw ether and burn tokens
    function sellToken(uint amountTokens) returns (bool){
        if (amountTokens==0) throw;
        uint value=amountTokens*tokenPrice;
        if (tokenBalance[msg.sender]>=value){
                msg.sender.transfer(value);
                tokenMarketSupply-=amountTokens;
                reserveBalanceEther-=value;
                tokenPrice=reserveBalanceEther/(tokenMarketSupply*reserveRatio);
            
        }
        else{
            revert();
        }
        
    }
    
    
    //check tokenBalance
    function checkTokenBalance() returns(uint ){
        return  tokenBalance[msg.sender];
        
    }
    
    
    //check etherBalance of the contarct
    
    function checkEtherBalance() onlyOwner returns (uint ){
        return this.balance;
        
    }
    
   
    //check totalTOken supply
    function checkTokensupply() onlyOwner returns(uint ){
        return tokenMarketSupply;
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
