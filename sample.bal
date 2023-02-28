import ballerina/http;

import ballerina/io;
import ballerina/mime;

http:Client clientEP = check new (" https://9731-2402-d000-a400-dd1e-c491-ee55-d21b-1959.in.ngrok.io");
http:Client clientEPBPMN = check new ("https://7c09-2402-d000-a400-7d25-5872-c55d-5d16-9eb4.in.ngrok.io");

service / on new http:Listener(8090) {
    resource function get .() returns string|error? {

        http:Response res = check clientEP->get("/api/workflow/testmap");
        io:print(res);

        return res.getTextPayload();
    }

    resource function post .(http:Caller caller, http:Request request) returns error? {
        json res = check request.getJsonPayload();
        io:println(res);
        check caller->respond(res.toString());
    }

    resource function get bpmndata() returns string|error? {

        http:Response res = check clientEP->get("/api/workflow/testmap/see");
        io:print(res);

        return res.getTextPayload();
    }

     resource function post bpmndata(http:Caller caller, http:Request request) returns error? {
        json requestbody = check request.getJsonPayload();
        // string userCredentials = "admin:admin";
        // byte[] inputArr = userCredentials.toBytes();
        // string encode=inputArr.toBase64();
        // string encodedString = check url:encode(encode, "UTF-8");
        // string encodedString1 = "Basic" + encodedString; 

        string userCredentials = "admin:admin";
    string basicAuth = "Basic " + <string>(check mime:base64Encode(userCredentials, "UTF-8"));
  
        map<string> headers = {"Content-Type": "application/json", "Authorization": basicAuth,"Content-Language": "en-US","Accept":"*/*"};
        http:Response res = check clientEPBPMN->post("/bpmn/runtime/process-instances/", requestbody, headers);

        check caller->respond(res);
      
    }
}

// public function soapRequest() {

// soap:Soap12Client soapClient = new("http://localhost:9000/services");
//     xml body = xml `<m0:getQuote xmlns:m0="http://services.samples">
//                         <m0:request>
//                             <m0:symbol>WSO2</m0:symbol>
//                         </m0:request>
//                     </m0:getQuote>`;

//     var resp = soapClient->sendReceive("/SimpleStockQuoteService", "urn:getQuote", body);
//     if (resp is soap:SoapResponse) {
//         io:println(resp);
//     } else {
//         io:println(resp.detail().message);
//     }

// }

