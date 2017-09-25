pragma solidity ^0.4.11;


contract Nasdex{
    
    address owner;
    uint256 private reserveBalanceEther;
    uint256 private reserveRatio;
    uint256 public tokenPrice;
    uint256 public tokenMarketSupply;
    
    
    
    
    
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
    function Nasdex(uint crr,uint supply) payable{
        owner=msg.sender;
        reserveBalanceEther=msg.value;
        tokenPrice=msg.value/100000000000000000;
        reserveRatio=crr;
        tokenMarketSupply=supply;
    
        
    }
    
    
   // calculate token Price based on reserveether,supply and reserveratio
   function tokenPrice() external returns(uint256){
       return tokenPrice;
       
   }
    
    //buyToken Nasdex    
    function buyToken() payable external returns(bool ){
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
    function sellToken(uint amountTokens) external returns (bool){
        if (amountTokens==0) revert();
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
    function checkTokenBalance() external  returns(uint256 ){
        return  tokenBalance[msg.sender];
        
    }
    
    
    //check etherBalance of the contarct
    
    function checkEtherBalance() onlyOwner external  returns (uint256 ){
        return this.balance;
        
    }
    
   
    //check totalTOken supply
    function checkTokensupply() onlyOwner external  returns(uint256 ){
        return tokenMarketSupply;
    }
    
    
    
}
