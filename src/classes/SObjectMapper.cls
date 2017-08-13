public class SObjectMapper {
	private static Map<String,IFieldMapping> fieldMappingSource;
	static {
		fieldMappingSource = new Map<String, IFieldMapping>();
	}
	/**
	 * initializes mapping to be used in mapObject static method
	 * @param  objectName
	 * @param  fieldMapping
	 */
	public static void initialize(String objectName, IFieldMapping fieldMapping){
		system.debug('objectName.init  ' + objectName);
		if(fieldMappingSource.containsKey(objectName)){
			SObjectMapper.fieldMappingSource.remove(objectName);
		}
		SObjectMapper.fieldMappingSource.put(objectName, fieldMapping);
	}

	/**
	 * initializes mapping to be used in mapObject static method
	 * @param  fieldMapping
	 */
	public static void initialize(MapperConfigBuilder builder){
		IFieldMapping fieldMapping = builder.build();
		initialize(builder.getName(), fieldMapping);
	}


	public static Boolean isInitialized(String schemeName){
		return fieldMappingSource.containsKey(schemeName);
	}
	/**
	 * splits source into sobject map based on config from initialize method //TBD: need refactoring 
	 * NOTE: in order to support heirarchies you need to pass already built sObjectsContainerList that contains valid structure of paranets containers
	 * //TBD: provide capability to build sObjectsContainerList based on field mapping rules
	 * @param  source
	 * @param  fieldMappingSource
	 * @param  mappedObjects
	 * @return returns map of sobjects "name of sobject" => "sobject"
	 */
	public static List<SObjectContainer> mapObject(IResourceProvider source, List<SObjectContainer> sObjectsContainerList, String mappingName){
		String describeMappingName = String.isNotBlank(mappingName) ?  mappingName : source.getName();
		if(!SObjectMapper.fieldMappingSource.containsKey(describeMappingName)){
			throw new SplitException('Field mapping for this object is empty. Make sure SObjectMapper.initialize was invoked.');
		}
		IFieldMapping fieldMappingSource = SObjectMapper.fieldMappingSource.get(describeMappingName);
		// Map<String, Set<String>> objectMapping = fieldMappingSource.getObjectMapping();
		Set<String> objectNameSet = fieldMappingSource.getObjectNames();
		// Map<String, FieldMappingRule> fieldMapping = fieldMappingSource.getfieldMapping();
		Map<String, Schema.SObjectType> objectNameToObjectTypeMap = new Map<String,Schema.SObjectType>();
		Map<String, Map<String, Schema.SObjectField>> objectNameToFieldInfoMap = new Map<String, Map<String, Schema.SObjectField>>();
		String defaultObjectToMapName = fieldMappingSource.getDefaultMappingObject();
		if(!objectNameSet.contains(defaultObjectToMapName) && String.isNotBlank(defaultObjectToMapName)){
			objectNameSet.add(defaultObjectToMapName);
		}
		for(String objectName: objectNameSet){
			Schema.SObjectType convertType = Schema.getGlobalDescribe().get(objectName);
			if(convertType == null){
				throw new SplitException('Cannot find sObject to split.');
			}
			objectNameToObjectTypeMap.put(objectName, convertType);
			objectNameToFieldInfoMap.put(objectName, convertType.getDescribe().fields.getMap());
		}
		for(FieldMappingRule mappingRule : fieldMappingSource.getMappingRules()){
			// system.debug('mappingRule ' + mappingRule);
			String fieldToCopy = mappingRule.source;
			String objectToMapName = mappingRule.objectName;
			Boolean isCurrentFieldMapped = false;
			ResourceProviderResult valueToWrite = source.getValue(fieldToCopy);
			if(valueToWrite == null || valueToWrite.data == null){
				continue;
			}
			// to be mapped*
			String containerToMapId = mappingRule.getContainerId();
			if(String.IsNotBlank(fieldToCopy)){
				fieldToCopy = fieldToCopy.toLowerCase();
			}
			//object/container mapping 
			if(String.IsNotBlank(defaultObjectToMapName) && String.IsBlank(containerToMapId)){
				containerToMapId = defaultObjectToMapName;
				objectToMapName = defaultObjectToMapName;
			}
			
			if(String.IsBlank(objectToMapName)){
				continue;
			}

			string childObjectFieldName = fieldToCopy;
			
			// system.debug('valueToWrite ' + valueToWrite);
			childObjectFieldName = mappingRule.destination;
			if(String.IsNotBlank(childObjectFieldName)){
				childObjectFieldName = childObjectFieldName.toLowerCase();
			}
			IFieldFormatter formatter = mappingRule.formatter;
			SObjectContainer currContainer = SObjectContainerUtil.getSObjectContainerById(sObjectsContainerList, containerToMapId);

			if(valueToWrite.isMultipleData){
				//TBD: refactor
				try{
					List<Object> valueToWriteList = (List<Object>)valueToWrite.data;
					String currContainerParentId = mappingRule.getParentContainerId();
					if(String.isNotBlank(currContainerParentId)){
						SObjectContainer parentContainer = SObjectContainerUtil.getSObjectContainerById(sObjectsContainerList, mappingRule.getParentContainerId());
						// system.debug('parentContainer ' + parentContainer);
						if(parentContainer != null){
							for(Integer i = 0 ; i < valueToWriteList.size(); i++){
								Object dataToWrite_i = valueToWriteList[i];
								String containerId_i = containerToMapId + String.valueOf(i);
								SObjectContainer container_i = 
									SObjectContainerUtil.getSObjectContainerById(parentContainer.getChildContainers(), containerId_i, 0);
								if(container_i == null){
									container_i = createSObjectContainer(objectNameToObjectTypeMap, objectToMapName, containerId_i);
									parentContainer.getChildContainers().add(container_i);
								}
								writeMappingResultToSObject(container_i, dataToWrite_i, fieldToCopy, childObjectFieldName, objectToMapName, formatter, objectNameToFieldInfoMap);
							}
						}
					}else{
						for(Integer i = 0 ; i < valueToWriteList.size(); i++){
							Object dataToWrite_i = valueToWriteList[i];
							String containerId_i = containerToMapId + String.valueOf(i);
							SObjectContainer container_i = SObjectContainerUtil.getSObjectContainerById(sObjectsContainerList, containerId_i, 0);
							if(container_i == null){
								container_i = createSObjectContainer(objectNameToObjectTypeMap, objectToMapName, containerId_i);
								sObjectsContainerList.add(container_i);
							}
							writeMappingResultToSObject(container_i, dataToWrite_i, fieldToCopy, childObjectFieldName, objectToMapName, formatter, objectNameToFieldInfoMap);
						}
						
					}
				}catch(Exception e){
					system.debug('[valueToWrite.isMultipleData cast to List<Object> Exception]' +e.getMessage());
					system.debug(e.getLineNumber());
					system.debug(e.getStackTraceString());
				}
			}else{
				if(currContainer == null){
					//TBD: possible to create empty object 
					currContainer = createSObjectContainer(objectNameToObjectTypeMap, objectToMapName, containerToMapId);
					sObjectsContainerList.add(currContainer);
				}
				writeMappingResultToSObject(currContainer, valueToWrite.data, fieldToCopy, childObjectFieldName, objectToMapName, formatter, objectNameToFieldInfoMap);
			}
		}
		return sObjectsContainerList;
	}
	public static Map<String, SObject> mapObject(IResourceProvider source, Map<String, SObject> mappedObjects, String mappingName){
		//for backwards API compatability
		List<SObjectContainer> result =  mapObject(source, SObjectContainerUtil.transfromSObjectMapToContainerList(mappedObjects), mappingName);
		return SObjectContainerUtil.transfromContainerListToSObjectMap(result);
	}
	/**
	 * splits sobject into sobject map based on config from initialize method 
	 * @param  sObjectTomap
	 * @return returns map of sobjects "name of sobject" => "sobject"
	 */
	public static Map<String, SObject> mapObject(SObject sObjectTomap){
		return mapObject(new SObjectResourceProvider(sObjectTomap), new Map<String, sObject>(), '');
	}

	/**
	 * splits sobject into sobject map based on config from initialize method 
	 * @param  sobject
	 * @param  mappedObjects
	 * @return returns map of sobjects "name of sobject" => "sobject"
	 */
	public static Map<String, SObject> mapObject(SObject sObjectTomap, Map<String, sObject> mappedObjects){
		return mapObject(new SObjectResourceProvider(sObjectTomap), mappedObjects, '');
	}

	/**
	 * splits source into sobject map based on config from initialize method 
	 * @param  source
	 * @return returns map of sobjects "name of sobject" => "sobject"
	 */
	public static Map<String, SObject> mapObject(IResourceProvider source){
		return mapObject(source, new Map<String, sObject>(), '');
	}

	/**
	 * splits source into sobject map based on config from initialize method 
	 * @param  source
	 * @return returns map of sobjects "name of sobject" => "sobject"
	 */
	public static Map<String, SObject> mapObject(IResourceProvider source, String mappingName){
		return mapObject(source, new Map<String, sObject>(), mappingName);
	}
	
	/**
	 * splits source into sobject map based on config from initialize method 
	 * @param  source
	 * @return returns map of sobjects "name of sobject" => "sobject"
	 */
	public static Map<String, SObject> mapObject(IResourceProvider source, Map<String, sObject> mappedObjects){
		return mapObject(source, mappedObjects, '');
	}


	/**
	 * splits source into sobject map based on config from initialize method and return default entity 
	 * @param  source 
	 * @return 
	 */
	public static sObject mapSingleObject(SObject sobjectToMap){
		return mapSingleObject(new SObjectResourceProvider(sobjectToMap));
	}

	/**
	 * splits source into sobject map based on config from initialize method and return default entity 
	 * @param  source 
	 * @return 
	 */
	public static sObject mapSingleObject(IResourceProvider source){
		Map<String, SObject> result = SObjectMapper.mapObject(source);
		if(result.values().size() > 1){
			throw new SplitException('map ambiguity condition. Use mapSingleObject(String name) instead.');
		}
		return result.values()[0];
	}

	/**
	 * splits source into sobject map based on config from initialize method and return default entity 
	 * @param  source 
	 * @return 
	 */
	public static sObject mapSingleObject(SObject source, Map<String, sObject> mappedObjects){
		return mapSingleObject(new SObjectResourceProvider(source), mappedObjects);
	}

	/**
	 * splits source into sobject map based on config from initialize method and return default entity 
	 * @param  source 
	 * @return 
	 */
	public static sObject mapSingleObject(IResourceProvider source, Map<String, sObject> mappedObjects){
		Map<String, SObject> result = SObjectMapper.mapObject(source, mappedObjects);
		if(result.values().size() > 1){
			throw new SplitException('map ambiguity condition. Use mapSingleObject(String name) instead.');
		}
		return result.values()[0];
	}

	/**
	 * splits source into sobject map based on config from initialize method and return entity specified by name parameter 
	 * @param  source 
	 * @param  name - name of result object (note: note name of mapping config)
	 * @return 
	 */
	public static sObject mapSingleObject(IResourceProvider source, String name){
		return mapSingleObject(source, new Map<String, SObject>(), name);
	}

	/**
	 * splits source into sobject map based on config from initialize method and return entity specified by name parameter 
	 * @param  source
	 * @param  mappedObjects
	 * @param  name - name of result object (note: note name of mapping config)
	 * @return 
	 */
	public static sObject mapSingleObject(IResourceProvider source, Map<String, SObject> mappedObjects, String name){
		Map<String, SObject> result = SObjectMapper.mapObject(source, mappedObjects);
		if(result.containsKey(name)){
			return result.get(name);
		}else{
			throw new SplitException('Object is not found. Make sure that name is appropriate.');
		}
	}

	private static void writeMappingResultToSObject(
		SObjectContainer currContainer,
		Object valueToWrite,
		String fieldToCopy, 
		String childObjectFieldName,
		String objectToMapName,
		IFieldFormatter formatter,
		Map<String, Map<String, Schema.SObjectField>> objectNameToFieldInfoMap){

		if(formatter != null){
			valueToWrite = formatter.format(valueToWrite);
		}
		if(valueToWrite != null){
			try{
				//TBD: dirty approach, change 
				currContainer.putValue(childObjectFieldName, valueToWrite);
			}catch(Exception e){
				Schema.DescribeFieldResult displayType;
				FormatterResult formatterResult;
				Boolean isLogError = false;
				if(!objectNameToFieldInfoMap.get(objectToMapName).containsKey(childObjectFieldName)){
					isLogError = true;
				}else{
					displayType = objectNameToFieldInfoMap.get(objectToMapName).get(childObjectFieldName).getDescribe();
					system.debug('field.displayType - ' + displayType.getType());
					IFieldFormatter fallbackFormatter = FieldFormatterFactory.createFieldFormatter(displayType.getType());
					if(fallbackFormatter != null){
						formatterResult = fallbackFormatter.format(valueToWrite);
						system.debug('formatterResult ' + formatterResult);
						if(formatterResult.isSuccess){
							currContainer.putValue(
								childObjectFieldName,
								formatterResult.data
							);
						}
					}
				}
				if(formatterResult == null || !formatterResult.isSuccess || isLogError){
					//TBD: add custom logger (posibility to mute debug output)
					system.debug('[error: ' +'from: ' + fieldToCopy + ' to ' + childObjectFieldName + ']' +e.getMessage());
					system.debug(e.getLineNumber());
					system.debug(e.getStackTraceString());
				}
			}
		}
	}

	private static SObjectContainer createSObjectContainer(Map<String, Schema.SObjectType> objectNameToObjectTypeMap, String objectToMapName, String containerToMapId){
		Schema.SObjectType convertType = objectNameToObjectTypeMap.get(objectToMapName);
		SObject genericObject = convertType.newSObject();
		SObjectContainer result = new SObjectContainer(containerToMapId)
			.setData(genericObject);
		return result;
	}

	public class SplitException extends Exception{}
}