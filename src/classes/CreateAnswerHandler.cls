public with sharing class CreateAnswerHandler {
	
	public void onAfterInsert(List<OpportunityLineItem> lstOLIs) {
		
		createAnswersAfterInsertingOLI(lstOLIs);
	}
	
	public void createAnswersAfterInsertingOLI(List<OpportunityLineItem> lstOLIs) {
		
		Set<Id> setProduct2Ids = new Set<Id>();
		Set<Id> setProductGroupIds = new Set<Id>();
		List<Answer__c> lstAnswers = new List<Answer__c>();
		List<Question__c> lstQuestions = new List<Question__c>();
		Map<Id , List<Question__c> > mapQuestionsByPGs = new Map<Id , List<Question__c> >();
		
		//Get the Opportunity Id's to which products are attached and product2 Id's of products which are attached to those opportunities. 
		for(OpportunityLineItem objOLI: lstOLIs) {
			
			setProduct2Ids.add(objOLI.Product2Id);
		}
		
		//Get the Product group Id for each attached product on opportunity.
		List<Product2> lstProducts = 	[	SELECT Product_Group__c 
											FROM Product2 
											WHERE Id 
											IN :setProduct2Ids
										];
		
		for(Product2 objProduct2: lstProducts) {
			
			setProductGroupIds.add(objProduct2.Product_Group__c);
		}
		
		
		//Get the Questions under each Product Group above.
		lstQuestions = 	[	SELECT Id, Name, Product_Group__c 
							FROM Question__c 
							WHERE Product_Group__c 
							IN :setProductGroupIds
						];
		
		//Organize those Questions by Product Groups.
		for(Question__c objQus: lstQuestions){
			
			if(mapQuestionsByPGs.get(objQus.Product_Group__c) == null){
				
				mapQuestionsByPGs.put(objQus.Product_Group__c , new List<Question__c>());
			}
			
			mapQuestionsByPGs.get(objQus.Product_Group__c).add(objQus);
		}
		
    	//Get the Product Group of the inserted product.
    	Map<Id , Product2> mapProducts = new Map<Id , Product2>([	SELECT Product_Group__c 
    																FROM Product2 
																	WHERE Id 
																	IN :setProduct2Ids
    															]);
    	
    	//Create Answer records.
		for(OpportunityLineItem objOLI: lstOLIs) {
			
			for(Question__c objQuestion: mapQuestionsByPGs.get(mapProducts.get(objOLI.Product2Id).Product_Group__c)) {
				
				Answer__c objAnswer = new Answer__c	(	Opportunity__c = objOLI.OpportunityId, 
														Product__c = objOLI.Product2Id, 
														Question__c = objQuestion.Id
													);
				lstAnswers.add(objAnswer);
			}
		}
		
		Database.insert(lstAnswers);
	}
}