@isTest
private class MapperConfigBuilderTest {
	
	@isTest static void test() {
		MapperConfigBuilder builder = new MapperConfigBuilder('test-builder');
		IFieldMapping fieldMappingConfig = builder
			.addObjectMapping('Account', new List<String>{'test1', 'test2'})
			.addObjectMapping('Contact', '*')
			.addFieldMapping('source', 'destination')
			.build();
		system.assertEquals('test-builder', builder.getName());
		system.assertEquals('Contact', fieldMappingConfig.getDefaultMappingObject());
	}	
	@isTest static void test2(){
		MapperConfigBuilder builder = new MapperConfigBuilder('test-builder');
		IFieldMapping fieldMappingConfig = builder
			.addFieldMapping(new Map<String, String>{
				'test1' => 'dest1'
			})
			.addFieldMapping(new Map<String, FieldMappingRule>{
				'test2' => new FieldMappingRule('dest2', new FieldFormatterFactory.BaseFormatter())
			})
			.addObjectMapping('Account', 'test1')
			.addObjectMapping('Account', 'test2')
			.build();
			
	}
}