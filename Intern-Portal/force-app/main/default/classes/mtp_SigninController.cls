public without sharing class mtp_SigninController {

    @AuraEnabled
    public static string login(String username, String password){
        try {
            String starturl = 'https://inspiration-drive-1434-dev-ed.my.site.com/s/';
            ApexPages.PageReference pageRef = Site.login(username, password, startUrl);
            if(pageRef != null){
                return pageRef.getUrl();
            } 
            return null;
        } catch (Exception e) {
            System.debug(e);
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static List<String> forgotSitePassword(String usernameval){
        try {
            // List<User> lstUser = [Select Id, Username, LastPasswordChangeDate From User where Username =: UsrId AND LastPasswordChangeDate != null];
            List<User> lstUser = [Select Id, Username From User where Username =: usernameval];

            if(!lstUser.isEmpty()) {
                // if (lstUser[0].LastPasswordChangeDate < System.now().addDays(-1)) {
                    boolean blnSuccess = Site.forgotPassword(usernameval);
                    List<string> str = new List<string>{'Success', 'Success'};
                    return str;
                // } else {
                //     List<string> str = new List<string>{'Error', 'We recently received a request to reset the Salesforce password for the username ' +usernameval+ ' We can not reset your password because it was changed within the last 24 hours.'};
                //     return str;
                // }     
            }else {
                List<string> str = new List<string>{'Error', 'Username doesnot match any records in our System. Please Enter a valid Username!'};
                return str;
            }
        } catch (Exception e) {
            System.debug(e);
            List<string> str = new List<string>{'Error', 'Something Went Wrong', 'getMessagelogin => '+e.getMessage() + 'line no => '+e.getLineNumber()};
            return str;
        }
          
    }
}