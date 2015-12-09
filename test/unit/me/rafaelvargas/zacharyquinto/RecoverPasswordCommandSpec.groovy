package me.rafaelvargas.zacharyquinto

import grails.test.mixin.Mock
import grails.test.mixin.support.GrailsUnitTestMixin
import grails.test.mixin.TestMixin
import spock.lang.Ignore
import spock.lang.Unroll

@TestMixin(GrailsUnitTestMixin)
@Mock([PendingEmailConfirmation, User])
class RecoverPasswordCommandSpec extends ConstraintUnitSpec{
    
    def setup() {
        User userInstance = new User(username:'rafael@gmail.com',
                                     password: 'mysecretpassword',
                                     firstName:'Rafael',
                                     lastName:'Vargas').save(flush:true)
        new PendingEmailConfirmation(user:userInstance, confirmationToken:'Token').save(flush:true)
        
        assert  User.count() == 1
        assert  PendingEmailConfirmation.count() == 1
    }

    def cleanup() {
        User.where { }.deleteAll()
        PendingEmailConfirmation.where{ }.deleteAll()
        
        assert  User.count() == 0
        assert  PendingEmailConfirmation.count() == 0
    }
    
    @Ignore
    @Unroll("Test '#reason' resulted #expectedValidation with #expectedErrorCount errors")
    void "Validate constraints"(){
        given: "A RecoverPasswordCommand"
            RecoverPasswordCommand rpInstance = new RecoverPasswordCommand(password: password,
                                                                           passwordConfirmation: passwordConfirmation,
                                                                           confirmationToken: confirmationToken)
            println getProperties(rpInstance)
        
        when: "RecoverPasswordCommand validation"
            Boolean validationResult = rpInstance.validate()
        
        then: "Validation is expected"
            validationResult == expectedValidation
        and: "Error count is expected"
            rpInstance.errors.errorCount == expectedErrorCount
        
        where:
            password            |passwordConfirmation   |confirmationToken  |expectedValidation |expectedErrorCount |reason
            'mysecurepassword'  |'mysecurepassword'     |'Token'            |true               |0                  |'All fields are valid :-)'
            null                |null                   |null               |false              |3                  |'All fields are invalid :-('
            
            //password
            null                |'mysecurepassword'     |'Token'            |false              |1                  |'Password is null'
            ''                  |'mysecurepassword'     |'Token'            |false              |1                  |'Password is blank'
            getString(101)      |'mysecurepassword'     |'Token'            |false              |2                  |'Password is longer thanh maxSize (100) and don\'t match with passwordConfirmation'
            
            //passwordConfirmation
            getString(10)       |null                   |'Token'            |false              |1                  |'PasswordConfirmation is null'
            getString(10)       |''                     |'Token'            |false              |1                  |'PasswordConfirmation is blank'
            getString(10)       |getString(101)         |'Token'            |false              |2                  |'PasswordConfirmation is longer thanh maxSize (100) and don\'t match with password'
            getString(10)       |getString(15)          |'Token'            |false              |1                  |'PasswordConfirmation don\'t match with password'
            
            //confirmationToken
            'mysecurepassword'  |'mysecurepassword'     |null               |false              |1                  |'ConfirmationToken is null'
            'mysecurepassword'  |'mysecurepassword'     |''                 |false              |1                  |'ConfirmationToken is blank'
            'mysecurepassword'  |'mysecurepassword'     |getString(256)     |false              |2                  |'ConfirmationToken is longer thanh maxSize (255) and don\'t match with any existing token'
            'mysecurepassword'  |'mysecurepassword'     |getString(25)      |false              |1                  |'ConfirmationToken don\'t match with any existing token'
    }
}
