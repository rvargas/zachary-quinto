package me.rafaelvargas.zacharyquinto

import grails.transaction.Transactional

@Transactional
class RecoverPasswordService {
    
    def userService
    def pendingEmailConfirmationService
    
    void recovery(RecoverPasswordCommand recoverPasswordCommand) {
        PendingEmailConfirmation pendingEmailConfirmationInstance = recoverPasswordCommand.pendingEmailConfirmation()
        User userInstance = pendingEmailConfirmationInstance.user
        
        userService.updatePassword(userInstance, recoverPasswordCommand.password)
        pendingEmailConfirmationService.delete(pendingEmailConfirmationInstance)
    }
}
