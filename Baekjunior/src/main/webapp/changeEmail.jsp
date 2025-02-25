<%@ page language="java" contentType="text/html; charset=UTF-8"
	import="java.sql.*, javax.naming.*, Baekjunior.db.*" session="false"%>
<%
request.setCharacterEncoding("utf-8");
String id = request.getParameter("id");
String newEmail = request.getParameter("newEmail");

try {
	UserInfoDB uidb = new UserInfoDB();
	uidb.updateEmail(id, newEmail);
	out.print("이매일이 변경되었습니다.");
	uidb.close();
	
} catch(SQLException e) {
	out.print(e);
	return;
}
%>