package me.rafaelvargas.zacharyquinto

import grails.validation.Validateable

@Validateable
class RecoverPasswordCommand {
    
    String confirmationToken
    
    String password
    
    String passwordConfirmation
    
    static constraints = {
        confirmationToken       blank:false,
                                maxSize:255,
                                validator: {String confirmationToken ->
                                    if(confirmationToken){
                                        PendingEmailConfirmation.validateToken(confirmationToken)
                                    }
                                }
        
        password                blank:false, maxSize:100
        
        passwordConfirmation    blank:false, 
                                maxSize:100, 
                                validator: { String passwordConfirmation, RecoverPasswordCommand recoverPassword ->
                                    if(passwordConfirmation && recoverPassword.password){
                                        passwordConfirmation == recoverPassword.password
                                    }
                                }
    }
    
}
