package me.rafaelvargas.zacharyquinto

import grails.test.mixin.TestFor
import grails.test.mixin.Mock
import spock.lang.Specification
import spock.lang.Ignore

@TestFor(RecoverPasswordService)
@Mock([User, PendingEmailConfirmation, PendingEmailConfirmationService, UserService])
class RecoverPasswordServiceSpec extends Specification {

    def setup() {
        User userInstance = new User(username:'rafael@gmail.com',
                                     password: 'mysecretpassword',
                                     firstName:'Rafael',
                                     lastName:'Vargas').save(flush:true)
        new PendingEmailConfirmation(user:userInstance, confirmationToken:'Token').save(flush:true)
        
        assert  User.count() == 1
        assert  PendingEmailConfirmation.count() == 1
    }
    
    @Ignore
    void "Validate recovery method"() {
        given: "A RecoverPasswordCommand instance"
            RecoverPasswordCommand recoverPasswordCommand = new RecoverPasswordCommand(confirmationToken:'Token',
                                                                                       password:'password',
                                                                                       passwordConfirmation:'password')
        
        when: "Calling recovery method"
            service.recovery(recoverPasswordCommand)
        
        then: "User have a new password"
            User.first().password == 'password'
        and: "Token no longer exists"
            PendingEmailConfirmation.count() == 0
    }
}
