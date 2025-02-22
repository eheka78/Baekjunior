<%@ page language="java" contentType="text/html; charset=UTF-8"
	import="java.sql.*, javax.naming.*, Baekjunior.db.*" session="false"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>note</title>
<link rel="stylesheet" href="Baekjunior_css.css">
<script src="https://kit.fontawesome.com/c9057320ee.js" crossorigin="anonymous"></script>

<script>
function updateWindowHeight() {
    let friends_code_list_div = document.getElementById("friends_code_list");
    let friend_code_div = document.getElementById("friend_code");
    friends_code_list_div.style.height = (window.innerHeight - 220) + "px";
    friend_code_div.style.height = (window.innerHeight - 210 + 60) + "px";
    
    console.log("현재 window.innerHeight 값:", window.innerHeight);
}

// 페이지 로드 시 실행
window.onload = updateWindowHeight;

// 창 크기가 변경될 때 실행
window.addEventListener("resize", updateWindowHeight);
</script>

<style>
a{
	text-decoration: none;
	color:black;
}

.friends_code_list_item:hover div {
	letter-spacing:3px;
	font-weight:bold;
	transition:0.3s;
}

 @-webkit-keyframes takent {
      0% {
         flex: 0;
      }
      100% {
         flex: 3;
      }
   }
   @keyframes takent {
      0% {
         flex: 0;
      }
      100% {
         flex: 3;
      }
   }
   @-webkit-keyframes outnt {
      0% {
         flex: 3;
      }
      100% {
         flex: 0;
      }
   }
   @keyframes outnt {
      0% {
         flex: 3;
      }
      100% {
         flex: 0;
      }
   }
   .outnote {
      animation-name: outnt;
      animation-duration: 2s;
   }
</style>

</head>
<%
request.setCharacterEncoding("utf-8");
String userId = "none";
HttpSession session = request.getSession(false);

if(session != null && session.getAttribute("login.id") != null) {
	userId = (String) session.getAttribute("login.id");
}
int problemId = Integer.parseInt(request.getParameter("problem_id"));

Connection con = DsCon.getConnection();
PreparedStatement pstmt = null;
ResultSet rs = null;
%>
<body>	
	<header style="padding:0 100px;">
		<a href="index.jsp" class="logo">Baekjunior</a>
		<%
		try {
			if(userId != "none") {
				String sql = "SELECT * FROM users WHERE user_id=?";
				pstmt = con.prepareStatement(sql);
				pstmt.setString(1, userId);
				rs = pstmt.executeQuery();
				rs.next();
			}

		%>
		<div>
			<ul onmouseover="opendiv()" onmouseout="closediv()" style="height:130px;">
				<li><img src="img/user.png" style="width:30px;"></li>
				<li><a href="MyPage.jsp"><%=userId %></a></li>
			</ul>
			<div id="myprodiv" onmouseover="opendiv()" onmouseout="closediv()" style="display:none;position:fixed;top: 100px;background: white;padding: 17px;border: 3px solid black;margin-right: 20px;width: 200px;">
				<div id="myprofileimgborder">
					<img id="myprofileimg" src="./upload/<%=rs.getString("savedFileName") %>" alt="profileimg">
				</div>
				<a href="MyPage.jsp" style="position:absolute;top:30px;margin-left:90px;text-decoration: none;color: black;"><%=userId %></a>
				<a href="logout_do.jsp" style="border: 1px solid;width: 90px;display:inline-block;text-align: center;height: 30px;position:absolute;top:60px;margin-left:78px;text-decoration: none;color: black;">로그아웃</a>
			</div>
		</div>
		
		<script>
		function opendiv() {
			document.getElementById("myprodiv").style.display = "block";
		}
		function closediv() {
			document.getElementById("myprodiv").style.display = "none";
		}
		</script>
		
		<%
			pstmt.close();
			rs.close();
		} catch (SQLException e){
			out.print(e);
			return;
		}	
		%>
		<!-- 프로필, 로그아웃 div 띄우기 -->
		
	</header>


	<script type="text/javascript">
		window.addEventListener("scroll", function(){
			var header= document.querySelector("header");
			header.classList.toggle("sticky", window.scrollY > 0);
		});
	</script>
	
	
	
	<section class="banner">
		<a href="#" class="logo"></a>
	</section>
	
	
	
	<div style="display: grid; grid-template-columns: 2fr 5fr;">
		<div  style="background-color:white;">
			<div style="border-bottom: solid black 3px;">
				<div style="margin:20px 20px 20px 40px; font-weight:bold;">Friend who solved LIST ▸</div>
			</div>
			<div id="friends_code_list" style="overflow-y:scroll;">

	
	<%
	var num = 0;
	try {
		String sql2 = "SELECT * FROM problems WHERE problem_id=? ORDER BY submitDate DESC";
		pstmt = con.prepareStatement(sql2);
		pstmt.setInt(1, problemId);
		rs = pstmt.executeQuery();
		while(rs.next()){
			num++;
	%>
				<div class="friends_code_list_item" <%if(num != 1){%>style="border-top: solid black 2px;"<%} %>>
					<div style="display: grid; margin:15px 20px 15px 40px; grid-template-columns: 1fr 10fr 2fr;">
						<div style="display:table;">
							<div style="vertical-align:middle; display:table-cell; text-alignn:center; font-size:15px;"><%=num %></div>
						</div>
						<div style="display: grid; grid-template-rows: 3fr 2fr;">
							<div id="friend_code_user_id" style="font-size: 18px; cursor: pointer;" 
							     onclick="ajax_fetch(&quot;<%= rs.getString("user_id") %>&quot;, <%= rs.getInt("problem_idx") %>, <%=num %>)"><%= rs.getString("user_id") %>
							</div>
	
							<div style="font-size: 13px;">Submit date: <%=rs.getDate("submitDate") %></div>
						</div>
						<div style="display:table; float:right;">
							<div style="vertical-align:middle; display:table-cell; text-alignn:center; font-size:18px;"><%=rs.getString("language") %></div>
						</div>
					</div>
				</div>
		
	<%
		}

	%>
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
	
	
	
			<!-- 오른쪽 친구 노트 출력 화면 -->
			<!-- 처리 script -->
			<script>
			function ajax_fetch(friend, problemIdx, num) {
				fetch("friend_note_fetch.jsp?friend=" + friend + "&problem_idx=" + problemIdx + "&num=" + num)
			        .then(response => response.text()) // 서버에서 텍스트 응답 받기
			        .then(data => {
			        	let noteElement = document.getElementById("noteContent");
			            noteElement.style = ""; // 모든 스타일 초기화
			            noteElement.innerHTML = data; // 특정 영역 업데이트
			        })
			        .catch(error => console.error("Error:", error));
			}
			</script>
			
			<!-- 나타나는 div -->
			<div id="friend_code" style="overflow-y:scroll;">
				<div id="noteContent" style="text-align:center;">
				<div style="margin-top:40vh;">Click on a list item,<br>and the note will appear here.</div>
				</div>
			</div>
			
	</div>	
	
	

	<footer></footer>

</body>
</html> 