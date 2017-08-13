public class SObjectContainerUtil {
	public static SObjectContainer getSObjectContainerById(List<SObjectContainer> sObjectContainerList, String containerId){
		for(SObjectContainer container_i : sObjectContainerList){
			if(container_i.getContainerId() == containerId){
				return container_i;
			}
			SObjectContainer childResult = getSObjectContainerById(container_i.getChildContainers(), containerId);
			if(childResult != null){
				return childResult;
			}
		}
		return null;
	}

	public static SObjectContainer getSObjectContainerById(List<SObjectContainer> sObjectContainerList, String containerId, Integer depth){
		if(depth < 0){
			return null;
		}
		depth = depth - 1;
		system.debug('sObjectContainerList ' + sObjectContainerList);
		system.debug('containerId ' + containerId);
		
		for(SObjectContainer container_i : sObjectContainerList){
			if(container_i.getContainerId() == containerId){
				return container_i;
			}
			SObjectContainer childResult = getSObjectContainerById(container_i.getChildContainers(), containerId, depth);
			if(childResult != null){
				return childResult;
			}
		}
		return null;
	}

	public static Map<String, SObject> transfromContainerListToSObjectMap(List<SObjectContainer> containerList){
		Map<String, SObject> resultMap = new Map<String, SObject>();
		system.debug('containerList ' + containerList);
		for(SObjectContainer container_i : containerList){
			if(!resultMap.containsKey(container_i.getContainerId())){
				resultMap.put(container_i.getContainerId(), container_i.getData());
			}else{
				throw new ContainerException('Duplicate containers');
			}
		}
		return resultMap;
	}

	public static List<SObjectContainer> transfromSObjectMapToContainerList(Map<String, SObject> sObjectMap){
		List<SObjectContainer> containerList = new List<SObjectContainer>();
		for(String key : sObjectMap.keySet()){
			containerList.add(
				new SObjectContainer(key)
					.setData(sObjectMap.get(key))
			);
		}
		return containerList;
	}

	public class ContainerException extends Exception{}
}