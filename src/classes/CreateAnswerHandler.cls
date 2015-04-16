public with sharing class CreateAnswerHandler {
	
	public void onAfterInsert(List<OpportunityLineItem> lstOLIs) {
		
		createAnswersAfterInsertingOLI(lstOLIs);
	}
	
	public void createAnswersAfterInsertingOLI(List<OpportunityLineItem> lstOLIs) {
		
		Set<Id> setProduct2Ids = new Set<Id>();
		Set<Id> setProductGroupIds = new Set<Id>();
		List<Answer__c> lstAnswers = new List<Answer__c>();
		List<Question__c> lstQuestions = new List<Question__c>();
		
		//Get the product2 Id's of products which are attached to opportunity. 
		for(OpportunityLineItem objOLI: lstOLIs) {
			
			setProduct2Ids.add(objOLI.Product2Id);
		}
		
		System.debug('---setProduct2Ids--'+setProduct2Ids);
		
		//Get the Product group Id for each attached product on opportunity.
		List<Product2> lstProducts = 	[	SELECT Product_Group__c 
											FROM Product2 
											WHERE Id 
											IN :setProduct2Ids
										];
		
		System.debug('---lstProducts--'+lstProducts);
		
		for(Product2 objProduct2: lstProducts) {
			
			setProductGroupIds.add(objProduct2.Product_Group__c);
		}
		
		System.debug('---setProductGroupIds--'+setProductGroupIds);
		
		//Get the Questions under each Product Group above.
		lstQuestions = 	[	SELECT Id, Name, Product_Group__c 
							FROM Question__c 
							WHERE Product_Group__c 
							IN :setProductGroupIds
						];
		
		System.debug('---lstQuestions--'+lstQuestions);
		
		//Organize those Questions by Product Groups.
		Map<Id , List<Question__c> > mapQuestionsByPGs = new Map<Id , List<Question__c> >();
		
		for(Question__c objQus: lstQuestions){
			
			if(mapQuestionsByPGs.get(objQus.Product_Group__c) == null){
				
				mapQuestionsByPGs.put(objQus.Product_Group__c , new List<Question__c>());
			}
			
			mapQuestionsByPGs.get(objQus.Product_Group__c).add(objQus);
		}
		
		System.debug('---mapQuestionsByPGs--'+mapQuestionsByPGs);
		
		for(OpportunityLineItem objOLI: lstOLIs) {
			
			System.debug('---objOLI.Id--'+objOLI.OpportunityId);
			System.debug('---objOLI.Id--'+objOLI.Product2Id);
			
			//for()
		}
	}
}