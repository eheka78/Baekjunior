<%@ page language="java" contentType="text/html; charset=UTF-8"
	import="java.sql.*, javax.naming.*, Baekjunior.db.*" session="false"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>MyPage</title>
<script src="https://kit.fontawesome.com/c9057320ee.js" crossorigin="anonymous"></script>
<link rel="stylesheet" type="text/css" href="MyPagest.css?v=1.2">
<link rel="stylesheet" type="text/css" href="editProfilest.css?v=1.2">


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
String profileimg = null;
String realemail = null;
String showemail = null;
String pw = null;
int emailVerifyStatus = 0;
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
		
		realemail = rs.getString("email");
		showemail = realemail.substring(0,2) + "******@" + realemail.split("@")[1].substring(0,1) + "******"; 
		pw = rs.getString("password");
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
		con.close();
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
		<% 
			ProblemInfoDB pidb = new ProblemInfoDB(); 
			int noteCount = pidb.countProblem(userId);
			int bookmarkCount = pidb.countBookmark(userId);
			pidb.close();
			
			AlgorithmMemoDB amdb = new AlgorithmMemoDB();
			int cateCount = amdb.countAlgorithmMemo(userId);
			amdb.close();
		%>
		<div class="inner_contents">
			<div class="select_div">
				<Button class="note_div" onclick="location.href='gather_note.jsp'">
					<div>
						<h3>NOTE</h3>
						<p><%=noteCount %></p>
						<i class="fa-solid fa-note-sticky fa-lg"></i>
					</div>
				</Button>
				<Button class="draft_div" onclick="location.href='gather_category.jsp'">
					<div>
						<h3>CATEGORY</h3>
						<p><%=cateCount %></p>
						<i class="fa-solid fa-box-open fa-lg"></i>
					</div>
				</Button>
				<Button class="bookmark_div" onclick="location.href='index.jsp?type=bookmark'">
					<div>
						<h3>BOOKMARK</h3>
						<p><%=bookmarkCount %></p>
						<i class="fa-solid fa-bookmark fa-lg"></i>
					</div>
				</Button>
			</div>
			<div class="myinfo">
				<form action="editProfile_do.jsp" method="POST" enctype="multipart/form-data">
				<div class="info_box">
					<input type="hidden" name="user_id" value="<%=userId%>">
					<div style="border-radius: 70%;width: 150px;height: 150px;overflow: hidden;">
						<img id="profilePreview" src=<%=profileimg %> class="profileimg" alt="profileimg" style="width: 100%;height: 100%;object-fit: cover;">
					</div>
					<input type="file" accept="image/jpg,image/gif" name="fileName" class="imgUpload" id="imgUpload" onchange="previewImage(event)">
					<button onclick="onClickUpload();" style="margin-top:10px;">프로필 사진 업로드</button>
					<button onclick="onClickDelete('<%=userId%>');" style="margin-top:10px;">현재 사진 삭제</button>
					<h1><%=rs.getString("user_id") %></h1>
					<textarea name="intro"><%=Util.nullChk(rs.getString("intro"), "") %></textarea>
					<input type="submit" value="저장">
				</div>
				</form>
				<script>
					function onClickUpload() {
						let myupload = document.getElementById("imgUpload");
						myupload.click();
						event.preventDefault();
					}
					function onClickDelete(id) {
						if (!confirm("프로필 이미지를 삭제하시겠습니까?")) {
					        return;
					    }
						fetch("deleteProfileImage.jsp?id="+id)
							.then(response => response.text())
							.then(result => {
								alert(result);
								location.reload(); // 페이지 새로고침하여 변경 반영
							})
							.catch(error => console.error("삭제 오류:", error));
					}
				</script>
			</div>
			<div style="margin:100px;">
				<table>
					<tr>
						<td>
							<i class="fa-solid fa-lock"></i>&nbsp;&nbsp;비밀번호
							<button onclick="openModal('oldPasswordModal')" style="width:80px;margin-left:650px;">변경</button>
							</td>
					</tr>
					<tr>
						<td>
							<i class="fa-solid fa-envelope"></i>&nbsp;&nbsp;<%=showemail %>
							<button onclick="openModal('emailModal')" style="width:80px;margin-left:578px;">변경</button>
						</td>
					</tr>
					<tr>
						<td><a href="#" onclick="confirmLogout()">로그아웃 ></a></td>
					</tr>
					<tr>
						<td><a href="#" onclick="confirmDeletion('<%=userId %>')">회원 탈퇴 ></a></td>
					</tr>
				</table>
			</div>
			
			<!-- 비밀번호 변경창 -->
			<div id="oldPasswordModal" class="modal">
				<div class="modal-content">
					<span class="close" onclick="closeModal('oldPasswordModal')">&times;</span>
					<h2>비밀번호 변경</h2>
					<label for="oldPassword">현재 비밀번호를 입력해주세요.</label>
					<br>
					<input type="password" id="oldPassword">
					<button onclick="checkOldPw()">확인</button>
				</div>
			</div>
			<div id="newPasswordModal" class="modal">
				<div class="modal-content">
					<span class="close" onclick="closeModal('newPasswordModal')">&times;</span>
					<h2>비밀번호 변경</h2>
					<label for="newPassword">새 비밀번호를 입력해주세요.</label>
					<br>
					<input type="password" id="newPassword">
					<br>
					<label for="checknewPassword">새 비밀번호 확인</label>
					<br>
					<input type="password" id="checknewPassword">
					<button onclick="checkNewPw()">변경</button>
				</div>
			</div>
			
			<!-- 이메일 변경창 -->
			<div id="emailModal" class="modal">
				<div class="modal-content">
					<span class="close" onclick="closeModal('emailModal')">&times;</span>
					<h2>이메일 변경</h2>
					<label for="oldEmail">기존 이메일을 입력해주세요.</label>
					<br>
					<input type="email" id="oldEmail">
					<button onclick="checkOldEmail()">확인</button>
					
					<label for="newEmail">새 이메일을 입력해주세요.</label>
					<br>
					<input type="email" id="newEmail">
					<button onclick="changeEmail()">변경</button>
				</div>
			</div>
		</div>
	</div>
<script>
	function closeModal(divid){
		document.getElementById(divid).style.display = "none";
	}
	function openModal(divid) {
		document.getElementById(divid).style.display = "block";
	}
	function checkOldPw() {
		let oldPw = document.getElementById("oldPassword").value;
		if(oldPw == ""){
			alert("비밀번호를 입력해주세요.");
			document.getElementById("oldPassword").focus();
			return;
		}
		else if(oldPw == "<%=pw%>"){
			document.getElementById("oldPasswordModal").style.display = "none";
			document.getElementById("newPasswordModal").style.display = "block";
		}
		else {
			alert("비밀번호가 일치하지 않습니다. 다시 입력해주세요.");
			document.getElementById("oldPassword").value="";
			document.getElementById("oldPassword").focus();
			return;
		}
		
	}
	function checkNewPw() {
		let userId = "<%= userId %>";
		let newPw = document.getElementById("newPassword").value;
		let check = document.getElementById("checknewPassword").value;
		
		if(newPw == ""){
			alert("새 비밀번호를 입력해주세요.");
			document.getElementById("newPassword").focus();
			return;
		}
		else if(check == ""){
			alert("비밀번호 확인을 입력해주세요.");
			document.getElementById("checknewPassword").focus();
			return;
		}
		else if(newPw == check) {
			fetch("changePW.jsp?id="+userId+"&newPw="+newPw)
				.then(response=>response.text())
				.then(result => {
					alert(result);
					window.location.href = "logout_do.jsp";
				})
				.catch(error => console.error("비밀번호 변경 오류:", error));
		}
		else {
			alert("비밀번호가 일치하지 않습니다. 다시 입력해주세요.");
			document.getElementById("newPassword").value="";
			document.getElementById("checknewPassword").value="";
			document.getElementById("newPassword").focus();
		}
	}
	function checkOldEmail() {
		let oldEmail = document.getElementById("oldEmail").value;
		if(oldEmail == ""){
			alert("기존 이메일을 입력해주세요.");
			document.getElementById("oldEmail").focus();
			return;
		}
		else if (oldEmail == "<%=realemail%>"){
			alert("확인되었습니다.");
			emailVerifyStatus = 1;
			document.getElementById("newEmail").focus();
			return;
		}
		else {
			alert("기존 이메일과 일치하지 않습니다. 다시 입력해주세요.");
			document.getElementById("oldEmail").value="";
			document.getElementById("oldEmail").focus();
		}
		
	}
	function changeEmail() {
		let userId = "<%= userId %>";
		let newEmail = document.getElementById("newEmail").value;
		if(newEmail == ""){
			alert("새 이메일을 입력해주세요.");
			document.getElementById("newEmail").focus();
			return;
		}
		else if (newEmail == document.getElementById("oldEmail").value){
			alert("기존 이메일과 동일합니다. 다른 이메일을 입력해주세요.");
			document.getElementById("newEmail").value="";
			document.getElementById("newEmail").focus();
			return;
		}
		else {
			if(<%= emailVerifyStatus%> == 0){
				alert("기존 이메일 확인 후 변경가능합니다.");
				document.getElementById("oldEmail").focus();
				return;
			}
			fetch("changeEmail.jsp?id="+userId+"&newEmail="+newEmail)
			.then(response=>response.text())
			.then(result => {
				alert(result);
				location.reload();
			})
			.catch(error => console.error("이메일 변경 오류:", error));
		}
	}
</script>
	
</body>
</html>