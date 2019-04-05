pragma solidity ^0.4.25;


contract GrantTrackingApplicationLine12 {
    
    address public requestedFrom;
    address public recipient;
    address public headerContractAddress;
    uint public id;
    uint public parentContractId;
    enum StateType {
        Requested,
        Approved,
        Funded,
        ReportingRequired,
        Compliant,
        OutOfCompliance,
        GrantRequestedFromRecipient,
        Closed
    } 
    StateType public State;

    uint public grantRequested;
    uint public reportingPeriod;
    uint public gracePeriod;
    uint public grantApproved;
    uint public grantRemaining;
    string public fileUrl;

    modifier onlyCallableFromHeader() {
        require(headerContractAddress == msg.sender);
        _;
    }

    constructor( uint _grantRequested, address _requestedFrom, uint _contractId, uint _parentContractId, address _headerContractAddress, address _recipient, string _fileUrl ) public {
        grantRequested = _grantRequested;
        requestedFrom = _requestedFrom;
        recipient = _recipient;
        id = _contractId;
        parentContractId = _parentContractId;
        headerContractAddress = _headerContractAddress;
        fileUrl = _fileUrl;
        State = StateType.Requested;
    }

    function requestGrant() public onlyCallableFromHeader{
        State = StateType.GrantRequestedFromRecipient;
    }

    function approveGrant( uint _grantApproved ) public onlyCallableFromHeader {
        grantApproved = _grantApproved;
        grantRemaining = _grantApproved;
        State = StateType.Approved;
    }

    function grantFund( uint _reportingPeriod, uint _gracePeriod ) public onlyCallableFromHeader {
        reportingPeriod = _reportingPeriod;
        gracePeriod = _gracePeriod;
        State = StateType.Funded;
    }

    function requireReporting()  public onlyCallableFromHeader{
        State = StateType.ReportingRequired;
    }

    function report( bool _isTriggeredByRecipient, bool _isTriggeredByFlow, uint _grantTransferred, uint _grantUsed ) public onlyCallableFromHeader {
        if(_isTriggeredByRecipient) {
            State = StateType.Compliant;
        } else {
            State = StateType.OutOfCompliance;
        }
    }
    
    function close() public onlyCallableFromHeader{
        State = StateType.Closed;
    }
    

    function deductMoneyFromParentContract(uint _grantApprovedToSomeOtherContract) public returns ( uint){
        grantRemaining = grantRemaining - _grantApprovedToSomeOtherContract;
        return grantRemaining;
    }
}