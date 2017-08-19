@isTest
private class FieldMappingTest {
	
	@isTest static void test_object_setup() {
		FieldMapping mapping = new FieldMapping(
			new Map<String, Set<String>>{
				'Test1' => new Set<String>{'t1', 't2'},
				'Test2' => new Set<String>{'t3', 't4'}
			}
		);
		mapping.getObjectMapping();
		mapping.getFieldMapping();
	}
}