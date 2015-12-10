package me.rafaelvargas.zacharyquinto

class PendingEmailConfirmation {
    
    User user
    String confirmationToken
    
    static constraints = {
        confirmationToken   blank:false, maxSize:255, unique:true
    }
    
    static Boolean validateToken(String token){
        PendingEmailConfirmation.where{confirmationToken == token}.count() > 0
    }
}
