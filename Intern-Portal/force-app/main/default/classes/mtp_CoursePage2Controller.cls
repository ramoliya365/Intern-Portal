public with sharing class mtp_CoursePage2Controller {

  /***************************************************
        * Author             : sakina
        * Created Date       : 6/09/2022
        * Last Modified Date : 6/09/2022
        * Description        : Used to bring Module object Data
   ***************************************************/
    @AuraEnabled
    public static List<mtp_Module__c> getModuleData(){
        try{

          return[SELECT Id, Name , Description__c , Index__c  FROM mtp_Module__c ORDER BY Index__c ASC];

        }catch(Exception e){

          throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<mtp_Task__c> getModuleTasks(Id getModuleId){

      try {
        return[Select Id , Name , Description__c  , mtp_Module__c  FROM mtp_Task__c WHERE mtp_Module__c =: getModuleId];

        
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    }
   
}