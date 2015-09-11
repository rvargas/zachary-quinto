package me.rafaelvargas.zacharyquinto

class PendingEmailConfirmation {
    
    User user
    String confirmationToken
    
    static constraints = {
        confirmationToken   blank:false, maxSize:255
    }
}
