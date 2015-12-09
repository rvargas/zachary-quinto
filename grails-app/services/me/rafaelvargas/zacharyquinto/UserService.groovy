package me.rafaelvargas.zacharyquinto

import grails.transaction.Transactional

@Transactional
class UserService {

    def updatePassword(User userInstance, String password) {
        userInstance.password = password
        userInstance.save(flush:true)
    }
}
