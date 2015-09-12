package me.rafaelvargas.zacharyquinto

import spock.lang.Specification
import org.apache.commons.lang.RandomStringUtils

class ConstraintUnitSpec extends Specification{

    String getString(Integer length) {
        RandomStringUtils.randomAlphabetic(length)
    }

    String getEmail(Integer length){
        "${RandomStringUtils.randomAlphabetic(length-10)}@gmail.com"
    }
    
    String getProperties(Object instance){
        List excludeAttributes = ['dateCreated', 'lastUpdated', 'id', 
                                  'class', 'errors', 'constraints']
        
        List propertiesWithoutId = instance.properties.keySet().toArray().findAll{String key -> !key.endsWith('Id') && !key.endsWith('Service')}
        Map filteredProperties = instance.properties.subMap(propertiesWithoutId - excludeAttributes)
        
        List propertiesList = []
        filteredProperties.each {key,value -> propertiesList << "$key: $value" }
        
        propertiesList.join('\n\n')
    }
}
