public class SObjectMapperManager {

	public String fieldToCopy {get; set;}
	public String childObjectFieldName {get; set;}
	public String objectToMapName {get; set;}
	public ResourceProviderResult valueToWriteResult {get; set;}
	public String containerToMapId {get; set;}
	public IFieldFormatter formatter {get; set;}

	private Map<String, Map<String, Schema.SObjectField>> objectNameToFieldInfoMap;
	private Map<String, Schema.SObjectType> objectNameToObjectTypeMap;
	
	private MappingLogger logger;

	public SObjectMapperManager() {
		
	}

	public SObjectMapperManager setFieldToCopy(String fieldToCopy){
		this.fieldToCopy = fieldToCopy; 
		if(String.IsNotBlank(fieldToCopy)){
			this.fieldToCopy = fieldToCopy.toLowerCase();
		}
		return this;
	}

	public SObjectMapperManager setFieldToMap(String childObjectFieldName){
		this.childObjectFieldName = childObjectFieldName;
		if(String.IsNotBlank(childObjectFieldName)){
			this.childObjectFieldName = childObjectFieldName.toLowerCase();
		}
		return this;
	}

	public SObjectMapperManager setObjectToMapName(String objectToMapName, String defaultObjectName){
		this.objectToMapName = objectToMapName;
		if(String.IsNotBlank(defaultObjectName) && String.IsBlank(objectToMapName)){
			this.objectToMapName = defaultObjectName;
		}
		return this;
	}

	public SObjectMapperManager setContainerId(String containerToMapId, String defaultObjectName){
		this.containerToMapId = containerToMapId;
		if(String.IsNotBlank(defaultObjectName) && String.IsBlank(containerToMapId)){
			containerToMapId = defaultObjectName;
		}
		return this;
	}

	public SObjectMapperManager setValueToWrite(ResourceProviderResult valueToWrite){
		this.valueToWriteResult = valueToWrite;
		return this;
	}

	public SObjectMapperManager setFormatter(IFieldFormatter formatter){
		this.formatter = formatter;
		return this;
	}

	public SObjectMapperManager setFieldInfoMap(Map<String, Map<String, Schema.SObjectField>> objectNameToFieldInfoMap){
		this.objectNameToFieldInfoMap = objectNameToFieldInfoMap;
		return this;
	}

	public SObjectMapperManager setObjectInfoMap(Map<String, Schema.SObjectType> objectNameToObjectTypeMap) {
		this.objectNameToObjectTypeMap = objectNameToObjectTypeMap;
		return this;
	}

	public SObjectMapperManager setLogger(MappingLogger logger){
		this.logger = logger;
		return this;
	}


	public void writeToSingleContainer(String containerId, String parentContainerId, List<SObjectContainer> sObjectsContainerList){
		SObjectContainer currContainer = SObjectContainerUtil.getSObjectContainerById(sObjectsContainerList, containerId);
		if(currContainer == null){
			// system.debug('containerToMapId ' + containerId);
			currContainer = createSObjectContainer(objectNameToObjectTypeMap, objectToMapName, containerId);
			SObjectContainer parentContainer;
			if(String.isNotBlank(parentContainerId)){
				parentContainer = SObjectContainerUtil.getSObjectContainerById(sObjectsContainerList, parentContainerId);
			}
			if(parentContainer != null){
				parentContainer.getChildContainers().add(currContainer);
			}else{
				sObjectsContainerList.add(currContainer);
			}
		}
		writeMappingResultToSObject(currContainer, this.valueToWriteResult.getData());
	}

	public void writeToContainerGroup(String groupName, List<SObjectContainer> sObjectsContainerList){
		List<SObjectContainer> containersToUpdate =	SObjectContainerUtil.getSObjectContainerGroupById(sObjectsContainerList, groupName);
		if(containersToUpdate != null && containersToUpdate.size() != 0){
			for(SObjectContainer containerToUpdate_i : containersToUpdate){
				writeMappingResultToSObject(containerToUpdate_i, this.valueToWriteResult.getData());
			}
		}
	}

	public void writeMultipleDataContainer(String decompositionNode, String parentId, Boolean manyToManyEnabled, List<SObjectContainer> sObjectsContainerList){
		List<ResourceProviderResult> rootResultList = valueToWriteResult.getResourceListByNodeName(decompositionNode);
		//TBD: log warning that number of parent containers does not equals to number of groups
		Integer numberOfGroups = rootResultList.size();
		Integer currGroupIndex = 0;
		Integer totalNumberOfGroupItems = 0;
		for(ResourceProviderResult resourceProviderGroupResult_i : rootResultList){
			try{
				String currContainerParentId = parentId;
				List<Object> valueToWriteList = ResourceProviderResult.toObjectList(resourceProviderGroupResult_i.getChilds());
				if(manyToManyEnabled && String.isNotBlank(currContainerParentId)){
					currContainerParentId += currGroupIndex;
				}
				SObjectContainer parentContainer;
				if(String.isNotBlank(currContainerParentId)){
					parentContainer = SObjectContainerUtil.getSObjectContainerById(sObjectsContainerList, currContainerParentId);
				}
				if(parentContainer != null){
					//TBD: possible null pointer exception if containers where created manually (sobject == null)
					for(Integer i = 0 ; i < valueToWriteList.size(); i++){
						Object dataToWrite_i = valueToWriteList[i];
						String containerId_i = containerToMapId;
						String currentPostFix = String.valueOf(manyToManyEnabled ? i:totalNumberOfGroupItems);
						String containerSearchId = containerToMapId + currentPostFix; 
						SObjectContainer container_i = SObjectContainerUtil.getSObjectContainerById(parentContainer.getChildContainers(), containerSearchId, 0);
						if(container_i == null){
							container_i = createSObjectContainer(objectNameToObjectTypeMap, objectToMapName, containerId_i)
								.setPostfix(currentPostFix);
							parentContainer.getChildContainers().add(container_i);
						}
						writeMappingResultToSObject(container_i, dataToWrite_i);
						totalNumberOfGroupItems++;
					}
				}else{
					for(Integer i = 0 ; i < valueToWriteList.size(); i++){
						Object dataToWrite_i = valueToWriteList[i];
						String containerId_i = containerToMapId;
						String currentPostFix = String.valueOf(manyToManyEnabled ? i:totalNumberOfGroupItems);
						String containerSearchId = containerToMapId + currentPostFix; 
						SObjectContainer container_i = SObjectContainerUtil.getSObjectContainerById(sObjectsContainerList, containerSearchId, 0);
						if(container_i == null){
							container_i = createSObjectContainer(objectNameToObjectTypeMap, objectToMapName, containerId_i)
								.setPostfix(currentPostFix);
							sObjectsContainerList.add(container_i);
						}
						writeMappingResultToSObject(container_i, dataToWrite_i);
						totalNumberOfGroupItems++;
					}
				}
			}catch(Exception e){
				String errorMessage = '[valueToWrite.isMultipleData cast to List<Object> Exception]' + e.getMessage() + '\n' + e.getStackTraceString();
				system.debug(errorMessage);
				logger.addLog(new MappingLog(errorMessage, MappingLogger.LogType.Warning));
			}
			currGroupIndex++;
		}
	}

	public void writeMappingResultToSObject(SObjectContainer currContainer, Object valueToWrite){
		if(formatter != null){
			valueToWrite = formatter.format(valueToWrite);
		}
		if(valueToWrite == null){
			return;
		}
		try{
			currContainer.putValue(childObjectFieldName, valueToWrite);
		}catch(Exception e){
			Schema.DescribeFieldResult displayType;
			FormatterResult formatterResult;
			Boolean isLogError = false;
			if(!objectNameToFieldInfoMap.get(objectToMapName).containsKey(childObjectFieldName)){
				isLogError = true;
			}else{
				displayType = objectNameToFieldInfoMap.get(objectToMapName).get(childObjectFieldName).getDescribe();
				// system.debug('field.displayType - ' + displayType.getType());
				IFieldFormatter fallbackFormatter = FieldFormatterFactory.createFieldFormatter(displayType.getType(), logger);
				if(fallbackFormatter != null){
					formatterResult = fallbackFormatter.format(valueToWrite);
					// system.debug('formatterResult ' + formatterResult);
					if(formatterResult.isSuccess){
						currContainer.putValue(
							childObjectFieldName,
							formatterResult.data
						);
					}
				}
			}
			if(formatterResult == null || !formatterResult.isSuccess || isLogError){
				String shortErrorMessage = e.getMessage() + ' [value: ' + valueToWrite + ', error: ' +' from ' + fieldToCopy + ' to ' + childObjectFieldName + '] ';
				String errorMessage = shortErrorMessage + e.getStackTraceString();
				logger.addLog(new MappingLog(errorMessage, shortErrorMessage, MappingLogger.LogType.Warning));
				system.debug(errorMessage);
			}
		}
	}

	public static SObjectContainer createSObjectContainer(Map<String, Schema.SObjectType> objectNameToObjectTypeMap, String objectToMapName, String containerToMapId){
		Schema.SObjectType convertType = objectNameToObjectTypeMap.get(objectToMapName);
		SObject genericObject = convertType.newSObject();
		SObjectContainer result = new SObjectContainer(containerToMapId)
			.setData(genericObject);
		return result;
	}


}