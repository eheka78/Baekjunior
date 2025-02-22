<%@ page language="java" contentType="text/html; charset=UTF-8"
	import="java.sql.*, javax.naming.*, Baekjunior.db.*" session="false"%>
<%
request.setCharacterEncoding("utf-8");
String[] selectedItems = request.getParameterValues("deletenoteitem");
// int problemIdx = Integer.parseInt(request.getParameter("problem_idx"));
if(selectedItems == null){
%>
	<script>
	alert("선택된 노트가 없습니다.");
	history.back();
	</script>
<%
	return;
}
try {
	ProblemInfoDB pidb = new ProblemInfoDB();
	
	for(String problemIdx : selectedItems) {
		pidb.deleteProblem(Integer.parseInt(problemIdx));
	}
	pidb.close();
	
	response.sendRedirect("gather_note.jsp");
} catch(SQLException e) {
	out.print(e);
	return;
}
%>