pragma solidity ^0.5.9;
contract Ballot {

    address owner;
    event Sent(address from, address to, uint amount);
    
    struct passengers_details {
        address _id;
        uint passenger_wallet;
        string passengers_name;
        uint80 passengers_contact;
    }
    
    struct drivers_details {
        address _id;
        uint drivers_wallet;
        string drivers_name;
        uint80 drivers_contact;
    }

    struct ride_details {
        uint id;
        address driver_id;
        address passenger_id;
        uint ride_fare;
        mapping (uint => drivers_details) drivers;
        mapping (uint => passengers_details) passengers;
    }
    
    uint public count;
    uint public dcount;
    uint public pcount;

    mapping(uint => ride_details) public curRide;
    mapping(address => drivers_details) public driver;
    mapping(address => passengers_details) public passenger;
    
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
    
    function mint(address _receiver, uint amount) public  {
        if(passenger[_receiver]._id != _receiver)   return;
        passenger[_receiver].passenger_wallet += amount;
    }

    function send(address _sender, address _receiver, uint _amount) public {
        if(state != State.EndRide) return;
        if (passenger[_sender].passenger_wallet < _amount) return;
        passenger[_sender].passenger_wallet -= _amount;
        driver[_receiver].drivers_wallet += _amount;
        emit Sent(_sender, _receiver, _amount);
    }

    function addDriver(address _driver, string memory _name, uint80 _contact) public Owner {
        dcount+=1;
        driver[_driver] = drivers_details(_driver, 0, _name, _contact);
    }
    
    function addPassenger(address _passenger, string memory _name, uint80 _contact) public Owner {
        pcount+=1;
        passenger[_passenger] = passengers_details(_passenger, 0, _name, _contact);
    }
    
    uint start;
    function startRide(address _driverid) public {
        if(driver[_driverid]._id != _driverid) return;
        state = State.StartRide;
        start = block.timestamp;    
    }
    
    uint end;
    function endRide(address _driverid) public {
        if(driver[_driverid]._id != _driverid) return;
        state = State.EndRide;
        end = block.timestamp;
    }
    
    function addRideDetails(address _driverid, address _passengerid) public {
        if(driver[_driverid]._id != _driverid || passenger[_passengerid]._id != _passengerid) return;
        uint fare = (end-start) % start;
        count += 1;       
        curRide[count] = ride_details(count, _driverid, _passengerid, fare);
    }   
    
}