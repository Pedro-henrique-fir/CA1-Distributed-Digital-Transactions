// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.2;


contract HotelBooking {
    address public owner;
    uint public roomCount;

    struct Room {uint price; bool active; bool exists;}

    mapping(uint => Room) public rooms;

    event RoomAdded(uint roomNumber, uint price);
    event RoomPriceUpdated(uint roomNumber, uint newPrice);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addRoom(uint _roomNumber, uint _price) public onlyOwner {
        require(!rooms[_roomNumber].exists, "Room already exists.");
        require(_price > 0, "Invalid price.");

        rooms[_roomNumber] = Room(_price, true, true);
        roomCount++;
        emit RoomAdded(_roomNumber, _price);
    }


    function updateRoomPrice(uint _roomNumber, uint _newPrice) public onlyOwner {
        require(rooms[_roomNumber].exists, "Room does not exist.");
        require(_newPrice > 0, "Invalid price.");

        rooms[_roomNumber].price = _newPrice;
        emit RoomPriceUpdated(_roomNumber, _newPrice);
    }


    function getRoom(uint _roomNumber) public view returns (uint price, bool active) {
        require(rooms[_roomNumber].exists, "Room does not exist.");
        Room memory room = rooms[_roomNumber];
        return (room.price, room.active);
    }
}
