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

public with sharing class CTDataCleanUpSchedule implements Schedulable {

    //declaring cron var
    //Second Minute Hour *(anyday of month) *(anymonth from a years) ?(any value from weekdays)
    public static final String CRON = '0 0 2 * * ?';

    public void execute(SchedulableContext sc) {
        //within this mehtod we can create instance of batch class (People Tracing)
        CTPeopleTracingDataCleanupBatch peopleTracingBatch = new CTPeopleTracingDataCleanupBatch();

        //Executing using Databse.Executebatch() method //here 2000 : Batch size
        Database.executeBatch(peopleTracingBatch, 2000);

        //Anonymous Window code:
        //CTDataCleanUpSchedule dataCleanUp = new CTDataCleanUpSchedule();
        //String jobId = system.schedule('Data Clean Up Job',CTDataCleanUpSchedule.CRON ,dataCleanUp);
        //system.debug('Job Id: '+jobId);

        //To check schduled Job : Setup >> Scheduled Jobs
        //To Test diectly change date to oplder than pas 30days : dataCleanUp.execute(null);    


        //To schedule Location Tracing
        CTLocationTracingDataCleanupBatch locationTracingBatch = new CTLocationTracingDataCleanupBatch();
        Database.executeBatch(locationTracingBatch, 2000);
    }
}