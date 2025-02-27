<%@ page language="java" contentType="text/html; charset=UTF-8"
	import="java.sql.*, javax.naming.*, Baekjunior.db.*" session="false"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>checkdelete_note</title>
<script src="https://kit.fontawesome.com/c9057320ee.js" crossorigin="anonymous"></script>
<link rel="stylesheet" type="text/css" href="MyPagest.css?v=3">
<link rel="stylesheet" type="text/css" href="Baekjunior_css.css?v=3">

<script>
//진짜 로그아웃할건지 확인하는 함수
function confirmLogout() {
	var result = confirm("정말 로그아웃 하시겠습니까?");
	if (result) {
	    window.location.href = "logout_do.jsp";
		} else {
    	return false;
		}
}

// 진짜 삭제할건지 확인하는 함수
function confirmDeletion(problemIdx) {
	var result = confirm("정말 삭제하시겠습니까?");
    if (!result) {
    	event.preventDefault();
    	return false;
    }
}
</script>

</head>


<%
request.setCharacterEncoding("utf-8");
String userId = "none";
HttpSession session = request.getSession(false);
if(session != null && session.getAttribute("login.id") != null) {
	userId = (String) session.getAttribute("login.id");
}
else{
	response.sendRedirect("information.jsp");
    return;
}

// 정렬 순서 정하기
String sortClause = "problem_idx DESC"; // 기본 최신순
if (request.getParameter("latest") != null) {
	sortClause = "problem_idx DESC";	// 최신순
} else if (request.getParameter("earliest") != null) {
	sortClause = "problem_idx";	// 오래된 순
} else if (request.getParameter("ascending") != null) {
	sortClause = "problem_id";	// 문제번호 오름차순
} else if (request.getParameter("descending") != null) {
	sortClause = "problem_id DESC";	// 문제번호 내림차순
}
Connection con = DsCon.getConnection();
PreparedStatement problemPstmt = null;
ResultSet problemRs = null;
PreparedStatement problemCountPstmt = null;
ResultSet countRs = null;
PreparedStatement categoryPstmt = null;
ResultSet categoryRs = null;
PreparedStatement levelPstmt = null;
ResultSet levelRs = null;
%>


<body style="min-height:100vh;">
	<header>
		<a href="index.jsp" class="logo">Baekjunior</a>
		<%
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String profileimg = null;
		try {
			if(userId != "none") {
				String sql = "SELECT * FROM users WHERE user_id=?";
				pstmt = con.prepareStatement(sql);
				pstmt.setString(1, userId);
				rs = pstmt.executeQuery();
				rs.next();

				// 프로필이미지 설정 전인 경우 기본이미지 뜨도록 처리
				profileimg = rs.getString("savedFileName");
				if(profileimg == null){
					profileimg = "img/user.png";
				}
				else {
					profileimg = "./upload/" + rs.getString("savedFileName");
				}
			}

		%>
						
		<!-- header 프로필 -->
		<div id="profile">
			<ul onmouseover="opendiv()" onmouseout="closediv()" style="height:70px;">
				<li><img src=<%=profileimg %> id="myprofileimg" alt="profileimg" style="width:40px; height:40px;"></li>
				<li><a href="MyPage.jsp"><%=userId %></a></li>
			</ul>
			<!-- header 프로필 hover했을 때 나오는 프로필 -->
			<div id="myprodiv" onmouseover="opendiv()" onmouseout="closediv()" style="display:none; position:fixed; top:100px; background:white; padding:17px; border:3px solid black; margin-right:20px; width:200px;">
				<div id="myprofileimgborder">
					<img id="myprofileimg" src=<%=profileimg %> alt="profileimg">
				</div>
				<a href="MyPage.jsp" style="position:absolute; top:20px; margin-left:90px; text-decoration:none; color:black;"><%=userId %></a>
				<a href="#" onclick="confirmLogout()" style="border:1px solid;width:90px; display:inline-block; text-align:center; height:30px; position:absolute; top:50px; margin-left:78px; text-decoration:none; color:black;">로그아웃</a>
			</div>
		</div>

		<%
		pstmt.close();
		rs.close();
		} catch (SQLException e){
			out.print(e);
			return;
		}	
		%>
		<!-- 프로필, 로그아웃 div 띄우기 -->
		<script>
		function opendiv() {
			document.getElementById("myprodiv").style.display = "block";
		}
		function closediv() {
			document.getElementById("myprodiv").style.display = "none";
		}
		</script>
	</header>
	
	<script type="text/javascript">
		window.addEventListener("scroll", function(){
			var header= document.querySelector("header");
			header.classList.toggle("sticky", window.scrollY > 0);
		});
	</script>
	
	<section class="banner">
		<a href="index.jsp" class="logo"></a>
	</section>
	<div class="contents">
		<script>
		function checkAll() {
			const checkboxes = document.getElementsByName("deletenoteitem");
			let allcheck = document.getElementById("allCheck").innerHTML;
			if (allcheck == "전체선택") {
				checkboxes.forEach((checkbox) => {
					checkbox.checked = true
				})
				document.getElementById("allCheck").innerHTML = "전체해제";
			}
			else if (allcheck == "전체해제") {
				checkboxes.forEach((checkbox) => {
					checkbox.checked = false
				})
				document.getElementById("allCheck").innerHTML = "전체선택";
			}
		}
		</script>
		<div class="inner_contents" style="margin-top:35px;">
		<form action="checkdelete_do.jsp" onsubmit="return validateForm()" method="post" name="deletenote">
			<div class="inner_header">
				<h1 style="font-size:30px;">노트</h1>
				<div>
					<button type="button" onclick="checkAll()" id="allCheck" name="allCheck" style="width:100px;height:40px;border-radius:40px;">전체선택</button>
					<input type="submit" onclick="confirmDeletion()" value="삭제" style="width:100px;height:40px;border-radius:40px;cursor:pointer;">
				</div>
			</div>
			<div id="list_group" style="padding:0;margin-top:20px;">
				<table>
					<tr>
					  <th>#</th>
					  <th>제목</th>
					  <th></th>
					  <th style="width:100px;"></th>
					</tr>
		 		<%
		 		if (!userId.equals("none")) {
		 			try {
		 				
		 				// 문제 선택
		 				String problemQuery = "SELECT * FROM problems WHERE user_id=? ORDER BY is_fixed DESC, " + sortClause;
		 				problemPstmt = con.prepareStatement(problemQuery);
		 				problemPstmt.setString(1, userId);
		 				problemRs = problemPstmt.executeQuery();
						
		 				// 등록된 문제 수 세기
						String problemCountQuery = "SELECT COUNT(*) FROM problems WHERE user_id=?";
						problemCountPstmt = con.prepareStatement(problemCountQuery);
						problemCountPstmt.setString(1, userId);
						countRs = problemCountPstmt.executeQuery();
		 			
		 				if (countRs.next() && countRs.getInt(1) <= 0) {
		 					%>
		 					</table>
		 					
		 					<%
		 				} else {
		 					// 고정된 문제 먼저 출력
		 					while (problemRs.next()) {
		 		%>
				  <tr class="table_item">
				    <td style="padding-left: 10px;">
				    	<input type="checkbox" id="deletenoteitem" name="deletenoteitem" value="<%=problemRs.getInt("problem_idx")%>" style="margin-right:10px;cursor:pointer;">
				    	<a href="note_detail.jsp?problem_idx=<%=problemRs.getInt("problem_idx")%>"><%=problemRs.getInt("problem_id") %></a>
				    </td>
				    <td><a href="note_detail.jsp?problem_idx=<%=problemRs.getInt("problem_idx")%>"><%=problemRs.getString("memo_title") %></a></td>
				    
				    <td>
					    <% if(problemRs.getInt("is_fixed") == 1) { %>
				    			<img class="content_set_a" id="content_set_a_<%= problemRs.getInt("problem_idx") %>" src="img/pin.png" align="right" style="width:15px;">
				    	<% } else { %>
				    			<img class="content_set_a" id="content_set_a_<%= problemRs.getInt("problem_idx") %>" src="img/pin.png" align="right" style="display:none;width:15px;">
				    	<% } %>
			    	</td>
			    	<td style="text-align:right;"></td>
				  </tr>
		 		<%
		 					}			
		 				}
		 			} catch(SQLException e) {
		 				out.print(e);
		 			} finally {
		 				if (con != null) con.close();
						if(problemPstmt != null) problemPstmt.close();
						if(problemRs != null) problemRs.close();
						if(problemCountPstmt != null) problemCountPstmt.close();
						if(countRs != null) countRs.close();
						if(levelPstmt != null) levelPstmt.close();
						if(levelRs != null) levelRs.close();
		 			}
		 		}
		 		%>
			</div>
		</form>
		</div>
	</div>
	
	
</body>
</html>