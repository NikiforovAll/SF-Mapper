@isTest
private class SObjectResourceProviderTest {
	
	@isTest static void test() {
		SObjectResourceProvider source = new SObjectResourceProvider(new Account(Name = 'Test'));
		source.describeSource();
		source.getValue('name');
		source.getName();
		source = new SObjectResourceProvider(
			new Account(Name = 'Test', Phone ='123-123-123'), 
			new Set<String>{'Name'}
		);
	}
}