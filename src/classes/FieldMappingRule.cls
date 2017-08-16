public class FieldMappingRule implements Comparable{
	public String source {get;set;}
	public String destination {get;set;} 
	public String objectName {get;set;}
	private String containerId {get; set;}
	private String containerPrefix {get;set;}
	private String parentContainerId {get;set;}
	private String decompositionNode {get;set;}
	private Boolean isManyToManyEnabled {get; set;}
	private Boolean isOneToManyEnabled {get; set;}
	public IFieldFormatter formatter {get; set;}



	public FieldMappingRule(String source, String destination, String objectName, IFieldFormatter formatter) {
		//TBD: check for null poiter exception and cast custom exception
		this.source = source;
		this.destination = destination;
		this.objectName = objectName;
		this.formatter = formatter;
		this.isManyToManyEnabled = false;
		this.isOneToManyEnabled = false;
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

	public String getDecompositionNode(){
		return String.isNotBlank(decompositionNode)? decompositionNode : 'root';
	}

	public FieldMappingRule setDecompositionNode(String node){
		this.decompositionNode = node;
		return this;
	}

	public FieldMappingRule setManyToMany(Boolean flag){
		this.isManyToManyEnabled = flag;
		return this;
	}

	public Boolean getManyToManyEnabled(){
		return this.isManyToManyEnabled;
	}

	public FieldMappingRule setOneToMany(Boolean flag){
		this.isOneToManyEnabled = flag;
		return this;
	}
	public Boolean getOneToManyEnabled(){
		return this.isOneToManyEnabled;
	}

	public FieldMappingRule setFormatter(IFieldFormatter formatter){
		this.formatter = formatter;
		return this;
	}

	public Integer compareTo(Object other){
		FieldMappingRule compareTo = (FieldMappingRule)other; 
		Integer result = 0;
		if(compareTo.getOneToManyEnabled() && !this.getOneToManyEnabled()){
			result = -1;
		}else if(!compareTo.getOneToManyEnabled() && this.getOneToManyEnabled()){
			result = 1;
		}else if(compareTo.getManyToManyEnabled() && !this.getManyToManyEnabled()){
			result = -1;
		}else if(!compareTo.getManyToManyEnabled() && this.getManyToManyEnabled()){
			result = 1;
		}else if(String.isNotBlank(compareTo.getParentContainerId()) && String.isBlank(this.getParentContainerId())){
			result = -1;
		}else if(String.isBlank(compareTo.getParentContainerId()) && String.isNotBlank(this.getParentContainerId())){
			result = 1;
		}else if(compareTo.getParentContainerId() == this.getContainerId()){
			system.debug('compareTo.getParentContainerId() == this.getContainerId()');
			result = -1;
		}else if(this.getParentContainerId() == compareTo.getContainerId()){
			system.debug('this.getParentContainerId() ' + this.getParentContainerId());
			system.debug('this.getParentContainerId() == compareTo.getContainerId()');
			result = 1;
		} else if(compareTo.getOneToManyEnabled() == this.getOneToManyEnabled()){
			result = 0;
		} else if(compareTo.getManyToManyEnabled() == this.getManyToManyEnabled()){
			result = 0;
		}
		// system.debug('compareTo.result ' + result);
		// system.debug('this ' + this);
		// system.debug('compareTo ' + compareTo);
		return result;
	}
}