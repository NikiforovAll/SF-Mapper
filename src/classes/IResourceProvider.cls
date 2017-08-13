public interface IResourceProvider {
	// Set<String> describeSource();
	ResourceProviderResult getValue(String key);
	String getName();
}