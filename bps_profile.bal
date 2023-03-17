public class BPSProfile {
    private string profileName;
    private string profileDescription;
    private string serviceUrl;
    private string username;
    private string password;

    function init() {
        // The `init` method can initialize the `final` field.
     
    }
    function setUsername(string username) {
        self.username = username;
    }
    function setPassword(string password) {
        self.password = password;
    }
    
}