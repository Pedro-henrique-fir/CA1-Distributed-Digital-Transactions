// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.2;


contract HotelBooking {
    address public owner;
    uint public roomCount;
    uint public bookingCount;

    struct Room {uint price; bool active; bool exists;}

    mapping(uint => Room) public rooms;

    enum BookingStatus {
        Confirmed,
        Cancelled,
        Completed
    }

    struct Booking {
        uint bookingId;
        uint roomNumber;
        address guest;
        uint checkInTime;
        uint amountPaid;
        BookingStatus status;
    }

    mapping(uint => Booking) public bookings;
    mapping(uint => mapping(uint => bool)) public bookedDates;

    event RoomAdded(uint roomNumber, uint price);
    event RoomPriceUpdated(uint roomNumber, uint newPrice);

    event BookingCreated(
        uint bookingId,
        uint roomNumber,
        address guest,
        uint checkInTime
    );

    event PaymentReceived(address guest, uint amount);

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

    function checkAvailability(uint _roomNumber, uint _daysFromToday) public view returns (bool) {
        uint checkInDay = (block.timestamp / 1 days) + _daysFromToday;
        uint checkInTime = checkInDay * 1 days + 15 hours;

        return (rooms[_roomNumber].exists && rooms[_roomNumber].active && checkInTime > block.timestamp && !bookedDates[_roomNumber][checkInDay]);
    }

    function bookRoom(uint _roomNumber, uint _daysFromToday) public payable {
        require(checkAvailability(_roomNumber, _daysFromToday), "Room not available.");

        Room memory room = rooms[_roomNumber];

        require(msg.value == room.price, "Incorrect payment amount.");

        uint checkInDay = (block.timestamp / 1 days) + _daysFromToday;
        uint checkInTime = checkInDay * 1 days + 15 hours;
        uint bookingId = bookingCount;

        bookings[bookingId] = Booking(
            bookingId,
            _roomNumber,
            msg.sender,
            checkInTime,
            msg.value,
            BookingStatus.Confirmed
        );

        bookedDates[_roomNumber][checkInDay] = true;
        bookingCount++;

        emit BookingCreated(
            bookingId,
            _roomNumber,
            msg.sender,
            checkInTime
        );

        emit PaymentReceived(msg.sender, msg.value);
    }

    function getBooking(uint _bookingId) public view returns (uint roomNumber, address guest, uint checkInTime, uint amountPaid, BookingStatus status) {
        require(_bookingId < bookingCount, "Booking does not exist.");
        Booking memory booking = bookings[_bookingId];
        return (booking.roomNumber, booking.guest, booking.checkInTime, booking.amountPaid, booking.status);

    }


    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}



