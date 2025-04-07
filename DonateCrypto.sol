// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

struct Campaign {
    address author;
    string title;
    string description;
    string videoUrl;
    string imageUrl;
    uint256 balance;
    bool active;
}

contract DonateCrypto {
    uint256 public fee = 100; // wei é a fração da moeda, como centavos do real
    uint256 public nextId = 0;

    mapping(uint256 => Campaign) public campaigns; // id => map campaign

    function addCampaign(
        string calldata title,
        string calldata description,
        string calldata videoUrl,
        string calldata imageUrl
    ) public {
        Campaign memory newCampaign;
        newCampaign.title = title;
        newCampaign.description = description;
        newCampaign.videoUrl = videoUrl;
        newCampaign.imageUrl = imageUrl;
        newCampaign.active = true;
        newCampaign.author = msg.sender;

        nextId++;
        campaigns[nextId] = newCampaign;
    }

    function donate(uint256 id) public payable {
        require(
            msg.value > 0,
            "You must send a donation value greater than zero"
        );
        require(
            campaigns[id].active == true,
            "This campaign is not active yet."
        );

        campaigns[id].balance += msg.value;
    }

    function withdraw(uint256 id) public {
        Campaign memory campaign = campaigns[id];

        require(msg.sender == campaign.author, "You are not the author");
        require(
            campaigns[id].active == true,
            "This campaign is not active yet."
        );
        require(
            campaign.balance > fee,
            "This campaign has not enough money to withdraw"
        );

        address payable recipient = payable(campaign.author);
        recipient.call{value: campaign.balance - fee}("");

        campaigns[id].active = false;
    }
}
