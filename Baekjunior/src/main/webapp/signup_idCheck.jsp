<%@ page language="java" contentType="text/html; charset=UTF-8"
	import="java.sql.*, Baekjunior.db.*, javax.naming.*"%>
<%
request.setCharacterEncoding("utf-8");

String id = request.getParameter("id");

try {
	UserInfoDB userDB = new UserInfoDB();
	
	// 아이디 중복 체크
	int is_exist = userDB.idCheck(id);
	
	if(is_exist == 1) {	
		out.print("unavailable");
	} else {
		out.print("available");
	}
	userDB.close();
} catch(SQLException e) {
	out.print(e);
	return;
} catch(NamingException e) {
	out.print(e);
	return;
}
%>
