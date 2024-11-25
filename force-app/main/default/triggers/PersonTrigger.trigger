trigger PersonTrigger on Person__c (before insert, before update, after insert, after update ) {
    Switch on Trigger.operationType {
        When BEFORE_INSERT {
            PersonTriggerHandler.handleBeforeInsert(Trigger.new);
        }
        When BEFORE_UPDATE {
            PersonTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
        //Enhancement
        When AFTER_UPDATE {
            PersonTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }
        //Enhancement
    }
    
}