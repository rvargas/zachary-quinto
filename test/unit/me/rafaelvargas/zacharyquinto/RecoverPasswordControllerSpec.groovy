package me.rafaelvargas.zacharyquinto

import grails.test.mixin.TestFor
import grails.test.mixin.Mock
import spock.lang.Specification
import spock.lang.Unroll
import spock.lang.Ignore

@TestFor(RecoverPasswordController)
@Mock([User, PendingEmailConfirmation, RecoverPasswordService, PendingEmailConfirmationService, UserService])
class RecoverPasswordControllerSpec extends Specification {

    def setup() {
        User userInstance = new User(username:'rafael@gmail.com',
                                     password: 'mysecretpassword',
                                     firstName:'Rafael',
                                     lastName:'Vargas').save(flush:true)
        new PendingEmailConfirmation(user:userInstance, confirmationToken:'Token').save(flush:true)
        
        assert  User.count() == 1
        assert  PendingEmailConfirmation.count() == 1
    }

    //recover
    @Ignore
    @Unroll("Recover: Method #method have response code #resultExpected")
    void "Recover action is only accesible with POST method"(){
        setup: "http method"
            request.method = method
            
        when: "Calling list action"
            controller.recover()
        
        then: "Response code is expected"
            resultExpected == response.status
        
        where:
            method      ||resultExpected
            "GET"       ||405
            "PUT"       ||405
            "DELETE"    ||405
            "ANYTHING"  ||405
    }
    
    @Ignore
    void "Recover action with invalid RecoverPasswordCommand"(){
        given: "Required parameters"
            controller.params.confirmationToken = 'WRONGTOKEN'
            controller.params.password = 'MyNewPassword'
            controller.params.passwordConfirmation = 'MyNewPassword'
        and: "Set HTTTP method"
            request.method = 'POST'
        
        when: "Calling recover action"
            controller.recover()
        
        then: "Recover is rendered"
            view == '/recoverPassword/index'
        and: "RecoverPasswordCommand is sent in model"
            model.recoverPasswordCommand
            model.recoverPasswordCommand.confirmationToken == 'WRONGTOKEN'
            model.recoverPasswordCommand.password == 'MyNewPassword'
            model.recoverPasswordCommand.passwordConfirmation == 'MyNewPassword'
            model.recoverPasswordCommand.hasErrors()
        and: "User remains with old password"
            User.first().password == 'mysecretpassword'
        and: "Token still exists"
            PendingEmailConfirmation.first().confirmationToken == 'Token'
    }
    
    @Ignore
    void "Recover action with valid RecoverPasswordCommand"(){
        given: "Required parameters"
            controller.params.confirmationToken = 'Token'
            controller.params.password = 'MyNewPassword'
            controller.params.passwordConfirmation = 'MyNewPassword'
        and: "Set HTTTP method"
            request.method = 'POST'
        
        when: "Calling recover action"
            controller.recover()
        
        then: "User have a new password"
            User.first().password == 'MyNewPassword'
        and: "Token no longer exists"
            PendingEmailConfirmation.count() == 0
        and: "Flow was redirected to index"
            response.redirectedUrl == '/recoverPassword/index'
        and: "Flash message was set"
            flash.message == 'Su contraseña ha sido actualizada'
            !flash.error
    }
    
}
