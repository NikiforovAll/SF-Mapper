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
		return mapObject(source, mappingName, sObjectsContainerList, new MappingLogger(false));
	}

	public static List<SObjectContainer> mapObject(List<IResourceProvider> sourceList, String mappingName, List<SObjectContainer> sObjectsContainerList, MappingLogger logger){
		for(IResourceProvider provider_i : sourceList){
			List<SObjectContainer> currList = new List<SObjectContainer>();
			mapObject(provider_i, mappingName, currList, logger);
			sObjectsContainerList.addAll(currList);
		}
		return sObjectsContainerList;
	}
	public static List<SObjectContainer> mapObject(IResourceProvider source, String mappingName, List<SObjectContainer> sObjectsContainerList, MappingLogger logger){
		String describeMappingName = String.isNotBlank(mappingName) ?  mappingName : source.getName();
		if(!SObjectMapper.fieldMappingSource.containsKey(describeMappingName)){
			String errorMessage = 'Field mapping for this object is empty. Make sure SObjectMapper.initialize was invoked.';
			if(logger.isActive){
				logger.addLog(new MappingLog(errorMessage, MappingLogger.LogType.Error));
				system.debug(errorMessage);
				return sObjectsContainerList;
			}else{
				throw new SplitException(errorMessage);
			}
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
		try{
			if(!source.build()){
				throw new SplitException('source build failed');
			}
		}catch(Exception e){
			String shortErrorMessage = e.getMessage();
			String errorMessage = shortErrorMessage + e.getStackTraceString();
			if(logger.isActive){
				logger.addLog(new MappingLog(errorMessage, shortErrorMessage, MappingLogger.LogType.Error));
				system.debug(errorMessage);
				return sObjectsContainerList;
			}else{
				throw new SplitException(errorMessage);
			}
			
			logger.addLog(new MappingLog(errorMessage, shortErrorMessage, MappingLogger.LogType.Error));
			system.debug(errorMessage);
		}
		for(String objectName: objectNameSet){
			Schema.SObjectType convertType = Schema.getGlobalDescribe().get(objectName);
			if(convertType == null){
				String errorMessage = 'Cannot find sObject to split. [' + objectName + ']';
				if(logger.isActive){
					logger.addLog(new MappingLog(errorMessage, MappingLogger.LogType.Error));
					continue;
				}else{
					throw new SplitException(errorMessage);
				}
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
				logger.addLog(new MappingLog('objectToMapName is blank, skipped mapping rule ', MappingLogger.LogType.Warning));
				continue;
			}

			string childObjectFieldName = fieldToCopy;
			
			// system.debug('valueToWrite ' + valueToWrite);
			childObjectFieldName = mappingRule.destination;
			if(String.IsNotBlank(childObjectFieldName)){
				childObjectFieldName = childObjectFieldName.toLowerCase();
			}

			if(valueToWrite == null || valueToWrite.isEmpty()){
				String errorMessage = 'Value not found' + ' [from ' + fieldToCopy + ' to ' + childObjectFieldName + ']';
				logger.addLog(new MappingLog(errorMessage, errorMessage, MappingLogger.LogType.Warning));
				system.debug(errorMessage);
				continue;
			}
			IFieldFormatter formatter = mappingRule.formatter;
			SObjectContainer currContainer = SObjectContainerUtil.getSObjectContainerById(sObjectsContainerList, containerToMapId);
			// system.debug('valueToWrite.isMultipleData() ' + valueToWrite.isMultipleData());
			if(valueToWrite.isMultipleData()){
				List<ResourceProviderResult> rootResultList = valueToWrite.getResourceListByNodeName(mappingRule.getDecompositionNode());
				// system.debug('root ' + rootResultList);
				// TBD: refactor
				//TBD: log warning that number of parent containers does not equals to number of groups
				Integer numberOfGroups = rootResultList.size();
				Integer currGroupIndex = 0;
				Integer totalNumberOfGroupItems = 0;
				// system.debug('rootResultList ' + rootResultList);
				for(ResourceProviderResult resourceProviderGroupResult_i : rootResultList){
					try{
						List<Object> valueToWriteList = ResourceProviderResult.toObjectList(resourceProviderGroupResult_i.getChilds());
						// system.debug('valueToWriteList ' + valueToWriteList);
						// if(valueToWriteList.isEmpty()){
						// 	String errorMessage = 'Value not found' + ' [from ' + fieldToCopy + ' to ' + childObjectFieldName + ']';
						// 	logger.addLog(new MappingLog(errorMessage, errorMessage, MappingLogger.LogType.Warning));
						// 	system.debug(errorMessage);
						// }
						String currContainerParentId = mappingRule.getParentContainerId();
						if(mappingRule.getManyToManyEnabled() && String.isNotBlank(currContainerParentId)){
							currContainerParentId += currGroupIndex;
						}
						SObjectContainer parentContainer;
						if(String.isNotBlank(currContainerParentId)){
							parentContainer = SObjectContainerUtil.getSObjectContainerById(sObjectsContainerList, currContainerParentId);
						}
						if(parentContainer != null){
							// system.debug('parentContainer ' + parentContainer);
							// system.debug('valueToWriteList(1) ' + valueToWriteList);
							//TBD: possible null pointer exception if containers where created manually (sobject == null)
							for(Integer i = 0 ; i < valueToWriteList.size(); i++){
								Object dataToWrite_i = valueToWriteList[i];
								String containerId_i = containerToMapId;
								String currentPostFix = String.valueOf(mappingRule.getManyToManyEnabled() ? i:totalNumberOfGroupItems);
								String containerSearchId = containerToMapId + currentPostFix; 
								SObjectContainer container_i = SObjectContainerUtil.getSObjectContainerById(parentContainer.getChildContainers(), containerSearchId, 0);
								// system.debug('container_i ' + container_i);
								if(container_i == null){
									container_i = createSObjectContainer(objectNameToObjectTypeMap, objectToMapName, containerId_i)
										.setPostfix(currentPostFix);
									parentContainer.getChildContainers().add(container_i);
								}
								writeMappingResultToSObject(container_i, dataToWrite_i, fieldToCopy, childObjectFieldName, objectToMapName, formatter, objectNameToFieldInfoMap, logger);
								totalNumberOfGroupItems++;
							}
						}else{
							// system.debug('valueToWriteList(2) ' + valueToWriteList);
							for(Integer i = 0 ; i < valueToWriteList.size(); i++){
								Object dataToWrite_i = valueToWriteList[i];
								String containerId_i = containerToMapId;
								String currentPostFix = String.valueOf(mappingRule.getManyToManyEnabled() ? i:totalNumberOfGroupItems);
								String containerSearchId = containerToMapId + currentPostFix; 
								SObjectContainer container_i = SObjectContainerUtil.getSObjectContainerById(sObjectsContainerList, containerSearchId, 0);
								// system.debug('container_i ' + container_i);
								if(container_i == null){
									//TBD: CHANGE CONTAINER ID TO PREFIX + ID + POSTFIX
									container_i = createSObjectContainer(objectNameToObjectTypeMap, objectToMapName, containerId_i)
										.setPostfix(currentPostFix);
									sObjectsContainerList.add(container_i);
								}
								writeMappingResultToSObject(container_i, dataToWrite_i, fieldToCopy, childObjectFieldName, objectToMapName, formatter, objectNameToFieldInfoMap, logger);
								totalNumberOfGroupItems++;
							}
							// system.debug('sObjectsContainerList ' + sObjectsContainerList);
						}
					}catch(Exception e){
						String errorMessage = '[valueToWrite.isMultipleData cast to List<Object> Exception]' + e.getMessage() + '\n' + e.getStackTraceString();
						system.debug(errorMessage);
						logger.addLog(new MappingLog(errorMessage, MappingLogger.LogType.Warning));
					}
					currGroupIndex++;
				}
			}else{
				if(mappingRule.getOneToManyEnabled()){
					List<SObjectContainer> containersToUpdate =	SObjectContainerUtil.getSObjectContainerGroupById(sObjectsContainerList, containerToMapId);
					// system.debug('containersToUpdate ' + containersToUpdate);
					if(containersToUpdate != null && containersToUpdate.size() != 0){
						// system.debug('containerToMapId ' + objectToMapName);
						for(SObjectContainer containerToUpdate_i : containersToUpdate){
							// system.debug('containerToUpdate_i ' + containerToUpdate_i);
							writeMappingResultToSObject(containerToUpdate_i, valueToWrite.getData(), fieldToCopy, childObjectFieldName, objectToMapName, formatter, objectNameToFieldInfoMap, logger);
						}
					}
				}else{
					if(currContainer == null){
						//TBD: possible to create empty object 
						currContainer = createSObjectContainer(objectNameToObjectTypeMap, objectToMapName, containerToMapId);
						sObjectsContainerList.add(currContainer);
					}
					writeMappingResultToSObject(currContainer, valueToWrite.getData(), fieldToCopy, childObjectFieldName, objectToMapName, formatter, objectNameToFieldInfoMap, logger);
				}
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
		Map<String, Map<String, Schema.SObjectField>> objectNameToFieldInfoMap, 
		MappingLogger logger){

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
					//TBD: add custom logger (posibility to mute debug output)
					String shortErrorMessage = e.getMessage() + ' [value: ' + valueToWrite + ', error: ' +' from ' + fieldToCopy + ' to ' + childObjectFieldName + '] ';
					String errorMessage = shortErrorMessage + e.getStackTraceString();
					logger.addLog(new MappingLog(errorMessage, shortErrorMessage, MappingLogger.LogType.Warning));
					system.debug(errorMessage);
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