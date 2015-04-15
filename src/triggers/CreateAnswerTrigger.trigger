trigger CreateAnswerTrigger on OpportunityLineItem (after insert) {
	
	CreateAnswerHandler objCreateAnswerHandler = new CreateAnswerHandler();
	
	if(Trigger.isAfter && Trigger.isInsert) {
		
		objCreateAnswerHandler.createAnswersAfterInsertingOLI(Trigger.new);
	}
}