<%@ page language="java" contentType="text/html; charset=UTF-8"
	import="java.sql.*, javax.naming.*, Baekjunior.db.*" session="false"%>
<%
request.setCharacterEncoding("utf-8");
String id = request.getParameter("id");
String newPw = request.getParameter("newPw");

try {
	UserInfoDB uidb = new UserInfoDB();
	uidb.updatePassword(id, newPw);
	out.print("비밀번호가 변경되었습니다.");
	uidb.close();
	
} catch(SQLException e) {
	out.print(e);
	return;
}
%>