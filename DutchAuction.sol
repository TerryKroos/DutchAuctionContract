pragma solidity ^0.4.9;

contract DutchAuction {


    address private seller;
    address private highestBidder;
    uint private  highestBid;
    uint256 private  initialPrice;
    uint256 private reservePrice;
    address private judgeAddress;
    uint256 private numBlocksAuctionOpen;
    uint256 private  offerPriceDecrement;
    bool private auctionOver;
    uint256 private  startBlock;
    uint private currentBlock = 0;
    bool private winnerAck;
    bool private refundCalled;
    bool private finalizeCalled;





    constructor(uint256 _reservePrice, address _judgeAddress, uint256 _numBlocksAuctionOpen, uint256 _offerPriceDecrement) public payable{
        seller = msg.sender;
        startBlock = block.number;
        reservePrice = _reservePrice;
        judgeAddress = _judgeAddress;
        numBlocksAuctionOpen = _numBlocksAuctionOpen;
        offerPriceDecrement = _offerPriceDecrement;
        initialPrice = reservePrice + numBlocksAuctionOpen * offerPriceDecrement;

    }

    function bid() payable external returns(address) {
        require(block.number - startBlock < numBlocksAuctionOpen );
        require(auctionOver == false);
        initialPrice =initialPrice - (block.number - startBlock)* offerPriceDecrement;
        require(msg.value >= initialPrice);

        auctionOver = true;
        highestBid = msg.value;
        highestBidder = msg.sender;



        if(judgeAddress == 0){
            seller.transfer(highestBid);

        }
        return highestBidder;
    }

    function finalize() public {
        require(msg.sender == judgeAddress || msg.sender == highestBidder);
        require(finalizeCalled ==false);
        require(highestBid > 0);
        require(auctionOver == true);
        require(refundCalled == false && finalizeCalled == false);
        require(seller != judgeAddress);
        finalizeCalled = true;

        seller.transfer(highestBid);






    }

    function refund() public {
        require(auctionOver == true);
        require(highestBid > 0);
        require(msg.sender == judgeAddress);
        require(seller != judgeAddress);
        require(refundCalled == false && finalizeCalled == false);
        require(msg.sender!=0);
        require(judgeAddress!=0);

        refundCalled = true;



        highestBidder.transfer(highestBid);
    }


    //for testing framework
    function nop() public returns(bool) {
        return true;
    }

}
