package me.rafaelvargas.zacharyquinto

import grails.transaction.Transactional

@Transactional
class PendingEmailConfirmationService {

    void delete(PendingEmailConfirmation pendingEmailConfirmationInstance) {
        pendingEmailConfirmationInstance.delete(flush:true)
    }
}
