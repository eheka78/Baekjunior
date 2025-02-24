<%@ page language="java" contentType="text/html; charset=UTF-8"
	import="java.sql.*, javax.naming.*, java.io.*, Baekjunior.db.*" session="false"%>
<%
request.setCharacterEncoding("utf-8");
String id = request.getParameter("id");

try {
	UserInfoDB uidb = new UserInfoDB();
	String savedFileName = uidb.imageExistCheck(id);
	if(savedFileName == "" || savedFileName == null || savedFileName.trim().isEmpty()){
		out.print("현재 기본 프로필 이미지입니다.");
	}
	else {
		ServletContext context = getServletContext();
		String uploadDir = context.getRealPath("upload");
		String filePath = uploadDir + File.separator + savedFileName;
		
		File file = new File(filePath);
		if(file.exists()) {
			file.delete();
		}
		
		uidb.deleteProfileImage(id);
		out.print("프로필 이미지가 삭제되었습니다.");
	}
	uidb.close();
	
} catch(SQLException e) {
	out.print(e);
	return;
}
%>