
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FeePaymentScholarship {

    address public admin;

    struct Student {
        uint256 totalFees;
        uint256 feesPaid;
        bool isRegistered;
        bool hasScholarship;
    }

    mapping(address => Student) public students;

    event StudentRegistered(address student, uint256 totalFees);
    event FeePaid(address student, uint256 amount);
    event ScholarshipGranted(address student);

    constructor() {
        admin = msg.sender; // admin is contract deployer
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }

    // ---------------------------------------
    // 1. Register a student with total fee
    // ---------------------------------------
    function registerStudent(address _student, uint256 _totalFees)
        external
        onlyAdmin
    {
        require(!students[_student].isRegistered, "Already registered");

        students[_student] = Student({
            totalFees: _totalFees,
            feesPaid: 0,
            isRegistered: true,
            hasScholarship: false
        });

        emit StudentRegistered(_student, _totalFees);
    }

    // ---------------------------------------
    // 2. Students pay fee (payable)
    // ---------------------------------------
    function payFees() external payable {
        Student storage s = students[msg.sender];

        require(s.isRegistered, "You are not registered");
        require(msg.value > 0, "No amount sent");
        require(s.feesPaid + msg.value <= s.totalFees, "Exceeds total fees");

        s.feesPaid += msg.value;

        emit FeePaid(msg.sender, msg.value);
    }

    // ---------------------------------------
    // 3. Admin grants scholarship
    // ---------------------------------------
    function grantScholarship(address _student) external onlyAdmin {
        Student storage s = students[_student];

        require(s.isRegistered, "Not registered");
        require(!s.hasScholarship, "Already has scholarship");

        s.hasScholarship = true;

        emit ScholarshipGranted(_student);
    }

    // ---------------------------------------
    // 4. Get details of a student
    // ---------------------------------------
    function getStudentDetails(address _student)
        external
        view
        returns (
            uint256 totalFees,
            uint256 feesPaid,
            bool isRegistered,
            bool hasScholarship
        )
    {
        Student memory s = students[_student];
        return (s.totalFees, s.feesPaid, s.isRegistered, s.hasScholarship);
    }
}
