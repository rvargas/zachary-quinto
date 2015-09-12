package me.rafaelvargas.zacharyquinto

import grails.test.mixin.TestFor
import spock.lang.Specification
import spock.lang.Unroll
import spock.lang.Ignore

@TestFor(User)
class UserSpec extends Specification {

    def setup() {
        new User(username:'rafael@gmail.com', 
                 password: 'mysecretpassword', 
                 firstName:'Rafael', 
                 lastName:'Vargas').save(flush:true)

        assert          User.count() == 1
        assert          User.count()
        assertEquals    User.count(),1
    }

    def cleanup() {
        assert          User.count() == 1
        User.where { }.deleteAll()
        assert          User.count() == 0
        assert          !User.count()
        assertEquals    User.count(),0
    }
    
    void "Username can't be blank"() {
        given: "A user"
            User userInstance = new User(username:'', 
                                         password: 'mysecretpassword',
                                         firstName:'Rafael',
                                         lastName:'Vargas')
        
        when: "User validation"
            Boolean validationResult = userInstance.validate()
        
        then: "User is not valid"
            !validationResult
            validationResult == false
    }
    
    void "Username can't be longer than 100 characters"() {
        given: "A user"
            User userInstance = new User(username: "${'e'*91}@gmail.com",
                                         password: 'mysecretpassword', 
                                         firstName:'Rafael', 
                                         lastName:'Vargas')
        
        when: "User validation"
            Boolean validationResult = userInstance.validate()
        
        then: "User is not valid"
            !validationResult
            validationResult == false
    }
    
    void "Username must be an email"() {
        given: "A user"
            User userInstance = new User(username: 'notAnEmail', 
                                         password: 'mysecretpassword', 
                                         firstName: 'Rafael', 
                                         lastName: 'Vargas')
        
        when: "User validation"
            Boolean validationResult = userInstance.validate()
        
        then: "User is not valid"
            !validationResult
            validationResult == false
    }
    
    /*
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     *  I N T E R M I S S I O N
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     * 
     */
    @Ignore
    Void "Validate User constraints"(){
        
        given: "A user"
            User userInstance = new User(username: username,
                                         password: password,
                                         firstName: firstName,
                                         lastName: lastName)
        
        when: "User validation"
            Boolean validationResult = userInstance.validate()
        
        then: "Validation is expected"
            validationResult == expectedValidation
        and: "Error count is expected"
            userInstance.errors.errorCount == expectedErrorCount
        
        where:
            username                |password           |firstName  |lastName       |expectedValidation |expectedErrorCount |reason
            "rv@manoderecha.mx"     |"mysecretpassword" |"Rafael"   |"Vargas"       |true               |0                  |"All fields are valid :-)"
            null                    |null               |null       |null           |false              |4                  |"All fields are invalid :-("
            
            // Username
            null                    |"mysecretpassword" |"Rafael"   |"Vargas"       |false              |1                  |"Username is null"
            ""                      |"mysecretpassword" |"Rafael"   |"Vargas"       |false              |1                  |"Username is blank"
            "rv"                    |"mysecretpassword" |"Rafael"   |"Vargas"       |false              |1                  |"Username is not an email"
            "${'e'*91}@gmail.com"   |"mysecretpassword" |"Rafael"   |"Vargas"       |false              |1                  |"Username is longer than maxSize (100)"
            "rafael@gmail.com"      |"mysecretpassword" |"Rafael"   |"Vargas"       |false              |1                  |"Username is not unique"
        
    }
    
    /*
     *
     *
     *
     *
     *
     *
     *
     *
     *  I N T E R M I S S I O N
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     */
    
    @Ignore
    @Unroll("Test '#reason' resulted #expectedValidation with #expectedErrorCount errors")
    Void "Validate User constraints but Unrolled"(){
        
        given: "A user"
            User userInstance = new User(username: username,
                                         password: password,
                                         firstName: firstName,
                                         lastName: lastName)
        
        when: "User validation"
            Boolean validationResult = userInstance.validate()
        
        then: "Validation is expected"
            validationResult == expectedValidation
        and: "Error count is expected"
            userInstance.errors.errorCount == expectedErrorCount
        
        where:
            username                |password           |firstName  |lastName       |expectedValidation |expectedErrorCount |reason
            "rv@manoderecha.mx"     |"mysecretpassword" |"Rafael"   |"Vargas"       |true               |0                  |"All fields are valid :-)"
            null                    |null               |null       |null           |false              |4                  |"All fields are invalid :-("
            
            // Username
            null                    |"mysecretpassword" |"Rafael"   |"Vargas"       |false              |1                  |"Username is null"
            ""                      |"mysecretpassword" |"Rafael"   |"Vargas"       |false              |1                  |"Username is blank"
            "rv"                    |"mysecretpassword" |"Rafael"   |"Vargas"       |false              |1                  |"Username is not an email"
            "${'e'*91}@gmail.com"   |"mysecretpassword" |"Rafael"   |"Vargas"       |false              |1                  |"Username is longer than maxSize (100)"
            "rafael@gmail.com"      |"mysecretpassword" |"Rafael"   |"Vargas"       |false              |1                  |"Username is not unique"
        
    }
    
    /*
     *
     *
     *
     *
     *
     *
     *
     *
     *  I N T E R M I S S I O N
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     */
    
    String getString(Integer length){
        'e'*length
    }
    
    String getEmail(Integer length){
        "${'e'*(length-10)}@gmail.com"
    }
    
    @Ignore
    @Unroll("Test '#reason' resulted #expectedValidation with #expectedErrorCount errors")
    Void "Validate User constraints but with helper functions"(){
        
        given: "A user"
            User userInstance = new User(username: username,
                                         password: password,
                                         firstName: firstName,
                                         lastName: lastName)
        
        when: "User validation"
            Boolean validationResult = userInstance.validate()
        
        then: "Validation is expected"
            validationResult == expectedValidation
        and: "Error count is expected"
            userInstance.errors.errorCount == expectedErrorCount
        
        where:
            username                |password           |firstName      |lastName       |expectedValidation |expectedErrorCount |reason
            "rv@manoderecha.mx"     |"mysecretpassword" |"Rafael"       |"Vargas"       |true               |0                  |"All fields are valid :-)"
            null                    |null               |null           |null           |false              |4                  |"All fields are invalid :-("
            
            // Username
            null                    |getString(10)      |getString(10)  |getString(10)  |false              |1                  |"Username is null"
            ""                      |getString(10)      |getString(10)  |getString(10)  |false              |1                  |"Username is blank"
            "rv"                    |getString(10)      |getString(10)  |getString(10)  |false              |1                  |"Username is not an email"
            getEmail(101)           |getString(10)      |getString(10)  |getString(10)  |false              |1                  |"Username is longer than maxSize (100)"
            "rafael@gmail.com"      |getString(10)      |getString(10)  |getString(10)  |false              |1                  |"Username is not unique"
        
    }
    
    /*
     *
     *
     *
     *
     *
     *
     *
     *  L A S T
     *  I N T E R M I S S I O N
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     *
     */
    @Ignore
    @Unroll("Test '#reason' resulted #expectedValidation with #expectedErrorCount errors")
    Void "Validate User constraints but extending ConstraintUnitTest"(){
        
        given: "A user"
            User userInstance = new User(   username: username,
                                            password: password,
                                            firstName: firstName,
                                            lastName: lastName)
            println getProperties(userInstance)
        
        when: "User validation"
            Boolean validationResult = userInstance.validate()
        
        then: "Validation is expected"
            validationResult == expectedValidation
        and: "Error count is expected"
            userInstance.errors.errorCount == expectedErrorCount
        
        where:
            username                |password           |firstName      |lastName       |expectedValidation |expectedErrorCount |reason
            "rv@manoderecha.mx"     |"mysecretpassword" |"Rafael"       |"Vargas"       |true               |0                  |"All fields are valid :-)"
            null                    |null               |null           |null           |false              |4                  |"All fields are invalid :-("
            
            // Username
            null                    |getString(10)      |getString(10)  |getString(10)  |false              |1                  |"Username is null"
            ""                      |getString(10)      |getString(10)  |getString(10)  |false              |1                  |"Username is blank"
            "rv"                    |getString(10)      |getString(10)  |getString(10)  |false              |1                  |"Username is not an email"
            getEmail(101)           |getString(10)      |getString(10)  |getString(10)  |false              |1                  |"Username is longer than maxSize (100)"
            "rafael@gmail.com"      |getString(10)      |getString(10)  |getString(10)  |false              |1                  |"Username is not unique"
            
            //password
            getEmail(15)           |null                |getString(10)  |getString(10)  |false              |1                  |"Password is null"
            getEmail(15)           |""                  |getString(10)  |getString(10)  |false              |1                  |"Password is blank"
            getEmail(15)           |getString(101)      |getString(10)  |getString(10)  |false              |1                  |"Password is longer thanh maxSize (100)"
            
            //firstName
            getEmail(15)           |getString(10)       |null           |getString(10)  |false              |1                  |"FirstName is null"
            getEmail(15)           |getString(10)       |""             |getString(10)  |false              |1                  |"FirstName is blank"
            getEmail(15)           |getString(10)       |getString(101) |getString(10)  |false              |1                  |"FirstName is longer thanh maxSize (100)"
            
            //lastName
            getEmail(15)           |getString(10)       |getString(10)  |null           |false              |1                  |"LastName is null"
            getEmail(15)           |getString(10)       |getString(10)  |""             |false              |1                  |"LastName is blank"
            getEmail(15)           |getString(10)       |getString(10)  |getString(101) |false              |1                  |"LastName is longer thanh maxSize (100)"
    }
}
