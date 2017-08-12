public interface IResourceProvider {
	// Set<String> describeSource();
	Object getValue(String key);
	String getName();
}