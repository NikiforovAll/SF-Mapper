@isTest
private class SObjectContainerTest {
	
	@isTest static void test() {
		SObjectContainer container = new SObjectContainer('test');
		container.addChildContainer(null);
		container.getChildContainers();
		container.setParentContainer(null);
		container.setData(null);
	}
}