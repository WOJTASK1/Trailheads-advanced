public with sharing class MaintenanceRequestHelper {
    
    public static void updateWorkOrders(List<Case> listOfCases) {
        List<Id> casesToWorkOn=new List<Id>();
        
        for(Case c:listOfCases){
            if(c.Type.equals('Reapair') or c.Type.equals('Maintenance Request') and c.IsClosed){
                casesToWorkOn.add(c.Id);
            }
        }
        
        if(!casesToWorkOn.isEmpty()){
            List<Case> newCases = new List<Case>();
            Map<Id, Case> cCases = new Map<Id,Case>(
                [SELECT Id, Vehicle__c, Equipment__c, Equipment__r.Maintenance_Cycle__c,
                (SELECT Id, Equipment__c, Quantity__c 
                FROM Equipment_Maintenance_Items__r) 
                FROM Case WHERE Id IN :listofId]);
                         
            Map<Id,Decimal> mtCycles=new Map<Id, Decimal>;

            AggregateResult[] results = [SELECT Maintenance_Request__c, MIN(Equipment__r.Maintenance_Cycle__c)cycle 
            FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN :listofId GROUP BY Maintenance_Request__c];
            for(AggregateResult j : results){
                mtCycles.put((Id) j.get('Maintenance_Request__c'), (Decimal) j.get('cycle'));
            }
            for(Case k:cCases.values()){
                Case createCase=new Case(Status='New', ParentId=k.Id, Subject='Routine Maintenance',
                Type='Routine Maintenance', Vehicle__c=k.Vehicle__c, Equipment__c=k.Equipment__c,
                Origin='Web', Date_Reported__c=Date.Today();
                )
                If(mtCycles.containskey(k.Id)){
                    createCase.Date.Due__c=Date.Today().addDays((Integer)mtCycles.get(k.Id));
                }
                newCases.add(createCase);
            }
            insert newCases;

            List<Equipment_Maintenance_Item__c> copyEQT=new List<Equipment_Maintenance_Item__c>();
            for(Case z : newCases){
                for(Equipment_Maintenance_Item__c q: cCases.get(z.ParentId).Equipment_Maintenance_Items__r){
                    Equipment_Maintenance_Item__c EQT=q.clone();
                    EQT.Maintenance_Request__c = z.Id;
                    copyEQT.add(EQT);
                }
            }
            insert copyEQT;
        }
    }        
    

    
}