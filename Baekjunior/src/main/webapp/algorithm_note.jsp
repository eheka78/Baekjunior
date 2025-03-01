<%@ page language="java" contentType="text/html; charset=UTF-8"
	import="java.sql.*, javax.naming.*, Baekjunior.db.*" session="false"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>algorithm_note</title>
<link rel="stylesheet" href="Baekjunior_css.css">

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


// 고정 여부 업데이트하는 함수
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
}else{
	response.sendRedirect("information.jsp");
    return;
}

String algorithmSort = request.getParameter("algorithm_sort");

Connection con = DsCon.getConnection();
PreparedStatement pstmt = null;
ResultSet rs = null;
PreparedStatement problemPstmt = null;
ResultSet problemRs = null;
PreparedStatement memoPstmt = null;
ResultSet memoRs = null;

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

<body>
	<header>
		<a href="index.jsp" class="logo">Baekjunior</a>
				
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
		<a href="#" class="logo"></a>
	</section>

	<div style="display: grid; grid-template-columns: 1fr 1fr;">
		<div style="margin-top: 20px;">
			<div style="width: 80%; margin: 0 auto;margin-right:50px;">
				<div class="algorithm_name" style="display: flex;align-items: center;">
					<img src="img/dot1.png" style="width: 20px;height:20px;">
					<h1 style="display: inline;font-size: 40px;margin-left: 15px;cursor: pointer;" onclick="history.back()"><%=algorithmSort %></h1>
				</div>
				<div class="memo" style="margin-top:20px;">
					<div class="memo_box" contenteditable="true" id="editablememo" style="min-height:600px;padding:60px;background:white;border-radius:10px;border:3px solid black;">
						<%
							String memoSql = "SELECT * FROM algorithm_memo WHERE user_id=? AND algorithm_name=?";
		                  	
		                  	memoPstmt = con.prepareStatement(memoSql);
		                  	memoPstmt.setString(1, userId);
		                  	memoPstmt.setString(2, algorithmSort);
		                  	
		                  	memoRs = memoPstmt.executeQuery();
		                  	if(memoRs.next()) {
						%>
						<%=Util.nullChk(memoRs.getString("algorithm_memo"), "")%>
                 		<% } %>
					</div>
					<!-- editablememo 내용 수정할때마다 받아오기 -->
					<script>
						const editablememo = document.getElementById('editablememo');
						
						// 텍스트가 수정될 때마다 발생하는 이벤트 리스너 추가
						editablememo.addEventListener('input', function() {
							//변경된 텍스트 받아오기
							const editedtext = this.innerText;
							console.log('변경된 텍스트: ', editedtext);
						})
						editablememo.addEventListener('focusout', function() {
					    	console.log('포커스를 잃었습니다.');
					    	// 사용자가 메모box를 벗어나면 db에 저장
					    	
					    	 const xhr = new XMLHttpRequest();
			                 const userId = '<%= userId %>'; // 세션에서 가져온 사용자 ID
			                 const algorithmSort = '<%= algorithmSort %>'; // 문제의 알고리즘 분류
			                 const editedtext = editablememo.innerText	; // 현재 수정된 텍스트
			
			                 xhr.open("POST", "algorithm_note_modify.jsp", true);
			                 xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
			                 xhr.onreadystatechange = function () {
			                     if (xhr.readyState === 4 && xhr.status === 200) {
			                         console.log("Response from server: ", xhr.responseText);
			                      }
			                 };
			
			                 // 파라미터로 userId, algorithmSort, 수정된 메모를 전송
			                 xhr.send("user_id=" + encodeURIComponent(userId) + "&algorithm_name=" + encodeURIComponent(algorithmSort) + "&algorithm_memo=" + encodeURIComponent(editedtext));
			                 });
						
					</script>
				</div>
			</div>
		</div>		
		<div style="float: right;margin-top:70px;">
			<div id="list_group" style="padding-left:0px;">
				<ul class="list">
					<% 
					try {
						String problemQuery = "SELECT * FROM problems p JOIN algorithm_sort a ON p.problem_idx=a.problem_idx " 
											+ "WHERE a.user_id=? AND a.sort=? ORDER BY is_fixed DESC";
						problemPstmt = con.prepareStatement(problemQuery);
						problemPstmt.setString(1, userId);
						problemPstmt.setString(2, algorithmSort);
						
						problemRs = problemPstmt.executeQuery();
						if(problemRs.next()) {
							problemRs.beforeFirst();
							while(problemRs.next()) {
		 		%>
					<li class="item">
		 				<div class="content_number"><a href="note.jsp?problem_idx=<%=problemRs.getInt("problem_idx")%>"># <%=problemRs.getInt("problem_id") %></a></div>
		 				<div class="content_set">
		 				<!-- 고정 핀 아이콘 출력 여부 -->
		 				<% if(problemRs.getInt("is_fixed") == 1) { %>
			    			<img class="content_set_a" id="content_set_a_<%= problemRs.getInt("problem_idx") %>" src="img/pin.png">
			    		<% } else { %>
			    			<img class="content_set_a" id="content_set_a_<%= problemRs.getInt("problem_idx") %>" src="img/pin.png" style="display:none">
			    		<% } %>
			    		<button class="content_set_b" style="cursor:pointer;"><img src="img/....png"></button>
				    		<ul>
				    			<li><a onclick="updatePin('<%=problemRs.getInt("problem_idx") %>')" style="display: block; cursor:pointer;">Unpin / Pin to top</a></li>
				    			<li><a href="split_screen.jsp?problem_idx1=<%=problemRs.getInt("problem_idx")%>&problem_idx2=-1" style="display: block; cursor:pointer;">Split screen</a></li>
				    			<li><a onclick="confirmDeletion('<%=problemRs.getInt("problem_idx") %>')" href="#" style="display: block; cursor:pointer;">Delete</a></li>
				    		</ul>
			    		</div>
		 				<div class="content_title area ellipsis"><a href="note.jsp?problem_idx=<%=problemRs.getInt("problem_idx")%>"><%=problemRs.getString("memo_title") %></a></div>
		 			</li>
				<%
							}
						}
				%>
				</ul>
			</div>
		</div>
	</div>

<%
					con.close();
					problemPstmt.close();
					problemRs.close();
					memoPstmt.close();
					memoRs.close();
					} catch(SQLException e){
						out.print(e);
						return;
					}
%>


	<br>
	<br>
	<br>
	<br>

	<footer></footer>

</body>
</html>
