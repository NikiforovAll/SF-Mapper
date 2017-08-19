@isTest
public class SObjectContainerUtilTest {
	@isTest static void test_getSObjectContainerById() {
		List<SObjectContainer> containerList = new List<SObjectContainer>{
			new SObjectContainer('#1')
				.addChildContainer(new SObjectContainer('#1_1'))
				.addChildContainer(new SObjectContainer('#1_2')),
			new SObjectContainer('#2')
		};
		System.assertNotEquals(null, SObjectContainerUtil.getSObjectContainerById(containerList, '#1_1'));	
	}
}