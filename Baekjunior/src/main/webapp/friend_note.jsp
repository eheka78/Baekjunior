<%@ page language="java" contentType="text/html; charset=UTF-8"
	import="java.sql.*, javax.naming.*, Baekjunior.db.*" session="false"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>friend_note</title>
<link rel="stylesheet" href="Baekjunior_css.css">
<script src="https://kit.fontawesome.com/c9057320ee.js" crossorigin="anonymous"></script>

<script>
function updateWindowHeight() {
    let friends_code_list_div = document.getElementById("friends_code_list");
    let friend_code_div = document.getElementById("friend_code");
    friends_code_list_div.style.height = (window.innerHeight - 160) + "px";
    friend_code_div.style.height = (window.innerHeight - 87) + "px";
    
    console.log("현재 window.innerHeight 값:", window.innerHeight);
}

// 페이지 로드 시 실행
window.addEventListener("DOMContentLoaded", updateWindowHeight);
// 창 크기가 변경될 때 실행
window.addEventListener("resize", updateWindowHeight);



/* profile top 위치 */
function updateProfileSelectTopLoc() {
	let profile_div = document.getElementById("profile");
	let myprodiv_div = document.getElementById("myprodiv");
	

	let profile_div_bottom = profile_div.getBoundingClientRect().bottom;
	 myprodiv_div.style.top = profile_div_bottom + "px";
	console.log("top2: " + profile_div_bottom);
	
}

function confirmLogout() {
	var result = confirm("정말 로그아웃 하시겠습니까?");
	if (result) {
	   		window.location.href = "logout_do.jsp";
		} else {
    		return false;
		}
}

window.addEventListener("DOMContentLoaded", updateProfileSelectTopLoc);
window.addEventListener("resize", updateProfileSelectTopLoc);
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
} else {
	response.sendRedirect("information.jsp");
    return;
}
int problemId = Integer.parseInt(request.getParameter("problem_id"));

Connection con = DsCon.getConnection();
PreparedStatement pstmt = null;
ResultSet rs = null;
%>



<body>	
	<header style="padding:5px 100px;">
		<a href="index.jsp" class="logo">Baekjunior</a>
		<%
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
		<div id="profile">
			<ul onmouseover="opendiv()" onmouseout="closediv()" style="height:70px;">
				<li><img src=<%=profileimg %> id="myprofileimg" alt="profileimg" style="width:40px;height:40px;"></li>
				<li><a href="MyPage.jsp"><%=userId %></a></li>
			</ul>
			<div id="myprodiv" onmouseover="opendiv()" onmouseout="closediv()" style="display:none;position:fixed;top: 100px;background: white;padding: 17px;border: 3px solid black;margin-right: 20px;width: 200px;">
				<div id="myprofileimgborder">
					<img id="myprofileimg" src=<%=profileimg %> alt="profileimg">
				</div>
				<a href="MyPage.jsp" style="position:absolute;top:30px;margin-left:90px;text-decoration: none;color: black;"><%=userId %></a>
				<a href="#" onclick="confirmLogout()" style="border: 1px solid;width: 90px;display:inline-block;text-align: center;height: 30px;position:absolute;top:60px;margin-left:78px;text-decoration: none;color: black;">로그아웃</a>
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
	
	
	<section class="banner" style="padding:43px;">
		<a href="#" class="logo"></a>
	</section>
	
	
	
	<div style="display: grid; grid-template-columns: 2fr 5fr;">
		<div  style="background-color:white;">
			<div style="border-bottom:solid black 3px;">
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
				<div class="friends_code_list_item" style="<%if(num != 1){ %>border-top: solid black 2px;<%} %> width:95%; margin:0 auto; border-color:gray">
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
		con.close();
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
			        .then(response => response.text())
			        .then(data => {
			            let noteElement = document.getElementById("noteContent");
			            noteElement.style = ""; 
			            noteElement.innerHTML = data;

			            let scripts = noteElement.getElementsByTagName("script");

			            for (let script of scripts) {
			                eval(script.innerText); // 직접 실행
			            }
			        })
			        .catch(error => console.error("Error:", error));
			}

			</script>
			
			<!-- 나타나는 div -->
			<div id="friend_code" style="overflow-y:scroll;">
				<div id="noteContent" style="text-align:center;">
				<div id="noteContent_empty" style="margin-top:40vh; display:block;">Click on a list item,<br>and the note will appear here.</div>
				</div>
			</div>
			
	</div>	
	
	

	<footer></footer>

</body>
</html> 