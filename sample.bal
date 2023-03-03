import ballerina/http;

import ballerina/io;
import ballerina/mime;

http:Client clientEP = check new ("https://9731-2402-d000-a400-dd1e-c491-ee55-d21b-1959.in.ngrok.io");
http:Client clientEPBPMN = check new ("https://47f2-2402-d000-a500-8b95-555-9be0-e525-98b2.in.ngrok.io");
http:Client clientBPEL = check new (" https://0066-2402-d000-a400-6112-c828-967f-36-d2f4.in.ngrok.io");

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
    



    //bpmn endpoint 
     resource function post bpmndata(http:Caller caller, http:Request request) returns error? {
        json requestbody = check request.getJsonPayload();
        json jsonData = check convertBPMN(requestbody);
        string userCredentials = "admin:admin";
        string basicAuth = "Basic " + <string>(check mime:base64Encode(userCredentials, "UTF-8"));
  
        map<string> headers = {"Content-Type": "application/json", "Authorization": basicAuth,"Content-Language": "en-US","Accept":"*/*"};
        http:Response res = check clientEPBPMN->post("/bpmn/runtime/process-instances/", jsonData, headers);
        check caller->respond(res);
      
    }



    //bepl endpoint
 resource function post bpeldata(http:Caller caller, http:Request request) returns error? {
        json requestbody = check request.getJsonPayload();
        xml|error? xmlData = convertBPEL(requestbody);
        io.print(xmlData);
        string userCredentials = "admin:admin";
        string basicAuth = "Basic " + <string>(check mime:base64Encode(userCredentials, "UTF-8"));
        map<string> headers = {"Content-Type": "application/xml", "Authorization": basicAuth,"Content-Language": "en-US","Accept":"*/*"};
        http:Response res = check clientBPEL->post("/services/create_RoleService", check xmlData,headers);
        io:print(res);

      }



//camunda endpoint
 resource function post camunda(http:Caller caller, http:Request request) returns error? {
        json requestbody = check request.getJsonPayload();
    }


}







