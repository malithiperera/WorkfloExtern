import ballerina/http;
import ballerina/io;

type Greeting record {
    string 'from;
    string to;
    string message;
};

http:Client clientEP = check new("https://30c2-203-94-95-2.in.ngrok.io");

service / on new http:Listener(8090) {
    resource function get .() returns Greeting|error? {
        Greeting greetingMessage = {"from" : "Choreo", "to" : "name", "message" : "Welcome to Choreo!"};
        http:Response res = check clientEP->get("/api/workflow/testmap");
io:print(res);
        return greetingMessage;
    }


}

