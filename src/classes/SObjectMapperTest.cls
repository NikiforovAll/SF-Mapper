@isTest
public class SObjectMapperTest {

	@isTest static void test_multi_split_newly_created_records_success() {
		//Arrange
		SObjectMapper.initialize('Lead',
			new FieldMapping(
				//object mapping 
				new Map<String, Set<String>>{
					'Account' => new Set<String>{'phone', 'company'},
					'Contact' => new Set<String>{'email', 'city'}
				},
				//field mapping
				new Map<String, String>{
					'company' => 'name',
					'city' => 'mailingCity'
				}
			)
		);
		Lead lead = new Lead(
			Email = 'testlead@test.com',
			City = 'test address',
			Phone = '123-123-123',
			Company = 'Test Company'
		);
		//Act
		Map<String, sObject> result = SObjectMapper.mapObject(new SObjectResourceProvider(lead));
		Account account = (Account)result.get('Account');
		Contact contact = (Contact)result.get('Contact');
		//Assert
		system.assertEquals(lead.Company, account.Name);
		system.assertEquals(lead.Phone, account.Phone);
		system.assertEquals(lead.City, contact.MailingCity);
		system.assertEquals(lead.Email, contact.Email);
		
	}

	@isTest static void test_multi_split_existing_records_success() {
		//Arrange 
		SObjectMapper.initialize('Lead',
			new FieldMapping(
				//object mapping 
				new Map<String, Set<String>>{
					'Account' => new Set<String>{'phone', 'company'},
					'Contact' => new Set<String>{'email', 'city'}
				},
				//field mapping
				new Map<String, String>{
					'company' => 'name',
					'city' => 'mailingCity'
				}
			)
		);
		Lead lead = new Lead(
			Email = 'testlead@test.com',
			City = 'test address',
			Phone = '123-123-123',
			Company = 'Test Company'
		);
		Account account = new Account();
		Contact contact = new Contact();
		Map<String, sObject> sObjectsToUpdateMap = new Map<String, sObject> {
			'Account' => account,
			'Contact' => contact
		};
		//Act
		SObjectMapper.mapObject(new SObjectResourceProvider(lead), sObjectsToUpdateMap);
		//Assert
		system.assertEquals(lead.Company, account.Name);
		system.assertEquals(lead.Phone, account.Phone);
		system.assertEquals(lead.City, contact.MailingCity);
		system.assertEquals(lead.Email, contact.Email);
	}

	@isTest static void test_single_newly_created_record_success(){
		//Arrange
		SObjectMapper.initialize('Lead',
			new FieldMapping(
				new Map<String, Set<String>>{
					'Account' => new Set<String>{'company'}
				},
				new Map<String, String>{
					'company' => 'name'
				}
			)
		);
		Lead lead = new Lead(Company = 'Test company');
		//Act
		Account acc = (Account)SObjectMapper.mapSingleObject(new SObjectResourceProvider(lead));
		//Assert
		system.assertEquals(lead.Company, acc.Name);
	}

	@isTest static void test_single_existing_record_success(){
		//Arrange
		SObjectMapper.initialize('Lead',
			new FieldMapping(
				new Map<String, Set<String>>{
					'Account' => new Set<String>{'company'}
				},
				new Map<String, String>{
					'company' => 'name'
				}
			)
		);
		Lead lead = new Lead(Company = 'Test company');
		Account account = new Account();
		Map<String, sObject> recordsToUpdate = new Map<String, sObject>{'Account' => account};
		//Act
		SObjectMapper.mapSingleObject(new SObjectResourceProvider(lead), recordsToUpdate);
		//Assert
		system.assertEquals(lead.Company, account.Name);
	}

	@isTest static void test_single_newly_created_record_by_name_success(){
		//Arrange
		SObjectMapper.initialize('Lead',
			new FieldMapping(
				new Map<String, Set<String>>{
					'Account' => new Set<String>{'company'}
				},
				new Map<String, String>{
					'company' => 'name'
				}
			)
		);
		Lead lead = new Lead(Company = 'Test company');
		//Act
		Account acc = (Account)SObjectMapper.mapSingleObject(new SObjectResourceProvider(lead), 'Account');
		//Assert
		system.assertEquals(lead.Company, acc.Name);
	}

	@isTest static void test_single_existing_record_by_name_success(){
		//Arrange
		SObjectMapper.initialize('Lead',
			new FieldMapping(
				new Map<String, Set<String>>{
					'Account' => new Set<String>{'company'}
				},
				new Map<String, String>{
					'company' => 'name'
				}
			)
		);
		Lead lead = new Lead(Company = 'Test company');
		Account account = new Account();
		Map<String, sObject> recordsToUpdate = new Map<String, sObject>{'Account' => account};
		//Act
		SObjectMapper.mapSingleObject(new SObjectResourceProvider(lead), recordsToUpdate, 'Account');
		//Assert
		system.assertEquals(lead.Company, account.Name);
	}

	@isTest static void test_multi_split_sobject_records_success(){
		//Arrange
		SObjectMapper.initialize('Lead',
			new FieldMapping(
				new Map<String, Set<String>>{
					'Account' => new Set<String>{'company'}
				},
				new Map<String, String>{
					'company' => 'name'
				}
			)
		);
		Lead lead = new Lead(Company = 'Test company');
		Account account = new Account();
		Map<String, sObject> recordsToUpdate = new Map<String, sObject>{'Account' => account};
		//Act
		SObjectMapper.mapSingleObject(lead, recordsToUpdate);
		//Assert
		system.assertEquals(lead.Company, account.Name);
	}

	@isTest static void test_single_existing_sobject_record_success(){
		//Arrange
		SObjectMapper.initialize('Lead',
			new FieldMapping(
				new Map<String, Set<String>>{
					'Account' => new Set<String>{'company'}
				},
				new Map<String, String>{
					'company' => 'name'
				}
			)
		);
		Lead lead = new Lead(Company = 'Test company');
		Account account = new Account();
		Map<String, sObject> recordsToUpdate = new Map<String, sObject>{'Account' => account};
		//Act
		SObjectMapper.mapSingleObject(lead, recordsToUpdate);
		SObjectMapper.mapSingleObject(lead);
		//Assert
		system.assertEquals(lead.Company, account.Name);
	}

	@isTest static void test_multi_split_newly_created_records_from_json_success() {
		//Arrange
		SObjectMapper.initialize('Lead',
			new FieldMapping(
				//object mapping 
				new Map<String, Set<String>>{
					'Account' => new Set<String>{'phone', 'company'},
					'Contact' => new Set<String>{'email', 'city'}
				},
				//field mapping
				new Map<String, String>{
					'company' => 'name',
					'city' => 'mailingCity'
				}
			)
		);
		Lead lead = new Lead(
			Email = 'testlead@test.com',
			City = 'test address',
			Phone = '123-123-123',
			Company = 'Test Company'
		);
		//Act
		//  {"Email":"testlead@test.com","City":"test address","Phone":"123-123-123","Company":"Test Company"}
		Map<String, sObject> result = SObjectMapper.mapObject(new JsonResourceProvider(JSON.serialize(lead)), 'Lead');
		Account account = (Account)result.get('Account');
		Contact contact = (Contact)result.get('Contact');
		//Assert
		system.assertEquals(lead.Company, account.Name);
		system.assertEquals(lead.Phone, account.Phone);
		system.assertEquals(lead.City, contact.MailingCity);
		system.assertEquals(lead.Email, contact.Email);
		
	}
}