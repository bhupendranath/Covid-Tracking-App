/**
 * @description       : Schedule Class for Data Cleanup
 * @auther            : Bhupendra
 * @group             : 
 * @last modified on  : 03-22-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   03-22-2023   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/

public with sharing class CTStatusUpdateSchedule implements Schedulable {

    //declaring cron var
    //Second Minute Hour *(anyday of month) *(anymonth from a years) ?(any value from weekdays)
    public static final String CRON = '0 0 3 * * ?';

    public void execute(SchedulableContext sc) {
        //within this mehtod we can create instance of batch class (Person status)
        CTUpdatePersonStatusBatch updatePersonStatusBatch = new CTUpdatePersonStatusBatch();

        //Executing using Databse.Executebatch() method //here 2000 : Batch size
        Database.executeBatch(updatePersonStatusBatch, 2000);

        //Anonymous Window code:
        //CTStatusUpdateSchedule statusUpdateSchedule = new CTStatusUpdateSchedule();
        //String jobId = system.schedule('Status Update Job',CTStatusUpdateSchedule.CRON ,statusUpdateSchedule);
        //system.debug('Job Id: '+jobId);

        //To check schduled Job : Setup >> Scheduled Jobs
        //To Test diectly change date to older than past 30days : statusUpdateSchedule.execute(null);    


        //To schedule Location status update
        CTUpdateLocationStatusBatch updateLocationStatus = new CTUpdateLocationStatusBatch();
        Database.executeBatch(updateLocationStatus, 2000);
    }
}