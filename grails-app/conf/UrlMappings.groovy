class UrlMappings {

	static mappings = {
        "/$id?"(controller:"recoverPassword", action:'index')
        "/recoverPassword"(controller:"recoverPassword", action:'recover')
	}
}
