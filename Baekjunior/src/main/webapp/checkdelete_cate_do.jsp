<%@ page language="java" contentType="text/html; charset=UTF-8"
	import="java.sql.*, javax.naming.*, Baekjunior.db.*" session="false"%>
<%
request.setCharacterEncoding("utf-8");
String[] selectedItems = request.getParameterValues("deletecateitem");
// int problemIdx = Integer.parseInt(request.getParameter("problem_idx"));
if(selectedItems == null){
%>
	<script>
	alert("선택된 카테고리가 없습니다.");
	history.back();
	</script>
<%
	return;
}
try {
	AlgorithmMemoDB Amdb = new AlgorithmMemoDB();
	
	for(String categoryIdx : selectedItems) {
		Amdb.deleteAlgorithm(Integer.parseInt(categoryIdx));
	}
	Amdb.close();
	
	response.sendRedirect("gather_category.jsp");
} catch(SQLException e) {
	out.print(e);
	return;
}
%>