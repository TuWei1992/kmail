<%@page errorPage="error.jsp"
%><%@page import="java.io.File"
%><%@page import="java.util.List"
%><%@page import="org.workcast.kmail.MailListener"
%><%

    String check = request.getParameter("check");
    List<File> msgs = MailListener.listAllEmails();

    if (check!=null && "yes".equals(check)) {
         MailListener.deleteEmails();
         response.sendRedirect("main.jsp");
         return;
     }
%>
<html>
<head>
<link href="kmail.css" rel="styleSheet" type="text/css"/>
</head>
<body>
<p><a href="main.jsp">Home</a> </p>
<h3>Clear Old Emails?</h3>

<p>Would you like to delete all <%=msgs.size()%> current email messages?</p>

<form method="post" action="delete.jsp">
<input type="submit" value="Delete All">
<input type="checkbox" name="check" value="yes"> (check this box to confirm delete)
</form>

</body>
</html>