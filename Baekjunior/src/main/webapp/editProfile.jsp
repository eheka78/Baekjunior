<%@ page language="java" contentType="text/html; charset=UTF-8"
	import="java.sql.*, java.util.*, java.io.*, javax.naming.*, Baekjunior.db.*, Baekjunior.multipart.*" session="false"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<script src="https://kit.fontawesome.com/c9057320ee.js" crossorigin="anonymous"></script>
<link rel="stylesheet" type="text/css" href="editProfilest.css?v=3">
</head>
<%
request.setCharacterEncoding("utf-8");
String userId = "none";
HttpSession session = request.getSession(false);
if(session != null && session.getAttribute("login.id") != null) {
	userId = (String) session.getAttribute("login.id");
} else{
	response.sendRedirect("information.jsp");
    return;
}

Connection con = DsCon.getConnection();
PreparedStatement pstmt = null;
ResultSet rs = null;
try {
	if(userId != "none") {
		String sql = "SELECT * FROM users WHERE user_id=?";
		pstmt = con.prepareStatement(sql);
		pstmt.setString(1, userId);
		rs = pstmt.executeQuery();
		rs.next();
	}
%>

<script type="text/javascript">
    function confirmDeletion(userId) {
        var result = confirm("정말 탈퇴하시겠습니까?");
        if (result) {
            window.location.href = "ask_real_delete_user.jsp";
        } else {
            return false;
        }
    }
    
    // 이미지 미리보기 함수
    function previewImage(event) {
        var reader = new FileReader();
        reader.onload = function() {
            var output = document.getElementById('profilePreview');
            output.src = reader.result;
        };
        reader.readAsDataURL(event.target.files[0]);
    }
</script>
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
				<li><a href="#"><%=userId %></a></li>
			</ul>
			<div id="myprodiv" onmouseover="opendiv()" onmouseout="closediv()" style="display:none;position:fixed;top: 100px;background: white;padding: 17px;border: 3px solid black;margin-right: 20px;width: 200px;">
				<img src="./upload/<%=rs.getString("savedFileName") %>" alt="profileimg" style="border-radius:70%;width:70px;">
				<a href="MyPage.jsp" style="position:absolute;top:30px;margin-left:20px;text-decoration: none;color: black;"><%=userId %></a>
				<a href="logout_do.jsp" style="border: 1px solid;width: 90px;display:inline-block;text-align: center;height: 30px;position:absolute;top:60px;margin-left:8px;text-decoration: none;color: black;">로그아웃</a>
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
	<div class="contents">
		<div class="menu">
			<div class="menu_box">
				<ul>
					<li><a href="#">내 활동</a></li>
					<li><a href="#">프로필 수정</a></li>
					<li><a href="#">친구 관리</a></li>
				</ul>
			</div>
		</div>
		<div class="inner_contents">
			<div class="myinfo">
				<form action="editProfile_do.jsp" method="POST" enctype="multipart/form-data">
				<div class="info_box">
					<input type="hidden" name="user_id" value="<%=userId%>">
					<div style="border-radius: 70%;width: 150px;height: 150px;overflow: hidden;">
						<img id="profilePreview" src="./upload/<%=rs.getString("savedFileName") %>" class="profileimg" alt="profileimg" style="width: 100%;height: 100%;object-fit: cover;">
					</div>
					<input type="file" accept="image/jpg,image/gif" name="fileName" class="imgUpload" id="imgUpload" onchange="previewImage(event)">
					<button onclick="onClickUpload();" style="margin-top:10px;">프로필 사진 업로드</button>
					<h1><%=rs.getString("user_id") %></h1>
					<textarea name="intro"><%=Util.nullChk(rs.getString("intro"), "") %></textarea>
					<input type="submit">
				</div>
				</form>
				<script>
					function onClickUpload() {
						let myupload = document.getElementById("imgUpload");
						myupload.click();
						event.preventDefault();
					}
				</script>
			</div>
			<div>
				<table>
					<tr>
						<td><a href="">비밀번호 변경 ></a></td>
					</tr>
					<tr>
						<td><a href="">이메일 변경 ></a></td>
					</tr>
					<tr>
						<td><a href="logout_do.jsp">로그아웃 ></a></td>
					</tr>
					<tr>
						<td><a href="#" onclick="confirmDeletion('<%=userId %>')">회원 탈퇴 ></a></td>
					</tr>
				</table>
			</div>
		</div>
	</div>
</body>
</html>
<%
	con.close();
	pstmt.close();
	rs.close();
} catch (SQLException e){
	out.print(e);
	return;
}
%>