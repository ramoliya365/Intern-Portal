public without sharing class CourseController {

    @AuraEnabled
    public static List<Course__C> getcourse(){
        try {
            List<Course__C> course = [SELECT Id,Course__c,Name,Course_Index__c FROM Course__c];
            //List<mtp_Module__c> module = [SELECT Id,Completed__c FROM mtp_Module__c];
            return course;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
