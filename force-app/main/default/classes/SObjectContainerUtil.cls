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
		// system.debug('sObjectContainerList ' + sObjectContainerList);
		// system.debug('containerId ' + containerId);
		
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

	public static List<SObjectContainer> getSObjectContainerGroupById(List<SObjectContainer> sObjectContainerList, String groupId){
		List<SObjectContainer> result = new List<SObjectContainer>();
		getSObjectContainerGroupById(sObjectContainerList, groupId, result);
		return result;
	}

	private static List<SObjectContainer> getSObjectContainerGroupById(List<SObjectContainer> sObjectContainerList, String groupId, List<SObjectContainer> result){
		// system.debug('sObjectContainerList ' + sObjectContainerList);
		for(SObjectContainer container_i : sObjectContainerList){
			// system.debug('groupId ' + groupId);
			// system.debug('container_i.getContainerGroupId() ' + container_i.getContainerGroupId());
			// system.debug('container_i ' + container_i);
			if(container_i.getContainerGroupId() == groupId){
				result.add(container_i);
				continue;
			}
			List<SObjectContainer> childResult = getSObjectContainerGroupById(container_i.getChildContainers(), groupId, result);
		}
		return result;
	}

	public static Map<String, SObject> transfromContainerListToSObjectMap(List<SObjectContainer> containerList){
		Map<String, SObject> resultMap = new Map<String, SObject>();
		// system.debug('containerList ' + containerList);
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