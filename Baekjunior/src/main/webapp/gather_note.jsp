<%@ page language="java" contentType="text/html; charset=UTF-8"
	import="java.sql.*, javax.naming.*, Baekjunior.db.*" session="false"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>gather_note</title>
<script src="https://kit.fontawesome.com/c9057320ee.js" crossorigin="anonymous"></script>
<link rel="stylesheet" type="text/css" href="MyPagest.css?v=3">
<link rel="stylesheet" type="text/css" href="Baekjunior_css.css?v=3">

<script>
/* profile top 위치 */
function updateProfileSelectTopLoc() {
	let profile_div = document.getElementById("profile");
	let myprodiv_div = document.getElementById("myprodiv");
	

	let profile_div_bottom = profile_div.getBoundingClientRect().bottom;
	 myprodiv_div.style.top = profile_div_bottom + "px";
	console.log("top2: " + profile_div_bottom);
	
}

window.addEventListener("DOMContentLoaded", updateProfileSelectTopLoc);
window.addEventListener("resize", updateProfileSelectTopLoc);

//profile에 hover할 때만 실행
let profile_div = document.getElementById("profile");

document.addEventListener("DOMContentLoaded", function () {
    let profile_div = document.getElementById("profile");

    if (profile_div) {
        profile_div.addEventListener("mousemove", (event) => {
            updateProfileSelectTopLoc();
        });
    }
});



function confirmLogout() {
	var result = confirm("정말 로그아웃 하시겠습니까?");
	if (result) {
	    window.location.href = "logout_do.jsp";
		} else {
    	return false;
		}
}

function confirmDeletion(problemIdx) {
    var result = confirm("정말 삭제하시겠습니까?");
    if (result) {
        window.location.href = "note_delete_do.jsp?problem_idx=" + problemIdx;
    } else {
        return false;
    }
}

//고정 여부 업데이트하는 함수
function updatePin(problemIdx) {
    var pinIcon = document.getElementById('content_set_a_' + problemIdx);
    let fix = 0;
    
	if(pinIcon.offsetWidth > 0 && pinIcon.offsetHeight > 0) {
		pinIcon.style.display = 'none';
		fix = 0;
	} else {
		pinIcon.style.display = 'inline-block';
		fix = 1;
	}
  
	const xhr = new XMLHttpRequest();
    xhr.open("POST", "updatePin.jsp", true);
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr.onreadystatechange = function () {
        if (xhr.readyState === 4 && xhr.status === 200) {
            console.log(xhr.responseText);  
        }
    };
    xhr.send("problem_idx=" + problemIdx +"&is_fixed=" + fix);
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
		<div class="inner_contents" style="margin-top:35px;">
			<div class="inner_header">
				<h1 style="font-size:30px;">NOTE</h1>
				<button onclick="location.href='checkdelete_note.jsp'" style="width:90px;height:40px;border-radius:40px;">선택</button>
			</div>
			<div id="list_group" style="padding:0;margin-top:20px;">
				<table>
					<tr>
					  <th>#</th>
					  <th>제목</th>
					  <th></th>
					  <th style="width:100px;">설정</th>
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
				    <td style="padding-left: 10px;"><a href="note_detail.jsp?problem_idx=<%=problemRs.getInt("problem_idx")%>"><%=problemRs.getInt("problem_id") %></a></td>
				    <td><a href="note.jsp?problem_idx=<%=problemRs.getInt("problem_idx")%>"><%=problemRs.getString("memo_title") %></a></td>
				    
				    <td>
					    <% if(problemRs.getInt("is_fixed") == 1) { %>
				    			<img class="content_set_a" id="content_set_a_<%= problemRs.getInt("problem_idx") %>" src="img/pin.png" align="right" style="width:15px;">
				    	<% } else { %>
				    			<img class="content_set_a" id="content_set_a_<%= problemRs.getInt("problem_idx") %>" src="img/pin.png" align="right" style="display:none;width:15px;">
				    	<% } %>
			    	</td>
			    	<td style="text-align:right;">
			    		<div class="content_set" style="position:relative;">
			    		<button class="content_set_b"><img src="img/....png"></button>
			    			<ul style="width:180px;top:15px;right:0px;">
				    			<li><a onclick="updatePin('<%=problemRs.getInt("problem_idx") %>')" href="#">Unpin / Pin to top</a></li>
				    			<li><a href="split_screen.jsp?problem_idx1=<%=problemRs.getInt("problem_idx")%>&problem_idx2=-1">Split screen</a></li>
				    			<li><a onclick="confirmDeletion('<%=problemRs.getInt("problem_idx") %>')" href="#">Delete</a></li>
				    		</ul>
				    	</div>
			    	</td>
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
				</table>
			</div>
		</div>
	</div>
	
	
</body>
</html>