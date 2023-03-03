// import ballerina/io;
// import ballerina/io;

function convertBPMN(json requestbody) returns json|error {
    BPMNDataRecord bpmnPayload = check requestbody.cloneWithType(BPMNDataRecord);
      json jsonData = bpmnPayload.toJson();
      return jsonData;

}










