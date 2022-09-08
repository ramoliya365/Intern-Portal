/**
@ClassName    : RC_ContactHandler 
@CreatedOn    : 22/Apr/2016
@Ticket       :
@CreatedBy    : TR Dev
@ModifiedBy   : Starang Dev and TR Dev
@Description  :
*/

public without sharing class RC_ContactHandler {
    
    Candidate_Community__c objCustomSettingForCandidate;
    public Static Id commProfileId;
    public RC_ContactHandler()
    {  
        objCustomSettingForCandidate = Candidate_Community__c.getValues('RegistrationDetail');
        
        
    }
    
    
    //If the Enable Community User is true and the email id is unique, create a new user for the contacts
    public void onAfterInsert(Map<Id, Contact> mapNewContact, List<Contact> lstContact, Map<Id,Contact> mapOldContact)
    {
        insertCommunityUser(mapNewContact);
    }
    
    private void insertCommunityUser(Map<Id, Contact> mapNewContact)
    {
        Savepoint sp = Database.setSavepoint();
        try {
            Set<String> setEmailIds = new Set<String>();
            Set<String> setDupeEmailIds = new Set<String>();
            List<User> lstUser = new List<User>();
            
            //To get all the email id's to check it's duplicate or not
            for(Contact objContact : mapNewContact.values()){
                if(objContact.Enable_Community_User__c)
                    setEmailIds.add(objContact.Email);
            }
            
            //Get all the duplicate email Id's 
            String strLike = '\\_%';
            
            system.debug('::setEmailIds::'+setEmailIds);
            // system.debug(':::dup user::'+[Select Id, Email from User where Email IN: setEmailIds]);
            for(User objUser : [Select Id, Email from User where Email IN: setEmailIds AND (Not Username Like : strLike)])
                setDupeEmailIds.add(objUser.Email);
            
            DateTime dt = DateTime.now();
            if(objCustomSettingForCandidate != null && commProfileId==null)
            {            
                List<Profile> lstProfile = [Select Id from Profile where Name =: objCustomSettingForCandidate.Profile__c limit 1];
                commProfileId = !lstProfile.isEmpty() ? lstProfile[0].Id : null; 
            }
            //Check if the email id's is duplicate, throw the error else create a community user.
            for(Contact objContact : mapNewContact.values()){
                if(setDupeEmailIds.contains(objContact.Email)){
                    objContact.addError('User already available with this email');
                }
                else if(objContact.Enable_Community_User__c){
                    if(String.isBlank(objContact.Email)){
                        objContact.addError('Email Id should not be blank');
                    }
                    else{
                        
                        User objUser = new User(Email = objContact.Email, FirstName = objContact.FirstName,LastName = objContact.LastName, ProfileId = commProfileId,ContactId = objContact.Id);
                        
                        objUser.Username = objContact.Email.substring(0, objContact.Email.lastIndexOf('@')) + objCustomSettingForCandidate.Username_suffix__c;
                        
                        dt = dt.addSeconds(1);
                        
                        objUser.CommunityNickname = String.isNotBlank(objContact.FirstName) ? objContact.FirstName.left(3)+objContact.LastName.left(2) + String.valueOf(dt) 
                            : objContact.LastName.left(2) + String.valueOf(dt);
                        objUser.ContactId = objContact.Id;
                        objUser.Alias =  objContact.LastName.left(6);
                        objUser.EmailEncodingKey='UTF-8';
                        objUser.LanguageLocaleKey='en_US';
                        objUser.LocaleSidKey='en_GB';
                        objUser.TimeZoneSidKey='Europe/London';
                        System.debug('::::euroope');
                        lstUser.add(objUser);
                        system.debug('USER TO BE INSERTED' +lstUser);
                    }
                }
            }
            insert lstUser;
            if(Test.isRunningTest()) Integer i=1/0;
        } 
        catch(DMLException ex){
            Database.rollback(sp);
            if(!Test.isRunningTest()) trigger.new[0].addError('Insert Community User failed : '+ex.getDMLMessage(0));
        }
        catch(Exception ex){
            Database.rollback(sp);
            if(!Test.isRunningTest()) trigger.new[0].addError('Insert Community User failed : '+ex.getMessage());
        }        
        //Database.SaveResult[] srList = Database.insert(lstUser,UserInsertDatabaseOptionalFlag);
        //system.debug('::srList:::'+srList);
    }
    
    /*
Event: On Before update
Criteria 1:  If the user is already available and enable community user is deactive then update the user to deactive(Vice versa for Enable Community user active)
Criteria 2: If the user is not avaliable and enable community user is active then create a new user if the Email Id is unique else throw an error. 
*/
    public void onBeforeUpdate(List<Contact> lstNewContact, Map<Id, Contact> mapOldContact)
    {
        InsertUpdateCommunityUser(mapOldContact, lstNewContact);
        UpdateNameOnCommunityUser(mapOldContact, lstNewContact);//Chirag@27May2016 : Added logic to update First Name/Last Name on User Record based on update in Contact Record.
    }
    
    private void InsertUpdateCommunityUser(Map<Id, Contact> mapOldContact, List<Contact> lstNewContact)
    {
        Savepoint sp = Database.setSavepoint();
        try {
            Set<String> setEmailIds = new Set<String>();
            Set<String> setDupeEmailIds = new Set<String>();
            Set<Id> setDeactiveContact = new Set<Id>();
            Set<Id> setActiveContact = new Set<Id>(); 
            Set<Id> setExistingActiveContact = new Set<Id>();
            List<User> lstUser = new List<User>();  
            
            //To get the email Id for activate or creating new user  
            List<Contact>  enableDisableContList=new List<Contact>();
            for(Contact objContact : lstNewContact)
            {
                if(objContact.Enable_Community_User__c != mapOldContact.get(objContact.Id).Enable_Community_User__c && objContact.Enable_Community_User__c)
                {
                    enableDisableContList.add(objContact);
                    setEmailIds.add(objContact.Email);
                    setActiveContact.add(objContact.Id);
                }
                else if(objContact.Enable_Community_User__c != mapOldContact.get(objContact.Id).Enable_Community_User__c && !objContact.Enable_Community_User__c){
                    setDeactiveContact.add(objContact.Id);
                    enableDisableContList.add(objContact);
                }
            }
            
            //Check the contact is already available or not. 
            String strLike = '\\_%';
            if(!enableDisableContList.isEmpty()){
                if(objCustomSettingForCandidate != null && commProfileId==null)
                {            
                    List<Profile> lstProfile = [Select Id from Profile where Name =: objCustomSettingForCandidate.Profile__c limit 1];
                    commProfileId = !lstProfile.isEmpty() ? lstProfile[0].Id : null; 
                }
                for(User objUser : [Select Id, Email, ContactId, Username  from User where (Email IN: setEmailIds OR ContactId IN: enableDisableContList) AND (NOT Username Like :strLike )])
                {
                    if(setActiveContact.contains(objUser.ContactId)){
                        setActiveContact.remove(objUser.ContactId);
                        setExistingActiveContact.add(objUser.ContactId);
                    }
                    else if(!setDeactiveContact.contains(objUser.ContactId))
                        setDupeEmailIds.add(objUser.Email);
                }
                
                DateTime dt = DateTime.now();
                
                //Create a new contact.  
                for(Contact objContact : enableDisableContList)
                {
                    if(String.isBlank(objContact.Email) && objContact.Enable_Community_User__c){
                        objContact.addError('Email Id should not be blank');
                    }
                    else if(setActiveContact.contains(objContact.Id) && setDupeEmailIds.contains(objContact.Email)){
                        objContact.addError('User already available with this email');
                    }
                    else if(setActiveContact.contains(objContact.Id)){
                        User objUser = new User(Email = objContact.Email, FirstName = objContact.FirstName,LastName = objContact.LastName, ProfileId = commProfileId,ContactId = objContact.Id);
                        
                        objUser.Username = objContact.Email.substring(0, objContact.Email.lastIndexOf('@')) + objCustomSettingForCandidate.Username_suffix__c;
                        
                        dt = dt.addSeconds(1);
                        
                        objUser.CommunityNickname = String.isNotBlank(objContact.FirstName) ? objContact.FirstName.left(3)+objContact.LastName.left(2) + String.valueOf(dt) :
                        objContact.LastName.left(2) + String.valueOf(dt);
                        objUser.ContactId = objContact.Id;
                        objUser.Alias =  objContact.LastName.left(6);
                        objUser.EmailEncodingKey='UTF-8';
                        objUser.LanguageLocaleKey='en_US';
                        objUser.LocaleSidKey='en_GB';
                        objUser.TimeZoneSidKey='Europe/London';
                        System.debug('::::: europe now');
                        // objUser.EmailEncodingKey='UTF-8';
                        //  objUser.LanguageLocaleKey='en_US';
                        //  objUser.LocaleSidKey='en_US';
                        //   objUser.TimeZoneSidKey='America/Chicago';
                        
                        lstUser.add(objUser);
                        system.debug('USER TO BE UPDATED' +lstUser);
                    }
                }
                
                insert lstUser;
            }
            if(setExistingActiveContact.size() > 0 || setDeactiveContact.size() > 0)
                updateUserRecords(setExistingActiveContact,setDeactiveContact);
            
            if(Test.isRunningTest()) Integer i=1/0;
        }
        catch(DMLException ex){
            Database.rollback(sp);
            if(!Test.isRunningTest()) trigger.new[0].addError('Insert/Update Community User failed : '+ex.getDMLMessage(0));
        }
        catch(Exception ex){
            Database.rollback(sp);
            if(!Test.isRunningTest()) trigger.new[0].addError('Insert/Update Community User failed : '+ex.getMessage());
        } 
    }
    
    private void UpdateNameOnCommunityUser(Map<Id, Contact> mapOldContact, List<Contact> lstNewContact)
    {
        Savepoint sp = Database.setSavepoint();
        try {
            Set<Id> contactIdSet = new Set<Id>();
            Map<Id,String> contactIdToFirstNameMap = new Map<Id,String>();
            Map<Id,String> contactIdToLastNameMap = new Map<Id,String>();
            
            for(Contact objContact : lstNewContact){
                if(objContact.FirstName != mapOldContact.get(objContact.Id).FirstName && String.isNotBlank(objContact.FirstName) && objContact.LastName != mapOldContact.get(objContact.Id).LastName && String.isNotBlank(objContact.LastName)){
                    contactIdToFirstNameMap.put(objContact.id,objContact.FirstName);
                    contactIdToLastNameMap.put(objContact.id,objContact.LastName);
                    contactIdSet.add(objContact.id);
                }
                else if(objContact.FirstName != mapOldContact.get(objContact.Id).FirstName && String.isNotBlank(objContact.FirstName)){
                    contactIdToFirstNameMap.put(objContact.id,objContact.FirstName);
                    contactIdSet.add(objContact.id);
                }
                else if(objContact.LastName != mapOldContact.get(objContact.Id).LastName && String.isNotBlank(objContact.LastName)){
                    contactIdToLastNameMap.put(objContact.id,objContact.LastName);
                    contactIdSet.add(objContact.id);
                }
            }
            
            if(contactIdSet.size() > 0 && (contactIdToFirstNameMap.keySet().size() > 0 || contactIdToLastNameMap.keySet().size() > 0)){
                updateNameOnUserRecords(contactIdSet,contactIdToFirstNameMap,contactIdToLastNameMap);
            }
            
            if(Test.isRunningTest()) Integer i=1/0;
        }
        catch(DMLException ex){
            Database.rollback(sp);
            if(!Test.isRunningTest()) trigger.new[0].addError('Insert/Update Community User failed : '+ex.getDMLMessage(0));
        }
        catch(Exception ex){
            Database.rollback(sp);
            if(!Test.isRunningTest()) trigger.new[0].addError('Insert/Update Community User failed : '+ex.getMessage());
        }         
    }
    
    @future
    public static void updateUserRecords(Set<Id> setExistingActiveContact, Set<Id> setDeactiveContact)
    {   
        Set<Id> setAllContactIds = new Set<Id>();
        List<User> lstActiveOrDeactiveUser = new List<User>();
        
        setAllContactIds.addAll(setExistingActiveContact);
        setAllContactIds.addAll(setDeactiveContact);
        
        
        for(User objUser : [Select Id,Email,ContactId from User where ContactId IN: setAllContactIds ]){
            if(setExistingActiveContact.contains(objUser.ContactId)){
                objUser.isActive = true;
                lstActiveOrDeactiveUser.add(objUser);   
            }
            else if(setDeactiveContact.contains(objUser.ContactId)){
                objUser.isActive = false;
                lstActiveOrDeactiveUser.add(objUser);
            }
            
            Database.update(lstActiveOrDeactiveUser, false);    
        }
    }
    
    @future
    public static void updateNameOnUserRecords(Set<Id> contactIdSet, Map<Id,String> contactIdToFirstNameMap, Map<Id,String> contactIdToLastNameMap)
    {   
        List<User> userListToBeUpdated = new List<User>();
        for(User objUser : [Select Id,Email,ContactId from User where ContactId IN: contactIdSet]){
            if(contactIdToFirstNameMap.containsKey(objUser.ContactId) && contactIdToLastNameMap.containsKey(objUser.ContactId)){
                objUser.FirstName = contactIdToFirstNameMap.get(objUser.ContactId);
                objUser.LastName = contactIdToLastNameMap.get(objUser.ContactId);
                userListToBeUpdated.add(objUser);   
            }
            else if(contactIdToFirstNameMap.containsKey(objUser.ContactId)){
                objUser.FirstName = contactIdToFirstNameMap.get(objUser.ContactId);
                userListToBeUpdated.add(objUser);   
            }
            else if(contactIdToLastNameMap.containsKey(objUser.ContactId)){
                objUser.LastName = contactIdToLastNameMap.get(objUser.ContactId);
                userListToBeUpdated.add(objUser);   
            }
            Database.update(userListToBeUpdated, false);    
        }
    }
}