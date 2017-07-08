@isTest
public class FieldFormatterFactoryTest {
	@isTest
	private static void test(){
		Map<Schema.DisplayType, Object>	testData = new Map<Schema.DisplayType, Object>{
			Schema.DisplayType.Double => 1,
			Schema.DisplayType.Boolean => true
			// Schema.DisplayType.Date => date.today(),
			// Schema.DisplayType.DateTime => system.now()
		};
		for(Schema.DisplayType displayType :FieldFormatterFactory.formatterFactory.keySet()){
			system.assertEquals(
				testData.get(displayType),
				FieldFormatterFactory.createFieldFormatter(displayType)
					.format(
						String.valueOf(testData.get(displayType))
					).data
			);
			
		}
	}
}