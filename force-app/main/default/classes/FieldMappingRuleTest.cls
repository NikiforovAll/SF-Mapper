@isTest
private class FieldMappingRuleTest {
	
	@isTest static void test() {
		new FieldMappingRule('source', 'destination', 'objectName');
		new FieldMappingRule('source', 'destination', 'objectName', null);
	}
	
}