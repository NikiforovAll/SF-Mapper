public class FieldMappingRule {
	public String source {get;set;}
	public String destination {get;set;} 
	public String objectName {get;set;}
	private String containerId {get; set;}
	private String containerPrefix {get;set;}
	private String parentContainerId {get;set;}
	public IFieldFormatter formatter {get; set;}

	public FieldMappingRule(String source, String destination, String objectName, IFieldFormatter formatter) {
		//TBD: check for null poiter exception and cast custom exception
		this.source = source;
		this.destination = destination;
		this.objectName = objectName;
		this.formatter = formatter;
	}
	public FieldMappingRule(String source, String destination, String objectName) {
		this(source, destination, objectName, null);
	}

	public FieldMappingRule setContainerId(String containerId){
		this.containerId = containerId;
		return this;
	}

	public String getContainerId(){
		if(String.isBlank(containerId)){
			this.containerId = objectName;
		}
		String prefix = containerPrefix != null ? containerPrefix : '';
		return prefix + containerId;
	}

	//means that current container is the child and need to add prefix before it's name
	public FieldMappingRule setContainerPrefix(String prefix){
		this.containerPrefix = prefix;
		return this;
	}

	public String getContainerPrefix(){
		return containerPrefix;
	}

	public FieldMappingRule setParentContainerId(String containerId){
		this.parentContainerId = containerId;
		return this;
	}

	public String getParentContainerId(){
		return parentContainerId;
	}
}