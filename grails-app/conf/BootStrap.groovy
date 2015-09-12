import java.nio.file.attribute.UserDefinedFileAttributeView;

import me.rafaelvargas.zacharyquinto.User
import me.rafaelvargas.zacharyquinto.PendingEmailConfirmation

class BootStrap {

    def init = { servletContext ->
        User userInstance = new User(   username:'rv@manoderecha.mx', 
                                        password:'securepassword',
                                        firstName:'Rafael',
                                        lastName:'Vargas').save(flush:true)
        
        for(i in 1..10){
            new PendingEmailConfirmation(user:userInstance, confirmationToken:"qwerty${10}").save(flush:true)
        }
        
        assert User.count() == 1
        assert PendingEmailConfirmation.count() == 10
        
    }
    def destroy = {
    }
}
