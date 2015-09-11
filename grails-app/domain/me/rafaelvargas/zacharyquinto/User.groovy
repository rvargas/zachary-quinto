package me.rafaelvargas.zacharyquinto

class User {
    
    String username
    
    String password
    
    String firstName
    
    String lastName
    
    static constraints = {
        username    blank: false, maxSize:100, email:true, unique:true
        password    blank: false, maxSize:100
        firstName   blank: false, maxSize:100
        lastName    blank: false, maxSize:100
    }
}
