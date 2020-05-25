pragma solidity ^0.5.9;
contract Ballot {

    address owner;
    
    struct passengers_details {
        uint _id;
        uint passenger_wallet;
        string passengers_name;
        uint80 passengers_contact;
    }
    
    struct drivers_details {
        uint _id;
        uint drivers_wallet;
        string drivers_name;
        uint80 drivers_contact;
    }

    struct ride_details {
        uint id;
        uint driver_id;
        uint passenger_id;
        uint ride_fare;
        mapping (uint => drivers_details) drivers;
        mapping (uint => passengers_details) passengers;
    }
    
    uint public count;
    uint public dcount;
    uint public pcount;

    mapping(uint => ride_details) public curRide;
    mapping(uint => drivers_details) public driver;
    mapping(uint => passengers_details) public passenger;
    
    enum State {Waiting, StartRide, EndRide}
    State public state;
    
    modifier Owner {
        require (msg.sender == owner);
        _;
    }
    
    constructor() public {
        owner = msg.sender;
        state = State.Waiting;
    }
    
    function mint(uint receiver, uint amount) public  {
        passenger[receiver].passenger_wallet += amount;
    }

    function send(uint _sender, uint _receiver, uint _amount) public {
        if(state != State.EndRide) return;
        if (passenger[_sender].passenger_wallet < _amount) return;
        passenger[_sender].passenger_wallet -= _amount;
        driver[_receiver].drivers_wallet += _amount;
    }

    function addDriver(string memory _name, uint80 _contact) public Owner {
        dcount+=1;
        driver[dcount] = drivers_details(dcount, 0, _name, _contact);
    }
    
    function addPassenger(string memory _name, uint80 _contact) public Owner {
        pcount+=1;
        passenger[pcount] = passengers_details(pcount, 0, _name, _contact);
    }
    
    uint start;
    function startRide(uint _driverid) public Owner {
        if(dcount < _driverid) return;
        state = State.StartRide;
        start = block.timestamp;    
    }
    
    uint end;
    function endRide(uint _driverid) public Owner {
        if(dcount < _driverid) return;
        state = State.EndRide;
        end = block.timestamp;    
    }
    
    function addRideDetails(uint _driverid, uint _passengerid) public {
        
        if(_driverid > dcount && _passengerid > pcount) return;
        uint fare = (end-start) % start;
        count += 1;       
        curRide[count] = ride_details(count, _driverid, _passengerid, fare);
    }   
    
}