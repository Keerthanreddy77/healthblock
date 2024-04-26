pragma solidity 0.5.16;

contract PatientData {
    uint256 public countMedicalReports = 0;

    mapping(address => Sender) public senders;
    mapping(uint => PatientMedicalReportStruct) public medicalReports;

    struct PatientBioStruct {
        string name;
        string birthDate;
        string phoneNumber;
        string _address;
        uint medicalReportNo;
    }

    struct PatientMedicalReportStruct {
        address senderId;
        string medReportId;
        uint weight;
        uint height;
        string bloodGroup;
        string diseaseName;
        string diseaseDescription;
        string diseaseStartedOn;
    }

    struct Sender {
        string name;
        string institutionName;
        string institutionCode;
        uint patientCount;
        mapping(uint => string) patientsArray;
        mapping(string => PatientBioStruct) patients;
    }

    constructor() public {
    }

    // Add encryption function
    function encrypt(string memory _data, string memory _key) internal pure returns (string memory) {
        bytes memory dataBytes = bytes(_data);
        bytes memory keyBytes = bytes(_key);
        bytes memory encryptedBytes = new bytes(dataBytes.length);

        for (uint i = 0; i < dataBytes.length; i++) {
            encryptedBytes[i] = dataBytes[i] ^ keyBytes[i % keyBytes.length];
        }

        return string(encryptedBytes);
    }

    // Add decryption function
    function decrypt(string memory _encryptedData, string memory _key) internal pure returns (string memory) {
        bytes memory encryptedBytes = bytes(_encryptedData);
        bytes memory keyBytes = bytes(_key);
        bytes memory decryptedBytes = new bytes(encryptedBytes.length);

        for (uint i = 0; i < encryptedBytes.length; i++) {
            decryptedBytes[i] = encryptedBytes[i] ^ keyBytes[i % keyBytes.length];
        }

        return string(decryptedBytes);
    }

    function addMedicalReport(
        string memory patientId,
        string memory patientName, 
        string memory birthDate, 
        string memory phoneNumber, 
        string memory _address,
        string memory medReportId,
        uint weight,
        uint height,
        string memory bloodGroup,
        string memory diseaseName,
        string memory diseaseDescription,
        string memory diseaseStartedOn
    ) public {
        // Encrypt sensitive data
        string memory encryptedDiseaseDescription = encrypt(diseaseDescription, medReportId);

        Sender storage sender = senders[msg.sender];
        if (bytes(sender.patients[patientId].name).length == 0) {
            sender.patientsArray[sender.patientCount++] = patientId;
            sender.patients[patientId].name = patientName;
            sender.patients[patientId].birthDate = birthDate;
            sender.patients[patientId].phoneNumber = phoneNumber;
            sender.patients[patientId]._address = _address;
            sender.patients[patientId].medicalReportNo = countMedicalReports;
        }

        medicalReports[countMedicalReports++] = PatientMedicalReportStruct(
            msg.sender,
            medReportId,
            weight,
            height,
            bloodGroup,
            diseaseName,
            encryptedDiseaseDescription, // Store encrypted disease description
            diseaseStartedOn
        );
    }

    // Function to retrieve patient list
    function getPatientsList(uint index) public view returns (
        string memory,
        string memory, 
        string memory, 
        string memory, 
        uint
    ) {
        Sender storage sender = senders[msg.sender];
        string memory patientId = sender.patientsArray[index];
        PatientBioStruct memory patient = sender.patients[patientId];

        return (
            patient.name,
            patient.birthDate,
            patient.phoneNumber,
            patient._address,
            patient.medicalReportNo
        );
    }
}
