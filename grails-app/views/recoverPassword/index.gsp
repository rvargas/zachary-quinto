<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
        <meta name="description" content="">
        <meta name="author" content="">

        <title>Password recovery</title>

        <!-- Bootstrap core CSS -->
        <link href="http://getbootstrap.com/dist/css/bootstrap.min.css" rel="stylesheet">

        <!-- Custom styles for this template -->
        <link href="http://getbootstrap.com/examples/signin/signin.css" rel="stylesheet">

    </head>

    <body>

        <div class="container" >
            <g:hasErrors bean="${recoverPasswordCommand}">
                <div class="alert alert-danger">
                    <g:renderErrors bean="${recoverPasswordCommand}" />
                </div>
            </g:hasErrors>
            
            <g:if test="${flash.message}">
                <div class="alert alert-success">${flash.message}</div>
            </g:if>
            
            <g:form class="form-signin" action="recover" method="POST">
                <h2 class="form-signin-heading">Password Recovery</h2>
            
                <label for="password" class="sr-only">New password</label>
                <input type="password" value="${recoverPasswordCommand?.password}" name="password" id="password" class="form-control" placeholder="New password" required autofocus>
            
                <label for="passwordConfirmation" class="sr-only">Password verification</label>
                <input type="password" value="${recoverPasswordCommand?.passwordConfirmation}" name="passwordConfirmation" id="passwordConfirmation" class="form-control" placeholder="Password verification" required autofocus>
            
                <g:hiddenField name="confirmationToken" value="${recoverPasswordCommand?.confirmationToken?:params.id}"/>
            
                <button class="btn btn-lg btn-primary btn-block" type="submit">Change password</button>
            </g:form>
        </div>
    </body>
</html>
