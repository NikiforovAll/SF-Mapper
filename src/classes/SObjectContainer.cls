public class SObjectContainer {
	private String containerId;
	private String prefix; 
	private String postfix; 

	public SObjectContainer parentContainer; 
	private List<SObjectContainer> childContainers;
	private SObject dataObject; 

	public SObjectContainer(String containerId) {
		this.containerId = containerId;
		childContainers = new List<SObjectContainer>();
		prefix = '';
		postfix = '';
	}

	public String getContainerId(){
		return prefix + containerId + postfix;
	}

	public String getContainerGroupId(){
		return prefix + containerId;
	}

	public String getPrefix(){
		return this.prefix;

	}

	public SObjectContainer setPrefix(String prefix){
		this.prefix = prefix;
		return this;
	}

	public String getPostfix(){
		return postfix;
	}

	public SObjectContainer setPostfix(String postfix){
		this.postfix = postfix;
		return this;
	}

	public SObjectContainer setContainerId(String prefix, String containerId, String postfix){
		this.containerId = containerId;
		this.prefix = prefix; 
		this.postfix = postfix;
		return this;
	}

	public SObjectContainer addChildContainer(SObjectContainer container){
		if(container != null){
			container.setParentContainer(this);
			childContainers.add(container);
		}
		return this;
	}

	public List<SObjectContainer> getChildContainers(){
		return childContainers;
	}

	public SObjectContainer setParentContainer(SObjectContainer container){
		this.parentContainer = container;
		return this;
	}

	public SObjectContainer setData(SObject data){
		this.dataObject = data;
		return this;
	}

	public SObject getData(){
		return dataObject;
	}
	public void putValue(String field, Object value){
		dataObject.put(field, value);
	}

	public Integer hashCode() {
		return System.hashCode(getContainerId());
	}

	public Boolean equals(Object other) {
		return ((SObjectContainer)other).getContainerId() == getContainerId();
	}
}