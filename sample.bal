import ballerina/http;

type Greeting record {
    string 'from;
    string to;
    string message;
};

http:Client clientEP = check new("http://localhost:8080");

service / on new http:Listener(8090) {
    resource function get .() returns Greeting|error? {
        Greeting greetingMessage = {"from" : "Choreo", "to" : "name", "message" : "Welcome to Choreo!"};
        http:Response res = check clientEP->get("choreo");

        return greetingMessage;
    }


}

