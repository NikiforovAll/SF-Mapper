@isTest
private class JsonResourceProviderTest {
	
	@isTest static void test_json_provider() {
		Lead lead = new Lead(
			Email = 'testlead@test.com',
			City = 'test address',
			Phone = '123-123-123',
			Company = 'Test Company'
		);
		JsonResourceProvider jsonProvider = new JsonResourceProvider(JSON.serialize(lead, true));
		jsonProvider.describeSource();
		jsonProvider.getName();
		system.assertEquals(lead.Email, jsonProvider.getValue('email'));
		jsonProvider = new JsonResourceProvider(JSON.serialize(lead, true), new Set<String>{'email'});
	}
}