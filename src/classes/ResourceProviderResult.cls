public class ResourceProviderResult {
	public Boolean isMultipleData; 
	public Object data; 
	public ResourceProviderResult(Object data, Boolean isMultipleData){
		this.isMultipleData = isMultipleData;
		this.data = data;
	}
}