trigger CaseJiraTrigger on Case (after insert) {
    List<Id> highPriorityCaseIds = new List<Id>();

    for (Case c : Trigger.new) {
        if (c.Priority == 'High') {
            highPriorityCaseIds.add(c.Id);
        }
    }

    if (!highPriorityCaseIds.isEmpty() && Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
        System.enqueueJob(new JiraQueueableCallout(highPriorityCaseIds));
    }
}