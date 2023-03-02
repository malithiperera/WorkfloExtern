

import ballerina/crypto;
import ballerina/http;
import ballerina/lang.'xml as xmllib;
import ballerina/log;
import ballerina/mime;
// import ballerina/system;

import ballerina/uuid;
import ballerina/time;

# Provides the namespace for the given SOAP version.
#
# + soapVersion - The SOAP version of the request
# + return - The namespace for the given SOAP version
function getNamespace(SoapVersion soapVersion) returns string {
    if (soapVersion == SOAP11) {
        return SOAP11_NAMESPACE;
    }
    return SOAP12_NAMESPACE;
}

# Provides the encoding style for the given SOAP version.
#
# + soapVersion - The SOAP version of the request
# + return - The encoding style for the given SOAP version
function getEncodingStyle(SoapVersion soapVersion) returns string {
    if (soapVersion == SOAP11) {
        return SOAP11_ENCODING_STYLE;
    }
    return SOAP12_ENCODING_STYLE;
}

# Provides an empty SOAP envelope for the given SOAP version.
#
# + soapVersion - The SOAP version of the request
# + return - XML with the empty SOAP envelope
function createSoapEnvelop(SoapVersion soapVersion) returns xmllib:Element {
    string namespace = getNamespace(soapVersion);
    string encodingStyle = getEncodingStyle(soapVersion);
    if (soapVersion == SOAP11) {
        return <xmllib:Element> xml `<soap:Envelope
        xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
        soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
                </soap:Envelope>`;
    } else {
        return <xmllib:Element> xml `<soap:Envelope
        xmlns:soap="http://www.w3.org/2003/05/soap-envelope"
        soap:encodingStyle="http://www.w3.org/2003/05/soap-encoding">
                </soap:Envelope>`;
    }
}

# Provides the WS-Addressing header.
#
# + options - SOAP options to be sent
# + return - XML with the WS-addressing header
function getWSAddressingHeaders(Options options) returns xml {
    xmlns "https://www.w3.org/2005/08/addressing" as wsa;

    // This `requestTo` parameter is already validated as an `xml` before calling this method.
    string requestTo = options?.wsAddressing["requestTo"] ?: "";
    var wsaAction = options?.wsAddressing["wsaAction"];

    xml headerElement = xml `<wsa:To>${requestTo}</wsa:To>`;
    if (wsaAction is string) {
        headerElement = headerElement + xml `<wsa:Action>${wsaAction}</wsa:Action>`;
    }

    var relatesTo = options?.wsAddressing["relatesTo"];
    if (relatesTo is string) {
        xmllib:Element relatesToElement = <xmllib:Element> xml `<wsa:RelatesTo>${relatesTo}</wsa:RelatesTo>`;
        var relationshipType = options?.wsAddressing["relationshipType"];
        if (relationshipType is string) {
            map<string> relatesAttr = relatesToElement.getAttributes();
            relatesAttr[wsa:RelatesTo] = relationshipType;
        } else {
            log:printDebug("relationshipType is not of type string");
        }
        xml relatesToXml = relatesToElement;
        headerElement = headerElement + relatesToXml;
    }

    var requestFrom = options?.wsAddressing["requestFrom"];
    if (requestFrom is string) {
        xml fromElement = xml `<wsa:From>${requestFrom}</wsa:From>`;
        headerElement = headerElement + fromElement;
    }

    var replyTo = options?.wsAddressing["replyTo"];
    if (replyTo is string) {
        var messageId = options?.wsAddressing["messageId"];
        if (messageId is string) {
            xml messageIDElement = xml `<wsa:MessageID>${messageId}</wsa:MessageID>`;
            headerElement = headerElement + messageIDElement;
        } else {
            error err = error(SOAP_ERROR_CODE,
            message = "If ReplyTo element is present, wsa:MessageID MUST be present");
            panic err;
        }
        xml replyToElement = xml `<wsa:ReplyTo><wsa:Address>${replyTo}</wsa:Address></wsa:ReplyTo>`;
        headerElement = headerElement + replyToElement;
    }

    var faultTo = options?.wsAddressing["faultTo"];
    if (faultTo is string) {
        xml faultToElement = xml `<wsa:FaultTo>${faultTo}</wsa:FaultTo>`;
        headerElement = headerElement + faultToElement;
    } else {
        log:printDebug("faultTo is not of type string");
    }

    return headerElement;
}

# Provides the WS-secure username token headers.
#
# + options - SOAP options to be sent
# + return - XML with the WS-secure username token headers
function getWSSecureUsernameTokenHeaders(Options options) returns xml {
    xmlns "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" as wsse;
    xmlns "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" as wsu;

    string username = options?.usernameToken["username"] ?: "";
    string password = options?.usernameToken["password"] ?: "";

    xmllib:Element securityRoot = <xmllib:Element> xml `<wsse:Security></wsse:Security>`;
    xmllib:Element usernameTokenRoot = <xmllib:Element> xml `<wsse:UsernameToken> </wsse:UsernameToken>`;
    xml usernameElement = xml `<wsse:Username>${username}</wsse:Username>`;
    xml passwordElement;

    time:Utc time = time:utcNow();
    xml timestampElement = xml `<wsu:Timestamp><wsu:Created>${time.toString()}</wsu:Created></wsu:Timestamp>`;

    var passwordType = options?.usernameToken["passwordType"];
    if (passwordType is ()) {
        passwordType = "PasswordText";
    }
    string pwdType = <string>passwordType;
    if (equalsIgnoreCase("PasswordDigest", pwdType)) {
        string nonce = uuid:createType4AsString();
        string encodedNonce = nonce.toBytes().toBase64();
        string createdTime = time.toString();
        password = createDigestPassword(nonce, password, createdTime);
        xml passwordDigest = xml `<wsse:Password Type="${PWD_DIGEST}">${password}</wsse:Password>`;
        xml nonceElement = xml `<wsse:Nonce EncodingType="${BASE64ENCODED}">${encodedNonce}</wsse:Nonce>`;
        xml createdTimeElement = xml `<wsu:Created>${createdTime}</wsu:Created>`;
        passwordElement = passwordDigest + nonceElement + createdTimeElement;
    } else {
        passwordElement = xml `<wsse:Password Type="${PWD_TEXT}">${password}</wsse:Password>`;
    }

    xml headerElement = usernameElement + passwordElement;
    usernameTokenRoot.setChildren(headerElement);
    xml userTokenXml = usernameTokenRoot;
    userTokenXml = userTokenXml + timestampElement;
    securityRoot.setChildren(usernameTokenRoot);
    return securityRoot;
}

# Provides the SOAP headers in the request as XML.
#
# + options - SOAP options to be sent
# + soapVersion - The SOAP version of the request
# + return - XML with the empty SOAP header
function createSoapHeader(SoapVersion soapVersion, Options? options = ()) returns xml {
    string namespace = getNamespace(soapVersion);
    xmllib:Element headersRoot;
    if (soapVersion == SOAP11) {
        headersRoot = <xmllib:Element> xml `<soap:Header xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"></soap:Header>`;
    } else {
        headersRoot = <xmllib:Element> xml `<soap:Header xmlns:soap="http://www.w3.org/2003/05/soap-envelope"></soap:Header>`;
    }
    xml? headerElement = ();
    if (options is Options) {
        xml[] headers = options["headers"] ?: [];
        if (headers.length() != 0) {
            int i = 1;
            xml headersXML = headers[0];
            while (i < headers.length()) {
                headersXML = headersXML + headers[i];
                i = i + 1;
            }
            headerElement = headersXML;
        }
        if (options["wsAddressing"]["requestTo"] is string) {
            if (headerElement is ()) {
                headerElement = getWSAddressingHeaders(options);
            } else {
                headerElement = headerElement + getWSAddressingHeaders(options);
            }
        }
        if (options["usernameToken"]["username"] is string) {
            if (headerElement is ()) {
                headerElement = getWSSecureUsernameTokenHeaders(options);
            } else {
                headerElement = headerElement + getWSSecureUsernameTokenHeaders(options);
            }
        }
        if (headerElement is xml && (headerElement/*).length() != 0) {
            headersRoot.setChildren(headerElement);
        }
    }
    return headersRoot;
}

# Provides the SOAP body in the request as XML.
#
# + payload - The payload to be sent
# + soapVersion - The SOAP version of the request
# + return - XML with the SOAP body
function createSoapBody(xml payload, SoapVersion soapVersion) returns xml {
    string namespace = getNamespace(soapVersion);
    xmllib:Element bodyRoot;
    if (soapVersion == SOAP11) {
        bodyRoot = <xmllib:Element> xml `<soap:Body xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"></soap:Body>`;
    } else {
        bodyRoot = <xmllib:Element> xml `<soap:Body xmlns:soap="http://www.w3.org/2003/05/soap-envelope"></soap:Body>`;
    }
    bodyRoot.setChildren(payload);
    return bodyRoot;
}

# Prepares a SOAP envelope with the XML to be sent.
#
# + soapAction - SOAP action
# + body - SOAP request body as an `XML` or `mime:Entity[]` to work with soap attachments
# + options - The SOAP options to be sent
# + soapVersion - The SOAP version of the request
# + return - The SOAP Request sent as `http:Request` with the SOAP envelope
function fillSOAPEnvelope(SoapVersion soapVersion, xml | mime:Entity[] body, string? soapAction = (), Options? options = ())
returns http:Request {
    xml soapPayload = createSoapHeader(soapVersion, options = options);
    http:Request req = new;
    var requestPayload = body;
    if (requestPayload is xml) {
        xml bodyPayload = createSoapBody(requestPayload, soapVersion);
        soapPayload = soapPayload + bodyPayload;

        xmllib:Element soapEnv = createSoapEnvelop(soapVersion);
        soapEnv.setChildren(soapPayload);
        req.setXmlPayload(soapEnv);
    } else {
        req.setBodyParts(requestPayload);
    }
    if (soapVersion == SOAP11) {
        req.setHeader(mime:CONTENT_TYPE, mime:TEXT_XML);
        if (soapAction is string) {
            req.addHeader("SOAPAction", soapAction);
        }
    } else {
        if (soapAction is string) {
            map<string> stringMap = {};
            stringMap["action"] = "\"" + soapAction + "\"";
            var mediaType = mime:getMediaType(mime:APPLICATION_SOAP_XML);
            if (mediaType is mime:MediaType) {
                mediaType.parameters = stringMap;
                req.setHeader(mime:CONTENT_TYPE, mediaType.toString());
            }
        } else {
            req.setHeader(mime:CONTENT_TYPE, mime:APPLICATION_SOAP_XML);
        }
    }
    map<string>? httpHeaders = options["httpHeaders"];
    if (httpHeaders is map<string>) {
        foreach var [headerName, headerValue] in httpHeaders.entries() {
            req.setHeader(headerName, headerValue);
        }
    }
    return req;
}

# Creates the SOAP response from the HTTP Response.
#
# + response - The request to be sent
# + soapVersion - The SOAP version of the request
# + return - The SOAP response created from the `http:Response` or the `error` object when reading the payload
function createSOAPResponse(http:Response response, SoapVersion soapVersion) returns @tainted SoapResponse | error {
    xml payload = check response.getXmlPayload();
    xmlns "http://schemas.xmlsoap.org/soap/envelope/" as soap11;
    xmlns "http://www.w3.org/2003/05/soap-envelope" as soap12;
    xml soapHeaders;
    if (soapVersion == SOAP11) {
        soapHeaders = payload/<soap11:Header>/*;
    } else {
        soapHeaders = payload/<soap12:Header>/*;
    }
    xml[] soapResponseHeaders = [];

    if ((soapHeaders/*).length() !=0) {
        int i = 0;
        xml[] headersXML = [];
        while (i < soapHeaders.length()) {
            headersXML[i] = soapHeaders[i];
            i += 1;
        }
        soapResponseHeaders = headersXML;
    }
    xml soapResponsePayload;
    if (soapVersion == SOAP11) {
        soapResponsePayload = payload/<soap11:Body>;
    } else {
        soapResponsePayload = payload/<soap12:Body>;
    }
    SoapResponse soapResponse = {
        headers: soapResponseHeaders,
        payload: soapResponsePayload,
        soapVersion: soapVersion,
        httpResponse: response
    };
    return soapResponse;
}

# Creates the password used in password digest usernameToken WS-Security.
#
# + nonce - The nonce string
# + password - The password in plain text
# + createdTime - The created timestamp
# + return - The digest password in string format
function createDigestPassword(string nonce, string password, string createdTime) returns string {
    string concatenatedDigest = nonce + createdTime + password;
    byte[] SHA1hashedDigest = crypto:hashSha1(concatenatedDigest.toBytes());
    string base64EncodedDigest = SHA1hashedDigest.toBase64();
    return base64EncodedDigest;
}

string path = "";

function sendReceive(SoapVersion soapVersion, xml|mime:Entity[] body, http:Client httpClient, string? soapAction = (), 
                     Options? options = ()) returns @tainted SoapResponse|error {
    http:Request req = fillSOAPEnvelope(soapVersion, body, options = options, soapAction = soapAction);
    var fut = check httpClient->submit("post",path, req);
    var response=httpClient->getResponse(fut);
    if (response is http:Response) {
        return createSOAPResponse(response, soapVersion);
    } else {
        return response;
    }
}

function sendRobust(SoapVersion soapVersion, xml|mime:Entity[] body, http:Client httpClient, string? soapAction = (),
                    Options? options = ()) returns error? {
    http:Request req = fillSOAPEnvelope(soapVersion, body, options = options, soapAction = soapAction);
    var fut = check httpClient->submit("post",path, req);
    var response=httpClient->getResponse(fut);
    if (response is error) {
        return response;
    }
}

function sendOnly(SoapVersion soapVersion, xml|mime:Entity[] body, http:Client httpClient, string? soapAction = (),
                  Options? options = ()) returns  error? {
    http:Request req = fillSOAPEnvelope(SOAP11, body, options = options, soapAction = soapAction);
   var fut = check httpClient->submit("post",path, req);
    var response=httpClient->getResponse(fut);
    if (response is error) {
        return response;
    }
}

# Returns the value equality of two strings despite of case.
#
# + stringOne - string one
# + stringTwo - string two
# + return - boolean equality
function equalsIgnoreCase(string stringOne, string stringTwo) returns boolean {
    if (stringOne.toLowerAscii() == stringTwo.toLowerAscii()) {
        return true;
    }
    return false;
}
