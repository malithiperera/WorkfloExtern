import ballerina/http;

import ballerina/io;
//import ballerina/mime;

http:Client clientEP = check new ("https://9731-2402-d000-a400-dd1e-c491-ee55-d21b-1959.in.ngrok.io");
http:Client clientEPBPMN = check new ("https://47f2-2402-d000-a500-8b95-555-9be0-e525-98b2.in.ngrok.io");

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
    //  string userCredentials = "admin:admin";
    // string basicAuth = "Basic " + <string>(check mime:base64Encode(userCredentials, "UTF-8"));
  
    //     map<string> headers = {"Content-Type": "application/json", "Authorization": basicAuth,"Content-Language": "en-US","Accept":"*/*"};
    //     http:Response res = check clientEPBPMN->post("/bpmn/runtime/process-instances/", requestbody, headers);

        string var1 = requestbody.toString();
        check caller->respond(var1);
      
    }
}

// public function main() returns error? {

// Soap12Client soapClient = check new("https://www.w3schools.com/xml/tempconvert.asmx");

//     xml body = xml `<FahrenheitToCelsius xmlns="https://www.w3schools.com/xml/">

//       <Fahrenheit>75</Fahrenheit>

//     </FahrenheitToCelsius>`;

//     var response = soapClient->sendReceive(body);
//     if (response is SoapResponse) {
//         io:println(response["payload"]);
//     } else {
//         io:println(response.message());
//     }
// }

