<%@ page language="java" contentType="text/html; charset=UTF-8"
	import="java.sql.*, java.util.*, java.io.*, javax.naming.*, Baekjunior.db.*, Baekjunior.multipart.*" session="false"%>
<%
request.setCharacterEncoding("utf-8");
String userId = request.getParameter("user_id");
String userPwd = request.getParameter("password");
try {
	UserInfoDB uidb = new UserInfoDB();
	
	int is_exist = uidb.userExistCheck(userId, userPwd);
	if(is_exist == 0) {
%>
		<script>
			opener.showAlert("비밀번호가 일치하지 않습니다.");
			window.close();
		</script>
<%
		uidb.close();
	}
	else {
	
		ServletContext context = getServletContext();
		String realFolder = context.getRealPath("upload");
		
		String imageStr = uidb.imageExistCheck(userId);
		// 이미 프로필 사진이 존재하는 경우
		if(imageStr != "") {
			String oldFileName = imageStr;
			File oldFile = new File(realFolder + File.separator + oldFileName);
			oldFile.delete();
		}
		
		uidb.deleteUser(userId);
		uidb.close();
%>
		<script>
			alert("탈퇴가 완료되었습니다."); // 1. 탈퇴 완료 메시지 띄우기
		    opener.location.href = "logout_do.jsp"; // 2. 부모 창을 로그아웃 페이지로 이동
		    window.close(); // 3. 현재 창 닫기
		</script>
<%
	}
	
} catch (SQLException e) {
	out.print(e);
	return;
}
%>