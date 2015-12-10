package me.rafaelvargas.zacharyquinto

class RecoverPasswordController {
    
    def recoverPasswordService
    
    static allowedMethods = [index:'GET', recover:'POST']
    
    def index() {
        
    }
    
    def recover(RecoverPasswordCommand recoverPasswordCommand){
        if(!recoverPasswordCommand.validate()) {
            render view:'index', model:[recoverPasswordCommand:recoverPasswordCommand]
            return
        }
        
        recoverPasswordService.recovery(recoverPasswordCommand)
        
        flash.message = 'Su contraseña ha sido actualizada'
        redirect action:'index'
    }
}
