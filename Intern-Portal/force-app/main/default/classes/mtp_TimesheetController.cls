/* ****************************************************************************************************************************
Class Name       : mtp_TimesheetController
Author           : Nitin
Created Date     : 06/09/2022
Description      : This Class Used In mtp_Timesheet (LWC component ).
TestClass        : 
Code Coverage    : 
================================================================================
Change No.          Developer Name              Date                Description     
1.                  
******************************************************************************************************************************/


public without sharing class mtp_TimesheetController {

    /***************************************************
    * Author             : Nitin
    * Created Date       : 06/09/2022
    * Last Modified Date : 
    * UsedBy             : mtp_Timesheet Component
    * Description        : get timesheet data for display timesheet records in mtp_Timesheet Component.
    ***************************************************/
    @AuraEnabled
    public static List<mtp_Timesheet__c> getTimesheetData(){
        User loggedInUser = [SELECT Name, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
        System.debug('loggedInUser ====>' + loggedInUser);
        List<mtp_Timesheet__c> timesheetDataList = new List<mtp_Timesheet__c>();

        try {
            timesheetDataList = [SELECT Id, CreatedDate, Name, Start_Time__c, End_Time__c, Status__c, Comments__c, mtp_Task__c, mtp_Task__r.Name, Course__c, User__c FROM mtp_Timesheet__c WHERE User__c =: UserInfo.getUserId()];
            // timesheetDataList = [SELECT Id, Name, Start_Time__c, End_Time__c, Status__c, Comments__c, mtp_Task__c, Course__c, User__c FROM mtp_Timesheet__c];

            return timesheetDataList;
        } catch (Exception e) {
            System.debug(e);
            System.debug('Line Number ==>'+ e.getLineNumber());
            System.debug('Message ===>'+ e.getMessage() + ' <==>'+ e.getStackTraceString());
            return null;
        }
    }


    /***************************************************
    * Author             : Nitin
    * Created Date       : 07/09/2022
    * Last Modified Date : 
    * UsedBy             : mtp_Timesheet Component
    * Description        : get task records for picklist option value for popup modal.
    ***************************************************/
    @AuraEnabled
    public static List<String> getTaskList(){
        List<String> taskDetails = new List<String>();
        List<mtp_Task__c> tasks = new List<mtp_Task__c>();
        
        try {
            tasks = [SELECT Id, Name FROM mtp_Task__c];
            if (tasks.size() >0) {
                for (mtp_Task__c tsk : tasks) {
                    taskDetails.add(tsk.Name + ':::'+ tsk.Id);
                }
            }
            return taskDetails;
        } catch (Exception e) {
            System.debug(e);
            System.debug('Line Number ==>'+ e.getLineNumber());
            System.debug('Message ===>'+ e.getMessage() + ' <==>'+ e.getStackTraceString());
            return null;
        }
    }

    /***************************************************
    * Author             : Nitin
    * Created Date       : 07/09/2022
    * Last Modified Date : 
    * UsedBy             : mtp_Timesheet Component
    * Description        : Creating timesheet record.
    ***************************************************/
    @AuraEnabled
    public static String createTimesheetRecord(String taskId, Datetime startTime, Datetime endTime, String comments){
        try {
            mtp_Timesheet__c tsr = new mtp_Timesheet__c();
            System.debug('taskId:    ==>'+ taskId);
            System.debug('comments:  ==>'+ comments);
            
            System.debug('startTime : ==>'+ startTime);
            System.debug('endTime   :   ==>'+ endTime);
            // startTime = startTime.addHours(5).addMinutes(30);
            // endTime = endTime.addHours(5).addMinutes(30);
            System.debug('startTime after: ==>'+ startTime);
            System.debug('endTime after:   ==>'+ endTime);

            if (taskId == null || startTime == null || endTime == null) {
                return 'required field missing';
            } else {
                tsr.mtp_Task__c = taskId;
                tsr.Start_Time__c = startTime;
                tsr.End_Time__c = endTime;
                tsr.Comments__c = comments;
                tsr.User__c = UserInfo.getUserId();
                insert tsr;
            }
            return 'success';
        } catch (Exception e) {
            System.debug(e);
            System.debug('Line Number ==>'+ e.getLineNumber());
            System.debug('Message ===>'+ e.getMessage() + ' <==>'+ e.getStackTraceString());
            return null;
        }
    }
}