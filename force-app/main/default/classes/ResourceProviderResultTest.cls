@isTest
private class ResourceProviderResultTest {
	
	@isTest static void test_flattenResource() {
		List<ResourceProviderResult> testData = new List<ResourceProviderResult>{
			new ResourceProviderResult('root')
				.setChilds(
					new List<ResourceProviderResult>{
						new ResourceProviderResult('Container2')
							.setChilds(
								new List<ResourceProviderResult>{
									new ResourceProviderResult().setData('val1'),
									new ResourceProviderResult().setData('val1')
								}
							),
						new ResourceProviderResult('Container2')
							.setChilds(
								new List<ResourceProviderResult>{
									new ResourceProviderResult().setData('val1')
								}
							)
					}
				)
		};
		List<ResourceProviderResult> result = ResourceProviderResult.flattenResource(testData);
		System.assertEquals(3, result.size());
	}

}