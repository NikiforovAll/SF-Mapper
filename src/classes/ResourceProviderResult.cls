public class ResourceProviderResult {
	private String nodeName; 
	private Object data; 
	private List<ResourceProviderResult> dataList;
	private NodeType type; 

	public ResourceProviderResult(Object data){
		// this.isMultipleData = isMultipleData;
		// this.nodeName = name;
		this.data = data;
		this.dataList = new List<ResourceProviderResult>();
		type = NodeType.Data;
	}

	public ResourceProviderResult(String nodeName){
		this.nodeName = nodeName;
		this.dataList = new List<ResourceProviderResult>();
		type = NodeType.Container;
	}

	public ResourceProviderResult(){
		this.dataList = new List<ResourceProviderResult>();
		type = NodeType.Data;
	}

	public void addDataLeaf(Object data){
		dataList.add(new ResourceProviderResult(data));
	}

	public void addContainerLeaf(ResourceProviderResult leaf){
		dataList.add(leaf);
	}

	public Object getData(){
		return data;
	}

	public List<ResourceProviderResult> getChilds(){
		return dataList;
	}
	public ResourceProviderResult setChilds(List<ResourceProviderResult> dataList){
		this.dataList = dataList;
		return this;
	}

	public ResourceProviderResult setData(Object data){
		this.data = data;
		return this;
	}

	public Boolean isEmpty(){
		return !isMultipleData() && data == null;
	}

	public Boolean isMultipleData(){
		return dataList != null && dataList.size() > 0;
	}

	public String getNodeName(){
		return nodeName;
	}
	
	private NodeType getType(){
		return type;
	}

	//TBD: bug when node is on child level (value as group expected)
	public List<ResourceProviderResult> getResourceListByNodeName(String node){
		List<ResourceProviderResult> resultList = new List<ResourceProviderResult>();
		Boolean isNodeFound = false;
		ResourceProviderResult parentNode = this; 
		while(!isNodeFound  && parentNode.isMultipleData()){
			//NOTE: all nodes at the same level should have same names
			ResourceProviderResult childNode = parentNode.getChilds()[0];
			// system.debug('node ' + node);
			// system.debug('childNode.getNodeName() ' + childNode.getNodeName());
			if(node == 'root'){
				isNodeFound = true;
				resultList.add(
					new ResourceProviderResult(node)
						.setChilds(flattenResource(parentNode.getChilds()))
				);
			}else if(childNode.getNodeName() == node){
				for(ResourceProviderResult childNode_i : parentNode.getChilds()){
					resultList.add(
						new ResourceProviderResult(node)
							.setChilds(flattenResource(childNode_i.getChilds()))
					);
				}
			}
			parentNode = childNode;
		}
		// system.debug('resultList ' + resultList);
		return resultList;
	}

	public static List<ResourceProviderResult> flattenResource(List<ResourceProviderResult> resourceList){
		List<ResourceProviderResult> result = new List<ResourceProviderResult>();
		for(Integer i = 0 ; i < resourceList.size(); i++){
			if(resourceList[i].getType() == NodeType.Container){
				result.addAll(flattenResource(resourceList[i].getChilds()));
			}else{
				result.add(resourceList[i]);
			}
		}
		return result;
	}

	public static List<Object> toObjectList(List<ResourceProviderResult> providerResultList){
		List<Object> result = new List<Object>();
		for(ResourceProviderResult providerResult_i : providerResultList){
			result.add(providerResult_i.getData());
		}
		return result;
	}

	private enum NodeType{
		Data, 
		Container
	}
}