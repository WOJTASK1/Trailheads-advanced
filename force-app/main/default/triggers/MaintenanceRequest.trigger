trigger MaintenanceRequest on Case (before update, after update) {
    Map<Id,Vehicle__c> mapa=new Map<Id, Vehicle__c>();
    List <Vehicle__c>
    for (Case c : Trigger.new) {
        if((c.Type='Repair' or c.Type='Routine Maintenance') and c.IsClosedOnCreate=true){
            mapa.put(c.Id, c.Vehicle__c);
            MaintenanceRequest new_req=new MaintenanceRequest();
            new_req=c;
            new_req.IsClosedOnCreate=false;
            insert new_req;
        }

    } 


}