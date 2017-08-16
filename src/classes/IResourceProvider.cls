public interface IResourceProvider {
	// Set<String> describeSource();
	ResourceProviderResult getValue(String key);
	Boolean build();
	String getName();
}